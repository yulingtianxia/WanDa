//
//  TMError.m
//  TrackMaster
//
//  Created by Tony Tang on 11-9-15.
//  Modified by David Yang on 12-09-07
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import "TMError.h"

#define ERR(X, Y) Y,X

NSString* msgWithCode(NSInteger statusCode) {
    static NSDictionary *codeMapFromMsg;
    if(!codeMapFromMsg) {
        codeMapFromMsg = [[NSDictionary alloc] initWithObjectsAndKeys:
                          ERR(UNKNOWN_ERROR, @"未知错误"),
                          
                          //1xx
                          ERR(NO_DATA_ERROR, @"没有数据"),
                          ERR(UNEXPECTED_DATA, @"错误数据"),
                          //2xx
                          ERR(SUC_CREATED,     @"创建成功"),
                          ERR(SUC_ACCEPTED,    @"更新、修改成功"),
                          ERR(SUC_NO_CONTENT,  @"无返回内容"),
                          //3xx
                          ERR(PLS_LOGIN_FIRST, @"您没有权限操作，请先登录"),
                          ERR(NO_DEFAULT_NET, @"请选择网络"),
                          ERR(ADER_NOT_EXSITS, @"您访问的广告主不存在"),

                          //4xx
                          ERR(ERR_BAD_REQUEST, @"请求地址不存在或者带有不支持的参数"),
                          ERR(ERR_UNAUTHORIZED,@"未经授权"),
                          ERR(ERR_FORBIDDEN,   @"禁止访问"),
                          ERR(ERR_NOT_FOUND,   @"请求的资源不存在"),
                          //500
                          ERR(ERR_INTERNAL_SERVER_ERROR, @"服务器内部错误"),
                          nil];
    }
    NSString * status = [NSString stringWithFormat:@"%ld",(long)statusCode];
    NSString *msg = [codeMapFromMsg objectForKey:status];
    if (!msg) {
        msg = @"未知错误";
    }
    return msg;
}

@implementation TMError

+ (NSError *)errorWithMsg:(NSString *)msg {
    return [NSError errorWithDomain:@"SensoroErrorDomain" code:0  userInfo:[NSDictionary dictionaryWithObject:msg forKey:@"err_msg"]];
}

+ (NSError *)errorWithCode:(NSInteger)statusCode
{
    return [NSError errorWithDomain:@"SensoroErrorDomain" code:statusCode userInfo:[NSDictionary dictionaryWithObject:msgWithCode(statusCode) forKey:@"err_msg"]];
}

@end

@implementation NSError (geterrormsg)

- (NSString *)err_msg {
    NSString * errDesc = [self.userInfo objectForKey:@"err_msg"];
    if(errDesc == nil || [errDesc length] == 0){
        errDesc = [self localizedDescription];
    }
    
    return errDesc;
}

@end
