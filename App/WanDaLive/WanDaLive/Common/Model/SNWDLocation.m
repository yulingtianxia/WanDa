//
//  SNWDLocation.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-17.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNWDLocation.h"

@implementation SNWDLocation
@synthesize Name;
@synthesize WDLoc;
-(instancetype)initWithName:(NSString*) name Location:(CLLocation *)loc{
    if (self=[super init]) {
        Name=name;
        WDLoc=loc;
    }
    return self;
}
@end
