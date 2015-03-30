//
//  MapInformationViewController.m
//  Are You Open
//
//  Created by Yun Jang on 7/13/14.
//  Copyright (c) 2014 Yun Jang. All rights reserved.
//

#import "MapInformationViewController.h"
#import <GoogleMaps/GoogleMaps.h>

@interface MapInformationViewController () <GMSMapViewDelegate>

@property NSDictionary *storeDictionary;

@property (weak, nonatomic) IBOutlet UILabel *navTitle;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *storeName;
@property (weak, nonatomic) IBOutlet UILabel *storeAddress;
@property (weak, nonatomic) IBOutlet UILabel *storePhoneNumber;
@property (weak, nonatomic) IBOutlet UILabel *storeSite;
@property (weak, nonatomic) IBOutlet UIView *openIndicator;
@property (weak, nonatomic) IBOutlet UILabel *storeOpenHours;
@property (weak, nonatomic) IBOutlet UIView *openHoursView;
@property (weak, nonatomic) IBOutlet UIView *googleMapsView;
@property (weak, nonatomic) IBOutlet UILabel *noOpenHoursLabel;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *hoursLabelCollection;


@end

@implementation MapInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
//        NSLog(@"dictionary: %@", dictionary);
//        for (id key in dictionary)
//            NSLog(@"%@: %@", key, [dictionary objectForKey:key]);
        
        self.storeDictionary = dictionary;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.openIndicator.layer setCornerRadius:self.openIndicator.frame.size.width / 2];
    [self.openIndicator setBackgroundColor:[UIColor greenColor]];
    [self.openHoursView.layer setCornerRadius:5.0];
    [self.openHoursView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.openHoursView.layer setBorderWidth:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set the labels.
    [self.navTitle setText:[self.storeDictionary objectForKey:@"name"]];
    [self.navTitle setAdjustsFontSizeToFitWidth:YES];
    [self.storeName setText:[self.storeDictionary objectForKey:@"name"]];
    [self.storeAddress setText:[self.storeDictionary objectForKey:@"vicinity"]];
    [self.storePhoneNumber setText:[self.storeDictionary objectForKey:@"formatted_phone_number"]];
    [self.storeSite setText:[self.storeDictionary objectForKey:@"website"]];
    
    // If the hours are available, display them and display an indication of whether the store is open or not.
    if ([self.storeDictionary objectForKey:@"opening_hours"])
    {
        NSArray *hoursArr = [[self.storeDictionary objectForKey:@"opening_hours"] objectForKey:@"weekday_text"];
        for (int i = 0; i < [self.hoursLabelCollection count]; ++i)
        {
            UILabel *hoursLabel = [self.hoursLabelCollection objectAtIndex:i];
            NSArray *splitStr = [[hoursArr objectAtIndex:i] componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSString *hoursStr = @"";
            for (int j = 1; j < [splitStr count]; ++j)
                hoursStr = [[hoursStr stringByAppendingString:[splitStr objectAtIndex:j]] stringByAppendingString:@" "];
            [hoursLabel setText:hoursStr];
        }
    }
    else
    {
        [self.noOpenHoursLabel setAlpha:1];
    }
    
    // Grab the coordinates.
    NSDictionary *coordinates = [[self.storeDictionary objectForKey:@"geometry"] objectForKey:@"location"];
    NSString *latitude = [coordinates objectForKey:@"lat"];
    NSString *longitude = [coordinates objectForKey:@"lng"];
    
    // Initialize Google Maps based on search done on Google.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[latitude floatValue] longitude:[longitude floatValue] zoom:16];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.googleMapsView.frame.size.width, self.googleMapsView.frame.size.height) camera:camera];
    [mapView setMyLocationEnabled:YES];
    [mapView setDelegate:self];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.map = mapView;
    
    [self.googleMapsView addSubview:mapView];
}

- (IBAction)backButtonTouchUpInside:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
