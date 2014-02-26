//
//  SNMessageManager.m
//  WanDaLive
//
//  Created by David Yang on 13-11-28.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMessageManager.h"
#import "SNTopModel.h"
#import "SNCommonUtils.h"

@implementation SNMessage

@end

@interface SNMessageManager ()
{
    NSUInteger _newMessageCount;
    NSUInteger _newCouponCount;
}

@property (nonatomic,strong) NSMutableArray* messages;
@end

@implementation SNMessageManager

+ (SNMessageManager *)sharedInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void) addMessage:(SNMessage*) message{
    if (self.messages == nil) {
        self.messages = [NSMutableArray arrayWithCapacity:100];
    }
    
    [self.messages addObject:message];
}
- (void) addMessageWithTitle:(NSString*) title message:(NSString*)message
{
    SNMessage * new = [[SNMessage alloc] init];
    new.title = title;
    new.content = message;
    [self addMessage:new];
}

- (void) addMessageWithTitle:(NSString*) title message:(NSString*)message type:(NSString*)type url:(NSString*)url;
{
    SNMessage * new = [[SNMessage alloc] init];
    new.title = title;
    new.content = message;
    new.type = type;
    new.url = url;
    [self addMessage:new];
}
//设置message内容
- (void) addMessageWithTitle:(NSString*) title message:(NSString*)message type:(NSString*)type
{
    SNMessage * new = [[SNMessage alloc] init];
    new.title = title;
    new.content = message;
    new.type = type;
    [self addMessage:new];
}
//通过请求的类型分别设置message的内容
- (void) setupMessages:(NSArray *)messagesArry
{
    for (NSDictionary * dic in messagesArry) {
        //获取店铺信息
        NSString * sid = [dic objectForKey:@"sid"];
        NSMutableDictionary * shopsInfo = [SNTopModel sharedInstance].shopsInfo;
        SNShops * shop = [shopsInfo objectForKey:sid];
        if ([[dic objectForKey:@"type"] isEqualToString:@"credits"]) {
            //获得积分信息
            NSString * credits = [dic objectForKey:@"credits"];
            NSString * incr = [dic objectForKey:@"incr"];
            
            NSString * msg = [NSString stringWithFormat:@"您获得了%@积分，您目前的总积分为%@",incr,credits];
            
            [self addMessageWithTitle:@"积分" message:msg type:@"credits"];
        }else if([[dic objectForKey:@"type"]isEqualToString:@"shop"]){
            
            NSString * url = [dic objectForKey:@"url"];
            //店铺信息
            [self addMessageWithTitle:shop.name message:shop.address type:@"shop" url:url];
            
        }else if ([[dic objectForKey:@"type"] isEqualToString:@"fixedcorner"]){
            //淘金角信息
            NSString * title = [dic objectForKey:@"title"];
            NSString * msg = [NSString stringWithFormat:@"您获得了一张优惠券，%@",title];
            [self addMessageWithTitle:shop.name message:msg type:@"fixedcorner"];
        }else if ([[dic objectForKey:@"type"]isEqualToString:@"hunt"]){
            NSString * subtype = [dic objectForKey:@"subtype"];
            if ([subtype isEqualToString:@"partial"]) {
                NSString * msgStr = [NSString stringWithFormat:@"您已完成寻宝任务的%@部分，继续努力吧！",shop.name];
                [self addMessageWithTitle:@"寻宝" message:msgStr type:@"hunt"];
            }else if([subtype isEqualToString:@"all"]){
                [self addMessageWithTitle:@"寻宝" message:@"您已完成今日的所有寻宝任务，恭喜！" type:@"hunt"];
            }
        }
    }
}

- (void) setUpCreditMsgs:(NSArray *)array
{
    for (NSDictionary * dic in array) {
        //获取店铺信息
        NSString * sid = [dic objectForKey:@"sid"];
        NSMutableDictionary * shopsInfo = [SNTopModel sharedInstance].shopsInfo;
        SNShops * shop = [shopsInfo objectForKey:sid];
        if ([[dic objectForKey:@"type"] isEqualToString:@"credits"]) {
            //获得积分信息
            NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
            
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"MM.dd HH:mm:ss"];
            [formatter setTimeZone:[NSTimeZone systemTimeZone]];
            
            NSString * incr = [dic objectForKey:@"incr"];
            NSString * timestamp = [dic objectForKey:@"timestamp"];
            NSDate * date = [SNCommonUtils dateFromTimeStemp:timestamp];
            
            NSString * title = [NSString stringWithFormat:@"%@分",incr];
            NSString * msg = [NSString stringWithFormat:@"%@  %@",[formatter stringFromDate:date],shop.name];
            
            [self addMessageWithTitle:title message:msg type:@"credits"];
        }
    }
}

- (void)removeAllMessages{
    if (self.messages != nil) {
        [self.messages removeAllObjects];
    }
}

- (NSArray*) allMessage{
    return self.messages;
}

- (void) updateMessageNumber: (NSUInteger) num{
    _newMessageCount += num;
    if (self.watcher != nil) {
        if ([self.watcher respondsToSelector:@selector(hasNewMessage)]) {
            [self.watcher hasNewMessage];
        }
    }
}

- (void) updateCouponNumber: (NSUInteger) num{
    _newCouponCount += num;
    if (self.watcher != nil) {
        if ([self.watcher respondsToSelector:@selector(hasNewCoupon)]) {
            [self.watcher hasNewCoupon];
        }
    }
}

- (void) clearMessageUpdate{
    _newMessageCount = 0;
}

- (void) clearCouponUpdate{
    _newCouponCount = 0;
}

- (NSUInteger) newCouponCount{
    return _newCouponCount;
}

- (NSUInteger) newMessageCount{
    return _newMessageCount;
}

@end
