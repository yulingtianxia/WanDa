//
//  SNWeiboAlert.m
//  SensoroLive
//
//  Created by Jarvis on 13-12-24.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNWeiboAlert.h"
#import "Weibo.h"
#import "KeyDefine.h"
@interface SNWeiboAlert ()

@property (nonatomic, strong) NSString * weiboMsg;
- (UIView *)createDemoView;

@end

@implementation SNWeiboAlert
- (void)setUpWeiboAlertWithMsg:(NSString *)string
{
    _weiboMsg = string;
    // Add some custom content to the alert view
    [self setContainerView:[self createDemoView]];
    
    // Modify the parameters
    [self setButtonTitles:[NSMutableArray arrayWithObjects:@"取消", @"发送", nil]];
    [self setDelegate:self];
    
    // You may use a Block, rather than a delegate.
    [self setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        NSLog(@"Block: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
        if (buttonIndex==0) {
            [alertView close];
        }
        else if(buttonIndex==1){
            // UIAlertViewStylePlainTextInput will only ever have a single field at index 0
            UITextView * textview = (UITextView*)[alertView containerView];
            
            Weibo *weibo = [[Weibo alloc] initWithAppKey:WEIBO_APP_KEY withAppSecret:WEIBO_APP_SECRET];
            [Weibo setWeibo:weibo];
            // Override point for customization after application launch.
            
            if (weibo.isAuthenticated) {
                [weibo newStatus:textview.text pic:nil completed:^(Status *status, NSError *error) {
                    if (error) {
                        NSLog(@"failed to post:%@", error);
                        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"悲剧" message:@"微博发送失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [av setAlertViewStyle:UIAlertViewStyleDefault];
                        [av show];
                    }
                    else {
                        NSLog(@"success: %lld.%@", status.statusId, status.text);
                        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"恭喜" message:@"微博发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [av setAlertViewStyle:UIAlertViewStyleDefault];
                        [av show];
                    }
                }];
            }else{
                [Weibo.weibo authorizeWithCompleted:^(WeiboAccount *account, NSError *error) {
                    if (!error) {
                        NSLog(@"Sign in successful: %@", account.user.screenName);
                        [weibo newStatus:textview.text pic:nil completed:^(Status *status, NSError *error) {
                            if (error) {
                                NSLog(@"failed to post:%@", error);
                                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"悲剧" message:@"微博发送失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                [av setAlertViewStyle:UIAlertViewStyleDefault];
                                [av show];
                            }
                            else {
                                NSLog(@"success: %lld.%@", status.statusId, status.text);
                                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"恭喜" message:@"微博发送成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                                [av setAlertViewStyle:UIAlertViewStyleDefault];
                                [av show];
                            }
                        }];
                    }
                    else {
                        NSLog(@"Failed to sign in: %@", error);
                        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"悲剧" message:@"微博登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [av setAlertViewStyle:UIAlertViewStyleDefault];
                        [av show];
                        
                    }
                }];
            }
            [alertView close];
        }
    }];
    
    [self setUseMotionEffects:true];
}

- (UIView *)createDemoView
{
    
    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 290, 120)];
    [tv setEditable:YES];
    [tv setTextColor:[UIColor orangeColor]];
    [tv setText:_weiboMsg];
    [tv setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [tv setKeyboardType:UIKeyboardTypeDefault];
    tv.layer.borderColor = [UIColor clearColor].CGColor;
    tv.layer.borderWidth =1.0;
    tv.layer.cornerRadius =5.0;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return tv;
}
@end
