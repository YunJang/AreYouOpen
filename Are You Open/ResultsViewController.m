//
//  ResultsViewController.m
//  Are You Open
//
//  Created by Yun Jang on 3/19/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import "ResultsViewController.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "MapInformationViewController.h"
#import "ResultsTableViewCell.h"
#import <iAd/iAd.h>

@interface ResultsViewController () <ADBannerViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *placesArr;
@property (strong, nonatomic) IBOutlet ADBannerView *adBanner;
@end

@implementation ResultsViewController

- (NSMutableArray *)placesArr
{
    if (!_placesArr)
        _placesArr = [[NSMutableArray alloc] init];
    return _placesArr;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchTitle = [self.searchTitle stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    [self.searchLabel setText:[self.searchTitle isEqualToString:@""] ? @"Anything Nearby!" : [[@"\"" stringByAppendingString:self.searchTitle] stringByAppendingString:@"\""]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CustomResultsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultsTableViewCell" bundle:nil] forCellReuseIdentifier:@"CustomResultsCell"];
    [self initAdBanner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self getResultsJSONData:self.urlData];
    });
}

#pragma mark Setup
- (void)getResultsJSONData:(NSURL *)url
{
    // Once Nearby JSON is obtained, get the Details JSON.
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        // Add the name, place_id, and vicinity into a dictionary and add it into an array.
        NSArray *nearbyResults = [responseObject objectForKey:@"results"];
        [self storeNearbyInformation:nearbyResults];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"SearchViewController: %@", [error localizedDescription]);
    }];
    
    [operation start];
}

- (void)storeNearbyInformation:(NSArray *)nearbyResults
{
    for (int i = 0; i < [nearbyResults count]; ++i)
    {
        NSDictionary *placeDic = [nearbyResults objectAtIndex:i];
        NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
        [tempDic setObject:[placeDic objectForKey:@"name"] forKey:@"name"];
        [tempDic setObject:[placeDic objectForKey:@"place_id"] forKey:@"place_id"];
        [tempDic setObject:[placeDic objectForKey:@"vicinity"] forKey:@"vicinity"];
        [tempDic setObject:[placeDic valueForKeyPath:@"geometry.location"] forKey:@"location"];
        if ([placeDic valueForKeyPath:@"opening_hours.open_now"])   [tempDic setObject:[placeDic valueForKeyPath:@"opening_hours.open_now"] forKey:@"open_now"];
        else                                                        [tempDic setObject:@"nil_info" forKey:@"open_now"];
        [self.placesArr addObject:tempDic];
    }
    
    [self.tableView reloadData];
}

- (IBAction)backButtonTouchUpInside:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.placesArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ResultsTableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"CustomResultsCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *placesDic = [self.placesArr objectAtIndex:indexPath.row];
    [cell setStoreNameText:[placesDic objectForKey:@"name"]];
    [cell setAddressText:[placesDic objectForKey:@"vicinity"]];
    [cell setOpenStatus:[placesDic objectForKey:@"open_now"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setUserInteractionEnabled:NO];
    NSURL *detailsURL = [NSURL URLWithString:[[GooglePlacesDetailsJSONURL
                                               stringByAppendingString:[[self.placesArr objectAtIndex:indexPath.row] objectForKey:@"place_id"]]
                                              stringByAppendingString:GooglePlacesAPIKey]];
    
    NSURLRequest *detailsRequest = [NSURLRequest requestWithURL:detailsURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:detailsRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [tableView setUserInteractionEnabled:YES];
        NSMutableDictionary *detailsResults = [[responseObject objectForKey:@"result"] mutableCopy];
        [self.navigationController pushViewController:[[MapInformationViewController alloc] initWithDictionary:detailsResults] animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [tableView setUserInteractionEnabled:YES];
        NSLog(@"ResultsViewController: %@", [error localizedDescription]);
    }];
    [operation start];
}

- (CGFloat) tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Makes Xcode not throw out a warning about the custom table view cell.
    return 44.0;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

#pragma mark adBanner

- (void)initAdBanner
{
    [self.adBanner setDelegate:self];
    [self.adBanner setAlpha:0.0];
}

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 1.0;
    }];
}


- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [UIView animateWithDuration:0.5 animations:^{
        self.adBanner.alpha = 0.0;
    }];
}

@end
