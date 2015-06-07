//
//  SNCouponCell.m
//  WanDaLive
//
//  Created by apple on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNCouponCell.h"
#import "SNCommonUtils.h"
#import "SNSharedResource.h"
#import "SNCouponCellBg.h"
@interface SNCouponCell ()
-(void)drawCouponBackground;
@property (nonatomic , strong) SNCouponCellBg * subview;
@end

@implementation SNCouponCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure th
}

/**
 设置Cell
 */
-(void)setupCell:(SNCoupons *)model
{
    // UIImage *image = [[UIImage alloc] init];
    NSString * sid = model.sid;
    NSMutableDictionary * shopsInfo = [SNTopModel sharedInstance].shopsInfo;
    SNShops * shop = shopsInfo[sid];
    
    self.lblTime.text = [model getTimeStr];
    self.lblTime.font = [[SNSharedResource sharedInstance] commonLargerFont];
    self.lblTitle.text = shop.name;
    self.lbDiscount.text = model.title;
    [self.imPath setPlaceholderImage:[UIImage imageNamed:@"ok.png"]];
    if (self.imPath.image==nil) {
        [self.imPath setImageURL:[NSURL URLWithString:model.path]];
    }
    [self drawCouponBackground];
    if ([model isOutOfDate]) {
        [self setTitleColor:[UIColor grayColor]];
    }else{
        [self setTitleColor:RGB(0, 167, 98)];
    }
}

-(void)drawCouponBackground
{
    _subview = [[SNCouponCellBg alloc] init];
    _subview.coupon_rect = CGRectMake(0, 0, self.bounds.size.width, 135);
    _subview.title_rect = CGRectMake(_subview.coupon_rect.origin.x, _subview.coupon_rect.origin.y, _subview.coupon_rect.size.width, 65);
    _subview.content_color = [UIColor whiteColor].CGColor;
    _subview.bg_color = [SNCommonUtils getColorFromRed:223 Green:239 Blue:247 Alpha:1];
    _subview.arc_radius = 5;
    self.backgroundView = _subview;
    self.lblTime.textColor = [UIColor colorWithCGColor:_subview.title_color];
}


- (void)setTitleColor:(UIColor *)color
{
    _subview.title_color = color.CGColor;
    self.lblTime.textColor = color;
}

@end