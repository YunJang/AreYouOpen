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
#import "SMCalloutView.h"


@interface CloseToMeViewController () <GMSMapViewDelegate>

@property (strong, nonatomic) NSArray *places;
@property (weak, nonatomic) IBOutlet UIView *googleMapsView;
@property CLLocation *currentLocation;

@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) SMCalloutView *calloutView;
@property (strong, nonatomic) UIView *emptyCalloutView;

@end

static const CGFloat OFFSET = 40.0f;

@implementation CloseToMeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize Google Maps based on search done on Google.
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:self.currentLocation.coordinate.latitude longitude:self.currentLocation.coordinate.longitude zoom:14];
    self.mapView = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.googleMapsView.frame.size.width, self.googleMapsView.frame.size.height) camera:camera];
    [self.mapView setDelegate:self];
    self.mapView.settings.myLocationButton = YES;
    
    [self initCalloutView];
    

    [self.mapView setMyLocationEnabled:YES];
    [self addPlacesToMapView:self.mapView];
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

/*
 initializes callout window stuff.
 for creating accessory button in google map marker
 */
- (void)initCalloutView
{
    self.calloutView = [[SMCalloutView alloc] init];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [button addTarget:self action:@selector(calloutAccessoryButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.calloutView.rightAccessoryView = button;
    self.emptyCalloutView = [[UIView alloc] initWithFrame:CGRectZero];
}


# pragma mark Add Markers

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
        if ([[place valueForKey:@"open_now"] isKindOfClass:[NSString class]]) {
            // nil_info
            marker.icon = [GMSMarker markerImageWithColor:[UIColor yellowColor]];
        }
        else if ([[place valueForKey:@"open_now"] integerValue]) {
            marker.icon = [GMSMarker markerImageWithColor:[UIColor greenColor]];
        }
        else if (![[place valueForKeyPath:@"open_now"] integerValue]){
            marker.icon = [GMSMarker markerImageWithColor:[UIColor redColor]];
        }
        marker.map = mapView;
    }
    [self.googleMapsView addSubview:mapView];
}

# pragma mark google map markers

- (UIView *)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker
{
    CLLocationCoordinate2D anchor = marker.position;
    CGPoint point = [mapView.projection pointForCoordinate:anchor];
    
    self.calloutView.title = marker.title;
    self.calloutView.calloutOffset = CGPointMake(0, -OFFSET);
    self.calloutView.hidden = NO;
    
    CGRect calloutRect = CGRectZero;
    calloutRect.origin = point;
    calloutRect.size = CGSizeZero;
    
    [self.calloutView presentCalloutFromRect:calloutRect inView:mapView constrainedToView:mapView animated:YES];
    
    return self.emptyCalloutView;
}

- (void)mapView:(GMSMapView *)mapView didChangeCameraPosition:(GMSCameraPosition *)position
{
    /* move callout with map drag */
    if (mapView.selectedMarker != nil && !self.calloutView.hidden) {
        CLLocationCoordinate2D anchor = [mapView.selectedMarker position];
        
        CGPoint arrowPt = self.calloutView.backgroundView.arrowPoint;
        
        CGPoint pt = [mapView.projection pointForCoordinate:anchor];
        pt.x -= arrowPt.x;
        pt.y -= arrowPt.y + OFFSET;
        
        self.calloutView.frame = (CGRect) {.origin = pt, .size = self.calloutView.frame.size };
    } else {
        self.calloutView.hidden = YES;
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.calloutView.hidden = YES;
}

- (BOOL)mapView:(GMSMapView *)mapView didTapMarker:(GMSMarker *)marker
{
    mapView.selectedMarker = marker;
    return YES;
}


#pragma mark button-actions

- (IBAction)backButtonTouchUpInside:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)calloutAccessoryButtonTapped:(id)sender
{
    GMSMarker *marker = self.mapView.selectedMarker;
    if (marker) {
        
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
}

@end
