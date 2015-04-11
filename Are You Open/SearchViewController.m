//
//  SearchViewController.m
//  Are You Open
//
//  Created by Yun Jang on 7/12/14.
//  Copyright (c) 2014 Yun Jang. All rights reserved.
//

#import "LocationManagerSingleton.h"
#import "SearchViewController.h"
#import "Constants.h"
#import "ResultsViewController.h"
#import "MapInformationViewController.h"
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>
#import "CloseToMeViewController.h"

@interface SearchViewController () <UITextFieldDelegate, CLLocationManagerDelegate>

@property CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *searchNearbyButton;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setBlueButtonRoundedRectangleStyle:self.searchButton];
    [self setBlueButtonRoundedRectangleStyle:self.searchNearbyButton];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar setDelegate:self];
    
    // Get your current location.
    [[LocationManagerSingleton singleton] addObserver:self forKeyPath:@"currentLocation" options:NSKeyValueObservingOptionNew context:nil];
    [[LocationManagerSingleton singleton] startUpdatingLocation];
}

#pragma mark Logic

- (NSString *) parsedString
{
    NSArray *arr = [self.searchBar.text componentsSeparatedByString:@" "];
    NSString *locationString = @"";
    for (int i = 0; i < [arr count]; i++) {
        if (i == [arr count] - 1)
            locationString = [locationString stringByAppendingString:[arr objectAtIndex:i]];
        else
            locationString = [[locationString stringByAppendingString:[arr objectAtIndex:i]] stringByAppendingString:@"%20"]; // I need to test this out some more.
    }
    return locationString;
}

#pragma mark UIButton

- (IBAction)searchButtonTouchUpInside:(id)sender
{
    // Generate the URL to fetch the JSON.
    NSURL *jsonURL = [NSURL URLWithString:[[[[GooglePlacesNearbyJSONURL
                        stringByAppendingString:[NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude]]
                        stringByAppendingString:GooglePlacesDistance]
                        stringByAppendingString:[self parsedString]]
                        stringByAppendingString:GooglePlacesAPIKey]];
    
    // Once Nearby JSON is obtained, get the Details JSON.
    NSURLRequest *request = [NSURLRequest requestWithURL:jsonURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        
        // Work here.
        // Do error checking to make sure query is valid.
        // Check the results and get the specific data into a dictionary to send to next view controller.
        // Data needed: name, place_id, address.
        NSArray *nearbyResults = [responseObject objectForKey:@"results"];
        
        // Add the name, place_id, and vicinity into a dictionary and add it into an array.
        NSMutableArray *placesArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [nearbyResults count]; ++i)
        {
            NSDictionary *placeDic = [nearbyResults objectAtIndex:i];
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            [tempDic setObject:[placeDic objectForKey:@"name"] forKey:@"name"];
            [tempDic setObject:[placeDic objectForKey:@"place_id"] forKey:@"place_id"];
            [tempDic setObject:[placeDic objectForKey:@"vicinity"] forKey:@"vicinity"];
            if ([placeDic objectForKey:@"opening_hours"]) [tempDic setObject:[[placeDic objectForKey:@"opening_hours"] objectForKey:@"open_now"] forKey:@"open_now"];
            else    [tempDic setObject:@"nil_info" forKey:@"open_now"];
            [placesArr addObject:tempDic];
        }
        
        ResultsViewController *vc = [[ResultsViewController alloc] init];
        [vc setPlacesArr:placesArr];
        [vc setSearchTitle:[self parsedString]];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"SearchViewController: %@", [error localizedDescription]);
    }];
    
    [operation start];
}

- (IBAction)searchNearbyButtonTouchUp:(id)sender
{
    // Generate the URL to fetch the JSON.
    NSURL *jsonURL = [NSURL URLWithString:[[[[GooglePlacesNearbyJSONURL
                                              stringByAppendingString:[NSString stringWithFormat:@"%f,%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude]]
                                             stringByAppendingString:GooglePlacesNearby]
                                            stringByAppendingString:[self parsedString]]
                                           stringByAppendingString:GooglePlacesAPIKey]];
    
    // Once Nearby JSON is obtained, get the Details JSON.
    NSURLRequest *request = [NSURLRequest requestWithURL:jsonURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *op, id responseObject) {
        
        // Work here.
        // Do error checking to make sure query is valid.
        // Check the results and get the specific data into a dictionary to send to next view controller.
        // Data needed: name, place_id, address.
        NSArray *nearbyResults = [responseObject objectForKey:@"results"];

        // Add the name, place_id, and vicinity into a dictionary and add it into an array.
        NSMutableArray *placesArr = [[NSMutableArray alloc] init];
        for (int i = 0; i < [nearbyResults count]; ++i)
        {
            NSDictionary *placeDic = [nearbyResults objectAtIndex:i];
            NSMutableDictionary *tempDic = [[NSMutableDictionary alloc] init];
            [tempDic setObject:[placeDic objectForKey:@"name"] forKey:@"name"];
            [tempDic setObject:[placeDic objectForKey:@"place_id"] forKey:@"place_id"];
            [tempDic setObject:[placeDic objectForKey:@"vicinity"] forKey:@"vicinity"];
            [tempDic setObject:[placeDic valueForKeyPath:@"geometry.location"] forKey:@"location"];
            [placesArr addObject:tempDic];
        }
        
        CloseToMeViewController *vc = [[CloseToMeViewController alloc] initWithArray:placesArr currentLocation:self.currentLocation];
        [self.navigationController pushViewController:vc animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"NearbyViewController: %@", [error localizedDescription]);
    }];
    
    [operation start];


}

#pragma mark UITextFieldViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Minimize the search bar when Return is hit.
    [self.searchBar resignFirstResponder];
    
    // Don't process request that is inside of the text field.
    return NO;
}

# pragma mark ButtonUIStyle

- (void) setBlueButtonRoundedRectangleStyle:(UIButton *)button
{
    [button.layer setCornerRadius:4.0];
    [button.layer setBorderColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor];
    [button.layer setBorderWidth:1.0];
}

# pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentLocation"])
    {
        NSLog(@"KVO Triggered - Setting new current location.");
        self.currentLocation = [[LocationManagerSingleton singleton] currentLocation];
    }
}

@end
