//
//  SNPersonInfoViewController.m
//  WanDaLive
//
//  Created by David Yang on 13-11-25.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNPersonInfoViewController.h"
#import "Circle.h"
#import "Credit.h"
#import "SNRequest.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "SNMessageManager.h"
#import "SNWeiboAlert.h"

#define radius 0.8
#define Yoffset 0.18
#define CreditHeight 100
#define payTFHeight 30
#define payBtHeight 35

@interface SNPersonInfoViewController () <CustomIOS7AlertViewDelegate>

@end

@implementation SNPersonInfoViewController
@synthesize credit;
@synthesize bottomcredit;
@synthesize circle;
@synthesize bottomcircle;
@synthesize payScoreBt;
@synthesize ChangeToPayModeBt;
@synthesize payScoreTF;
@synthesize fetchCreditsRequest;
@synthesize delCreditsRequest;
CGRect payBtFrame;
CGRect payTFFrame;
double newscore;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //设置支付积分输入框代理
    payScoreTF.delegate = self;
    //设置SNTriggerDelegate
    [[SNGlobalTrigger sharedInstance] addObserver:self];
    //获取设备分辨率
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    //    NSLog(@"%f,%f",size_screen.height,size_screen.width);
    [self.view setBackgroundColor:[UIColor colorWithRed:(223.0/255.0)green:(242.0/255.0) blue:(248.0/255.0) alpha:1.0]];
    CGRect circleFrame = CGRectMake(size_screen.width*(1-radius)/2, size_screen.height*Yoffset, size_screen.width*(radius), size_screen.width*(radius));
    CGRect creditFrame = CGRectMake(size_screen.width*(1-radius)/2, circleFrame.size.height/2+circleFrame.origin.y-CreditHeight/2, size_screen.width*(radius), CreditHeight);
    payTFFrame = CGRectMake(size_screen.width*(1-radius/2)/2, circleFrame.size.height*3/4+circleFrame.origin.y-payTFHeight/2, size_screen.width*(radius)/2, payTFHeight);
    payBtFrame = CGRectMake((size_screen.width-payBtHeight)/2, circleFrame.origin.y+circleFrame.size.height-payBtHeight/2, payBtHeight, payBtHeight);
//    CGRect payBtFrame = CGRectMake((size_screen.width-payBtHeight)/2, payTFFrame.origin.y+payTFFrame.size.height,payBtHeight, payBtHeight);
    //Circle
    circle = [[Circle alloc] initWithFrame:circleFrame];
    circle.color = [UIColor colorWithRed:(132.0/255.0) green:(212.0/255.0) blue:(232.0/255.0) alpha:1.0];
    
    [self.view insertSubview: circle atIndex:1];
    bottomcircle = [[Circle alloc] initWithFrame:circleFrame];
    bottomcircle.color = [UIColor whiteColor];
    [self.view insertSubview:bottomcircle atIndex:0];
    //Credit
    credit = [[Credit alloc]initWithFrame:creditFrame];
    [self.view insertSubview:credit atIndex:3];
    bottomcredit = [[Credit alloc]initWithFrame:creditFrame];
    bottomcredit.textColor=[UIColor colorWithRed:(132.0/255.0) green:(212.0/255.0) blue:(232.0/255.0) alpha:1.0];
    [self.view insertSubview:bottomcredit atIndex:2];
    //积分文本输入框和支付按钮
    
    payScoreTF = [[UITextField alloc]initWithFrame:payTFFrame];
    [payScoreTF setTextColor:[UIColor colorWithRed:(135.0/255.0) green:(211.0/255.0) blue:(233.0/255.0) alpha:1.0]];
    payScoreTF.placeholder =@"请输入积分";
    [payScoreTF setBorderStyle:UITextBorderStyleRoundedRect];
    [payScoreTF setReturnKeyType:UIReturnKeyDone];
    [payScoreTF setDelegate:self];
    [payScoreTF setAlpha:0.0];
    [payScoreTF setKeyboardType:UIKeyboardTypeDecimalPad];
    [payScoreTF setReturnKeyType:UIReturnKeyDone];
    [payScoreTF setTextAlignment:NSTextAlignmentCenter];
    [self.view insertSubview:payScoreTF atIndex:4];
    payScoreBt = [[UIButton alloc]initWithFrame:payBtFrame];
    [payScoreBt setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [payScoreBt addTarget:self action:@selector(payScore:) forControlEvents:UIControlEventTouchUpInside];
    [payScoreBt setAlpha:0.0];
    [self.view insertSubview:payScoreBt atIndex:4];
    
    //获取上一次的用户积分
    [self refreshCredits];
    //获取当前积分
    NSString *uid=[SNTopModel sharedInstance].userInfo.userID;
    fetchCreditsRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchCredits:uid]];
    [fetchCreditsRequest connect];
    //保存当前用户积分到本地
    [self saveUserScore:newscore];
}

-(void)viewWillAppear:(BOOL)animated{
    //判断用户是否进入支付beacon，决定是否显示支付按钮
    if ([SNGlobalTrigger sharedInstance].isInVerifyArea == YES) {
        ChangeToPayModeBt.enabled = YES;
        ChangeToPayModeBt.alpha=1.0;
    }
    else{
        ChangeToPayModeBt.enabled = NO;
        ChangeToPayModeBt.alpha = 0.0;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [[SNGlobalTrigger sharedInstance] removeObserver:self];
}

-(void) saveUserScore:(double) newscore{
    NSUserDefaults *userscore = [NSUserDefaults standardUserDefaults];
    [userscore setDouble:newscore forKey:@"userscore"];
    [userscore synchronize];
    [SNTopModel sharedInstance].userInfo.credits=newscore;
}

-(double)UserScore{
    NSUserDefaults *userscore = [NSUserDefaults standardUserDefaults];
    return [userscore doubleForKey:@"userscore"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeToPayView{
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        circle.alpha=0.0;
        credit.alpha=0.0;
        payScoreTF.alpha=1.0;
        payScoreBt.alpha=1.0;
        payScoreBt.frame =payBtFrame;
        payScoreTF.frame = payTFFrame;
        payScoreTF.placeholder =@"请输入积分";
        [payScoreTF setText:@""];
    } completion:^(BOOL finished) {
        //可以消费积分啦
    }];
}

-(void)changeToViewScore{
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        circle.alpha=1.0;
        credit.alpha=1.0;
        payScoreTF.alpha=0.0;
        payScoreBt.alpha=0.0;
        payScoreBt.frame =payBtFrame;
        payScoreTF.frame = payTFFrame;
    } completion:^(BOOL finished) {
        //
    }];
}

- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

//- (IBAction)shareScore:(id)sender {
//    UIAlertView *alertForCancel = [[UIAlertView alloc] initWithTitle: @"Reason for Cancel:"
//                                                             message: @"\n\n\n\n\n"
//                                                            delegate: self
//                                                   cancelButtonTitle: @"OK"
//                                                   otherButtonTitles: @"Cancel",nil];
//    UITextView *textView = [[UITextView alloc] initWithFrame: CGRectMake(12.0, 60, 260.0, 112.0)];
//    textView.font = [UIFont boldSystemFontOfSize:15];
//    textView.layer.cornerRadius = 6;
//    textView.layer.masksToBounds = YES;
//    [alertForCancel setTransform: CGAffineTransformMakeTranslation(0.0, -100)];
//    [alertForCancel addSubview: textView];
//    [alertForCancel show];
//    
//    UITextView *textView = [[UITextView alloc]initWithFrame:CGRectMake(12, 0, 260, 200)];
//    textView.editable = YES;
//    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"Type Your Message" message:@"\n\n\n\n\n\n" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",nil];
//    [av setAlertViewStyle:UIAlertViewStylePlainTextInput];
//    [[av textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
//    [av show];
//}

- (IBAction)changeToPayScore:(id)sender{
    [self changeToPayView];
    
}

- (void) refreshCredits{
    [credit changeFromNumber:[self UserScore] toNumber:newscore withAnimationTime:10];
    [credit autochangeFontsize:credit.text.doubleValue];
    [bottomcredit changeFromNumber:[self UserScore] toNumber:newscore withAnimationTime:10];
    [bottomcredit autochangeFontsize:credit.text.doubleValue];
}

- (void) sendMessage{
    
}

- (IBAction)payScore:(id)sender{
    NSString *uid=[SNTopModel sharedInstance].uid;
    //sid从哪获得？
    NSString *sid;
    if ([SNGlobalTrigger sharedInstance].isInVerifyArea) {
        sid = [SNGlobalTrigger sharedInstance].verifySID;
    }
    
    delCreditsRequest = [SNRequest getDeleteRequestWithParams:[NSMutableDictionary dictionaryWithObject:payScoreTF.text forKey:@"credits"] delegate:self requestURL:[URLManager delCredits:uid withsid:sid]];
    [delCreditsRequest connect];
//    fetchCreditsRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchCredits:uid]];
//    [fetchCreditsRequest connect];
    [self refreshCredits];
    [self changeToViewScore];
    [self.view setNeedsDisplay];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
}
#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didLoad:(id)result //TODOS
{
    
    if(result!=NULL&&request == fetchCreditsRequest){
        if ([result objectForKey:@"credits"]!=[NSNull null]) {
            newscore = [[result objectForKey:@"credits"] doubleValue] ;
        }
        [self refreshCredits];
    }
    if (result!=NULL&&request == delCreditsRequest) {
        NSLog(@"%@",result);
        if ([result objectForKey:@"credits"]!=[NSNull null]) {
            newscore = [[result objectForKey:@"credits"] doubleValue] ;
        }
        [self refreshCredits];
        
        //[[SNMessageManager sharedInstance] updateMessageNumber:1];
    }
    
    [self.view setNeedsDisplay];
}

#pragma mark UITextFieldDelegate
- (IBAction)ViewTouchDown:(id)sender {
    // 发送resignFirstResponder.

    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{ //当点触textField内部，开始编辑都会调用这个方法。textField将成为first responder

        NSTimeInterval animationDuration = 0.30f;
        CGRect frame = self.view.frame;
        frame.origin.y -=116;
        frame.size.height +=116;
        self.view.frame = frame;
        [UIView beginAnimations:@"ResizeView"context:nil];
        [UIView setAnimationDuration:animationDuration];
        self.view.frame = frame;
        [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y +=116;
    frame.size. height -=116;
    self.view.frame = frame;
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView"context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark SNTriggerDelegate

-(void)enterVerifyArea:(NSString *)sid{
    ChangeToPayModeBt.enabled = YES;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseInOut animations:^{
        ChangeToPayModeBt.alpha=1.0;
    } completion:^(BOOL finished) {
        ;
    }];
}

-(void)leaveVerifyArea{
    ChangeToPayModeBt.enabled = NO;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseInOut animations:^{
        ChangeToPayModeBt.alpha=0.0;
    } completion:^(BOOL finished) {
        ;
    }];
}

#pragma mark UIAlertViewDelegate
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex != alertView.cancelButtonIndex) {
//        // UIAlertViewStylePlainTextInput will only ever have a single field at index 0
//        UITextField * field = [alertView textFieldAtIndex:0];
//        
//        Weibo *weibo = [[Weibo alloc] initWithAppKey:@"3326691039" withAppSecret:@"75dd27596a081b28651d214e246c1b15"];
//        [Weibo setWeibo:weibo];
//        // Override point for customization after application launch.
//        
//        if (weibo.isAuthenticated) {
//            [weibo newStatus:field.text pic:nil completed:^(Status *status, NSError *error) {
//                if (error) {
//                    NSLog(@"failed to post:%@", error);
//                }
//                else {
//                    NSLog(@"success: %lld.%@", status.statusId, status.text);
//                }
//            }];
//        }else{
//            [Weibo.weibo authorizeWithCompleted:^(WeiboAccount *account, NSError *error) {
//                if (!error) {
//                    NSLog(@"Sign in successful: %@", account.user.screenName);
//                    [weibo newStatus:field.text pic:nil completed:^(Status *status, NSError *error) {
//                        if (error) {
//                            NSLog(@"failed to post:%@", error);
//                        }
//                        else {
//                            NSLog(@"success: %lld.%@", status.statusId, status.text);
//                        }
//                    }];
//                }
//                else {
//                    NSLog(@"Failed to sign in: %@", error);
//                }
//            }];
//        }
//    } else {
//        // this is where you would handle any actions for "Cancel"
//    }
//}

#pragma mark CustomIOS7AlertView

- (IBAction)shareScore:(id)sender
{
    // Here we need to pass a full frame
    SNWeiboAlert *alertView = [[SNWeiboAlert alloc] init];
    alertView.delegate = self;
    [alertView setUpWeiboAlert];
    
    // And launch the dialog
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
//    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
//    [alertView close];
}

- (UIView *)createDemoView
{
    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 290, 200)];
    [tv setKeyboardType:UIKeyboardTypeDefault];
    tv.layer.borderColor = [UIColor clearColor].CGColor;
    tv.layer.borderWidth =1.0;
    tv.layer.cornerRadius =5.0;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return tv;
}
@end
