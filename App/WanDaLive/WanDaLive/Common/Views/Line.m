//
//  Line.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-19.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "Line.h"

@implementation Line
@synthesize start;
@synthesize stop;
@synthesize color;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    // Drawing code
    if (color==Nil) {
        [[UIColor orangeColor] setStroke];
        //        NSLog(@"colornil");
    }
    else [self.color setStroke];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context,start.x,start.y);
    CGContextAddLineToPoint(context,stop.x,stop.y);
    CGContextSetLineWidth(context,0.5);
    CGContextStrokePath(context);
}

@end
