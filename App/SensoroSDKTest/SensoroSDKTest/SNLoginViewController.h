//
//  SNLoginViewController.h
//  WanDaLive
//
//  Created by David Yang on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"

@interface SNLoginViewController : UIViewController <UITextFieldDelegate,RequestDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userID;

@property (weak, nonatomic) IBOutlet UITextField *userName;
- (IBAction)loginAction:(id)sender;
@end
