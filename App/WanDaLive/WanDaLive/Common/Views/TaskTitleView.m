//
//  TaskTitleView.m
//  WanDaLive
//
//  Created by 汪卓民 on 13-12-5.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "TaskTitleView.h"
#define offsetY 10
@implementation TaskTitleView
@synthesize color;
@synthesize radius;
@synthesize title;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    self.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    
    if (color==Nil) {
        [[UIColor colorWithRed:(132.0/255.0) green:(121.0/255.0) blue:(196.0/255.0) alpha:1.0] setFill];
        //        NSLog(@"colornil");
    }
    else [self.color setFill];
    //    NSLog(@"color:%@",color);
//    radius = 20.0;
     
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1);
    CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
    CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
    CGContextMoveToPoint(context, minx, midy);
    CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
    CGContextClosePath(context);
    CGContextDrawPath(context, kCGPathFill);
    if (title==nil) {
        title=[[NSMutableAttributedString alloc] initWithString:@"this is test!"];
    }
    else{
        
        [title drawInRect:CGRectMake(rect.origin.x, rect.origin.y+offsetY, rect.size.width, rect.size.height-offsetY)];
    }
}


@end
