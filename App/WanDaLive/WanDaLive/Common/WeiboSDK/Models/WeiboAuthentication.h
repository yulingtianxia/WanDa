//
//  WeiboAuthentication.h
//  WeiboSDK
//
//  Created by Liu Jim on 8/3/13.
//  Copyright (c) 2013 openlab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeiboAuthentication : NSObject 

- (instancetype)initWithAuthorizeURL:(NSString *)authorizeURL accessTokenURL:(NSString *)accessTokenURL
                    AppKey:(NSString *)appKey appSecret:(NSString *)appSecret NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;
@property (nonatomic, copy) NSString *redirectURI;

@property (nonatomic, copy) NSString *authorizeURL;
@property (nonatomic, copy) NSString *accessTokenURL;

@property (nonatomic, copy) NSString *accessToken;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, retain) NSDate *expirationDate;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *authorizeRequestUrl;

@end

