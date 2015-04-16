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
@property (weak, nonatomic) IBOutlet UILabel *storeOpenHours;
@property (weak, nonatomic) IBOutlet UIView *openHoursView;
@property (weak, nonatomic) IBOutlet UIView *googleMapsView;
@property (weak, nonatomic) IBOutlet UILabel *noOpenHoursLabel;
@property (weak, nonatomic) IBOutlet UIView *openIndicator;
@property (weak, nonatomic) IBOutlet UIView *openIndicatorAnimate;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *hoursLabelCollection;
@property (weak, nonatomic) IBOutlet UIButton *addressButton;
@property (weak, nonatomic) IBOutlet UIButton *numberButton;
@property (strong, nonatomic) UIAlertController* numAlert;
@property (strong, nonatomic) UIAlertController* addressAlert;
@property (weak, nonatomic) IBOutlet UIView *hoursView;

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
//        NSLog(@"%@", [dictionary objectForKey:@"opening_hours"]);
//        NSLog(@"dictionary: %@", dictionary);
//        for (id key in dictionary)
//            NSLog(@"%@: %@", key, [dictionary objectForKey:key]);
        
        self.storeDictionary = dictionary;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setIndicatorStatus];
    
    // Create a method for setting stuff UI stuff like this.
    [self.openHoursView.layer setCornerRadius:5.0];
    [self.openHoursView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.openHoursView.layer setBorderWidth:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self doAnimation];
    self.numAlert = [self loadAlertController:[self.storeDictionary objectForKey:@"formatted_phone_number"]];
    self.addressAlert = [self loadAlertController:[self.storeDictionary objectForKey:@"vicinity"]];
    
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
        [self.hoursView setAlpha:0];
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

#pragma mark UI Updates

- (void) setIndicatorStatus
{
    [self.openIndicator.layer setCornerRadius:self.openIndicator.frame.size.width / 2];
    [self.openIndicatorAnimate.layer setCornerRadius:self.openIndicatorAnimate.frame.size.width / 2];
    if ([self.storeDictionary objectForKey:@"opening_hours"])
    {
        id open_status = [[self.storeDictionary objectForKey:@"opening_hours"] objectForKey:@"open_now"];
        if (![open_status integerValue])       // red - closed indicator
            [self.openIndicator setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:0.0 blue:0.0 alpha:1.0]];
        else if ([open_status integerValue])              // green - open indicator
            [self.openIndicator setBackgroundColor:[UIColor colorWithRed:38.0/255.0 green:193.0/255.0 blue:98.0/255.0 alpha:1.0]];
        else
            [self.openIndicator setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
    else
    {
        [self.openIndicator setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:204.0/255.0 blue:102.0/255.0 alpha:1.0]];
    }
}

- (void) doAnimation
{
    // Look up Core Animation.
}

# pragma mark UIButton Actions
- (IBAction)addressButtonPressed:(id)sender
{
    [self presentViewController:self.addressAlert animated:YES completion:nil];
}

- (IBAction)numberButtonPressed:(id)sender
{
    [self presentViewController:self.numAlert animated:YES completion:nil];
}

#pragma mark Setup
- (UIAlertController *)loadAlertController:(NSString *)string
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Copy" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setPersistent:YES];
        [pb setString:string];
    }];
    [ac addAction:cancelAction];
    [ac addAction:copyAction];
    return ac;
}

@end
