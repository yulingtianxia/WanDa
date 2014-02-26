//
//  SNMessageCellBg.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMessageCellBg.h"
@interface SNMessageCellBg (private)

-(void)drawMsgBgByRect:(CGRect)rect andTriangleRcet:(CGRect)tri_rect andArcRadius:(CGFloat)radius andColor:(CGColorRef)color;

@end
@implementation SNMessageCellBg

@synthesize msg_rect;//气泡的位置，包括小箭头
@synthesize arrow_rect;//小箭头的位置
@synthesize arc_radius;//气泡弧度
@synthesize msg_color;//气泡颜色
@synthesize fill_color;//cell的背景填充色
@synthesize msg_string;//详细信息字符串

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [self drawMsgBackground];
}

-(void)drawMsgBackground
{
    // Drawing code
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, fill_color);//cell的背景色
    CGContextFillRect(context,self.bounds);//把整个空间用刚设置的颜色填充
    //上面是准备工作，下面开始画图形了
    
    CGContextSetFillColorWithColor(context, msg_color);//气泡的填充色
    CGRect rrect = CGRectMake(msg_rect.origin.x , msg_rect.origin.y, msg_rect.size.width, msg_rect.size.height - arrow_rect.size.height);
    
    //设置箭头的位置
    CGFloat arrowX = arrow_rect.origin.x;
    CGFloat arrowWidth = arrow_rect.size.width;
    CGFloat arrowHeight = arrow_rect.size.height;
    
    CGFloat minx =CGRectGetMinX(rrect), midx =CGRectGetMidX(rrect), maxx =CGRectGetMaxX(rrect);
    CGFloat miny =CGRectGetMinY(rrect), midy =CGRectGetMidY(rrect), maxy =CGRectGetMaxY(rrect);
    
    // 画一下小箭头
    CGContextMoveToPoint(context, arrowX+arrowWidth, maxy);
    CGContextAddLineToPoint(context,arrowX, maxy+arrowHeight);
    CGContextAddLineToPoint(context,arrowX, maxy);
    //添加四个角的圆角弧度
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, arc_radius);//左下
    CGContextAddArcToPoint(context, minx, miny, midx, miny, arc_radius);//左上
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, arc_radius);//右上
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, arc_radius);//右下
    //结束绘制
    CGContextClosePath(context);//完成整个path
    CGContextFillPath(context);//把整个path内部填充
    
    CGPoint aPoints[2];
    aPoints[0] = CGPointMake(65, msg_rect.origin.y + 30);
    aPoints[1] = CGPointMake(245, msg_rect.origin.y + 30);
    CGContextSetStrokeColorWithColor (context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 1);
    CGContextAddLines(context, aPoints, 2);
    CGContextDrawPath(context, kCGPathStroke);
    
}

@end
