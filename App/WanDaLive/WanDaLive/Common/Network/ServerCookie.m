//
//  ServerCookie.m
//  TrackMaster
//
//  Created by Tony Tang on 11-9-16.
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import "ServerCookie.h"

@implementation ServerCookie

static NSString *cookieURLString = @"http://www.trackmaster.com.cn";

+ (BOOL)isCookieValid {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:cookieURLString]];
    
#if __TM_DEBUG_
        NSLog(@"Checking cookie:");
        NSLog(@"%@", cookies);
#endif
    
    if ([cookies count] == 0) {
        return NO;
    }
    
    NSHTTPCookie *cookie = cookies[0]; //? is index 0 ok in future?
    // they both in gmt time, not localized, so just compare it
    if ([cookie.expiresDate compare:[NSDate date]] == NSOrderedDescending) {
        return YES;
    } else {
        return NO;
    }
}

+ (NSArray *)getCookie {
    return [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:[NSURL URLWithString:cookieURLString]];
}

+ (void)updateCookie:(NSHTTPURLResponse *)httpResponse {
    NSURL *url = [NSURL URLWithString:cookieURLString];
    NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:[httpResponse allHeaderFields] forURL:url];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookies:cookies forURL:url mainDocumentURL:nil];
}

+ (void)clearCookie {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:
                        [NSURL URLWithString:cookieURLString]];
    for (NSHTTPCookie *cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
}

@end
