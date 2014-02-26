//
//  SNMovableGoldCornerController.h
//  WanDaLive
//
//  Created by David Yang on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNGlobalTrigger.h"

@interface SNMovableGoldCornerController : UIViewController <RequestDelegate,SNBusinessTrigger>

@property (weak, nonatomic) IBOutlet UILabel *cornerTip;

- (IBAction)backToPrev:(id)sender;

@end
