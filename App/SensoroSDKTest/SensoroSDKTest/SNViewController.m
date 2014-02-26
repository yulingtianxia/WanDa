//
//  SNViewController.m
//  SensoroSDKTest
//
//  Created by David Yang on 13-11-21.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNViewController.h"
#import "SNGlobalTrigger.h"

@interface SNViewController ()

@end

@implementation SNViewController
@synthesize discountBtn;
@synthesize taskBtn;
@synthesize newdiscountImg;
@synthesize newtaskImg;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
//    CGFloat round = 45;
//    self.usrImage.layer.cornerRadius = round;
//    self.usrImage.layer.masksToBounds = YES;
//    self.usrImage.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.usrImage.layer.borderWidth = 5.0;
    newdiscountImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"WDapp-icon_0000_new"]];
    [newdiscountImg setFrame:CGRectMake(100, 0, 30, 30)];
    [discountBtn addSubview:newdiscountImg];
    newtaskImg = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"WDapp-icon_0000_new"]];
    [newtaskImg setFrame:CGRectMake(100, 0, 30, 30)];
    [taskBtn addSubview:newtaskImg];
    [SNMessageManager sharedInstance].watcher = self;
    newtaskImg.alpha=0.0;
    newdiscountImg.alpha=0.0;
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([SNMessageManager sharedInstance].newCouponCount == 0) {
        newdiscountImg.alpha=0.0;
    }else{
        newdiscountImg.alpha=1.0;
    }
    
    if ([SNMessageManager sharedInstance].newMessageCount == 0) {
        newtaskImg.alpha=0.0;
    }else{
        newtaskImg.alpha=1.0;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)discountAction:(id)sender {
    [self performSegueWithIdentifier:@"showDiscount" sender:sender];
}

- (IBAction)personInfoAction:(id)sender {
    [self performSegueWithIdentifier:@"showPersonInfo" sender:sender];
}

- (IBAction)goldCornerAction:(id)sender {
    [self performSegueWithIdentifier:@"showGoldCorner" sender:sender];
}

- (IBAction)messageAction:(id)sender {
    [self performSegueWithIdentifier:@"showMessage" sender:sender];
}

- (IBAction)movableGoldCorner:(id)sender {
    [self performSegueWithIdentifier:@"showMovableGoldCorner" sender:sender];
}

- (IBAction)taskAction:(id)sender {
    [self performSegueWithIdentifier:@"showTask" sender:sender];
}
#pragma mark NewMessageTrigger

- (void)hasNewMessage{
    newtaskImg.alpha = 1.0;
}

- (void)hasNewCoupon{
    
    newdiscountImg.alpha=1.0;
}
@end
