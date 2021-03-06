//
//  MapInformationViewController.m
//  Are You Open
//
//  Created by Yun Jang on 7/13/14.
//  Copyright (c) 2014 Yun Jang. All rights reserved.
//

#import "MapInformationViewController.h"
#import "LocationManagerSingleton.h"
#import <GoogleMaps/GoogleMaps.h>
#import <iAd/iAd.h>

@interface MapInformationViewController () <GMSMapViewDelegate, ADBannerViewDelegate>

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
@property (strong, nonatomic) IBOutlet ADBannerView *adBanner;
@end

@implementation MapInformationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
        _storeDictionary = dictionary;
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setIndicatorStatus];
    
    [self.openHoursView.layer setCornerRadius:5.0];
    [self.openHoursView.layer setBorderColor:[UIColor lightGrayColor].CGColor];
    [self.openHoursView.layer setBorderWidth:1.0];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /* COMMENT IN TO ENABLE ADDS ON THIS VIEW */
//    [self initAdBanner];
    
    self.numAlert = [self loadNumberAlertController:[self.storeDictionary objectForKey:@"formatted_phone_number"]];
    self.addressAlert = [self loadAddressAlertController:[self.storeDictionary objectForKey:@"vicinity"]];
    
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
    [mapView.settings setMyLocationButton:YES];

    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.map = mapView;
    
    [self.googleMapsView addSubview:mapView];
}

#pragma mark UIButton

- (IBAction)backButtonTouchUpInside:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)homeButtonTouchUpInside:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)mapButtonTouchUpInside:(id)sender
{
    NSDictionary *locationDict = [self.storeDictionary valueForKeyPath:@"geometry.location"];
    NSString *lat = [locationDict objectForKey:@"lat"];
    NSString *lng = [locationDict objectForKey:@"lng"];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([lat doubleValue], [lng doubleValue]);
    MKPlacemark *placeMark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placeMark];
    [mapItem setName:[self.storeDictionary objectForKey:@"name"]];

    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
    [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem] launchOptions:launchOptions];
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
- (UIAlertController *)loadAddressAlertController:(NSString *)string
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

- (UIAlertController *)loadNumberAlertController:(NSString *)string
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:nil message:string preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *copyAction = [UIAlertAction actionWithTitle:@"Call" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // get rid of space
        NSString *phoneNumber = [NSString stringWithFormat:@"%@", [self.storePhoneNumber.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
        // make phone number url
        phoneNumber = [NSString stringWithFormat:@"tel://%@", phoneNumber];
        NSLog(@"%@", phoneNumber);
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:phoneNumber]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
        }
        else {
            NSLog(@"Error: can't open phone app with URL");
        }
    }];
    [ac addAction:cancelAction];
    [ac addAction:copyAction];
    return ac;
}

# pragma mark ButtonUIStyle

- (void) setBlueButtonRoundedRectangleStyle:(UIButton *)button
{
    [button.layer setCornerRadius:4.0];
    [button.layer setBorderColor:[UIColor colorWithRed:79.0/255.0 green:167.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor];
    [button.layer setBorderWidth:1.0];
    [button setBackgroundColor:[UIColor whiteColor]];
}


#pragma mark adBanner
/*
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
*/




@end
