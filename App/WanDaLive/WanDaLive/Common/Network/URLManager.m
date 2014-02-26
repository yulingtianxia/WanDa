//
//  URLManager.m
//  TrackMaster
//
//  Created by David Yang 0n 12-09-05.
//  Copyright 2012年 AdMaster Inc. All rights reserved.
//

#import "URLManager.h"

#define URLMACRO(ROOT, PATH) [NSString stringWithFormat:@"%@%@", ROOT, PATH]

@implementation URLManager

static NSString *rootURL = @"http://wanda.cloudapp.net:3000";
//static NSString *rootURL = @"http://192.168.1.102:3000";
//static NSString *rootURL = @"http://wanda.imapp.net:3000";

// userDetail
+ (NSString *)userDetail:(NSString*) uid{
    NSString * path = [NSString stringWithFormat:@"/users/%@",uid];
    return URLMACRO(rootURL, path);
}

+ (NSString *)cornerAward:(NSString *)uid
{
    NSString *path = [NSString stringWithFormat:@"/users/%@/corner/fixed", uid];
    return URLMACRO(rootURL, path);
}

+ (NSString *)movableCornerAward:(NSString *) uid{
    NSString *path = [NSString stringWithFormat:@"/users/%@/corner/mobile", uid];
    return URLMACRO(rootURL, path);
}

+ (NSString *)beaconDetail:(NSString*) bid{
    NSString * path = [NSString stringWithFormat:@"/beacons/%@",bid];
    return URLMACRO(rootURL, path);
}

+ (NSString *)listUserConpons:(NSString *)uid
{
    NSString * path = [NSString stringWithFormat:@"/users/%@/coupons",uid];
    NSLog(@"%@",URLMACRO(rootURL, path));
    return URLMACRO(rootURL, path);
}

+ (NSString *)deleteCoupon:(NSString *)uid couponID:(NSString *)cid endTime:(NSString *)endtime
{
    NSString * path = nil;
    path = [NSString stringWithFormat:@"/users/%@/coupons/deadline/%@,%@",uid,cid,endtime];
    NSLog(@"%@",URLMACRO(rootURL, path));
    return URLMACRO(rootURL, path);
}

+ (NSString *)applyConpon:(NSString *)uid couponID:(NSString *)cid
{
    NSString *path = [NSString stringWithFormat:@"/users/coupons/%@/%@", uid, cid];
    return URLMACRO(rootURL, path);
}

+ (NSString *)creditsIncr:(NSString *)uid shopID:(NSString *)sid{
    
    NSString * path = [NSString stringWithFormat:@"/users/%@/credits/%@",uid, sid];
    return URLMACRO(rootURL, path);
}

+ (NSString *) fetchMessages:(NSString *)uid timestamp:(NSString *)timestamp{
    NSString * path = [NSString stringWithFormat:@"/users/%@/messages?time=%@",uid, timestamp];
    return URLMACRO(rootURL, path);
}
+ (NSString *) fetchCriditsMessages:(NSString *)uid timestamp:(NSString *)timestamp{
    NSString * path = [NSString stringWithFormat:@"/users/%@/messages?time=%@&type=credits",uid, timestamp];
    return URLMACRO(rootURL, path);
}
+ (NSString *) fetchCredits:(NSString *)uid{
    NSString * path = [NSString stringWithFormat:@"/users/%@/credits",uid];
    return URLMACRO(rootURL, path);
}
+ (NSString *) delCredits:(NSString *)uid withsid:(NSString *)sid{
    NSString * path = [NSString stringWithFormat:@"/users/%@/credits/%@",uid,sid];
    return URLMACRO(rootURL, path);
}
+ (NSString *)imageUrl:(NSString *)path
{
    NSString *url = [NSString stringWithFormat:@"/image/%@", path];
    return URLMACRO(rootURL, url);
}
+ (NSString *)addFoundShop:(NSString *)sid toUser:(NSString *)uid onDate:(NSString *)date{
    NSString *url = [NSString stringWithFormat:@"/users/%@/hunt/%@/%@", uid,sid,date];
    return URLMACRO(rootURL, url);
}
+ (NSString *)fetchHuntRuleOfDate:(NSString *)date{
    NSString *url = [NSString stringWithFormat:@"/hunt/rule/%@", date];
    return URLMACRO(rootURL, url);
}

+ (NSString *)loginURL{
    NSString *url = [NSString stringWithFormat:@"/users/login"];
    return URLMACRO(rootURL, url);
}

+ (NSString *)registerNewURL{
    NSString *url = [NSString stringWithFormat:@"/users/register"];
    return URLMACRO(rootURL, url);
}

+ (NSString *)notifyGoodsInfo:(NSString*)uid shopID:(NSString*)sid{
    NSString *url = [NSString stringWithFormat:@"/users/%@/goods/%@",uid,sid];
    return URLMACRO(rootURL, url);
}

+ (NSString *)fetchHuntProgressOfUser:(NSString*)uid onDate:(NSString*)date{
    NSString *url = [NSString stringWithFormat:@"/users/%@/hunt/%@",uid,date];
    return URLMACRO(rootURL, url);
}

+ (NSString *)shopsURL{
    NSString *url = [NSString stringWithFormat:@"/shops"];
    return URLMACRO(rootURL, url);
}

+ (NSString *)fetchCreditRules{
    NSString *url = [NSString stringWithFormat:@"/shops/credits/all"];
    return URLMACRO(rootURL, url);
}

+ (NSString *)bindingAccountOfUser:(NSString*)uid WithBindingID:(NSString*)bid{
    NSString *url = [NSString stringWithFormat:@"/users/%@/bind/%@",uid,bid];
    return URLMACRO(rootURL, url);
}
@end
