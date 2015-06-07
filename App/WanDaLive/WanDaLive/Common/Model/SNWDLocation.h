//
//  SNWDLocation.h
//  WanDaLive
//
//  Created by 森哲 on 13-12-17.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface SNWDLocation : NSObject
@property NSString * Name;
@property CLLocation *WDLoc;
-(instancetype)initWithName:(NSString*) name Location:(CLLocation *)loc NS_DESIGNATED_INITIALIZER;
@end
