//
//  SensoroAnswer.h
//  SensoroAnswer
//
//  Created by David Yang on 13-11-21.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class SNSensor;
@class SNTrigger;

#pragma mark Protocol

//绑定到对象上的信息。
@protocol SNSensoroServiceDelegate <NSObject>

//进入监测区域
- (void) enterRegion;
//离开监测区域。
- (void) exitRegion;

//进入某些传感器的区域。
- (void) enterSensor: (NSArray*) sensors;
//离开某些传感器的区域。
- (void) exitSensor: (NSArray*) sensors;

//一些传感器出现了。
- (void) sensorAppear: (NSArray*) appear disappear: (NSArray*) disappear;

//发生错误了。
- (void) errorWasHappened:(NSError*)error;
@end

//绑定到Sensor上的信息。
@protocol SNTriggerDelegate <NSObject>

//到达指定时间，触发此事件。
- (void) timeTrigger: (SNTrigger*) triger sensor:(SNSensor*) sensors;

//到达指定距离出发此事件，前面是到达的此距离的传感器，后面是离开此距离的传感器。
- (void) distanceTrigger:(SNTrigger*) triger sensor:(SNSensor*) sensors;

//到达指定距离后又离开了，此时通知外部。
- (void) distanceLeaveTrigger:(SNTrigger*) triger;

@end

#pragma mark Class

@interface SNSensor : NSObject

@property (nonatomic,strong) NSString* uuid;
@property (nonatomic,strong) NSNumber* major;
@property (nonatomic,strong) NSNumber* minor;

@property CLProximity proximity;
@property (readonly)CLLocationAccuracy distance; //现在的距离
@property (readonly)CLLocationAccuracy minDistance; //曾经到过的最小距离。

@property (readonly)CLLocationAccuracy bleDistance; //现在的距离
@property (readonly)CLLocationAccuracy minBleDistance; //曾经到过的最小距离。

@property (nonatomic,strong) NSDate * entryTime;
@property NSUInteger stayTime; //停留时间
@property BOOL isOutOfRegion;//是否在Beacon的区域内。

@end

//enum SNTriggerTyp {
//    GOLD_CORNER = 0,
//    SHAKE_AWARD = 1,
//    GET_SCORE = 2,
//    MOVE_GOLD_CORNER = 3,
//    };

//用于Trigger的跟踪；每个Trigger都有
@interface SNTrigger : NSObject

//这个Trigger内使用的传感器，格式为字符串，UUID-major-minor
@property (nonatomic,strong) NSMutableDictionary* triggerSensores;
@property BOOL isStartTimer;//是否开始计时。
@property BOOL isTimerAutoDelete;//是否开始计时。
@property NSUInteger distTimer;//范围内计时。
@property NSUInteger stayTimeLimit; //停留多长时间算作超时。
@property CLLocationAccuracy stayDistLimit; //在什么范围内开始计算时间。

//绑在Trigger上的监测者。
@property (nonatomic,weak) id<SNTriggerDelegate> watcher;

@end

@interface SensoroAnswer : NSObject

////有传感器达到指定时间，触发事件。
//@property NSUInteger timeTriggerIntervale;
////在指定的传感器距离内。
//@property NSUInteger distanceTrigger;

@property (readonly) BOOL servicing;

//获取现在的范围内的传感器。
@property (NS_NONATOMIC_IOSONLY, getter=getCurSensors, readonly, copy) NSArray *curSensors;

//启动服务
- (void) initService;

//启动服务
- (void) startService;
//停止服务。
- (void) stopService;
//添加观测者。
- (void) addObserver:(id<SNSensoroServiceDelegate>) watcher;
//删除观测者。
- (void) removeObserver:(id<SNSensoroServiceDelegate>) watcher;

- (void) addTrigger:(SNTrigger*) trigger;
- (void) removeTrigger:(SNTrigger*) trigger;

+ (SensoroAnswer *)sharedInstance;

@end
