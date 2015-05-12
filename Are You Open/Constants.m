//
//  Constants.m
//  Are You Open
//
//  Created by Yun Jang on 7/12/14.
//  Copyright (c) 2014 Yun Jang. All rights reserved.
//

#import "Constants.h"

// Example : https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=<coordinate>&radius=<radius>&types=<category>&name=<search>&key=<key>

// Keys
NSString * const GoogleMapsAPIKey = @"AIzaSyC51rzHPoyeMvXvpSAXbuDMAnGlXvBgBUM";
NSString * const GooglePlacesAPIKey = @"AIzaSyD4NMuYyaEkYMHe_mBLNbRLRNl9mcdp3Ds";

// Google Places
NSString * const GooglePlacesNearbyJSONURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
NSString * const GooglePlacesDetailsJSONURL = @"https://maps.googleapis.com/maps/api/place/details/json?placeid=";
NSString * const GooglePlacesDistance = @"&radius=";
NSString * const GooglePlacesCategory = @"&types=";
NSString * const GooglePlacesName = @"&name=";
NSString * const GooglePlacesKey = @"&key=";

// Math
long const METERS = 1609.34;