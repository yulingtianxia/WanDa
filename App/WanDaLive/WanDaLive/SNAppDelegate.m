//
//  SNAppDelegate.m
//  WanDaLive
//
//  Created by David Yang on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNAppDelegate.h"
#import "SNRequest.h"
#import "KeyDefine.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "SensoroAnswer.h"
#import "SNGlobalTrigger.h"
#import "SNWebViewController.h"

#define PI 3.1415926
#define SearchRange 500

@implementation CLLocationManager (TemporaryHack)

- (void)hackLocationFix
{
    //CLLocation *location = [[CLLocation alloc] initWithLatitude:42 longitude:-50];
    float latitude = 26.036811;
    float longitude = 119.275493;  //这里可以是任意的经纬度值
    CLLocation *location= [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    [[self delegate] locationManager:self didUpdateToLocation:location fromLocation:nil];
}

- (void)startUpdatingLocation
{
    [self performSelector:@selector(hackLocationFix) withObject:nil afterDelay:0.1];
}

@end


@interface SNAppDelegate()<RequestDelegate>

@property (strong, nonatomic) SNRequest * registerRequest;
@property (strong, nonatomic) SNRequest * shopsRequest;

- (void) sendRegisterRequest;
- (void)initUserInfo;

@end
@implementation SNAppDelegate
@synthesize fetchHuntRuleRequest;
@synthesize localNotifURL;
@synthesize locationManager;
@synthesize checkinLocation;
@synthesize wdList;
NSString * curTime;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    application.applicationSupportsShakeToEdit = YES;
    wdList = [[SNWDList alloc]init];
    
    locationManager = [[CLLocationManager alloc] init];
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Starting CLLocationManager" );
        locationManager.delegate = self;
        locationManager.distanceFilter = 200;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Starting CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"UID"] != nil) {
        [self initUserInfo];
    }else{
        [self sendRegisterRequest];
    }
    [self sendShopsRequest];
    
    application.applicationSupportsShakeToEdit = YES;
    
    //判断是否是用户点击Notification进入的。
    
    UILocalNotification *localNotif =
    launchOptions[UIApplicationLaunchOptionsLocalNotificationKey];
    if (localNotif) {
        NSLog(@"Call didFinishLaunchingWithOptions with local notification %@",localNotif);
        //        NSUserDefaults *local = [NSUserDefaults standardUserDefaults];
        NSString * url = (localNotif.userInfo)[@"url"];
        //        [local setObject:url forKey:@"localNotif"];
        //        [local synchronize];
        localNotifURL = @{@"url": url,@"hasUrl": @"yes"};
        [self showNotificationInfo:localNotif application:application];
    }
    else localNotifURL = @{@"url": [NSNull null],@"hasUrl": @"no"};
    [application cancelAllLocalNotifications];
    
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
//                fetchHuntRuleRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchHuntRuleOfDate:@"20131212"]];
//                [fetchHuntRuleRequest connect];

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
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Stop CLLocationManager" );
        [locationManager stopUpdatingLocation];
    } else {
        NSLog( @"Cannot Stop CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog( @"Start CLLocationManager" );
        [locationManager startUpdatingLocation];
    } else {
        NSLog( @"Cannot Start CLLocationManager" );
        /*self.locationManager.delegate = self;
         self.locationManager.distanceFilter = 200;
         locationManager.desiredAccuracy = kCLLocationAccuracyBest;
         [self.locationManager startUpdatingLocation];*/
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark MyFunc
-(SNWDLocation*)nearestWD:(CLLocation *)loc
{
    NSArray * arr =  wdList.WDArray;
    double minDistance=SearchRange;
    int nearestWD=-1;
    for (int i=0; i<arr.count; i++) {
        double distance = [((SNWDLocation*)arr[i]).WDLoc distanceFromLocation:loc];
        if (distance<minDistance) {
            minDistance=distance;
            nearestWD=i;
        }
    }
    if (nearestWD==-1) {
        return nil;
    }
    else{
        return arr[nearestWD];
    }
}
#pragma mark Request Methods
- (void) sendRegisterRequest{
    NSString * phoneStr = [NSString stringWithFormat:@"temp_%@",[[NSUUID UUID] UUIDString]];
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    @"temp1234",NAME_KEY,
                                    phoneStr,PHONE_KEY,
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
- (void)initUserInfo{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"UID"] != nil) {
        [[SNTopModel sharedInstance] initUserInfo:nil];
        [SNTopModel sharedInstance].userInfo.userID = [[NSUserDefaults standardUserDefaults] objectForKey:@"UID"];
        NSLog(@"已加载本地uid:%@",[SNTopModel sharedInstance].userInfo.userID);
    }
}
#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    if(self.registerRequest == request){
        self.registerRequest = nil;
        NSLog(@"注册失败");
    }else if(self.shopsRequest == request){
        self.shopsRequest = nil;
        NSLog(@"商店信息取得失败");
    }
}

#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didLoad:(id)result
{
    //将寻宝规则写入UserDefaults
    if(result!=NULL&&request == fetchHuntRuleRequest){
        NSUserDefaults *LastLunchDate = [NSUserDefaults standardUserDefaults];
        [LastLunchDate setValue:curTime forKey:@"lastlunchdate"];
        [LastLunchDate setValue:@"yes" forKey:@"isnewrule"];
        [LastLunchDate synchronize];
        
        if (result[@"shops"]!=[NSNull null]) {
            NSDictionary * dic =(NSDictionary*)result[@"shops"];
            [[SNTopModel sharedInstance] initShops:dic];
        }
    }
    else if(result!=NULL&&self.registerRequest == request){
        self.registerRequest = nil;
        NSString * uid = result[@"id"];
        //此处没同步，不知道对不对@顾家俊
        [[NSUserDefaults standardUserDefaults] setObject:uid forKey:@"UID"];
        
        [self initUserInfo];
    }else if(result!=NULL&&self.shopsRequest == request){
        self.shopsRequest = nil;
        NSArray * array = result;
        [[SNTopModel sharedInstance] initShopsFromServer:array];
    }
}

#pragma mark MyFun

- (void) showNotificationInfo:(UILocalNotification*)notification application:(UIApplication*)application{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SNWebViewController * controller = [storyboard instantiateViewControllerWithIdentifier:@"shopInfoController"];
    if (controller != nil) {
        //[controller presentedViewController];
        NSString * url = (notification.userInfo)[@"url"];
        controller.url = url;
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:controller animated:YES completion:nil];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [application cancelAllLocalNotifications];
}
#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
    if ([self nearestWD:newLocation]==nil) {
        NSLog(@"附近没有支持的万达广场");
    }
    else{
        NSLog(@"%@",[self nearestWD:newLocation].Name);
        [locationManager stopUpdatingLocation];

    }
}
@end
