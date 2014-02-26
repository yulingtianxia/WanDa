//
//  SNBindingViewController.h
//  WanDaLive
//
//  Created by 森哲 on 13-12-17.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
@interface SNBindingViewController : UIViewController<RequestDelegate>
@property (strong,nonatomic) SNRequest *bindingAccountRequest;
- (IBAction)backToPrev:(id)sender;
- (IBAction)bindingToWeibo:(id)sender;
@end
