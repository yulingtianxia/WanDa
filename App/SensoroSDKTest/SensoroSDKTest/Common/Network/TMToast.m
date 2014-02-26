//
//  TMToast.m
//  TrackMaster
//
//  Created by Tony Tang on 11-9-15.
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "TMToast.h"


@implementation TMToast

+ (TMToast *)createWithText:(NSString *)text {
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    float x = 10.0f;
    float width = screenWidth - 2*x;
    
    UILabel *textLabel = [[UILabel alloc] init];
	textLabel.backgroundColor = [UIColor clearColor];
	textLabel.textAlignment = NSTextAlignmentCenter;
    textLabel.font = [UIFont systemFontOfSize:14];
	textLabel.textColor = [UIColor colorWithWhite:1.0 alpha:1.0];
	textLabel.numberOfLines = 0;
	textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    CGRect rc = [text boundingRectWithSize:CGSizeMake(width - 20.0f, 9999.0f)
                                   options:NSStringDrawingUsesLineFragmentOrigin
                                attributes:@{NSFontAttributeName:textLabel.font}
                                   context:nil];
    CGSize sz = rc.size;
    
    CGRect tmpRect;
    tmpRect.size.width = MAX(sz.width + 20, 38.0);
    tmpRect.size.height = MAX(sz.height + 20.0, 38.0);
    tmpRect.origin.x = floor((screenWidth - tmpRect.size.width) / 2.0);
    tmpRect.origin.y = floor((screenHeight - tmpRect.size.height - 15.0) / 2.0);
    
    TMToast *toast = [[TMToast alloc] initWithFrame:tmpRect];
    toast.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
    CALayer *layer = toast.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 5.0f;
    
    textLabel.text = text;
	tmpRect.origin.x = floor((toast.frame.size.width - sz.width) / 2.0f);
	tmpRect.origin.y = floor((toast.frame.size.height - sz.height) / 2.0f);
	tmpRect.size = sz;
	textLabel.frame = tmpRect;
    
    UIInterfaceOrientation orientation = (UIInterfaceOrientation)[[UIApplication sharedApplication] statusBarOrientation];
	switch (orientation) {
		case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationPortraitUpsideDown:
        {
            toast.transform = CGAffineTransformMakeRotation(M_PI);
            break;
        }
        case UIDeviceOrientationLandscapeLeft:
        {
            toast.transform = CGAffineTransformMakeRotation(M_PI/2); //rotation in radians
            break;
        }
        case UIDeviceOrientationLandscapeRight:
        {
            toast.transform = CGAffineTransformMakeRotation(-M_PI/2); //rotation in radians
            break;
        }
        default:
            break;
    }
	[toast addSubview:textLabel];
    
	toast.alpha = 0.0f;
    
    return toast;
}

- (void)_hide {
    [UIView animateWithDuration:0.8 animations:^(void) {
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)hide {
    [self performSelectorOnMainThread:@selector(_hide) withObject:nil waitUntilDone:NO];
}

- (void)show {
    [UIView animateWithDuration:0.6 animations:^(void) {
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(hide) userInfo:nil repeats:NO];
    }];
}

+ (void)showToastWithText:(NSString *)text {
    TMToast *toast = [TMToast createWithText:text];
    UIWindow *mainWindow = [[UIApplication sharedApplication] keyWindow];
    [mainWindow addSubview:toast];
    
    [toast show];
}

@end
