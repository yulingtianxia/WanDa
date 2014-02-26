//
//  TMError.h
//  TrackMaster
//
//  Created by Tony Tang on 11-9-15.
//  Modified by David Yang on 12-09-03
//  Copyright 2011年 AdMaster Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UNKNOWN_ERROR         @"0" //未知错误

// 1xx default
#define NO_DATA_ERROR       @"101" //没有数据
#define UNEXPECTED_DATA     @"102" //错误数据

// 2xx application
#define SUC_CREATED         @"201" //创建成功
#define SUC_ACCEPTED        @"202" //更新、修改成功
#define SUC_NO_CONTENT      @"204" //无返回内容

// 3xx server
#define PLS_LOGIN_FIRST     @"300" //您没有权限操作，请先登录
#define NO_DEFAULT_NET      @"301" //请选择网络
#define ADER_NOT_EXSITS     @"302" //您访问的广告主不存在

// 4xx server
#define ERR_BAD_REQUEST     @"400" //请求地址不存在或者带有不支持的参数
#define ERR_UNAUTHORIZED    @"401" //未经授权
#define ERR_FORBIDDEN       @"403" //禁止访问
#define ERR_NOT_FOUND       @"404" //请求的资源不存在

// 500
#define ERR_INTERNAL_SERVER_ERROR      @"500" //服务器内部错误

//int codeWithMsg(NSString *msg);

@interface TMError : NSObject

+ (NSError *)errorWithMsg:(NSString *)msg;
+ (NSError *)errorWithCode:(NSInteger)statusCode;

@end

@interface NSError (geterrormsg)

- (NSString *)err_msg;

@end
