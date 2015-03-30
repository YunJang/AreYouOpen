//
//  Constants.m
//  Are You Open
//
//  Created by Yun Jang on 7/12/14.
//  Copyright (c) 2014 Yun Jang. All rights reserved.
//

#import "Constants.h"

// Example : https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=30.2884360,-97.7488920&radius=1610&types=food&name=whataburger&key=AIzaSyD4NMuYyaEkYMHe_mBLNbRLRNl9mcdp3Ds

// Google Maps
NSString * const GoogleMapsAPIKey = @"AIzaSyC51rzHPoyeMvXvpSAXbuDMAnGlXvBgBUM";

// Google Places
NSString * const GooglePlacesNearbyJSONURL = @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=";
NSString * const GooglePlacesDetailsJSONURL = @"https://maps.googleapis.com/maps/api/place/details/json?placeid=";
NSString * const GooglePlacesDistance = @"&radius=10000&types=food&name=";
NSString * const GooglePlacesAPIKey = @"&key=AIzaSyD4NMuYyaEkYMHe_mBLNbRLRNl9mcdp3Ds";