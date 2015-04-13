//
//  CloseToMeViewController.m
//  Are You Open
//
//  Created by Ashley Ng on 3/30/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import "CloseToMeViewController.h"
#import "Constants.h"
#import "AFNetworking.h"
#import "MapInformationViewController.h"


@interface CloseToMeViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) NSArray *places;
@property (weak, nonatomic) IBOutlet UIView *googleMapsView;
@property CLLocation *currentLocation;

@end

@implementation CloseToMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize Google Maps based on search done on Google.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:14];
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
        marker.title = [NSString stringWithFormat:@"%@", [place valueForKeyPath:@"name"]];
        marker.userData = [place valueForKey:@"place_id"];
        // green if currenlty open, red otherwise
        // TODO: handle nil_info
        if ([place valueForKey:@"open_now"]) {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        }
        else {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        }
        marker.map = mapView;
    }
    [self.googleMapsView addSubview:mapView];
}

- (void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    NSURL *detailsURL = [NSURL URLWithString:[[GooglePlacesDetailsJSONURL
                                               stringByAppendingString: [marker userData]]
                                              stringByAppendingString:GooglePlacesAPIKey]];
    
    NSURLRequest *detailsRequest = [NSURLRequest requestWithURL:detailsURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:detailsRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary *detailsResults = [[responseObject objectForKey:@"result"] mutableCopy];
        [self.navigationController pushViewController:[[MapInformationViewController alloc] initWithDictionary:detailsResults] animated:YES];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"CloseToMeViewController: %@", [error localizedDescription]);
    }];
    [operation start];

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
