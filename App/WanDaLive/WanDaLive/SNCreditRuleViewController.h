//
//  SNCreditRuleViewController.h
//  WanDaLive
//
//  Created by 森哲 on 13-12-16.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"
#import "SNShop.h"
@interface SNCreditRuleViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,RequestDelegate>
@property (strong, nonatomic) IBOutlet UITableView *creditRuleTable;
@property (strong, nonatomic) SNRequest *creditRuleRequest;
@property (strong, nonatomic) NSMutableArray *shops;

- (IBAction)backToPrev:(id)sender;

@end
