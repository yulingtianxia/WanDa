//
//  SNMessageManager.h
//  WanDaLive
//
//  Created by David Yang on 13-11-28.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//
@protocol SNMessageTrigger <NSObject>

- (void) hasNewMessage;
- (void) hasNewCoupon;

@end

#import <Foundation/Foundation.h>

@interface SNMessage : NSObject
@property (nonatomic,strong) NSString* type;
@property (nonatomic,strong) NSString* title;
@property (nonatomic,strong) NSString* content;
@property (nonatomic,strong) NSString* url;
@end

@interface SNMessageManager : NSObject

@property (nonatomic,strong) id<SNMessageTrigger> watcher;

- (void) addMessage:(SNMessage*) message;
//- (void) addMessageWithTitle:(NSString*) title message:(NSString*)message;
- (void) addMessageWithTitle:(NSString*) title message:(NSString*)message type:(NSString*)type;
- (void) addMessageWithTitle:(NSString*) title message:(NSString*)message type:(NSString*)type url:(NSString*)url;
- (void) removeAllMessages;

- (void) setupMessages:(NSArray *)messagesArry;

- (NSArray*) allMessage;

+ (SNMessageManager *)sharedInstance;

@property (readonly) NSUInteger newCouponCount;
@property (readonly) NSUInteger newMessageCount;

- (void) clearMessageUpdate;
- (void) clearCouponUpdate;

- (void) updateMessageNumber: (NSUInteger) num;
- (void) updateCouponNumber: (NSUInteger) num;

@end
