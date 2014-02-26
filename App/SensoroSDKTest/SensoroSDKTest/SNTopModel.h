//
//  SNTopModel.h
//  WanDaLive
//
//  Created by David Yang on 13-11-27.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGOImageView.h"
@class SNSensorModel;

@interface SNUserInfo : NSObject

@property (nonatomic,strong) NSString* userName;
@property (nonatomic,strong) NSString* userID;
@property double credits;

+ (SNUserInfo*) getInstanceFrom: (NSDictionary*) dict;

@end
#pragma mark SNShops

@interface SNShops : NSObject<NSCoding>

@property (nonatomic,strong) NSString* sid;
@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* logo;
@property (nonatomic,strong) NSString* address;
@property (nonatomic,strong) NSString* beacons;
@property (nonatomic,strong) NSString* time;
@property (nonatomic,strong) NSString* IsCompleted;
- (id) initWithCoder: (NSCoder *)coder;
- (void) encodeWithCoder: (NSCoder *)coder;
+ (NSMutableArray *) getInstanceFrom: (NSDictionary*) dict;

@end
#pragma mark SNCoupons

@interface SNCoupons : NSObject

@property (nonatomic,strong) NSString* sid;
@property (nonatomic,strong) NSString* cid;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* discount;
@property (nonatomic,strong) NSString* path;
@property (nonatomic,strong) NSString* startTime;
@property (nonatomic,strong) NSString* endTime;

- (NSString *)getTimeStr;
- (BOOL)isOutOfDate;


+ (SNCoupons *) getInstanceFrom: (NSDictionary*) dict;

@end


@interface SNTopModel : NSObject

@property (nonatomic,strong) SNUserInfo * userInfo;
@property (nonatomic,strong) NSMutableArray * shops;
@property (nonatomic,strong) NSMutableArray * coupons;
@property (nonatomic,strong) NSMutableArray * useableCoupons;

@property (nonatomic,strong) NSMutableDictionary* sensors;
@property (nonatomic,strong) NSMutableDictionary* invalidSensors;
@property (nonatomic,strong) NSMutableDictionary* shopsInfo;

@property (readonly) NSString* uid;

- (void) initUserInfo:(NSDictionary*) dict;
- (void) initShops:(NSDictionary *) dict;

- (void) initShopsFromServer:(NSArray *) shops;

- (void) initCoupons: (NSArray *) dict;
- (void) initUseableCoupons:(NSMutableArray *)arry shopId:(NSString *) sid;

- (void) addSensorModel:(SNSensorModel*)model key:(NSString*)bid;
//- (void) addInvalidSensorModel:(SNSensorModel*)model key:(NSString*)bid;

+ (SNTopModel *)sharedInstance;

@end
