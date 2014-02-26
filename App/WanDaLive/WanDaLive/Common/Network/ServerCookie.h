//
//  ServerCookie.h
//  TrackMaster
//
//  Created by Tony Tang on 11-9-16.
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServerCookie : NSObject

+ (BOOL)isCookieValid;
+ (NSArray *)getCookie;
+ (void)updateCookie:(NSHTTPURLResponse *)httpResponse;
+ (void)clearCookie;

@end
