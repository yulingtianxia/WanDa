//
//  Request.h
//  TrackMaster
//
//  Created by Tony Tang on 11-9-15.
//  Modified by David Yang on 12-09-03
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol RequestDelegate;

@interface SNRequest : NSObject {
    id<RequestDelegate> _delegate;
    NSString *_url;
    NSString *_httpMethod;
    NSMutableDictionary *_params;
    NSURLConnection *_connection;
    NSMutableData *_responseData;
    NSInteger _status;//

    BOOL isWaitingForFormhash;
}

@property (nonatomic, retain) id<RequestDelegate> delegate;
@property (nonatomic, retain) NSString *url;
@property (nonatomic, retain) NSString *httpMethod;
@property (nonatomic, retain) NSMutableDictionary *params;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *responseData;

@property (nonatomic, assign) BOOL isWaitingForFormhash;
@property (nonatomic, strong) NSDictionary * exactInfo;

+ (SNRequest*)getRequestWithParams:(NSMutableDictionary *)params
                        delegate:(id<RequestDelegate>)delegate
					  requestURL:(NSString *)url;

+ (SNRequest*)getPostRequestWithParams:(NSMutableDictionary *)params
                        delegate:(id<RequestDelegate>)delegate
					  requestURL:(NSString *)url;

+ (SNRequest*)getDeleteRequestWithParams:(NSMutableDictionary *)params
                              delegate:(id<RequestDelegate>)delegate
                            requestURL:(NSString *)url;
+ (SNRequest*)getPutRequestWithParams:(NSMutableDictionary *)params
                             delegate:(id<RequestDelegate>)delegate
                           requestURL:(NSString *)url;
- (BOOL)isLoading;
- (void)cancel;
- (void)connect;

@end

@protocol RequestDelegate <NSObject>

@optional
- (void)requestLoading:(SNRequest *)request;
- (void)request:(SNRequest *)request didReceiveResponse:(NSURLResponse *)response;
- (void)request:(SNRequest *)request didFailWithError:(NSError *)error;
- (void)request:(SNRequest *)request didLoadRawResponse:(NSData *)data;
- (void)request:(SNRequest *)request didLoad:(id)result;

@end
