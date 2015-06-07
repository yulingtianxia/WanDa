//
//  Request.m
//  TrackMaster
//
//  Created by Tony Tang on 11-9-15.
//  Modified by David Yang on 12-09-03
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import "SNRequest.h"
#import "SBJson.h"
#import "TMError.h"
#import "ServerCookie.h"

//static NSString *kStringBoundary = @"3i2ndDfv2rTHiSisAbouNdArYfORhtTPEefj3";
static const NSTimeInterval kTimeoutInterval = 60.0;

static NSString *networkMutex = @"networkMutex";
static int networkConnectionCount = 0;

@interface SNRequest (private_methods)
+ (NSString *)userAgent;
+ (NSString *)generateQueryString:(NSDictionary *)params;
+ (NSString *)serializeURL:(NSString *)baseUrl 
                    params:(NSDictionary *)params;
+ (SNRequest*)getRequestWithParams:(NSMutableDictionary *)params
                      httpMethod:(NSString *)httpMethod
                        delegate:(id<RequestDelegate>)delegate
					  requestURL:(NSString *)url;
@end

@implementation SNRequest

@synthesize delegate=_delegate;
@synthesize url=_url;
@synthesize httpMethod=_httpMethod;
@synthesize params=_params;
@synthesize connection=_connection;
@synthesize responseData=_responseData;
@synthesize isWaitingForFormhash;

+ (void)aConnectionBegin {
    @synchronized(networkMutex) {
        ++networkConnectionCount;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

+ (void)aConnectionEnd {
    @synchronized(networkMutex) {
        --networkConnectionCount;
        if (!networkConnectionCount) {
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        }
    }
}

+ (NSString *)userAgent {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = infoDictionary[@"CFBundleDisplayName"];
    NSString *version = infoDictionary[@"CFBundleShortVersionString"];
    NSString *build = infoDictionary[@"CFBundleVersion"];
    
    //Sensoro/4.0 (SystemName; SystemVersion) Product/version/release
    return [NSString stringWithFormat:@"Sensoro/1.0 (%@; %@) %@ for iPhone(Dev)/%@/%@",
            [[UIDevice currentDevice] systemName],
            [[UIDevice currentDevice] systemVersion],
            name, version, build
            ];
}

+ (SNRequest *)getRequestWithParams:(NSMutableDictionary *)params 
                         delegate:(id<RequestDelegate>)delegate 
                       requestURL:(NSString *)url {
    return [SNRequest getRequestWithParams:params httpMethod:@"GET" delegate:delegate requestURL:url];
}

+ (SNRequest *)getPostRequestWithParams:(NSMutableDictionary *)params
                             delegate:(id<RequestDelegate>)delegate 
                           requestURL:(NSString *)url {
    return [SNRequest getRequestWithParams:params httpMethod:@"POST" delegate:delegate requestURL:url];
}

+ (SNRequest *)getDeleteRequestWithParams:(NSMutableDictionary *)params
                               delegate:(id<RequestDelegate>)delegate
                             requestURL:(NSString *)url {
    return [SNRequest getRequestWithParams:params httpMethod:@"DELETE" delegate:delegate requestURL:url];
}

+ (SNRequest*)getPutRequestWithParams:(NSMutableDictionary *)params
                             delegate:(id<RequestDelegate>)delegate
                           requestURL:(NSString *)url{
    return [SNRequest getRequestWithParams:params httpMethod:@"PUT" delegate:delegate requestURL:url];
}

+ (SNRequest *)getRequestWithParams:(NSMutableDictionary *) params
                       httpMethod:(NSString *) httpMethod
                         delegate:(id<RequestDelegate>) delegate
                       requestURL:(NSString *) url {
    //SNRequest* request = [[[SNRequest alloc] init] autorelease];
    SNRequest* request = [[SNRequest alloc] init];
    request.delegate = delegate;
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.connection = nil;
    request.responseData = nil;
    request.isWaitingForFormhash = YES;
    return request;
}

+ (NSString *)generateQueryString:(NSDictionary *)params {
    if (params == nil || [params count] == 0) {
        return @"";
    }
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *key in [params keyEnumerator]) {
        NSString *escaped_key = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)key, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        NSString *escaped_value = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (__bridge CFStringRef)params[key], NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8);
        [pairs addObject:[NSString stringWithFormat:@"%@=%@",escaped_key,escaped_value]];
    }
    
    return [pairs componentsJoinedByString:@"&"];
}

+ (NSString *)serializeURL:(NSString *)baseUrl 
                    params:(NSDictionary *)params {
    if ([params count] == 0) {
        return baseUrl;
    }
    NSURL *parsedURL = [NSURL URLWithString:baseUrl];
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString *query = [SNRequest generateQueryString:params];
    return [NSString stringWithFormat:@"%@%@%@", baseUrl, queryPrefix, query];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)dealloc {
    [_connection cancel];
}

- (BOOL)isLoading {
    return isWaitingForFormhash || !!_connection;
}

- (void)cancel {
    @synchronized(_connection) {
        [_connection cancel];
    }
}

- (NSData *)generatePostBody {
    NSString *postQuery = [SNRequest generateQueryString:_params];
    NSLog(@"params : %@\n PostBody : %@\n",_params,postQuery);
    return [postQuery dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:NO];
}

- (void)connect {
#if __TM_DEBUG_
    NSLog(@"conncection begin");
#endif
    isWaitingForFormhash = NO;
    if ([_delegate respondsToSelector:@selector(requestLoading:)]) {
        [_delegate requestLoading:self];
    }
    
    NSMutableURLRequest* urlRequest;
    if ([_httpMethod isEqualToString:@"GET"]) {
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[SNRequest serializeURL:_url params:_params]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeoutInterval];
    } else if([_httpMethod isEqualToString:@"POST"]) {
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeoutInterval];
        [urlRequest setHTTPBody:[self generatePostBody]];
    } else if ([_httpMethod isEqualToString:@"DELETE"]) {
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[SNRequest serializeURL:_url params:_params]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeoutInterval];
    }else if ([_httpMethod isEqualToString:@"PUT"]) {
        urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[SNRequest serializeURL:_url params:_params]] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kTimeoutInterval];
    }
    else {
        NSLog(@"---------unknown httpMethod----------");
    }
	[urlRequest setHTTPMethod:self.httpMethod];
    [urlRequest setAllHTTPHeaderFields:[NSHTTPCookie requestHeaderFieldsWithCookies:[ServerCookie getCookie]]];
    [urlRequest setValue:[SNRequest userAgent] forHTTPHeaderField:@"User-Agent"];
    [urlRequest setHTTPShouldHandleCookies:NO];
    
#if __TM_DEBUG_
    NSLog(@"%@\n%@", [urlRequest URL], [urlRequest allHTTPHeaderFields]);
#endif
    _connection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    [SNRequest aConnectionBegin];
}

- (void)failWithError:(NSError *)error {
#if __TM_DEBUG_
    NSLog(@"request fail with error: %@", [error err_msg]);
    NSLog(@"error: %@", error); // tctodo what inside error when connection time out happeneds
#endif
    if ([_delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [_delegate request:self didFailWithError:error];
    }
}

- (id)parseJsonResponse:(NSData *)data error:(NSError **)error {
    
    NSString* responseString = [[NSString alloc] initWithData:data
                                                      encoding:NSUTF8StringEncoding];
#if __TM_DEBUG_
    NSLog(@"response string: %@", responseString);
#endif
    //SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
    SBJsonParser *jsonParser = [SBJsonParser new];
    id result = [jsonParser objectWithString:responseString];
    if (!result) {
        *error = [TMError errorWithMsg:@"json parse error"];
    }
    return result;
}

- (void)handleResponseData:(NSData *)data {
    if ([_delegate respondsToSelector:@selector(request:didLoadRawResponse:)]) {
        [_delegate request:self didLoadRawResponse:data];
    }

    if (_status == 200) {
        NSError* error = nil;
        id result = [self parseJsonResponse:data error:&error];
        if (error) {
            [self failWithError:error];
        }else {
#if __TM_DEBUG_
            NSLog(@"Request did load, result: %@", result);
#endif
            if ([_delegate respondsToSelector:@selector(request:didLoad:)]) {
                [_delegate request:self didLoad:result];
            }
        }
    }else{//错误
        NSError* error = nil;
        //if(_status == 500 ){
        error = [TMError errorWithCode:_status];
        /*}else{
            id result = [self parseJsonResponse:data error:&error];
            if(result){
                NSDictionary * errInfo = result;
                error = [TMError errorWithMsg:[errInfo objectForKey:@"message"]];
            }else{
                error = [TMError errorWithCode:_status];
            }
        }*/
        
        [self failWithError:error];
    }
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    _status = [httpResponse statusCode];
	
#if __TM_DEBUG_
        NSLog(@"%@\n%@", [response URL],[httpResponse allHeaderFields]);
#endif
    
    // if we sent request with cookie, the response will not contain a cookie
    // but nerver mind.
    // another question is how to update the cookie's expiration date?
    [ServerCookie updateCookie:httpResponse];
    if ([_delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [_delegate request:self didReceiveResponse:httpResponse];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection 
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [SNRequest aConnectionEnd];
    
    [self handleResponseData:_responseData];
    
    _responseData = nil;
    _connection = nil;
    _status = 200;//OK
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [SNRequest aConnectionEnd];
    
    [self failWithError:error];
    
    _responseData = nil;
    _connection = nil;
    _status = 200;//OK
}

@end
