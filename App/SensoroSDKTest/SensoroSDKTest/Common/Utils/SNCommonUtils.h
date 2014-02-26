//
//  SNCommonUtils.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNMacroDefinition.h"
@interface SNCommonUtils : NSObject

+ (CGSize)calHeightForWidth:(CGFloat)width withString:(NSString *)str font:(UIFont *)font;//当宽度指定时，获取自动换行的字符串的size信息。
+ (CGColorRef) getColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha; //获取颜色，RGB值范围0-255，alpha值范围0-1

+ (NSString *)timeStamp;//获取当前时间戳
+ (NSString *)timeStampFromDate:(NSDate *)date;//时间转换为时间戳
+ (NSDate *)dateFromTimeStemp:(NSString *)timestamp;//时间戳转换为时间
+ (NSString *)formatterDate:(NSDate *)date;//获取规定格式的本地时间
+ (NSTimeInterval)intervalSinceNow:(NSDate *)theDate;
+ (NSTimeInterval)timeToDeadLine:(NSString *)deadLineStr;
+ (NSString *)timeFormatted:(int)totalSeconds;
@end
