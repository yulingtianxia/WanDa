//
//  SNCommonUtils.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNCommonUtils.h"
#import "SNSharedResource.h"

#define TIMESTAMP_SERVER     0.001

@implementation SNCommonUtils

+ (CGSize)calHeightForWidth:(CGFloat)width withString:(NSString *)str font:(UIFont *)font
{
    UILabel * testlable = [[SNSharedResource sharedInstance] testLabel];
    testlable.numberOfLines =0;
    testlable.font = font;
    testlable.lineBreakMode =NSLineBreakByCharWrapping ;
    testlable.text = str;
    
    //给一个比较大的高度，宽度不变
    CGSize size =CGSizeMake(width,1000);
    
    //    获取当前文本的属性
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font,NSFontAttributeName,nil];
    //ios7方法，获取文本需要的size，限制宽度
    CGSize  actualsize =[str boundingRectWithSize:size
                                          options:NSStringDrawingUsesLineFragmentOrigin |NSStringDrawingUsesFontLeading
                                       attributes:tdic
                                          context:nil].size;
    
    return actualsize;
}

+(CGColorRef) getColorFromRed:(int)red Green:(int)green Blue:(int)blue Alpha:(int)alpha
{
    CGFloat r = (CGFloat) red/255.0;
    CGFloat g = (CGFloat) green/255.0;
    CGFloat b = (CGFloat) blue/255.0;
    CGFloat a = (CGFloat) alpha/1.0;
    CGFloat components[4] = {r,g,b,a};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGColorRef color = (CGColorRef)CGColorCreate(colorSpace, components);
    CGColorSpaceRelease(colorSpace);
    
    return color;
}



+ (NSString *)timeStamp{
    return [self timeStampFromDate:[NSDate date]];
}

+ (NSString *)timeStampFromDate:(NSDate *)date
{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    return [NSString stringWithFormat:@"%.0f", a];
}
+ (NSDate *)dateFromTimeStemp:(NSString *)timestamp
{
    return [NSDate dateWithTimeIntervalSince1970:[timestamp doubleValue]/1000.0];
}

+ (NSString *)formatterDate:(NSDate *)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    
    NSTimeZone * timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
    return [formatter stringFromDate:date];
}

+ (NSTimeInterval)intervalSinceNow:(NSDate *)theDate
{
    NSTimeInterval late = [theDate timeIntervalSince1970];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSTimeInterval interval = late - now;
    
    if (late >= now) {
        return interval;
    }else{
        return 0;
    }
}

//dead line str是以毫秒为单位统计的服务器时间戳，通过与本地时间的比较返回剩余时间
+ (NSTimeInterval)timeToDeadLine:(NSString *)deadLineStr
{
    double deadline = [deadLineStr doubleValue] * TIMESTAMP_SERVER;
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    double interval = deadline - now;
    
    if (deadline >= now) {
        return interval;
    }else{
        return 0;
    }
}

+ (NSString *)timeFormatted:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
}
@end
