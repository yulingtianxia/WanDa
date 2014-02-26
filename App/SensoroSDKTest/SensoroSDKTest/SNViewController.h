//
//  SNViewController.h
//  SensoroSDKTest
//
//  Created by David Yang on 13-11-21.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNMessageManager.h"
@interface SNViewController : UIViewController<SNMessageTrigger>

@property (weak, nonatomic) IBOutlet UIImageView *usrImage;
@property (strong, nonatomic) IBOutlet UIButton *discountBtn;
@property (strong, nonatomic) IBOutlet UIButton *taskBtn;
@property (strong, nonatomic) IBOutlet UIImageView *newdiscountImg;
@property (strong, nonatomic) IBOutlet UIImageView *newtaskImg;

- (IBAction)discountAction:(id)sender;
- (IBAction)personInfoAction:(id)sender;
- (IBAction)goldCornerAction:(id)sender;
- (IBAction)messageAction:(id)sender;
- (IBAction)movableGoldCorner:(id)sender;
- (IBAction)taskAction:(id)sender;

@end
