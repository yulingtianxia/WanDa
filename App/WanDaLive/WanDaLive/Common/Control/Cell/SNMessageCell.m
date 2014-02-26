//
//  SNMessageCell.m
//  WanDaLive
//
//  Created by David Yang on 13-11-28.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMessageCell.h"
#import "SNMessageCellBg.h"
#import "SNCommonUtils.h"
#import "SNMessageManager.h"
#import "URLManager.h"
#import "SNSharedResource.h"

#define MSG_FONT ([UIFont systemFontOfSize:12])

@interface SNMessageCell ()
@property (strong, nonatomic) SNMessageCellBg * subview;
- (void)drawBackgroundWithHeight:(CGFloat)height;
@end

@implementation SNMessageCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)share:(id)sender {
}

- (IBAction)weiboShare:(id)sender {
}

-(void)setupCell:(SNMessage *)message{
    //绘制背景泡泡
    CGSize size = [SNCommonUtils calHeightForWidth:self.msgLabel.frame.size.width withString:message.content font:MSG_FONT];
    [self drawBackgroundWithHeight:size.height + 50];
    if ([message.type isEqualToString:@"shop"]) {
        [_iconImg setImage:[[SNSharedResource sharedInstance] shopIcon]];
        _subview.msg_color = [SNCommonUtils getColorFromRed:148 Green:200 Blue:133 Alpha:1.0];
    }else if ([message.type isEqualToString:@"credits"]){
        [_iconImg setImage:[[SNSharedResource sharedInstance] creditIcon]];
        _subview.msg_color = [SNCommonUtils getColorFromRed:127 Green:164 Blue:201 Alpha:1.0];
    }else if ([message.type isEqualToString:@"fixedcorner"]){
        [_iconImg setImage:[[SNSharedResource sharedInstance] cornerIcon]];
        _subview.msg_color = [SNCommonUtils getColorFromRed:241 Green:170 Blue:154 Alpha:1.0];
    }else if ([message.type isEqualToString:@"hunt"]){
        [_iconImg setImage:[[SNSharedResource sharedInstance] creditIcon]];
        _subview.msg_color = [SNCommonUtils getColorFromRed:231 Green:194 Blue:130 Alpha:1.0];
    }
    self.msgLabel.text = message.content;
    self.msgLabel.font = MSG_FONT;
    self.titleLabel.text = message.title;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    
}
- (void)drawBackgroundWithHeight:(CGFloat)height 
{
    _subview = [[SNMessageCellBg alloc]init];
    _subview.msg_rect = CGRectMake(0, 0, SCREEN_WIDTH * 270.0/320.0, height);
    _subview.arrow_rect = CGRectMake(SCREEN_WIDTH * 30.0/320, 0, SCREEN_WIDTH * 15.0/320.0, SCREEN_HEIGHT * 6.0/480.0);
    _subview.arc_radius = 3;
    _subview.fill_color = [SNCommonUtils getColorFromRed:223 Green:239 Blue:247 Alpha:1];
    _subview.userInteractionEnabled = NO;
    _subview.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_subview setNeedsDisplay];
    
    self.backgroundView = _subview;
}


@end