//
//  SNMovableGoldCornerViewController.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNGlobalTrigger.h"
#define PAGENUM 4
@interface SNMovableGoldCornerController : UIViewController <RequestDelegate,SNBusinessTrigger,UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *cornerTip;
@property (strong, nonatomic) IBOutlet UIImageView *TargetImage;
@property (strong, nonatomic) IBOutlet UIScrollView *imageScrollView;
@property (strong, nonatomic) IBOutlet UIPageControl *page;
@property NSInteger timeCount;
- (IBAction)backToPrev:(id)sender;

@end