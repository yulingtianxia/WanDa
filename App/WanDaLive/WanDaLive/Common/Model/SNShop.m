//
//  SNShop.m
//  WanDaLive
//
//  Created by David Yang on 13-12-7.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNShop.h"
#import "KeyDefine.h"

@implementation SNShop

+ (SNShop*) getInstanceFrom: (NSDictionary*) dict{
    
    SNShop * model = [[SNShop alloc] init];
    
    NSNull * null = [NSNull null];
    
    id temp = [dict objectForKey:SID_KEY];
    if (temp == nil ||
        temp == null) {
        return nil;//没有ID是致命缺陷。
    }else{
        if ([temp isKindOfClass:[NSNumber class]]) {
            model.sid = [temp stringValue];
        }else if ([temp isKindOfClass:[NSString class]]){
            model.sid = temp;
        }else{
            return nil;
        }
    }
    
    temp = [dict objectForKey:NAME_KEY];
    if (temp != nil &&
        temp != null) {
        model.name = temp;
    }
    
    temp = [dict objectForKey:ADDRESS_KEY];
    if (temp != nil &&
        temp != null) {
        model.address = temp;
    }
    
    temp = [dict objectForKey:LOGO_KEY];
    if (temp != nil &&
        temp != null) {
        model.logo = temp;
    }
    
    model.credits = nil;
    return model;
}

@end
