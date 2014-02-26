//
//  SNDiscountViewController.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
#import "SNGlobalTrigger.h"
#import "SNSensorModel.h"

@interface SNDiscountViewController : UIViewController<RequestDelegate,SNBusinessTrigger>
- (IBAction)backToPrev:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *couponTableView;
@end