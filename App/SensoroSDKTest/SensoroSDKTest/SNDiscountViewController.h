//
//  SNDiscountViewController.h
//  WanDaLive
//
//  Created by David Yang on 13-11-25.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
#import "SNGlobalTrigger.h"
#import "SNSensorModel.h"

@interface SNDiscountViewController : UIViewController <RequestDelegate,SNBusinessTrigger>

- (IBAction)backToPrev:(id)sender;

@property (weak, nonatomic) IBOutlet UITableView *couponTableView;

@end