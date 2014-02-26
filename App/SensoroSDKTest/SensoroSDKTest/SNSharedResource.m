//
//  SNSharedResource.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNSharedResource.h"
#import "KeyDefine.h"

const CGFloat kSmallFontSize = 12;
const CGFloat kMiddleFontSize = 16;
const CGFloat kLargeFontSize = 24;
const CGFloat kLargerFontSize = 36;
const CGFloat kSuperFontSize = 70;
const CGFloat kMaxFontSize = 120;

@interface SNSharedResource ()
{
    UIFont * _commonSmallFont;
    UIFont * _commonSmallBoldFont;
    UIFont * _commonMiddleFont;
    UIFont * _commonLargeFont;
    UIFont * _commonLargerFont;
    UIFont * _commonSuperFont;
    UIFont * _commonMaxFont;
}

@end

@implementation SNSharedResource

@synthesize cornerIcon;
@synthesize shopIcon;
@synthesize discountIcon;
@synthesize creditIcon;
@synthesize testLabel;
@synthesize placeholderImg;

+ (SNSharedResource *)sharedInstance
{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (UIImage *)cornerIcon
{
    if (cornerIcon == nil) {
        cornerIcon = [UIImage imageNamed:@"coupon-msg"];
    }
    return cornerIcon;
}
- (UIImage *)shopIcon
{
    if (shopIcon == nil) {
        shopIcon = [UIImage imageNamed:@"shop-msg"];
    }
    return shopIcon;
}
- (UIImage *)discountIcon
{
    if (discountIcon == nil) {
        discountIcon = [UIImage imageNamed:@"discount-msg"];
    }
    return discountIcon;
}
- (UIImage *)creditIcon
{
    if (creditIcon == nil) {
        creditIcon = [UIImage imageNamed:@"credit.png"];
    }
    return creditIcon;
}
- (UIImage *)placeholderImg
{
    if (placeholderImg == nil) {
        placeholderImg = [UIImage imageNamed:@"ok"];
    }
    return placeholderImg;
}


-(UIFont*)commonSmallFont{
    if (_commonSmallFont == nil) {
        _commonSmallFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kSmallFontSize];
    }
    
    return _commonSmallFont;
}

-(UIFont*)commonSmallBoldFont{
    if (_commonSmallBoldFont == nil) {
        _commonSmallBoldFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kSmallFontSize];
    }
    
    return _commonSmallBoldFont;
}

-(UIFont*)commonMiddleFont{
    if (_commonMiddleFont == nil) {
        _commonMiddleFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kMiddleFontSize];
    }
    
    return _commonMiddleFont;
}

-(UIFont*)commonLargeFont{
    if (_commonLargeFont == nil) {
        _commonLargeFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kLargeFontSize];
    }
    
    return _commonLargeFont;
}

-(UIFont*)commonLargerFont{
    if (_commonLargerFont == nil) {
        _commonLargerFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kLargerFontSize];
    }
    
    return _commonLargerFont;
}

-(UIFont*)commonSuperFont{
    if (_commonSuperFont == nil) {
        _commonSuperFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kSuperFontSize];
    }
    
    return _commonSuperFont;
}

-(UIFont*)commonMaxFont{
    if (_commonMaxFont == nil) {
        _commonMaxFont = [UIFont fontWithName:FONT_LANTING_THIN_NAME size:kMaxFontSize];
    }
    
    return _commonMaxFont;
}
@end
