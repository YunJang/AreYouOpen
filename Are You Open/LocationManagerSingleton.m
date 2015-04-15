//
//  LocationManagerSingleton.m
//  Are You Open
//
//  Created by Yun Jang on 3/30/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import "LocationManagerSingleton.h"

@implementation LocationManagerSingleton

+ (LocationManagerSingleton *)singleton
{
    // Only instantiate the LocationManager once.
    static LocationManagerSingleton *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc]init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        self.locationManager = [CLLocationManager new];
        [self.locationManager setDelegate:self];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
        {
//            NSLog(@"Location Authorization Complete.");
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
        }
    }
    return self;
}

- (void)startUpdatingLocation
{
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Get the latitude/longitude from our current location.
    CLLocation *location = [locations lastObject];
//    NSLog(@"Location Updating Complete - Lat: %f | Lng: %f", location.coordinate.latitude, location.coordinate.longitude);
    self.currentLocation = location;
    [manager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location Manager Error: %@", [error localizedDescription]);
}

@end
