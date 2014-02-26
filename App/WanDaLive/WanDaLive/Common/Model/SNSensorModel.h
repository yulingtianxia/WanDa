//
//  SNSensorModel.h
//  WanDaLive
//
//  Created by David Yang on 13-11-29.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSensorModel : NSObject

@property BOOL isGoldCorner;
@property double goldCornerDist;

@property BOOL isMovableGoldCorner;
@property double movableGoldCornerDist;
@property NSUInteger movableGoldCornerTimer;

@property BOOL isCredits;
@property double creditsDist;
@property NSUInteger creditsTimer;

@property BOOL isTask;
@property double taskDist;
@property NSUInteger taskTimer;

@property BOOL isGoodsShow;
@property double goodsShowDist;
@property NSUInteger goodsShowTimer;
@property (nonatomic,strong) NSString* goodsUrl;

@property BOOL isVerify;
@property double verfifyDist;

@property (nonatomic,strong) NSString* sid;//店铺ID，在淘金角时，有可能没有。
@property (nonatomic,strong) NSString* bid;//BeaconID。

+ (SNSensorModel*) getInstanceFrom: (NSDictionary*) dict;

@end
