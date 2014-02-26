//
//  SNLoginViewController.m
//  WanDaLive
//
//  Created by David Yang on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNLoginViewController.h"
#import "SNTopModel.h"
#import "TMToast.h"
#import "URLManager.h"
#import "KeyDefine.h"
#import "SBJson.h"
#import "SensoroAnswer.h"
#import "SNGlobalTrigger.h"
#import "SNWebViewController.h"
#import "SNAppDelegate.h"
@interface SNLoginViewController ()

@property (nonatomic,strong) SNRequest * loginRequest;
@property (nonatomic,strong) SNRequest * registerRequest;
@property (nonatomic,strong) SNRequest * shopsRequest;

@property (nonatomic,strong) SNRequest * creditsIncrRequest;

@end

@implementation SNLoginViewController

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
//    NSUserDefaults *local = [NSUserDefaults standardUserDefaults];
    NSString *url;
    SNAppDelegate *appDelegate = (SNAppDelegate*)[[UIApplication sharedApplication] delegate];
    if ([[appDelegate.localNotifURL objectForKey:@"hasUrl"] isEqualToString:@"yes"]) {
        url = [appDelegate.localNotifURL objectForKey:@"url"];
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SNWebViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"shopInfoController"];
        controller.url = url;
        [self presentViewController:controller animated:YES completion:nil];
        
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
    }
    [self sendShopsRequest];
    
    
//    self.creditsIncrRequest =
//    [SNRequest getPutRequestWithParams:nil
//                              delegate:self
//                            requestURL:[URLManager creditsIncr:@"123"
//                                                        shopID:@"1"]];
//    [self.creditsIncrRequest connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginAction:(id)sender {
    
    if (self.userID.text.length == 0 ||
        self.userName.text.length == 0) {
        [TMToast showToastWithText:@"用户昵称和手机号码不能为空"];
        return;
    }
    [self sendLoginRequest];
//    [self performSegueWithIdentifier:@"login" sender:nil];
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    if (textField == self.userName) {
        [self.userID becomeFirstResponder];
    }else if(textField == self.userID){
        [self loginAction:self.userID];
    }
    
//    [self performSegueWithIdentifier:@"login" sender:nil];
    [self sendLoginRequest];
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    
}
- (IBAction)ViewTouchDown:(id)sender {
    // 发送resignFirstResponder.
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{ //当点触textField内部，开始编辑都会调用这个方法。textField将成为first responder
    
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y -=56;
    frame.size.height +=56;
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView"context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y +=56;
    frame.size. height -=56;
    self.view.frame = frame;
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView"context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

- (void) sendLoginRequest{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.userID.text,PHONE_KEY,
                                   @"1234",PASSWORD_KEY,
                                   nil];
    self.loginRequest = [SNRequest getPostRequestWithParams:params
                                                   delegate:self
                                                   requestURL:[URLManager loginURL]];
    [self.loginRequest connect];
}

- (void) sendRegisterRequest{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    self.userName.text,NAME_KEY,
                                    self.userID.text,PHONE_KEY,
                                    @"1234",PASSWORD_KEY,
                                    nil];
    self.registerRequest = [SNRequest getPostRequestWithParams:params
                                                  delegate:self
                                             requestURL:[URLManager registerNewURL]];
    [self.registerRequest connect];
}

- (void) sendShopsRequest{
    NSMutableDictionary * params = nil;
    self.shopsRequest = [SNRequest getRequestWithParams:params
                                                   delegate:self
                                                 requestURL:[URLManager shopsURL]];
    [self.shopsRequest connect];
}

#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    if (self.loginRequest == request) {
        self.loginRequest = nil;
        NSString* responseString = [[NSString alloc] initWithData:request.responseData
                                                         encoding:NSUTF8StringEncoding];
        //SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
        SBJsonParser *jsonParser = [SBJsonParser new];
        id result = [jsonParser objectWithString:responseString];
        if (result) {
            NSDictionary * errDetail = [result objectForKey:@"error"];
            NSString * err = [errDetail objectForKey:@"user"];
            if ([err isEqualToString:@"not_exist"]) {
                [self sendRegisterRequest];
            }
        }else{
            [TMToast showToastWithText:@"登录失败"];
            NSLog(@"登录失败");
        }
    }else if(self.registerRequest == request){
        self.registerRequest = nil;
        [TMToast showToastWithText:@"登录失败"];
        NSLog(@"登录失败");
    }else if(self.shopsRequest == request){
        self.shopsRequest = nil;
        [TMToast showToastWithText:@"商店信息取得失败"];
        NSLog(@"商店信息取得失败");
    }else if(self.creditsIncrRequest == request){
        NSLog(@"区分信息失败");
    }
}

- (void)request:(SNRequest *)request didLoad:(id)result
{
    if (self.loginRequest == request) {
        self.loginRequest = nil;
        
        [[SNTopModel sharedInstance] initUserInfo:nil];
        [SNTopModel sharedInstance].userInfo.userID = self.userID.text;
        [SNTopModel sharedInstance].userInfo.userName = self.userName.text;
        
        [self performSegueWithIdentifier:@"login" sender:nil];

        [[SensoroAnswer sharedInstance] startService];
        //开始使用GlobalTrigger监测Beacon，beacon默认都进行监测。
        [[SNGlobalTrigger sharedInstance] startWatcherBeacon];
    }else if(self.registerRequest == request){
        self.registerRequest = nil;
        [self sendLoginRequest];
    }else if(self.shopsRequest == request){
        self.shopsRequest = nil;
        NSArray * array = result;
        [[SNTopModel sharedInstance] initShopsFromServer:array];
    }else if(self.creditsIncrRequest == request){
        NSLog(@"%@",result);
    }
}
@end
