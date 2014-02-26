//
//  SNVerifyTrigger.h
//  WanDaLive
//
//  Created by apple on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNGlobalTrigger.h"

@protocol SNVerifyTrigger <SNBusinessTrigger>
@optional

@end


@interface SNVerifyTrigger : NSObject

@property BOOL isInVerifyArea;
@property BOOL isLeaveVerifyArea;



@end