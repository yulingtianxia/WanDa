//
//  URLManager.h
//  TrackMaster
//
//  Created by David Yang 0n 12-09-05.
//  Copyright 2012年 AdMaster Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLManager : NSObject

+ (NSString *)userDetail:(NSString*) uid;

//return a random coupon title
+ (NSString *)cornerAward:(NSString *) uid;
+ (NSString *)movableCornerAward:(NSString *) uid;

+ (NSString *)beaconDetail:(NSString*) bid;

+ (NSString *)listUserConpons:(NSString *)uid;

+ (NSString *)deleteCoupon:(NSString *)sid couponID:(NSString *)cid endTime:(NSString *)endtime;

+ (NSString *)applyConpon:(NSString *)uid couponID :(NSString *)cid;

+ (NSString *)imageUrl:(NSString *)path;

+ (NSString *)creditsIncr:(NSString*)uid shopID: (NSString*)sid;

+ (NSString *)fetchMessages:(NSString*)uid timestamp: (NSString *)timestamp;

+ (NSString *)fetchCriditsMessages:(NSString *)uid timestamp:(NSString *)timestamp;

+ (NSString *) fetchCredits:(NSString *)uid;

+ (NSString *) delCredits:(NSString *)uid withsid:(NSString *)sid;

+ (NSString *)addFoundShop:(NSString *)sid toUser:(NSString *)uid onDate:(NSString *)date;

+ (NSString *)fetchHuntRuleOfDate:(NSString *)date;

+ (NSString *)loginURL;
+ (NSString *)registerNewURL;
+ (NSString *)shopsURL;

+ (NSString *)notifyGoodsInfo:(NSString*)uid shopID:(NSString*)sid;
+ (NSString *)fetchHuntProgressOfUser:(NSString*)uid onDate:(NSString*)date;
+ (NSString *)fetchCreditRules;
+ (NSString *)bindingAccountOfUser:(NSString*)uid WithBindingID:(NSString*)bid;
@end
