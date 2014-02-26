//
//  SensoroAnswer.m
//  SensoroAnswer
//
//  Created by David Yang on 13-11-21.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SensoroAnswer.h"
#import "SNBeacon.h"
#import <UIKit/UIApplication.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define DISTANCE_BUF_SIZE   5
#define MAX_SPEED_PEOPLE    5 //假设人最大的走动距离是五米
#define INVALID_DISTANCE    100000
#define SCAN_TIMER_INTERVAL 0.5 //扫描间隔为0.5s，

//大于此时间的beacon变为未知状态，小于此时间的beacon被认为还在范围内。
#define WILL_DISAPPEAR      10
//大于此时间被认为已经消失。在消失之前，每秒每个发送一个rssi=-1，
#define DISAPPEARED         30

#define RSSI_MAX            -10//所有大于此值的都过滤掉。

double calculateAccuracy(int txPower, double rssi) {
    if (rssi == 0) {
        return -1.0; // if we cannot determine accuracy, return -1.
    }
    
    double ratio = rssi*1.0/txPower;
    
    if (ratio < 1.0) {
        return pow(ratio,10);
    }
    else {
        double accuracy =  (0.89976)*pow(ratio,7.7095) + 0.111;
        return accuracy;
    }
}

@interface SNSensor ()
{
    CLLocationAccuracy distanceBuf[DISTANCE_BUF_SIZE];
    CLLocationAccuracy prevExcept;
    
    CLLocationAccuracy bleDistanceBuf[DISTANCE_BUF_SIZE];
}

- (void) pushDistance:(CLLocationAccuracy) dist;
- (void) clearDistance;
- (void) pushBleDistance:(CLLocationAccuracy) dist;
- (void) clearBleDistance;
+ (SNSensor*) getInstanceFrom:(CLBeacon *) beacon;
+ (SNSensor*) getInstanceFromBleBeacon:(SNBeacon *) beacon;

@end

@implementation SNSensor

+ (SNSensor*) getInstanceFromBleBeacon:(SNBeacon *) beacon{
    SNSensor * sensor = [[SNSensor alloc] init];
    
    sensor.uuid = beacon.proximityUUID;
    sensor.major = beacon.major;
    sensor.minor = beacon.minor;
    sensor.proximity = beacon.proximity;
    
    sensor.entryTime = [NSDate date];
    sensor.stayTime = 1;
    sensor.isOutOfRegion = NO;
    
    [sensor clearBleDistance];
    [sensor pushBleDistance:beacon.accuracy];
    
    return sensor;
}


+ (SNSensor*) getInstanceFrom:(CLBeacon *) beacon{
    SNSensor * sensor = [[SNSensor alloc] init];
    
    sensor.uuid = [beacon.proximityUUID UUIDString];
    sensor.major = beacon.major;
    sensor.minor = beacon.minor;
    sensor.proximity = beacon.proximity;
    
    sensor.entryTime = [NSDate date];
    sensor.stayTime = 1;
    sensor.isOutOfRegion = NO;
    
    [sensor clearDistance];
    [sensor pushDistance:beacon.accuracy];
    
    return sensor;
}

- (CLLocationAccuracy) distance{
    CLLocationAccuracy find = -1;
    for (int i = 0; i < DISTANCE_BUF_SIZE; i++) {
        if (distanceBuf[i] > 0) {
            find = distanceBuf[i];
            break;
        }
    }
    return find;
}

- (CLLocationAccuracy) minDistance{
    CLLocationAccuracy find = INVALID_DISTANCE;
    for (int i = 0; i < DISTANCE_BUF_SIZE; i++) {
        if (distanceBuf[i] > 0 &&
            distanceBuf[i] < find) {
            find = distanceBuf[i];
        }
    }
    
    return find;

//    int count = 0;
//    double sum = 0;
//    for (int i = DISTANCE_BUF_SIZE - 1; i > 0; i--) {
//        if (distanceBuf[i] > 0) {
//            sum += distanceBuf[i];
//            count++;
//        }
//    }
//    
//    double averg = 0.0;
//    if (count > 0) {
//        averg = sum / count;
//    }
//    if(find * 3.0 < averg){
//        find = averg;
//    }
//    
//    return find;
}

- (void) pushDistance:(CLLocationAccuracy) dist{
    //消除突然地变化，因为会出现从10米突然调整到0.x米的状况。
//    if ( distanceBuf[0] > 0 &&
//        fabs(distanceBuf[0] - dist) > MAX_SPEED_PEOPLE) {
//        
//        if (prevExcept > 0 && fabs(prevExcept - dist) < MAX_SPEED_PEOPLE) {
//            /*DO NOTHING*/
//        }else{
//            prevExcept = dist;
//            return ;
//        }
//    }
//    
//    prevExcept = 0;
    
    for (int i = DISTANCE_BUF_SIZE - 1; i > 0; i--) {
        distanceBuf[i] = distanceBuf[i - 1];
    }
    distanceBuf[0] = dist;
}

- (void) clearDistance{
    for (int i = DISTANCE_BUF_SIZE - 1; i >= 0; i--) {
        distanceBuf[i] = -1;
    }
}

#pragma mark BLE Sensor Distance

- (CLLocationAccuracy) bleDistance{
    CLLocationAccuracy find = -1;
    for (int i = 0; i < DISTANCE_BUF_SIZE; i++) {
        if (bleDistanceBuf[i] > 0) {
            find = bleDistanceBuf[i];
            break;
        }
    }
    return find;
}

- (CLLocationAccuracy) minBleDistance{
    CLLocationAccuracy find = INVALID_DISTANCE;
    for (int i = 0; i < DISTANCE_BUF_SIZE; i++) {
        if (bleDistanceBuf[i] > 0 &&
            bleDistanceBuf[i] < find) {
            find = bleDistanceBuf[i];
        }
    }
    
    return find;
}

- (void) pushBleDistance:(CLLocationAccuracy) dist{
    
    for (int i = DISTANCE_BUF_SIZE - 1; i > 0; i--) {
        bleDistanceBuf[i] = bleDistanceBuf[i - 1];
    }
    bleDistanceBuf[0] = dist;
}

- (void) clearBleDistance{
    for (int i = DISTANCE_BUF_SIZE - 1; i >= 0; i--) {
        bleDistanceBuf[i] = -1;
    }
}

@end

@interface SNTrigger ()

@property BOOL isTimerTiggered;

@end

@implementation SNTrigger

@end

@interface SensoroAnswer () <CLLocationManagerDelegate, CBCentralManagerDelegate>
{
    BOOL _servicing;
}

//位置服务
@property (nonatomic,strong) CLLocationManager * locationManager;
//支持的UUID
@property (nonatomic,strong) NSArray * supportedProximityUUIDs;
//现在正在监测的范围
@property (nonatomic,strong) NSMutableArray * rangedRegions;
//现在监测到的范围
@property (nonatomic,strong) NSMutableArray * watchedRegions;
//消息观察者
@property (nonatomic,strong) NSMutableArray * watcheres;
//是否是后台运行。
@property BOOL isBackgroundMonitor;
//发现的Sensor
@property (nonatomic,strong) NSMutableDictionary * foundSensores;
//用于存储
@property (nonatomic,strong) NSArray * prevFoundSensores;

@property (nonatomic,strong) NSMutableArray * triggers;

//蓝牙相关的内容
//通过ble扫描发现的内容
@property (strong, nonatomic) NSMutableDictionary * bleFoundBeacons;
//用于计算计数多少次了。用于确定何时停止扫描，何时开始扫描。
@property NSUInteger timerCount;
//扫描用计数器。
@property (strong, nonatomic) NSTimer * scanTimer;
//蓝牙用扫描变量。
@property (strong, nonatomic) CBCentralManager  *centralManager;

@end

@implementation SensoroAnswer

+ (SensoroAnswer *)sharedInstance{
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void) initService{
    
    //如果没有生成过，则初始化内容。
    if (self.locationManager == nil) {
        self.supportedProximityUUIDs =
        @[[[NSUUID alloc] initWithUUIDString:@"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0"],
          [[NSUUID alloc] initWithUUIDString:@"5A4BCFCE-174E-4BAC-A814-092E77F6B7E5"],
          [[NSUUID alloc] initWithUUIDString:@"BDB202C4-F692-419A-86B1-3D126E2E0A2F"],
          //[[NSUUID alloc] initWithUUIDString:@"B9407F30-F5F8-466E-AFF9-25556B57FE6D"],
          [[NSUUID alloc] initWithUUIDString:@"74278BDA-B644-4520-8F0C-720EAF059935"]];
        
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        //防止系统自动停止更新，我们使用更小的精度和更长的过滤距离还限制电池消耗
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        self.locationManager.distanceFilter = 50000;//5000 meter
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        
        // Populate the regions we will range once.
        self.rangedRegions = [NSMutableArray array];
        
        [_supportedProximityUUIDs enumerateObjectsUsingBlock:^(id uuidObj, NSUInteger uuidIdx, BOOL *uuidStop) {
            NSUUID *uuid = (NSUUID *)uuidObj;
            CLBeaconRegion *region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:[uuid UUIDString]];
            [self.rangedRegions addObject:region];
        }];
        
        //用于记录监测到了那些区域。
        self.watchedRegions = [NSMutableArray arrayWithCapacity:[self.rangedRegions count]];
        
        self.foundSensores = [NSMutableDictionary dictionaryWithCapacity:100];
        self.bleFoundBeacons = [NSMutableDictionary dictionaryWithCapacity:100];
        
        self.watcheres = [NSMutableArray arrayWithCapacity:10];
    }
    
    self.triggers = [NSMutableArray arrayWithCapacity:10];
    
    //添加消息监测，用于处理前台后台切换。
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredBackground:)
                                                 name: UIApplicationDidEnterBackgroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleBecomeActive:)
                                                 name: UIApplicationDidBecomeActiveNotification
                                               object: nil];
}

- (void) startService{
    //如果已经开始了服务，则返回
    if (_servicing == YES) {
        return;
    }
    
    //首先进行区域监测。此时，即使进入后台，也会有机会收到消息。
    [self.rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [self.locationManager startMonitoringForRegion:region];
    }];
    
    // Start up the CBCentralManager
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    _servicing = YES;
}

- (void) stopService{
    if (_servicing == NO) {
        return;
    }
    
    //首先进行区域监测。此时，即使进入后台，也会有机会收到消息。
    [self.rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [self.locationManager stopMonitoringForRegion:region];
    }];

    [self.rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CLBeaconRegion *region = obj;
        [self.locationManager stopRangingBeaconsInRegion:region];
    }];
    
    if (self.isBackgroundMonitor) {
        [self.locationManager stopUpdatingLocation];
        self.isBackgroundMonitor = NO;
    }
    
    [self.centralManager stopScan];
    self.centralManager = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidEnterBackgroundNotification];
    [[NSNotificationCenter defaultCenter] removeObserver:UIApplicationDidBecomeActiveNotification];
    
    _servicing = NO;
}

- (NSArray*) getCurSensors{
    return [self.foundSensores allValues];
}

- (void) addObserver:(id<SNSensoroServiceDelegate>) watcher
{
    for (id<SNSensoroServiceDelegate> cur in self.watcheres) {
        if (cur == watcher) {
            return;
        }
    }
    
    [self.watcheres addObject:watcher];
}

- (void) removeObserver:(id<SNSensoroServiceDelegate>) watcher
{
    for (id<SNSensoroServiceDelegate> cur in self.watcheres) {
        if (cur == watcher) {
            [self.watcheres removeObject:watcher];
            return;
        }
    }
}

- (BOOL) servicing{
    return _servicing;
}

#pragma mark location service

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Location was updated.\n");
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location error was happend %@.\n",error);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidPauseLocationUpdates was happend\n");
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    NSLog(@"locationManagerDidResumeLocationUpdates was happend\n");
}

- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    //NSLog(@"Location didDetermineState was happend %@.\n",region);
    if([region isKindOfClass:[CLBeaconRegion class]])
    {
        if(state == CLRegionStateInside){
            CLBeaconRegion * beaconRegion = (CLBeaconRegion *)region;
            NSLog(@"CLRegionStateInside %@\n",[[beaconRegion proximityUUID] UUIDString]);
            
            if ([self.watchedRegions count] == 0) {//如果是首次进入。
                
                if ([CLLocationManager isRangingAvailable] == YES) {
                    //启动Beacon监测，这时是在某一个区域里面。
                    [self.rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        CLBeaconRegion *region = obj;
                        [self.locationManager startRangingBeaconsInRegion:region];
                    }];
                }
                
                //判断是否需要启动位置监测，后台时，必须启动后台监测，才能保持app持续在后台运行。
                if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground &&
                    self.isBackgroundMonitor == NO) {
                    [self.locationManager startUpdatingLocation];
                    self.isBackgroundMonitor = YES;
                }

                //通知Observer，进入了一个区域。
                for (id<SNSensoroServiceDelegate> del in self.watcheres) {
                    if ([del respondsToSelector:@selector(enterRegion)]) {
                        [del enterRegion];
                    }
                }
            }
            
            //查找是否原来已经在其中了。
            BOOL found = NO;
            for (CLBeaconRegion* beacon in self.watchedRegions) {
                if ([[beacon.proximityUUID UUIDString] isEqualToString:
                     [beaconRegion.proximityUUID UUIDString]]) {
                    found = YES;
                    break;
                }
            }
            if (found == NO) {//原数组不包含，加入其中。
                [self.watchedRegions addObject:region];
            }
        } else if(state == CLRegionStateOutside) {
            CLBeaconRegion * beaconRegion = (CLBeaconRegion *)region;
            NSUInteger prevCount = [self.watchedRegions count];
            for (CLBeaconRegion* beacon in self.watchedRegions) {
                if ([[beacon.proximityUUID UUIDString] isEqualToString:
                     [beaconRegion.proximityUUID UUIDString]]) {
                    [self.watchedRegions removeObject:beacon];
                    //原来有，现在监测到没有，则处理所有的区域内消息。
                    [self processAllDisappearOfRegion:beaconRegion];

                    break;
                }
            }
            
            NSLog(@"CLRegionStateOutside %@\n",[[beaconRegion proximityUUID] UUIDString]);
            
            //由监测到区域状态，变为不再监测。
            if (prevCount > 0 && [self.watchedRegions count] == 0) {
                //启动Beacon监测，这时是在某一个区域里面。
                [self.rangedRegions enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    CLBeaconRegion *region = obj;
                    [self.locationManager stopRangingBeaconsInRegion:region];
                }];
                
                //如果超出范围，则停止监测。
                if (self.isBackgroundMonitor == YES) {
                    [self.locationManager stopUpdatingLocation];
                    self.isBackgroundMonitor = NO;
                }
                
                //通知Observer，退出了一个区域。
                for (id<SNSensoroServiceDelegate> del in self.watcheres) {
                    if ([del respondsToSelector:@selector(exitRegion)]) {
                        [del exitRegion];
                    }
                }
            }
        }else{
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //NSLog(@"Location didEnterRegion was happend %@.\n",region);
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    //NSLog(@"Location didExitRegion was happend %@.\n",region);
}

- (void)locationManager:(CLLocationManager *)manager didRangeBeacons:(NSArray *)beacons inRegion:(CLBeaconRegion *)region
{
    if ([beacons count] > 0) {
        
//        for (CLBeacon * beacon in beacons) {
//            NSString* prox = nil;
//            switch (beacon.proximity) {
//                case CLProximityUnknown:
//                    prox = @"Unknown";
//                    break;
//                case CLProximityImmediate:
//                    prox = @"Immediate";
//                    break;
//                case CLProximityNear:
//                    prox = @"Near";
//                    break;
//                case CLProximityFar:
//                    prox = @"Far";
//                    break;
//                    
//                default:
//                    break;
//            }
//            NSLog(@"BEACON %@-%@-%@ acc : %f, prox : %@, rssi : %ld",beacon.proximityUUID,
//                  beacon.major,
//                  beacon.minor,
//                  beacon.accuracy,
//                  prox,
//                  (long)beacon.rssi);
//        }
        
        //先处理Trigger，因为处理Sensor时会去除无效的Beacon
        [self processSensor:beacons];
        
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_async(queue, ^{[self processTrigger];});
    }else{
        
        [self processAllDisappearOfRegion:region];
        //删除所有的发现对象。
        //[self.foundSensores removeAllObjects];
        //不删除所有的Trigger对象。由使用端判断是否需要再次添加。
        //[self.triggers removeAllObjects];
    }
}

- (void) processAllDisappearOfRegion: (CLBeaconRegion *)region{
    //如果原来有Beacon，而现在任何Beacon了，则通知底层Beacon消失了。
    if (self.foundSensores.count > 0) {
        NSPredicate * endedPre = [NSPredicate predicateWithFormat:
                                  @"uuid like %@ && isOutOfRegion != YES"
                                  ,[region.proximityUUID UUIDString]];
        
        NSArray * disappear = [[self.foundSensores allValues] filteredArrayUsingPredicate:endedPre];
        
        if (disappear.count > 0) {
            for (id<SNSensoroServiceDelegate> del in self.watcheres) {
                if ([del respondsToSelector:@selector(exitSensor:)]) {
                    [del exitSensor:disappear];
                }
            }
            //通知Observer，退出了一个区域。
            for (id<SNSensoroServiceDelegate> del in self.watcheres) {
                if ([del respondsToSelector:@selector(sensorAppear:disappear:)]) {
                    [del sensorAppear:nil disappear:disappear];
                }
            }
            for (SNTrigger * trigger in self.triggers) {
                if ([trigger.watcher respondsToSelector:@selector(distanceLeaveTrigger:)] &&
                    trigger.isStartTimer == YES) {
                    [trigger.watcher distanceLeaveTrigger:trigger];
                }
                trigger.isStartTimer = NO;
                trigger.distTimer = 0;
            }
            
            for (SNSensor *iter in disappear) {
                iter.isOutOfRegion = YES;
                iter.stayTime = 0;
                
                [iter clearBleDistance];
                [iter clearDistance];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region withError:(NSError *)error
{
    NSLog(@"Beacon Error : %@\n",error.description);
}

- (void)processTrigger{
    
    NSString * key = nil;
    
    NSArray * sensors = self.prevFoundSensores;//[self.foundSensores allValues];
    NSMutableArray * wantDelTrigger = [NSMutableArray arrayWithCapacity:10];
    
    //处理所有的Trigger，在每一个Trigger中检查是否在其有效地Beacon内部，如果在了，则更新其计数器。
    //如果前面在了，后面没在，则重置其计数器。
    NSArray * triggersTemp = [NSArray arrayWithArray:self.triggers];
    for (SNTrigger * trigger in triggersTemp) {
        BOOL isRanged = NO;
        //在所有的发现的Beacon中查找，如果发现任何一个Beacon在其所属的内部，则认为在Trigger的内部，则
        //增加Trigger的时间计数。
        for (SNSensor * iter in sensors) {
            //做一个Key，查找相应的内容
            key = [NSString stringWithFormat:@"%@-%@-%@",
                   iter.uuid,iter.major,iter.minor];
            
            CLLocationAccuracy min = iter.minDistance;
            CLLocationAccuracy minBle = iter.minBleDistance;
            NSString * findKey = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0-9-15";
            if ([findKey isEqualToString:key]) {
                NSLog(@"min ble distance %f ibeacon distance : %f",minBle,min);
            }
            
            if ([trigger.triggerSensores objectForKey:key]) {
                if ((min > 0 && min != INVALID_DISTANCE &&
                    min < trigger.stayDistLimit) ||
                    (minBle > 0 && minBle != INVALID_DISTANCE &&
                     minBle < trigger.stayDistLimit))//任何一个达到距离，则认为在Trigger范围内。
                {
                    if (trigger.isStartTimer == NO) {//如果原来没有在范围内，则出发距离Trigger。
                        if ([trigger.watcher respondsToSelector:@selector(distanceTrigger:sensor:)]) {
                            
                            [trigger.watcher distanceTrigger:trigger sensor:iter];
                        }
                        trigger.isStartTimer = YES;
                    }
                    
                    trigger.distTimer++;//增加一次时间计数，每秒钟此函数被调用一次。
                    isRanged = YES;//如果发现任何一个Trigger的传感器在范围内，则认为在trigger的范围内。
                    
                    
                    if (trigger.stayTimeLimit > 0 && //等于0表示不用出发timer。
                        trigger.distTimer > trigger.stayTimeLimit &&
                        trigger.isTimerTiggered == NO) {
                        if ([trigger.watcher respondsToSelector:@selector(timeTrigger:sensor:)]) {
                            [trigger.watcher timeTrigger:trigger sensor:iter];
                        }
                        
                        
                        trigger.isTimerTiggered = YES;
                        
                        if (trigger.isTimerAutoDelete == YES) {
                            //Trigger被触发后，删除掉此Trigger，
                            [wantDelTrigger addObject:trigger];
                        }else{
                        }
                    }
                }
                
                //已经操作过了，Trigger就不再处理了。防止一个Trigger内的多个Sensor多次对Trigger操作。
                break;
            }
        }
        
        //如果所有的Beacon都没有在此Trigger的范围内，则停止Trigger的计时，并清除计数。
        if (isRanged == NO && trigger.isStartTimer == YES) {
            //如果计时已经启动，则所有的都超出了距离。则发送距离离开消息。
            if ([trigger.watcher respondsToSelector:@selector(distanceLeaveTrigger:)]) {
                [trigger.watcher distanceLeaveTrigger:trigger];
            }
            trigger.isStartTimer = NO;
            trigger.distTimer = 0;
        }
    }
    
    @synchronized(self.triggers){
        //删除掉那些要删除掉的Trigger
        [self.triggers removeObjectsInArray:wantDelTrigger];
    }
}

- (void)processSensor:(NSArray*) beacons{
    //新发现的Beacon
    NSMutableArray * newFound = [NSMutableArray arrayWithCapacity:beacons.count];
    //消失的Beacon
    NSMutableArray * disappear = [NSMutableArray arrayWithCapacity:beacons.count];
    
    NSString * key = nil;
    
    //用于记录一个临时的记录，以便处理Trigger时处理。
    self.prevFoundSensores = [self.foundSensores allValues];
    
    for (CLBeacon * iter in beacons) {
        key = [NSString stringWithFormat:@"%@-%@-%@",
               [iter.proximityUUID UUIDString],iter.major,iter.minor];
        SNSensor * sensor = [self.foundSensores objectForKey:key];
        
        if (sensor == nil) {
            
            if (iter.proximity == CLProximityUnknown ||
                iter.rssi > RSSI_MAX) {//大于RSSI_MAX的rssi都应该过滤掉，因为发射功率
                continue;
            }
            sensor = [SNSensor getInstanceFrom:iter];
            
            [self.foundSensores setObject:sensor forKey:key];
            
            [newFound addObject:sensor];
        }else{
            //不要对其进行过滤，在beacon消失时，ios会发送很多的unkown过来，
            //标示这个beacon已经消失。
            //if (iter.proximity == CLProximityUnknown) {
            //    continue;
            //}
            sensor.stayTime++;
            
            if (iter.proximity != CLProximityUnknown && iter.rssi > RSSI_MAX) {
                continue;
            }
            
            [sensor pushDistance:iter.accuracy];
            
            if (self.isBackgroundMonitor) {
                //在后台模式下，不能接收到ble信号所以要通过这里更新ble的距离，以使其保持最新的。
                [sensor pushBleDistance:iter.accuracy];
            }
        }
        
        NSString * findKey = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0-9-15";
        if ([findKey isEqualToString:key]) {
            NSLog(@"ble distance %f ibeacon distance : %f",sensor.bleDistance,sensor.distance);
        }
        
        if (sensor.distance >= 0 || sensor.bleDistance >= 0) {
            sensor.isOutOfRegion = NO;
        }else{
            [disappear addObject:sensor];
            sensor.isOutOfRegion = YES;
            sensor.stayTime = 0;
            [self.foundSensores removeObjectForKey:key];
        }
    }
    
    //处理蓝牙发现的内容。
    NSArray * array = self.bleFoundBeacons.allValues;
    for (SNBeacon * iter in array) {
        key = iter.key;
        SNSensor * sensor = [self.foundSensores objectForKey:key];
        
        if (sensor == nil) {
            
            if (iter.proximity == CLProximityUnknown ||
                iter.lastedRssi > RSSI_MAX) {
                continue;
            }
            sensor = [SNSensor getInstanceFromBleBeacon:iter];
            
            [self.foundSensores setObject:sensor forKey:key];
            
            [newFound addObject:sensor];
        }else{
            //不要对其进行过滤，在beacon消失时，ios会发送很多的unkown过来，
            //标示这个beacon已经消失。
            //if (iter.proximity == CLProximityUnknown) {
            //    continue;
            //}
            
            if (iter.lastedRssi > RSSI_MAX &&
                iter.lastedRssi != 0) {
                continue;
            }
            
            [sensor pushBleDistance:iter.accuracy];
        }
    }
    
    //触发进入Beacon区域。
    if (newFound.count > 0) {
        //通知Observer，退出了一个区域。
        for (id<SNSensoroServiceDelegate> del in self.watcheres) {
            if ([del respondsToSelector:@selector(enterSensor:)]) {
                [del enterSensor:newFound];
            }
        }
    }
    
    if (disappear.count > 0) {
        //通知Observer，退出了一个区域。
        for (id<SNSensoroServiceDelegate> del in self.watcheres) {
            if ([del respondsToSelector:@selector(exitSensor:)]) {
                [del exitSensor:disappear];
            }
        }
    }
    
    if (newFound.count > 0 || disappear.count > 0) {
        //通知Observer，退出了一个区域。
        for (id<SNSensoroServiceDelegate> del in self.watcheres) {
            if ([del respondsToSelector:@selector(sensorAppear:disappear:)]) {
                [del sensorAppear:newFound disappear:disappear];
            }
        }
    }
}

#pragma mark Handle for Notification

-(void)handleEnteredBackground:(UIApplication*)application
{
    //已经开始监测Beacon，但是是在前台启动的，所以没有启动后台模式。
    if ([self.watchedRegions count] > 0 && self.isBackgroundMonitor == NO) {
        [self.locationManager startUpdatingLocation];
        self.isBackgroundMonitor = YES;
    }
}

-(void)handleBecomeActive:(UIApplication*)application
{
    //进入前台运行时
    if (self.isBackgroundMonitor == YES) {
        [self.locationManager stopUpdatingLocation];
        self.isBackgroundMonitor = NO;
    }
}

#pragma mark Trigger

- (void) addTrigger:(SNTrigger*) trigger
{
    @synchronized(self.triggers){
        [self.triggers addObject:trigger];
    }
}

- (void) removeTrigger:(SNTrigger*) trigger
{
    @synchronized(self.triggers){
        [self.triggers removeObject:trigger];
    }
}

#pragma mark - Central Methods

/** centralManagerDidUpdateState is a required protocol method.
 *  Usually, you'd check for other states to make sure the current device supports LE, is powered on, etc.
 *  In this instance, we're just using it to wait for CBCentralManagerStatePoweredOn, which indicates
 *  the Central is ready to be used.
 */
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    // The state must be CBCentralManagerStatePoweredOn...
    
    // ... so start scanning
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:SCAN_TIMER_INTERVAL target:self selector:@selector(scanResult:) userInfo:nil repeats:YES];
    
    //[self scan];
}

/** Scan for peripherals - specifically for our service's 128bit CBUUID
 */
- (void)scan
{
    [self.centralManager scanForPeripheralsWithServices:nil
                                                options:nil];
    
    //NSLog(@"Scanning started");
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
//    NSString* txPower = [advertisementData objectForKey:CBAdvertisementDataTxPowerLevelKey];
//    
    NSData * data = [advertisementData objectForKey:CBAdvertisementDataManufacturerDataKey];
    if (data != nil) {
        
        SNBeacon * beacon = [SNBeacon getInstanceFromData:data rssi:RSSI.integerValue];
        
        beacon.lastSeenTime = [NSDate date];
        
        if (beacon != nil) {
            NSString * key = [beacon key];
            
            SNBeacon * exist = [self.bleFoundBeacons objectForKey:key];
            if (exist != nil) {
                //添加一个新的
                [exist pushRSSI:RSSI.integerValue];
                
                NSString * key = @"E2C56DB5-DFFB-48D2-B060-D0F5A71096E0-9-15";
                if ([beacon.key isEqualToString:key]) {
                    NSLog(@"flash distance by ble %@ at %f",key,beacon.accuracy);
                }
            }else{
                //添加新的beacon
                [self.bleFoundBeacons setObject:beacon forKey:key];
                
                NSLog(@"find a beacon by ble %@ at %f",key,beacon.accuracy);
                exist = beacon;
            }
        }
    }
}

- (void)scanResult:(NSTimer*) timer{
    if (timer == self.scanTimer) {
        if ((self.timerCount % 2) == 0) {
            //每次扫描开始前，处理Beacon，处理完成后，开始扫描新的beacon；
            [self processBeacons];
            [self scan];//整数秒时开始扫描
        }else if((self.timerCount % 2) == 1){
            [self.centralManager stopScan];//.5秒时停止扫描。
        }else{
        }
        
        self.timerCount ++;
        
        if (self.timerCount >= UINT32_MAX) {
            self.timerCount = 0;
        }
    }
}

- (void) processBeacons{
    NSArray * array = self.bleFoundBeacons.allValues;
    NSMutableArray * willDisappear = [NSMutableArray arrayWithCapacity:10];//
    NSMutableArray * didDisappear = [NSMutableArray arrayWithCapacity:10];//
    
    NSDate * now = [NSDate date];
    for (SNBeacon* beacon in array) {
        NSTimeInterval interval = [now timeIntervalSinceDate:beacon.lastSeenTime];
        
        if (interval < WILL_DISAPPEAR) {//还存在
            
        }else if (interval >= WILL_DISAPPEAR && interval < DISAPPEARED) {//将要消失
            [willDisappear addObject:beacon];
        }else if(interval >= DISAPPEARED){//已经消失。
            [didDisappear addObject:beacon];
        }
    }
    
    for (SNBeacon* beacon in didDisappear) {
        [self.bleFoundBeacons removeObjectForKey:beacon.key];
        
        SNSensor * sensor = [self.foundSensores objectForKey:beacon.key];
        if (sensor != nil) {
            [sensor clearBleDistance];
        }
    }
    
    for (SNBeacon* beacon in willDisappear) {
        [beacon pushRSSI:0];
    }
}

@end
