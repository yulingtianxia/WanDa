//
//  SNAppDelegate.h
//  WanDaLive
//
//  Created by David Yang on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SNRequest.h"
#import "SNWDList.h"
@interface SNAppDelegate : UIResponder <UIApplicationDelegate,RequestDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SNRequest * fetchHuntRuleRequest;
@property (strong, nonatomic) NSDictionary * localNotifURL;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *checkinLocation;
@property (strong, nonatomic) SNWDList *wdList;
@end
