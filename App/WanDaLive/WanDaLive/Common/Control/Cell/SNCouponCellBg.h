//
//  SNCouponCellBg.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-6.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNCouponCellBg : UIView

//coupon
@property (nonatomic) CGRect coupon_rect;//优惠券的Rect
//title
@property (nonatomic) CGRect title_rect;//优惠券上半部分的大小
@property (nonatomic) CGColorRef title_color;//上半部分的颜色，配合商店logo显示
//content
@property (nonatomic) CGColorRef content_color;//下半部分的颜色，下半部分的Rect由优惠券和上半部分的两个Rect计算得出
//cell background
@property (nonatomic) CGColorRef bg_color;//cell的背景界面
@property (nonatomic) CGFloat arc_radius;//优惠券页面圆角弧度

-(void)drawMsgBackground;
@end
