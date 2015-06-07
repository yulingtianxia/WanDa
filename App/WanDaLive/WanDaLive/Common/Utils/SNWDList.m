//
//  SNWDList.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-17.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNWDList.h"
#import <CoreLocation/CoreLocation.h>
@implementation SNWDList
@synthesize WDArray;

-(instancetype)init{
    if (self=[super init]) {
        SNWDLocation* cangshanWD = [[SNWDLocation alloc]initWithName:@"福州仓山万达广场‎" Location:[[CLLocation alloc]initWithLatitude:26.036753 longitude:119.2756]];
        
        WDArray =(NSMutableArray*) @[cangshanWD];
        
    }
    return self;
}
@end
