//
//  SNGoldCornerViewController.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
#import "SNGlobalTrigger.h"

@interface SNGoldCornerViewController : UIViewController <RequestDelegate, SNBusinessTrigger>

- (IBAction)backToPrev:(id)sender;

@property (weak, nonatomic) IBOutlet UILabel *goldTip;
@property (weak, nonatomic) IBOutlet UIImageView *goldImage;

@end
