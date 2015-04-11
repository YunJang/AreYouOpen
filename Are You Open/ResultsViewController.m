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

@interface ResultsViewController ()
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ResultsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchLabel setText:[[@"\"" stringByAppendingString:self.searchTitle] stringByAppendingString:@"\""]];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"CustomResultsCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ResultsTableViewCell" bundle:nil] forCellReuseIdentifier:@"CustomResultsCell"];
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"ResultsCell"];
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

@end
