//
//  SNBindingViewController.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-17.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNBindingViewController.h"
#import "Weibo.h"
#import "URLManager.h"
#import "SNTopModel.h"
@interface SNBindingViewController ()

@end

@implementation SNBindingViewController
@synthesize bindingAccountRequest;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)bindingToWeibo:(id)sender {
    Weibo *weibo = [[Weibo alloc] initWithAppKey:@"3326691039" withAppSecret:@"75dd27596a081b28651d214e246c1b15"];
    [Weibo setWeibo:weibo];
    // Override point for customization after application launch.
    
    if (weibo.isAuthenticated) {
        NSString* userId = [weibo currentAccount].userId;
        NSString* uid = [SNTopModel sharedInstance].userInfo.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
        bindingAccountRequest= [SNRequest getPutRequestWithParams:(NSMutableDictionary*)@{@"type": @"weibo"} delegate:self requestURL:[URLManager bindingAccountOfUser:uid WithBindingID:userId]];
        [bindingAccountRequest connect];
    }else{
        [Weibo.weibo authorizeWithCompleted:^(WeiboAccount *account, NSError *error) {
            if (!error) {
                NSString* userId = [weibo currentAccount].userId;
                NSString* uid = [SNTopModel sharedInstance].userInfo.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
                bindingAccountRequest= [SNRequest getPutRequestWithParams:(NSMutableDictionary*)@{@"type": @"weibo"} delegate:self requestURL:[URLManager bindingAccountOfUser:uid WithBindingID:userId]];
                [bindingAccountRequest connect];
            }
            else {
                NSLog(@"Failed to sign in: %@", error);
                UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"悲剧" message:@"微博登录失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [av setAlertViewStyle:UIAlertViewStyleDefault];
                [av show];
                
            }
        }];
    }
}

#pragma mark RequestDelegate

-(void)request:(SNRequest *)request didLoad:(id)result{
    if (result!=NULL&&request==bindingAccountRequest) {
        //此处别忘记获取返回的用户id，并写入UserDefaults和SNTopModel
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        [ud setObject:((NSDictionary*)result)[@"id"] forKey:@"UID"];
        [ud synchronize];
        [SNTopModel sharedInstance].userInfo.userID=((NSDictionary*)result)[@"id"];
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"恭喜" message:@"微博绑定成功" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av setAlertViewStyle:UIAlertViewStyleDefault];
        [av show];
    }
}
-(void)request:(SNRequest *)request didFailWithError:(NSError *)error{
    if (request==bindingAccountRequest) {
        
        UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"蛋疼" message:@"微博绑定失败" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [av setAlertViewStyle:UIAlertViewStyleDefault];
        [av show];
    }
}

@end
