//
//  SNSharedResource.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-3.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNSharedResource : NSObject

@property (readonly , strong) UIImage * cornerIcon;
@property (readonly , strong) UIImage * shopIcon;
@property (readonly , strong) UIImage * discountIcon;
@property (readonly , strong) UIImage * creditIcon;
@property (readonly , strong) UILabel * testLabel;
@property (readonly , strong) UIImage * placeholderImg;

@property (nonatomic,strong,readonly) UIFont * commonSmallFont;
@property (nonatomic,strong,readonly) UIFont * commonSmallBoldFont;
@property (nonatomic,strong,readonly) UIFont * commonMiddleFont;
@property (nonatomic,strong,readonly) UIFont * commonLargeFont;
@property (nonatomic,strong,readonly) UIFont * commonLargerFont;
@property (nonatomic,strong,readonly) UIFont * commonSuperFont;
@property (nonatomic,strong,readonly) UIFont * commonMaxFont;

+ (SNSharedResource *)sharedInstance;

@end
