//
//  SNAppDelegate.m
//  SensoroSDKTest
//
//  Created by David Yang on 13-11-21.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNAppDelegate.h"
#import "SNGlobalTrigger.h"
#import "SNWebViewController.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "SensoroAnswer.h"

@implementation SNAppDelegate
@synthesize fetchHuntRuleRequest;
@synthesize localNotifURL;
NSString * curTime;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    application.applicationSupportsShakeToEdit = YES;
    
    //判断是否是用户点击Notification进入的。
    
    UILocalNotification *localNotif =
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        NSLog(@"Call didFinishLaunchingWithOptions with local notification %@",localNotif);
//        NSUserDefaults *local = [NSUserDefaults standardUserDefaults];
        NSString * url = [localNotif.userInfo objectForKey:@"url"];
//        [local setObject:url forKey:@"localNotif"];
//        [local synchronize];
        localNotifURL = [NSDictionary dictionaryWithObjectsAndKeys:url,@"url",@"yes",@"hasUrl", nil];
        [self showNotificationInfo:localNotif application:application];
    }
    
    else localNotifURL = [NSDictionary dictionaryWithObjectsAndKeys:[NSNull null],@"url",@"no",@"hasUrl", nil];
    
    //更新本地寻宝规则
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];//获取当前日期
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formater setTimeZone:timeZone];
    [formater setDateFormat:@"yyyyMMdd"];//这里去掉 具体时间 保留日期
    curTime = [formater stringFromDate:curDate];

    NSUserDefaults *LastLunchDate = [NSUserDefaults standardUserDefaults];
    NSString *oldTime = [LastLunchDate stringForKey:@"lastlunchdate"];
    
    if (![oldTime isEqualToString:curTime]) {
        //开始准备从服务器读取寻宝规则
        fetchHuntRuleRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchHuntRuleOfDate:curTime]];
        [fetchHuntRuleRequest connect];
    }
    //测试代码：
//            fetchHuntRuleRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchHuntRuleOfDate:@"20131209"]];
//            [fetchHuntRuleRequest connect];
    

    [[SensoroAnswer sharedInstance] initService];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application cancelAllLocalNotifications];
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[SensoroAnswer sharedInstance] stopService];
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if ( state == UIApplicationStateInactive ){
        [self showNotificationInfo:notification application:application];
    }
}

- (void) showNotificationInfo:(UILocalNotification*)notification application:(UIApplication*)application{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SNWebViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"shopInfoController"];
    if (controller != nil) {
        //[controller presentedViewController];
        NSString * url = [notification.userInfo objectForKey:@"url"];
        controller.url = url;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}

#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didLoad:(id)result{
    //将寻宝规则写入UserDefaults
    if(result!=NULL&&request == fetchHuntRuleRequest){
        NSUserDefaults *LastLunchDate = [NSUserDefaults standardUserDefaults];
        [LastLunchDate setValue:curTime forKey:@"lastlunchdate"];
        [LastLunchDate synchronize];

        if ([result objectForKey:@"shops"]!=[NSNull null]) {
            NSDictionary * dic =(NSDictionary*)[result objectForKey:@"shops"];
            [[SNTopModel sharedInstance] initShops:dic];

        }
    }
}
@end
