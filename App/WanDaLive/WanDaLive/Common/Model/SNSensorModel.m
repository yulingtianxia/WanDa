//
//  SNSensorModel.m
//  WanDaLive
//
//  Created by David Yang on 13-11-29.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNSensorModel.h"
#import "KeyDefine.h"

@implementation SNSensorModel

+ (SNSensorModel*) getInstanceFrom: (NSDictionary*) dict{
    
    SNSensorModel * model = [[SNSensorModel alloc] init];
    
    NSNull * null = [NSNull null];
    
    id temp = [dict objectForKey:ID_KEY];
    if (temp == nil ||
        temp == null) {
        return nil;//没有ID是致命缺陷。
    }else{
        model.bid = temp;
    }
    
    temp = [dict objectForKey:GOODS_KEY];
    if (temp != nil &&
        temp != null &&
        [temp isKindOfClass:[NSDictionary class]]) {
        model.isGoodsShow = YES;
        
        model.goodsShowTimer = [[temp objectForKey:TIMER_KEY] integerValue];
        model.goodsShowDist = [[temp objectForKey:RANGE_KEY] doubleValue];
        model.goodsUrl = [temp objectForKey:URL_KEY];
    }
    
    temp = [dict objectForKey:CREDITS_KEY];
    if (temp != nil &&
        temp != null &&
        [temp isKindOfClass:[NSDictionary class]]) {
        model.isCredits = YES;
        
        model.creditsTimer = [[temp objectForKey:TIMER_KEY] integerValue];
        model.creditsDist = 100;//默认100米内触发。
    }
    
    temp = [dict objectForKey:CORNER_KEY];
    if (temp != nil &&
        temp != null &&
        [temp isKindOfClass:[NSDictionary class]]) {
        model.isGoldCorner = YES;
        
        model.goldCornerDist = [[temp objectForKey:RANGE_KEY] integerValue];
    }
    
    temp = [dict objectForKey:MOVABLE_CORNER_KEY];
    if (temp != nil &&
        temp != null &&
        [temp isKindOfClass:[NSDictionary class]]) {
        model.isMovableGoldCorner = YES;
        
        model.movableGoldCornerDist = [[temp objectForKey:RANGE_KEY] integerValue];
        model.movableGoldCornerTimer = [[temp objectForKey:TIMER_KEY] integerValue];
    }
    
    if (model.isGoldCorner != YES && model.isMovableGoldCorner != YES) {
        temp = [dict objectForKey:SID_KEY];
        if (temp == nil ||
            temp == null) {
            return nil;//没有ID是致命缺陷。
        }else{
            model.sid = temp;
        }
    }
    
    temp = [dict objectForKey:TASK_KEY];
    if (temp != nil &&
        temp != null &&
        [temp isKindOfClass:[NSDictionary class]]) {
        model.isTask = YES;
        
        model.taskDist = [[temp objectForKey:RANGE_KEY] integerValue];
        if (model.taskDist == 0) {
            model.taskDist = 100;
        }
        model.taskTimer = [[temp objectForKey:TIMER_KEY] integerValue];
    }

    model.isVerify = YES;
    model.verfifyDist = 1;//1m校验区。
    
    return model;
}

@end
