//
//  SNMessageViewController.h
//  WanDaLive
//
//  Created by David Yang on 13-11-25.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SNRequest.h"

@interface SNMessageViewController : UIViewController <RequestDelegate>

@property (weak, nonatomic) IBOutlet UITableView *messageTable;
- (IBAction)backToPrev:(id)sender;
@end
