//
//  Circle.m
//  NumberScrollTest
//
//  Created by 汪卓民 on 13-12-2.
//  Copyright (c) 2013年 sensoro. All rights reserved.
//

#import "Circle.h"

@implementation Circle
@synthesize color;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
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
        [[UIColor whiteColor] setFill];
//        NSLog(@"colornil");
    }
    else [self.color setFill];
//    NSLog(@"color:%@",color);

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextFillEllipseInRect(context, rect);

}


@end
