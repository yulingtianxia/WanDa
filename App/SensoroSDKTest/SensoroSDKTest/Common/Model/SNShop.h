//
//  SNShop.h
//  WanDaLive
//
//  Created by David Yang on 13-12-7.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNShop : NSObject

@property (nonatomic,strong) NSString* sid;//店铺ID，在淘金角时，有可能没有。
@property (nonatomic,strong) NSString* name;//店铺名称。
@property (nonatomic,strong) NSString* logo;//店铺LOGO。
@property (nonatomic,strong) NSString* address;//店铺地址。

+ (SNShop*) getInstanceFrom: (NSDictionary*) dict;

@end
