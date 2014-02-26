//
//  SNTopModel.m
//  WanDaLive
//
//  Created by David Yang on 13-11-27.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNTopModel.h"
#import "KeyDefine.h"
#import "URLManager.h"
#import "SNSensorModel.h"
#import "SNCommonUtils.h"
#import "SNShop.h"

@implementation SNUserInfo

+ (SNUserInfo*) getInstanceFrom: (NSDictionary*) dict{
    if (dict.count == 0) {
        return nil;
    }
    
    SNUserInfo* userInfo = [[SNUserInfo alloc] init];
    
    NSNull * null = [NSNull null];
    
    id temp = [dict objectForKey:CREDITS_KEY];
    
    if (temp != nil && temp != null) {
        userInfo.credits = [temp doubleValue];
    }
    
    return userInfo;
}

@end
#pragma mark SNShops

@implementation SNShops
- (id) initWithCoder: (NSCoder *)coder
{
    if (self = [super init])
    {
        self.sid = [coder decodeObjectForKey:SID_KEY];
        self.name = [coder decodeObjectForKey:NAME_KEY];
        self.beacons = [coder decodeObjectForKey:BEACONS_KEY];
        self.time = [coder decodeObjectForKey:TIME_KEY];
        self.logo = [coder decodeObjectForKey:LOGO_KEY];
        self.address = [coder decodeObjectForKey:ADDRESS_KEY];
        self.IsCompleted = [coder decodeObjectForKey:@"IsCompleted"];
    }
    return self;
}
- (void) encodeWithCoder: (NSCoder *)coder
{
    [coder encodeObject:self.sid forKey:SID_KEY];
    [coder encodeObject:self.name forKey:NAME_KEY];
    [coder encodeObject:self.beacons forKey:BEACONS_KEY];
    [coder encodeObject:self.time forKey:TIME_KEY];
    [coder encodeObject:self.logo forKey:LOGO_KEY];
    [coder encodeObject:self.address forKey:ADDRESS_KEY];
    [coder encodeObject:self.IsCompleted forKey:@"IsCompleted"];
}
+ (NSMutableArray *) getInstanceFrom: (NSDictionary*) dict{
    if (dict.count == 0) {
        return nil;
    }
    
    NSMutableArray* shops = [NSMutableArray arrayWithCapacity:dict.count];
    NSNull * null = [NSNull null];
    for( NSString *sid in dict.allKeys){
        SNShops *shop = [[SNShops alloc]init];
        shop.sid=sid;
        NSDictionary *temp = [dict objectForKey: sid];
        if(temp != nil && temp != null){
            shop.name = [temp objectForKey:NAME_KEY];
            shop.logo = [URLManager imageUrl:[temp objectForKey:LOGO_KEY]];
            shop.address = [temp objectForKey:ADDRESS_KEY];
            shop.beacons = [temp objectForKey:BEACONS_KEY];
            shop.time = [temp objectForKey:TIME_KEY];
            shop.IsCompleted = @"NO";
        }
        NSData *shopData = [NSKeyedArchiver archivedDataWithRootObject:shop];
        [shops addObject:shopData];
        NSLog(@"%@",shop.sid);
    }
    return shops;
}


@end
#pragma mark SNCoupons

@implementation SNCoupons

+ (SNCoupons *) getInstanceFrom: (NSDictionary*) dict
{
    if(dict.count == 0){ return nil; }
    SNCoupons *coupons = [[SNCoupons alloc] init];
    NSNull * null = [NSNull null];
    for( NSString *object in dict.allKeys){
        id temp = [dict objectForKey: object];
        if(temp != nil && temp != null){
            if([object isEqual: SID_KEY]){
                coupons.sid = temp;
            }else if([object isEqual:CID_KEY]){
                coupons.cid = temp;
            }else if([object isEqual:TITLE_KEY]){
                coupons.title = temp;
            }else if([object isEqual: DISCOUNT_KEY ]){
                coupons.discount = temp;
            }else if([object isEqual:START_TIME_KEY]){
                coupons.startTime = temp;
            }else if([object isEqual:END_TIME_KEY]){
                coupons.endTime = temp;
            }else if([object isEqual:PATH_KEY]){ // 将path转换为imageurl
                coupons.path = [URLManager imageUrl:temp];
            }
        }
    }
    
    return coupons;
}


- (NSString *)getTimeStr{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd"];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    
    int toStartTime = 0;
    int toEndTime = [SNCommonUtils timeToDeadLine:_endTime];
    if (_startTime) {
        toStartTime = [SNCommonUtils timeToDeadLine:_startTime];
    }
    
    if (toStartTime == 0 && toEndTime == 0) {
        return @"已过期";
    }else if (toStartTime == 0 && toEndTime > 0){
        if (toEndTime > 86400) {
            return [NSString stringWithFormat:@"%d天后过期",toEndTime/86400];
        }else{
            return [NSString stringWithFormat:@"%02d:%02d:%02d",toEndTime/3600,(toEndTime/60)%60,toEndTime%60];
        }
    }else if (toStartTime >0){
        NSDate * startDate = [NSDate dateWithTimeIntervalSince1970:[_startTime doubleValue]/1000];
        NSDate * endDate = [NSDate dateWithTimeIntervalSince1970:[_endTime doubleValue]/1000];
        NSString * startStr = [formatter stringFromDate:startDate];
        NSString * endStr = [formatter stringFromDate:endDate];
        
        return [NSString stringWithFormat:@"%@至\n%@有效",startStr,endStr];
    }
    
    
    return nil;
}

- (BOOL)isOutOfDate
{
    
    int toStartTime = 0;
    int toEndTime = [SNCommonUtils timeToDeadLine:_endTime];
    if (_startTime) {
        toStartTime = [SNCommonUtils timeToDeadLine:_startTime];
    }
    if (toEndTime==0 || toStartTime> 0) {
        return YES;
    }
    return NO;
}


@end

#pragma mark SNTopModel

@implementation SNTopModel

+ (SNTopModel *)sharedInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (NSString*) uid{
    return self.userInfo.userID;
}

- (void) initUserInfo:(NSDictionary*) dict
{
    self.userInfo = [SNUserInfo getInstanceFrom:dict];
    
    if (self.userInfo == nil) {
        self.userInfo = [[SNUserInfo alloc] init];
    }
}

- (void) initShops:(NSDictionary *)dict
{
    self.shops = [SNShops getInstanceFrom: dict];
    NSUserDefaults *shops = [NSUserDefaults standardUserDefaults];
    [shops setObject:self.shops forKey:@"shops"];
    [shops synchronize];
}

- (void) initCoupons: (NSArray *) arry
{
    //NSMutableArray *arry = [dict objectForKey: @"coupons"];
    
    self.coupons = [NSMutableArray arrayWithCapacity:[arry count]];
    for( NSDictionary *ddict in arry){
        SNCoupons *coupon = [SNCoupons getInstanceFrom: ddict];
        [self.coupons addObject: coupon];
    }
}

- (void) initUseableCoupons:(NSMutableArray *)arry shopId:(NSString *)sid
{
    self.useableCoupons = [NSMutableArray arrayWithCapacity:[arry count]];
    for(SNCoupons * obj in self.coupons){
        if (![obj isOutOfDate] && [obj.sid isEqualToString:sid]) {
            [self.useableCoupons addObject: obj];
        }
    }
}

- (void) addSensorModel:(SNSensorModel*)model key:(NSString*)bid{
    if (self.sensors == nil) {
        self.sensors = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    
    if (bid != nil) {
        [self.sensors setObject:model forKey:bid];
    }
}

- (void) initShopsFromServer:(NSArray *) shops
{
    if (self.shopsInfo == nil) {
        self.shopsInfo = [NSMutableDictionary dictionaryWithCapacity:[shops count]];
    }
    
    if ([shops count] == 0) {
        return;
    }

    [self.shopsInfo removeAllObjects];
    
    for (NSDictionary* dict in shops) {
        SNShop * shop = [SNShop getInstanceFrom:dict];
        
        if (shop != nil) {
            [self.shopsInfo setObject:shop forKey:shop.sid];
        }
    }
}

@end
