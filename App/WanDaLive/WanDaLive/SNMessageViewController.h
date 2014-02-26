//
//  SNMessageViewController.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"

@interface SNMessageViewController : UIViewController <RequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messageTable;
- (IBAction)backToPrev:(id)sender;
@end