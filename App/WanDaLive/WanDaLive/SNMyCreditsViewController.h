//
//  SNMyCreditsViewController.h
//  WanDaLive
//
//  Created by 森哲 on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
#import "SNGlobalTrigger.h"
@class Credit;
@class Circle;
@class SNRequest;
@interface SNMyCreditsViewController : UIViewController<UITextFieldDelegate,RequestDelegate,SNBusinessTrigger,UIAlertViewDelegate>

@property (strong,nonatomic) IBOutlet Credit *credit;
@property (strong,nonatomic) IBOutlet Credit *bottomcredit;
@property (strong,nonatomic) IBOutlet Circle *circle;
@property (strong,nonatomic) IBOutlet Circle *bottomcircle;
@property (strong, nonatomic) IBOutlet UIButton *shareScoreBt;
@property (strong,nonatomic) IBOutlet UITextField *payScoreTF;
@property (strong,nonatomic) IBOutlet UIButton *payScoreBt;
@property (strong, nonatomic) IBOutlet UIButton *ChangeToPayModeBt;
@property (strong,nonatomic) IBOutlet UILabel *CurCreditLabel;
@property (strong,nonatomic) IBOutlet UILabel *UseCreditGuideLabel;
@property (nonatomic,strong) SNRequest * fetchCreditsRequest;
@property (nonatomic,strong) SNRequest * delCreditsRequest;
//Credits Table
@property (weak, nonatomic) IBOutlet UITableView *myCreditsTable;



- (IBAction)backToPrev:(id)sender;
- (IBAction)shareScore:(id)sender;
- (IBAction)changeToPayScore:(id)sender;
- (IBAction)payScore:(id)sender;
- (IBAction)ViewTouchDown:(id)sender;

@end
