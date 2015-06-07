//
//  SNGlobalTrigger.m
//  WanDaLive
//
//  Created by David Yang on 13-11-28.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNGlobalTrigger.h"
#import "URLManager.h"
#import "SensoroAnswer.h"
#import "SNTopModel.h"
#import "SNSensorModel.h"
#import "SNMessageManager.h"
#import "KeyDefine.h"

@interface SNGlobalTrigger ()
{
    NSString* _verifySID;
    BOOL _isInVerifyArea;
}

@property (nonatomic,strong) NSMutableArray * watcheres;
@property (nonatomic,strong) SNRequest * creditsIncrRequest;
@property (nonatomic,strong) SNRequest * goodsRequest;
@property (nonatomic,strong) NSMutableDictionary * taskCompleteRequest;//用来做寻宝的

//用于记录正在查询的Beacon的quest，防止多次出现。
@property (nonatomic,strong) NSMutableDictionary * sensorRequest;

//一个广场只有一种淘金角，所有的淘金角距离是相同的。
@property (nonatomic,strong) SNTrigger * goldCornerTrigger;//用来计算淘金角的。
@property (nonatomic,strong) SNTrigger * movableCornerTrigger;//用来计算淘金角的。

//不同的商店有自己的积分，商品显示，验证，寻宝用传感器。key为商店的ID
@property (nonatomic,strong) NSMutableDictionary * creditsTrigger;//用来计算积分的
@property (nonatomic,strong) NSMutableDictionary * goodsTrigger;//用来计算商品的。
@property (nonatomic,strong) NSMutableDictionary * verifyTrigger;//用来计算验证的。
@property (nonatomic,strong) NSMutableDictionary * taskTrigger;//用来做寻宝的

@end

@implementation SNGlobalTrigger

+ (SNGlobalTrigger *)sharedInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void) sendCreditsRequest: (NSString*) sid{
    self.creditsIncrRequest =
    [SNRequest getPutRequestWithParams:nil
                               delegate:self
                             requestURL:[URLManager creditsIncr:
                                         [SNTopModel sharedInstance].uid
                                                         shopID:sid]];
    [self.creditsIncrRequest connect];
}

- (void) sendGoodsRequest: (NSString*) sid bid: (NSString*) bid userInfo:(NSDictionary*) dict{
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    bid,BID_KEY,
                                    nil];
    
    self.goodsRequest = [SNRequest getPutRequestWithParams:params
                                                     delegate:self
                                                   requestURL:[URLManager notifyGoodsInfo:
                                                               [SNTopModel sharedInstance].uid
                                                                                   shopID:sid]];
    self.goodsRequest.exactInfo = dict;
    [self.goodsRequest connect];
}

-(NSString*)curTimeString{
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];//获取当前日期
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formater setTimeZone:timeZone];
    [formater setDateFormat:@"yyyyMMdd"];//这里去掉 具体时间 保留日期
    return [formater stringFromDate:curDate];
}

- (void) sendTaskCompleteRequest: (NSString*) sid{
    
    SNRequest * huntTreasureRequest = (self.taskCompleteRequest)[sid];

    if (huntTreasureRequest == nil) {
        SNRequest * huntTreasureRequest = [SNRequest getPutRequestWithParams:nil
                                                                    delegate:self
                                                                  requestURL:
                                           [URLManager addFoundShop:sid
                                                             toUser:[SNTopModel sharedInstance].uid
                                                             onDate:[self curTimeString]]];
        [huntTreasureRequest connect];
        
        if (self.taskCompleteRequest == nil) {
            self.taskCompleteRequest = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        
        (self.taskCompleteRequest)[sid] = huntTreasureRequest;
    }
}

- (void) querySensorInfo:(NSString*) bid{
}

- (NSString*) verifySID{
    return _verifySID;
}

- (BOOL) isInVerifyArea{
    return _isInVerifyArea;
}

#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    NSArray * sids = [self.taskCompleteRequest allKeysForObject:request];
    
    if (request == self.creditsIncrRequest) {
        self.creditsIncrRequest = nil;
        NSLog(@"credits result failed");
    }else if (request == self.goodsRequest){
        self.goodsRequest = nil;
        NSLog(@"goods result failed");
    }else if ( sids.count > 0){
        [self.taskCompleteRequest removeObjectForKey:sids[0]];
        NSLog(@"hunt complete request result failed");
    }else{
        NSLog(@"beacon request result failed");
        for(NSString * iter in self.sensorRequest.allKeys){
            SNRequest * temp = (self.sensorRequest)[iter];
            if (temp == request) {
                [self.sensorRequest removeObjectForKey:iter];
                break;
            }
        }
    }
}

- (void)request:(SNRequest *)request didLoad:(id)result
{
    NSArray * taskSids = [self.taskCompleteRequest allKeysForObject:request];
    
    if (request == self.creditsIncrRequest) {
        [[SNMessageManager sharedInstance] updateMessageNumber:1];
    }else if (self.goodsRequest == request){
        
        NSLog(@"goods result : %@",result);
        
        NSDictionary * dict = result[SHOP_KEY];
        
        if (dict != nil) {
            NSString * name = dict[NAME_KEY];
            
            NSDictionary* dict = request.exactInfo;
            if ([dict isKindOfClass:[NSDictionary class]]) {
                //发送消息通知给系统。
                UILocalNotification *notification = [[UILocalNotification alloc] init];
                notification.alertBody = [NSString stringWithFormat:@"你已进入万达广场%@，点击查看店铺详细信息",
                                          name];
                notification.applicationIconBadgeNumber = 1;
                notification.userInfo = dict;
                [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
            }
        }
        
        [[SNMessageManager sharedInstance] updateMessageNumber:1];
    }else if ([taskSids count] > 0){
        [self.taskCompleteRequest removeObjectForKey:taskSids[0]];

        if (result[@"outcome"]!=[NSNull null]) {
            NSString * outcome = [NSString stringWithString:result[@"outcome"]] ;
            if ([outcome isEqualToString:@"have already accomplished"]) {
                //该店铺之前已经完成
                NSLog(@"have already accomplished");
            }else if([outcome isEqualToString:@"accepted"]){
                NSLog(@"accepted");
            }else if([outcome isEqualToString:@"congratulations"]){
                //完成寻宝活动，获得奖励
                NSLog(@"congratulations");
            }
        }
        
        //此处不需要用寻宝规则过滤一下sid，因为sid肯定是寻宝规则中的sid
        NSUserDefaults *shops = [NSUserDefaults standardUserDefaults];
        NSMutableArray* arrdata = [shops objectForKey:@"shops"];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:arrdata.count];
        NSMutableArray* newarrdata = [NSMutableArray arrayWithCapacity:arrdata.count];
        for (int i = 0;i<arrdata.count; i++) {
            SNShops *shop = [NSKeyedUnarchiver unarchiveObjectWithData:arrdata[i]];
            [arr addObject:shop];
        }
        for (int i=0; i<arr.count; i++) {
            if ([((SNShops*)arr[i]).sid isEqualToString:taskSids[0]]) {
                ((SNShops*)arr[i]).IsCompleted=@"YES";
            }
            [newarrdata addObject:[NSKeyedArchiver archivedDataWithRootObject:(SNShops*)arr[i]]];
        }
        
        [shops setObject:newarrdata forKey:@"shops"];//将更新完成状态后的shop存入
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(taskComplete:)]) {
                [del taskComplete:taskSids[0]];
            }
        }
    } else {
        for(NSString * iter in self.sensorRequest.allKeys){
            SNRequest * temp = (self.sensorRequest)[iter];
            if (temp == request) {
                [self.sensorRequest removeObjectForKey:iter];

                NSDictionary * dict = (NSDictionary*)result;
                SNSensorModel * model = [SNSensorModel getInstanceFrom:dict];
                
                if (([SNTopModel sharedInstance].sensors)[model.bid] == nil) {
                    [[SNTopModel sharedInstance] addSensorModel:model key:model.bid];
                    [self processSensorModel:model];
                };
                break;
            }
        }
    }
}

- (void) startWatcherBeacon{
    [[SensoroAnswer sharedInstance] addObserver:self];
}

#pragma mark SNSensoroServiceDelegate

//进入监测区域
- (void) enterRegion{
}

//离开监测区域。
- (void) exitRegion{
}

//进入某些传感器的区域。
- (void) enterSensor: (NSArray*) sensors{
    
//    NSString * key = [NSString stringWithFormat:@"%@-%d-%d",
//                      @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",4,4];
    
    for (SNSensor * iter in sensors) {
        NSString * findKey = [NSString stringWithFormat:@"%@-%@-%@",
                              iter.uuid,iter.major,iter.minor];

        NSLog(@"find beacon %@",findKey);
        //if ([findKey isEqualToString:key]) {
            
            SNSensorModel * model = ([SNTopModel sharedInstance].sensors)[findKey];
            
            if (model != nil) {//如果找到了，则处理Model。
                [self processSensorModel:model];
            }else{
                SNRequest * request = (self.sensorRequest)[findKey];
                if (request == nil) {//如果没有正在请求此Beacon的信息，则获取其信息。
                    request = [SNRequest getRequestWithParams:nil
                                                     delegate:self
                                                   requestURL:[URLManager beaconDetail:findKey]];
                    [request connect];
                    
                    if (self.sensorRequest == nil) {
                        self.sensorRequest = [NSMutableDictionary dictionaryWithCapacity:5];
                    }
                    
                    (self.sensorRequest)[findKey] = request;
                }
            }
        //}
    }
}

//离开某些传感器的区域。
- (void) exitSensor: (NSArray*) sensors{
}

//一些传感器出现了。
- (void) sensorAppear: (NSArray*) appear disappear: (NSArray*) disappear{
}

//发生错误了。
- (void) errorWasHappened:(NSError*)error{
}

#pragma mark SNTriggerDelegate

//到达指定时间，触发此事件。
- (void) timeTrigger: (SNTrigger*) triger sensor:(SNSensor*) sensors{
    NSLog(@"Timer was triggered!");
    
    if([[self.creditsTrigger allKeysForObject:triger] count] > 0){
        NSString * findKey = [NSString stringWithFormat:@"%@-%@-%@",
                              sensors.uuid,sensors.major,sensors.minor];
        
        NSDictionary * dict = [SNTopModel sharedInstance].sensors;
        SNSensorModel * model = dict[findKey];
        
        if (model != nil) {
            [[SNGlobalTrigger sharedInstance] sendCreditsRequest:model.sid];
        }
        
        NSLog(@"credits timer was triggered!\n");
    }else if([[self.taskTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"task timer was triggered!\n");
        
        NSArray* sids = [self.taskTrigger allKeysForObject:triger];
        if (sids.count > 0) {
            [self sendTaskCompleteRequest:sids[0]];
        }
    }else if([[self.goodsTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"goods show timer was triggered!\n");
        
        NSString * findKey = [NSString stringWithFormat:@"%@-%@-%@",
                              sensors.uuid,sensors.major,sensors.minor];

        NSDictionary * dict = [SNTopModel sharedInstance].sensors;
        SNSensorModel * model = dict[findKey];
        
        if (model != nil) {
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:1];
            dict[@"url"] = model.goodsUrl;
            [self sendGoodsRequest:model.sid bid:findKey userInfo:dict];
        }
    }else if(self.movableCornerTrigger == triger){
        NSLog(@"movableCorner timer was triggered!\n");
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(movableGoldCornerSuccess)]) {
                [del movableGoldCornerSuccess];
            }
        }
    }
}

//到达指定距离出发此事件，前面是到达的此距离的传感器，后面是离开此距离的传感器。
- (void) distanceTrigger:(SNTrigger*) triger sensor:(SNSensor*) sensors{
    NSLog(@"Distance was triggered!");
    if (triger == self.goldCornerTrigger) {
        NSLog(@"gold corner distance was triggered!\n");

        self.isInGloldCorner = YES;
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(enterGoldCorner)]) {
                [del enterGoldCorner];
            }
        }
    }else if([[self.creditsTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"credits distance was triggered!\n");
        //进入积分区域。
    }else if([[self.taskTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"task distance was triggered!\n");
        //进入寻宝区域。
    }else if([[self.verifyTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"verify distance was triggered!\n");
        //进入校验区域
        _isInVerifyArea = YES;
        
        NSString * findKey = [NSString stringWithFormat:@"%@-%@-%@",
                              sensors.uuid,sensors.major,sensors.minor];
        
        NSDictionary * dict = [SNTopModel sharedInstance].sensors;
        SNSensorModel * model = dict[findKey];
        
        if (model != nil) {
            _verifySID = model.sid;
            for (id<SNBusinessTrigger> del in self.watcheres) {
                if ([del respondsToSelector:@selector(enterVerifyArea:)]) {
                    [del enterVerifyArea:model.sid];
                }
            }
        }else{
            _verifySID = nil;
        }
        
        //self.verifyTrigger = nil;
    }else if([[self.goodsTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"goods distance was triggered!\n");
        //进入商品显示区域。
    }else if(self.movableCornerTrigger == triger){
        NSLog(@"movableCorner distance was triggered!\n");
        self.isInMovableGloldCorner = YES;
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(enterMovableGoldCorner)]) {
                [del enterMovableGoldCorner];
            }
        }
    }
}

//到达指定距离后又离开了，此时通知外部。
- (void) distanceLeaveTrigger:(SNTrigger*) triger{
    NSLog(@"Distance Leave was triggered!");
    if (triger == self.goldCornerTrigger) {
        NSLog(@"gold corner distance leave was triggered!\n");

        self.isInGloldCorner = NO;
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(leaveGoldCorner)]) {
                [del leaveGoldCorner];
            }
        }
    }else if([[self.creditsTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"credits distance leave was triggered!\n");
        //离开积分区域。
    }else if([[self.taskTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"task distance leave was triggered!\n");
        //离开寻宝区域。
    }else if([[self.verifyTrigger allKeysForObject:triger] count] > 0) {
        NSLog(@"verify distance leave was triggered!\n");
        //离开校验区域
        _isInVerifyArea = NO;
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(leaveVerifyArea)]) {
                [del leaveVerifyArea];
            }
        }
    }else if([[self.goodsTrigger allKeysForObject:triger] count] > 0){
        NSLog(@"goods distance leave was triggered!\n");
        //离开商品显示区域。
    }else if(self.movableCornerTrigger == triger){
        //离开移动淘金角区域。
        NSLog(@"movableCorner distance was triggered!\n");
        self.isInMovableGloldCorner = NO;
        
        for (id<SNBusinessTrigger> del in self.watcheres) {
            if ([del respondsToSelector:@selector(leaveMovableGoldCorner)]) {
                [del leaveMovableGoldCorner];
            }
        }
    }
}

#pragma mark Watcher

//添加观测者。
- (void) addObserver:(id<SNBusinessTrigger>) watcher{
    
    if (self.watcheres == nil) {
        self.watcheres = [NSMutableArray arrayWithCapacity:10];
    }
    
    for (id<SNBusinessTrigger> cur in self.watcheres) {
        if (cur == watcher) {
            return;
        }
    }
    
    [self.watcheres addObject:watcher];
}

//删除观测者。
- (void) removeObserver:(id<SNBusinessTrigger>) watcher{
    for (id<SNBusinessTrigger> cur in self.watcheres) {
        if (cur == watcher) {
            [self.watcheres removeObject:watcher];
            return;
        }
    }
}

#pragma mark SensorModel

- (void) processSensorModel: (SNSensorModel*)model{
    //添加Trigger
    
    if (model.isGoldCorner)//传感器是一个淘金角传感器。
    {
        if(self.goldCornerTrigger == nil) {//现在没有淘金角传感器。
            self.goldCornerTrigger = [[SNTrigger alloc] init];
            
            self.goldCornerTrigger.triggerSensores = [NSMutableDictionary dictionaryWithCapacity:5];
            (self.goldCornerTrigger.triggerSensores)[model.bid] = @1;
            self.goldCornerTrigger.stayDistLimit = model.goldCornerDist;
            self.goldCornerTrigger.stayTimeLimit = 0;//不需要时间激活。
            self.goldCornerTrigger.watcher = self;
            
            [[SensoroAnswer sharedInstance] addTrigger:self.goldCornerTrigger];
        }else{
            //向淘金角Trigger中添加新的
            (self.goldCornerTrigger.triggerSensores)[model.bid] = @1;
        }
    }
    
    if (model.isMovableGoldCorner)//传感器是一个移动淘金角传感器。
    {
        if(self.movableCornerTrigger == nil) {//现在没有淘金角传感器。
            self.movableCornerTrigger = [[SNTrigger alloc] init];
            
            self.movableCornerTrigger.triggerSensores = [NSMutableDictionary dictionaryWithCapacity:5];
            (self.movableCornerTrigger.triggerSensores)[model.bid] = @1;
            self.movableCornerTrigger.stayDistLimit = model.movableGoldCornerDist;
            self.movableCornerTrigger.stayTimeLimit = model.movableGoldCornerTimer;
            self.movableCornerTrigger.watcher = self;
            
            [[SensoroAnswer sharedInstance] addTrigger:self.movableCornerTrigger];
        }else{
            //向淘金角Trigger中添加新的
            (self.movableCornerTrigger.triggerSensores)[model.bid] = @1;
        }
    }
    
    if (model.isCredits)
    {
        if(self.creditsTrigger == nil) {
            self.creditsTrigger = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        
        SNTrigger * trigger = (self.creditsTrigger)[model.sid];
        if( trigger == nil)//没找到店铺相关的积分Trigger，添加一个新的。
        {
            trigger = [[SNTrigger alloc] init];
            
            trigger.triggerSensores = [NSMutableDictionary dictionaryWithCapacity:5];
            (trigger.triggerSensores)[model.bid] = @1;
            trigger.stayDistLimit = model.creditsDist;
            trigger.stayTimeLimit = model.creditsTimer;
            trigger.watcher = self;
            //trigger.isTimerAutoDelete = YES;
            
            //设定Trigger和店铺的对应。
            if (model.sid != nil) {
                (self.creditsTrigger)[model.sid] = trigger;
                [[SensoroAnswer sharedInstance] addTrigger:trigger];
            }
        }else{//找到店铺相关的积分Trigger，向Trigger中添加一个新的传感器
            (trigger.triggerSensores)[model.bid] = @1;
        }
    }
    
    if (model.isTask)
    {
        if(self.taskTrigger == nil) {
            self.taskTrigger = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        
        SNTrigger * trigger = (self.taskTrigger)[model.sid];
        if( trigger == nil)//没找到店铺相关的积分Trigger，添加一个新的。
        {
            trigger = [[SNTrigger alloc] init];
            
            trigger.triggerSensores = [NSMutableDictionary dictionaryWithCapacity:5];
            (trigger.triggerSensores)[model.bid] = @1;
            trigger.stayDistLimit = model.taskDist;
            trigger.stayTimeLimit = model.taskTimer;
            trigger.watcher = self;
            //trigger.isTimerAutoDelete = YES;
            
            //设定Trigger和店铺的对应。
            if (model.sid != nil) {
                (self.taskTrigger)[model.sid] = trigger;
                [[SensoroAnswer sharedInstance] addTrigger:trigger];
            }
        }else{//找到店铺相关的积分Trigger，向Trigger中添加一个新的传感器
            (trigger.triggerSensores)[model.bid] = @1;
        }
    }else{//查看所属店铺是否是寻宝店铺。
        
    }
    
    if (model.isGoodsShow)
    {
        if(self.goodsTrigger == nil) {
            self.goodsTrigger = [NSMutableDictionary dictionaryWithCapacity:10];
        }
        
        SNTrigger * trigger = (self.goodsTrigger)[model.sid];
        if (trigger == nil) {//没找到商品显示Trigger，新增一个
            trigger = [[SNTrigger alloc] init];
            
            trigger.triggerSensores = [NSMutableDictionary dictionaryWithCapacity:5];
            (trigger.triggerSensores)[model.bid] = @1;
            trigger.stayDistLimit = model.goodsShowDist;
            trigger.stayTimeLimit = model.goodsShowTimer;
            trigger.watcher = self;
            //trigger.isTimerAutoDelete = YES;

            if (model.sid != nil) {
                //设定Trigger和店铺的对应。
                (self.goodsTrigger)[model.sid] = trigger;
                [[SensoroAnswer sharedInstance] addTrigger:trigger];
            }
        }else{//找到了，在Trigger中添加新的传感器。
            (trigger.triggerSensores)[model.bid] = @1;
        }
    }
    
    if (model.isVerify)
    {
        if(self.verifyTrigger == nil) {
            self.verifyTrigger = [NSMutableDictionary dictionaryWithCapacity:10];
        }
    
        SNTrigger * trigger = (self.verifyTrigger)[model.sid];
        if (trigger == nil) {
            trigger = [[SNTrigger alloc] init];
            
            trigger.triggerSensores = [NSMutableDictionary dictionaryWithCapacity:1];
            (trigger.triggerSensores)[model.bid] = @1;
            trigger.stayDistLimit = model.verfifyDist;
            trigger.stayTimeLimit = 0;
            trigger.watcher = self;
            
            if (model.sid != nil) {
                //设定Trigger和店铺的对应。
                (self.verifyTrigger)[model.sid] = trigger;
                [[SensoroAnswer sharedInstance] addTrigger:trigger];
            }
        }else{
            (trigger.triggerSensores)[model.bid] = @1;
        }
    }
}

@end
