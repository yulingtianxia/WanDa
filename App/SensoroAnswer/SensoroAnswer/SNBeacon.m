//
//  SNBeacon.m
//  BTLE Transfer
//
//  Created by David Yang on 13-12-13.
//  Copyright (c) 2013年 Apple. All rights reserved.
//

#import "SNBeacon.h"

#define RSSI_BUF_SIZE 10

extern double calculateAccuracy(int txPower, double rssi);

@interface SNBeacon ()
{
    NSInteger rssies[RSSI_BUF_SIZE];
}

@property (strong, nonatomic) NSUUID*  inProximityUUID;
@property (strong, nonatomic) NSNumber * inMajor;
@property (strong, nonatomic) NSNumber * inMinor;

@end

@implementation SNBeacon

#pragma mark property

- (NSInteger) rssi{
    NSInteger sum = 0;
    NSInteger count = 0;
    for (int i = 0; i < RSSI_BUF_SIZE; i++) {
        if (rssies[i] < 0) {
            sum += rssies[i];
            count ++;
        }
    }
    if (count == 0) {
        return 0;
    }else{
        return sum/count;//求平均值
    }
}

- (NSInteger) lastedRssi{
    return rssies[0];
}

- (NSString*) proximityUUID{
    return [self.inProximityUUID UUIDString];
}

- (NSNumber *) major{
    return self.inMajor;
}

- (NSNumber *) minor{
    return self.inMinor;
}

- (NSString*) key{
    NSString * key = [NSString stringWithFormat:@"%@-%@-%@",
                      self.proximityUUID,self.major,self.minor];
    return key;
}

- (CLProximity) proximity{
    CLProximity ret = CLProximityUnknown;
    
    if (self.lastedRssi == 127 || self.lastedRssi == 0) {
        ret = CLProximityUnknown;
    }else{
        CLLocationAccuracy acc = self.accuracy;
        
        if (acc < 0) {
            ret = CLProximityUnknown;
        }else if (acc < 1.f) {
            ret = CLProximityImmediate;
        }else if(acc > 1.f && acc > 3.0f){
            ret = CLProximityNear;
        }else{
            ret = CLProximityFar;
        }
    }
    
    return ret;
}

- (CLLocationAccuracy) accuracy{
    CLLocationAccuracy acc = 0.0;
    
    acc = calculateAccuracy((int)self.txPower,self.lastedRssi);
    
    return acc;
}

- (NSInteger) minRSSI{
    NSInteger find = 10000;
    for (int i = 0; i < RSSI_BUF_SIZE; i++) {
        if (rssies[i] < 0 &&
            rssies[i] < find) {
            find = rssies[i];
        }
    }
    
    return find;
}

- (NSInteger) maxRSSI{
    NSInteger find = -10000;
    for (int i = 0; i < RSSI_BUF_SIZE; i++) {
        if (rssies[i] < 0 &&
            rssies[i] > find) {
            find = rssies[i];
        }
    }
    
    return find;
}

- (void) pushRSSI:(NSInteger) rssi{
    
    for (int i = RSSI_BUF_SIZE - 1; i > 0; i--) {
        rssies[i] = rssies[i - 1];
    }
    rssies[0] = rssi;
}

- (void) clearRSSI{
    for (int i = RSSI_BUF_SIZE - 1; i >= 0; i--) {
        rssies[i] = 0;
    }
}

+ (SNBeacon*) getInstanceFromData:(NSData*) data rssi:(NSInteger)rssi{
    
    if ([data length] < 25) {
        return nil;
    }
    
    SNBeacon * beacon = [[SNBeacon alloc] init];
    NSRange range = NSMakeRange(4, 16);
    unsigned char indentifier[16];
    [data getBytes:indentifier range:range];
    beacon.inProximityUUID = [[NSUUID alloc] initWithUUIDBytes:indentifier];
    
    range = NSMakeRange(20, 2);
    [data getBytes:indentifier range:range];
    //颠倒major的字节序。
    unsigned char temp = indentifier[0];
    indentifier[0] = indentifier[1];
    indentifier[1] = temp;
    beacon.inMajor = [NSNumber numberWithInt:*((unsigned short*)&indentifier[0])];
    
    //颠倒minor的字节序。
    range = NSMakeRange(22, 2);
    [data getBytes:indentifier range:range];
    temp = indentifier[0];
    indentifier[0] = indentifier[1];
    indentifier[1] = temp;
    beacon.inMinor = [NSNumber numberWithInt:*((unsigned short*)&indentifier[0])];

    range = NSMakeRange(24, 1);
    [data getBytes:indentifier range:range];
    beacon.txPower = (char)indentifier[0];
    
    [beacon clearRSSI];
    [beacon pushRSSI:rssi];
    
    return beacon;
}

@end
