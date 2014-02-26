//
//  SNHuntTreasureViewController.h
//  WanDaLive
//
//  Created by 森哲 on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "SNRequest.h"
#import "SNGlobalTrigger.h"
#import "ImageMaskView.h"
#import "Circle.h"
#define PAGENUM 4
@class STScratchView;
@interface SNHuntTreasureViewController : UIViewController<UIScrollViewDelegate,RequestDelegate,SNBusinessTrigger,EGOImageViewDelegate,ImageMaskFilledDelegate>

@property (strong, nonatomic) IBOutlet ImageMaskView *scratchImage;
@property
(strong, nonatomic) IBOutlet UIPageControl *page;

@property
(strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet EGOImageView *shopLogo1;
@property (strong, nonatomic) IBOutlet EGOImageView *shopLogo2;
@property (strong, nonatomic) IBOutlet EGOImageView *shopLogo3;
@property (strong, nonatomic) IBOutlet EGOImageView *shopLogo4;
@property (strong, nonatomic) IBOutlet EGOImageView *shopLogo5;
@property (strong, nonatomic) IBOutlet Circle *grayLogo1;
@property (strong, nonatomic) IBOutlet Circle *grayLogo2;
@property (strong, nonatomic) IBOutlet Circle *grayLogo3;
@property (strong, nonatomic) IBOutlet Circle *grayLogo4;
@property (strong, nonatomic) IBOutlet Circle *grayLogo5;
@property (strong, nonatomic) SNRequest *HuntTreasureRequest;
@property (strong, nonatomic) SNRequest *HuntProgressRequest;
@property (strong, nonatomic) NSMutableArray *HuntRuleShops;
@property (strong, nonatomic) NSMutableArray *ShopLogos;
@property (strong, nonatomic) IBOutlet UILabel *HintLabel;
@property NSInteger timeCount;

- (IBAction)backToPrev:(id)sender;
- (void)imageViewLoadedImage:(EGOImageView*)imageView;
@end
