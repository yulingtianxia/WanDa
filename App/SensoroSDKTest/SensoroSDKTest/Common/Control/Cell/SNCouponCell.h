//
//  SNCouponCell.h
//  WanDaLive
//
//  Created by apple on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNTopModel.h"
#import "EGOImageView.h"

@interface SNCouponCell : UITableViewCell
{
    @private
}

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;      // 优惠券头信息
@property (strong, nonatomic) IBOutlet UILabel *lbDiscount;    // 优惠券折扣信息
@property (strong, nonatomic) IBOutlet UILabel *lblTime;       // 优惠券有效时间
@property (strong, nonatomic) IBOutlet EGOImageView *imPath;   // 优惠券图片
@property (weak, nonatomic) IBOutlet UIButton *useButton;
@property (strong, nonatomic) NSString *deadLineStr;
/**
 设置Cell
 */
-(void)setupCell:(SNCoupons *)model;
- (void)setTitleColor:(UIColor *)color;

@end
