//
//  Weibo.h
//  WeiboSDK
//
//  Created by Liu Jim on 8/4/13.
//  Copyright (c) 2013 openlab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboRequest.h"
#import "Status.h"
#import "User.h"
#import "WeiboAccount.h"

enum {
    kJsonParseErrorCode          = 10100,
    kJsonParseTimelineErrorCode   = 10101,
    kJsonParseUserErrorCode   = 10102,
};

typedef void(^WeiboTimelineQueryCompletedBlock)(NSMutableArray *statuses, NSError *error);
typedef void(^WeiboUserQueryCompletedBlock)(User *user, NSError *error);
typedef void(^WeiboUserAuthenticationCompletedBlock)(WeiboAccount *account, NSError *error);
typedef void(^WeiboNewStatusCompletedBlock)(Status *status, NSError *error);


typedef NS_ENUM(unsigned int, StatusTimeline) {
    StatusTimelineFriends = 0,
    StatusTimelineMentions = 1,
};


@interface Weibo : NSObject

- (instancetype)initWithAppKey:(NSString *)appKey withAppSecret:(NSString *)appSecret NS_DESIGNATED_INITIALIZER;
+ (Weibo*)weibo;
+ (Weibo*)setWeibo:(Weibo*)weibo;


@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *appSecret;

#pragma mark - Auth

@property (NS_NONATOMIC_IOSONLY, getter=isAuthenticated, readonly) BOOL authenticated;
- (void)authorizeWithCompleted:(WeiboUserAuthenticationCompletedBlock)completedBlock;
- (void)signOut;
@property (NS_NONATOMIC_IOSONLY, readonly, strong) WeiboAccount *currentAccount;

#pragma mark - User Query

- (WeiboRequestOperation *)queryWithUserId:(long long)userId
                                 completed:(WeiboUserQueryCompletedBlock)completedBlock;


#pragma mark - Timeline Query

- (WeiboRequestOperation *)queryPublicTimelineWithCount:(int)count
                                              completed:(WeiboTimelineQueryCompletedBlock)completedBlock;


- (WeiboRequestOperation *)queryTimeline:(StatusTimeline)timeline
                                 sinceId:(long long)sinceId
                                   maxId:(long long)maxId
                                   count:(int)count
                               completed:(WeiboTimelineQueryCompletedBlock)completedBlock;

- (WeiboRequestOperation *)queryTimeline:(StatusTimeline)timeline
                                 sinceId:(long long)sinceId
                                   count:(int)count
                               completed:(WeiboTimelineQueryCompletedBlock)completedBlock;
- (WeiboRequestOperation *)queryTimeline:(StatusTimeline)timeline
                                   maxId:(long long)maxId
                                   count:(int)count
                               completed:(WeiboTimelineQueryCompletedBlock)completedBlock;
- (WeiboRequestOperation *)queryTimeline:(StatusTimeline)timeline
                                   count:(int)count
                               completed:(WeiboTimelineQueryCompletedBlock)completedBlock;


#pragma mark - Post

- (WeiboRequestOperation *)newStatus:(NSString *)status
                                 pic:(NSData *)picData
                           completed:(WeiboNewStatusCompletedBlock)completedBlock;

@end
