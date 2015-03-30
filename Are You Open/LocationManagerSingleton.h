//
//  LocationManagerSingleton.h
//  Are You Open
//
//  Created by Yun Jang on 3/30/15.
//  Copyright (c) 2015 Yun Jang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationManagerSingleton : NSObject <CLLocationManagerDelegate>

+ (LocationManagerSingleton *) singleton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (void)startUpdatingLocation;

@end
