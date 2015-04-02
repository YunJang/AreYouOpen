//
//  CloseToMeViewController.m
//  Are You Open
//
//  Created by Ashley Ng on 3/30/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import "CloseToMeViewController.h"


@interface CloseToMeViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) NSArray *places;
@property (weak, nonatomic) IBOutlet UIView *googleMapsView;
@property CLLocation *currentLocation;

@end

@implementation CloseToMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize Google Maps based on search done on Google.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:12];
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.googleMapsView.frame.size.width, self.googleMapsView.frame.size.height) camera:camera];
    [mapView setDelegate:self];
    
    // add current location, blue marker
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake(self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    marker.icon = [GMSMarker markerImageWithColor:[UIColor blueColor]];
    marker.map = mapView;
    
    [self addPlacesToMapView:mapView];
}

- (void)addPlacesToMapView: (GMSMapView *)mapView
{
    // add place markers, tap marker to view name
    for (int x = 0; x < [self.places count]; x++) {
        NSDictionary *place = self.places[x];
        CLLocationCoordinate2D position = CLLocationCoordinate2DMake([[place valueForKeyPath:@"location.lat"] floatValue], [[place valueForKeyPath:@"location.lng"] floatValue]);
        GMSMarker *marker = [GMSMarker markerWithPosition:position];
        marker.snippet = [NSString stringWithFormat:@"%@", [place valueForKeyPath:@"name"]];
        marker.map = mapView;
    }
    [self.googleMapsView addSubview:mapView];
}

- (id)initWithArray:(NSArray *)array currentLocation:(CLLocation *)currentLocation
{
    self = [super init];
    if (self) {
        self.places = array;
        self.currentLocation = currentLocation;
    }
    return self;
}

- (IBAction)backButtonTouchUpInside:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
