//
//  CollectionCell.m
//  WanDaLive
//
//  Created by 汪卓民 on 13-12-5.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "CollectionCell.h"

@implementation CollectionCell
@synthesize ShopLogo;
@synthesize ShopName;
@synthesize grayview;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        grayview =[[Circle alloc]initWithFrame:self.frame];
        grayview.color=[UIColor grayColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        ShopLogo.placeholderImage=[UIImage imageNamed:@"WDapp-icon_0000s_0000_logo2"];
        grayview =[[Circle alloc]initWithFrame:self.frame];
        grayview.color=[UIColor grayColor];
    }
    return self;
}

-(UIImage*)GrayImage:(UIImage*)sourceImage
{
    int width = sourceImage.size.width;
    int height = sourceImage.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,width,height,8,0,colorSpace,kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL) {
        return nil;
    }
    CGContextDrawImage(context,CGRectMake(0, 0, width, height), sourceImage.CGImage);
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    return grayImage;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
