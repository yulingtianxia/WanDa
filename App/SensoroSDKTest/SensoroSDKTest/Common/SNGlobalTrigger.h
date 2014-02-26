//
//  SNGlobalTrigger.h
//  WanDaLive
//
//  Created by David Yang on 13-11-28.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SensoroAnswer.h"
#import "SNRequest.h"

@protocol SNBusinessTrigger <NSObject>

@optional
- (void) enterGoldCorner;
- (void) leaveGoldCorner;

//校验区域
//进入一个校验区域
- (void) enterVerifyArea:(NSString*) sid;
- (void) leaveVerifyArea;

//寻宝任务
//寻宝中任何一项完成。
- (void) taskComplete: (NSString*) sid;

//移动淘金角
- (void) enterMovableGoldCorner;
- (void) leaveMovableGoldCorner;
- (void) movableGoldCornerSuccess;

@end

@interface SNGlobalTrigger : NSObject <RequestDelegate,SNSensoroServiceDelegate,SNTriggerDelegate>

@property BOOL isInGloldCorner;
@property BOOL isInMovableGloldCorner;

@property (readonly) BOOL isInVerifyArea;
@property (readonly) NSString * verifySID;

- (void) startWatcherBeacon;
- (void) querySensorInfo:(NSString*) bid;

//添加观测者。
- (void) addObserver:(id<SNBusinessTrigger>) watcher;
//删除观测者。
- (void) removeObserver:(id<SNBusinessTrigger>) watcher;

+ (SNGlobalTrigger *)sharedInstance;

@end
