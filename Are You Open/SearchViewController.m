//
//  SearchViewController.m
//  Are You Open
//
//  Created by Yun Jang on 7/12/14.
//  Copyright (c) 2014 Yun Jang. All rights reserved.
//

#import "SearchViewController.h"
#import "Constants.h"
#import "ResultsViewController.h"
#import "MapInformationViewController.h"
#import "AFNetworking.h"
#import <CoreLocation/CoreLocation.h>

@interface SearchViewController () <UITextFieldDelegate, CLLocationManagerDelegate>

@property NSString *latitude;
@property NSString *longitude;
@property NSString *coordinates;

@property CLLocationManager *lm;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

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
    [self.searchButton.layer setCornerRadius:4.0];
    [self.searchButton.layer setBorderColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor];
    [self.searchButton.layer setBorderWidth:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.searchBar setDelegate:self];
    
    // Get your current location.
    self.lm = [CLLocationManager new];
    [self.lm setDelegate:self];
    self.lm.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    if ([self.lm respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        NSLog(@"Location Authorization Complete.");
        [self.lm requestAlwaysAuthorization];
        [self.lm requestWhenInUseAuthorization];
    }
    [self.lm startUpdatingLocation];
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
            locationString = [[locationString stringByAppendingString:[arr objectAtIndex:i]] stringByAppendingString:@"%20"];
    }
    return locationString;
}

#pragma mark UIButton

- (IBAction)searchButtonTouchUpInside:(id)sender
{
    // Generate the URL to fetch the JSON.
    NSURL *jsonURL = [NSURL URLWithString:[[[[GooglePlacesNearbyJSONURL
                        stringByAppendingString:[NSString stringWithFormat:@"%@,%@", self.latitude, self.longitude]]
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

#pragma mark UITextFieldViewDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // Minimize the search bar when Return is hit.
    [self.searchBar resignFirstResponder];
    
    // Don't process request that is inside of the text field.
    return NO;
}

#pragma mark CLLocationManager

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Grab the latitude/longitude from the location manager.
    self.latitude = [NSString stringWithFormat:@"%f", self.lm.location.coordinate.latitude];
    self.longitude = [NSString stringWithFormat:@"%f", self.lm.location.coordinate.longitude];

    NSLog(@"Location Updating Complete - Lat: %@ | Lng: %@", self.latitude, self.longitude);
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

@end
