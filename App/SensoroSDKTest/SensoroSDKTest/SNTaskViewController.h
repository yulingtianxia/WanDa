//
//  SNTaskViewController.h
//  WanDaLive
//
//  Created by David Yang on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
#import "SNGlobalTrigger.h"
#import "EGOImageView.h"
@class TaskTitleView;

@interface SNTaskViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate,RequestDelegate,SNBusinessTrigger,EGOImageViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *ShopCollection;
@property (strong, nonatomic) IBOutlet TaskTitleView *TitleView;
@property (strong, nonatomic) NSString *TitleString;
@property (strong, nonatomic) SNRequest *HuntTreasureRequest;
@property (strong, nonatomic) SNRequest *HuntProgressRequest;
@property (strong, nonatomic) NSMutableArray *HuntRuleShops;
@property (strong, nonatomic) NSMutableArray *ShopLogos;

- (IBAction)backToPrev:(id)sender;
- (void)imageViewLoadedImage:(EGOImageView*)imageView;

@end
