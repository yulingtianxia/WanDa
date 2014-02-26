//
//  SNAppDelegate.h
//  SensoroSDKTest
//
//  Created by David Yang on 13-11-21.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
@interface SNAppDelegate : UIResponder <UIApplicationDelegate,RequestDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SNRequest * fetchHuntRuleRequest;
@property (strong, nonatomic) NSDictionary * localNotifURL;
@end
