//
//  SNCouponCellBg.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-6.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNCouponCellBg.h"

@implementation SNCouponCellBg

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setTitleColor:(CGColorRef)color
{
    _title_color = color;
}

- (void)drawRect:(CGRect)rect
{
    [self drawMsgBackground];
}
-(void)drawMsgBackground
{
    // Drawing code
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, _bg_color);//cell的背景色
    CGContextFillRect(context,self.bounds);//填充背景色
    
    //------------title部分------------
    CGContextSetFillColorWithColor(context, _title_color);//填充色
    CGFloat minx =CGRectGetMinX(_title_rect), midx =CGRectGetMidX(_title_rect), maxx =CGRectGetMaxX(_title_rect);
    CGFloat miny =CGRectGetMinY(_title_rect), midy =CGRectGetMidY(_title_rect), maxy =CGRectGetMaxY(_title_rect);
    //绘制Rect 只有上面两个角是圆角
    CGContextMoveToPoint(context, maxx, maxy);//右下开始
    CGContextAddLineToPoint(context,minx, maxy);//左下
    CGContextAddArcToPoint(context, minx, miny, midx, miny, _arc_radius);//左上
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, _arc_radius);//右上
    //结束绘制
    CGContextClosePath(context);//完成整个path
    CGContextFillPath(context);//把整个path内部填充
    //------------title部分绘制结束------------
    //------------content部分------------
    CGContextSetFillColorWithColor(context, _content_color);//填充色
    
    //计算content的Rect
    CGFloat content_x = _coupon_rect.origin.x;
    CGFloat content_y = _coupon_rect.origin.y + _title_rect.size.height;
    CGFloat content_width = _coupon_rect.size.width;
    CGFloat content_height = _coupon_rect.size.height - _title_rect.size.height;
    CGRect content_rect = CGRectMake(content_x, content_y, content_width, content_height);
    minx =CGRectGetMinX(content_rect), midx =CGRectGetMidX(content_rect), maxx =CGRectGetMaxX(content_rect);
    miny =CGRectGetMinY(content_rect), midy =CGRectGetMidY(content_rect), maxy =CGRectGetMaxY(content_rect);
    //绘制Rect 只有上面两个角是圆角
    CGContextMoveToPoint(context, minx, miny);//左上
    CGContextAddLineToPoint(context,maxx, miny);//右上
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, _arc_radius);//右下
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, _arc_radius);//左下
    //结束绘制
    CGContextClosePath(context);//完成整个path
    CGContextFillPath(context);//把整个path内部填充
    //------------content部分绘制结束------------
    
    CGRect mask_rect = CGRectMake(content_x, content_y, content_width , 2.5);
    CGImageRef mask = [UIImage imageNamed:@"mask.png"].CGImage;
    CGContextClipToMask(context, mask_rect, mask);
    CGContextSetFillColorWithColor(context, _title_color);
    CGContextFillRect(context, mask_rect);
    
}
@end