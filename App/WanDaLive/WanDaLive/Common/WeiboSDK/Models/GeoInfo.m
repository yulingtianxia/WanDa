//
//  GeoInfo.m
//  WeiboSDK
//
//  Created by Liu Jim on 8/3/13.
//  Copyright (c) 2013 openlab. All rights reserved.
//

#import "GeoInfo.h"
#import "NSDictionary+Json.h"

@implementation GeoInfo

- (instancetype)initWithJsonDictionary:(NSDictionary*)dic
{
	self = [super init];
    if (self) {
        NSArray *coordinatesArray = [dic arrayValueForKey:@"coordinates"];
        if (coordinatesArray && coordinatesArray.count == 2) {
            self.latitude = [coordinatesArray[0] doubleValue];
            self.longitude = [coordinatesArray[1] doubleValue];
        }
    }
    return self;
}

//===========================================================
//  Keyed Archiving
//
//===========================================================
- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeDouble:self.latitude forKey:@"latitude"];
    [encoder encodeDouble:self.longitude forKey:@"longitude"];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        self.latitude = [decoder decodeDoubleForKey:@"latitude"];
        self.longitude = [decoder decodeDoubleForKey:@"longitude"];
    }
    return self;
}

@end

