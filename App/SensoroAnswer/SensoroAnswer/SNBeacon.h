//
//  SNBeacon.h
//  BTLE Transfer
//
//  Created by David Yang on 13-12-13.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SNBeacon : NSObject

@property (readonly, nonatomic) NSString* proximityUUID;
@property (readonly, nonatomic) NSNumber *major;
@property (readonly, nonatomic) NSNumber *minor;
@property (readonly, nonatomic) CLProximity proximity;
@property (readonly, nonatomic) NSInteger rssi;
@property (readonly, nonatomic) NSInteger lastedRssi;
@property (readonly, nonatomic) CLLocationAccuracy accuracy;
@property (readonly, nonatomic) NSString* key;
@property NSInteger txPower;

@property (strong, nonatomic) NSDate * lastSeenTime;

- (void) pushRSSI:(NSInteger) rssi;
- (void) clearRSSI;

+ (SNBeacon*) getInstanceFromData:(NSData*) data rssi:(NSInteger)rssi;

@end
