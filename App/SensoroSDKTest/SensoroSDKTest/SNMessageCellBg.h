//
//  SNMessageCellBg.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNMessageCellBg : UIView

@property (nonatomic) CGRect msg_rect;
@property (nonatomic) CGRect arrow_rect;
@property (nonatomic) CGFloat arc_radius;
@property (nonatomic) CGColorRef msg_color;
@property (nonatomic) CGColorRef fill_color;
@property (nonatomic, strong) NSString * msg_string;

@end
