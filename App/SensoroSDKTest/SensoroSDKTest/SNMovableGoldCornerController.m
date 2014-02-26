//
//  SNMovableGoldCornerController.m
//  WanDaLive
//
//  Created by David Yang on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMovableGoldCornerController.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "SNMessageManager.h"

@interface SNMovableGoldCornerController ()

@property (nonatomic,strong) SNRequest * movableRequest;

@end

@implementation SNMovableGoldCornerController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateStatus];
    
    [[SNGlobalTrigger sharedInstance] addObserver:self];
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    [[SNGlobalTrigger sharedInstance] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark SNBusinessTrigger

- (void)enterMovableGoldCorner
{
    [self updateStatus];
}

- (void)leaveMovableCorner
{
    [self updateStatus];
}

- (void) movableGoldCornerSuccess{
    
    [self sendMovableRequest];
    
}

- (void) updateStatus{
    if ([SNGlobalTrigger sharedInstance].isInMovableGloldCorner == YES) {
        self.cornerTip.text = @"您找到它了，跟踪它。";
    }else{
        self.cornerTip.text = @"您还没有发现它，继续搜索！。";
    }
}


- (void) sendMovableRequest{
    NSMutableDictionary * params = nil;
    
    self.movableRequest = [SNRequest getRequestWithParams:params
                                                delegate:self
                                              requestURL:
                           [URLManager movableCornerAward:[SNTopModel sharedInstance].uid]];
    [self.movableRequest connect];
}

#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Movable request was failed");
    if (self.movableRequest == request) {
        self.movableRequest = nil;
    }
}

- (void)request:(SNRequest *)request didLoad:(id)result
{
    if (self.movableRequest == request) {
        NSString * title = [result objectForKey:@"title"];
        if([title isEqualToString:@"nothing"])
        {
            self.cornerTip.text = @"您啥都没有摇到。";
        }else{
            NSString *congratulate = @"恭喜您，摇到了 ";
            NSString * tipMessage = [[congratulate stringByAppendingString:title] stringByAppendingString:@"一张"];
            self.cornerTip.text = tipMessage;
            [[SNMessageManager sharedInstance] updateCouponNumber:1];
            [[SNMessageManager sharedInstance] updateMessageNumber:1];
        }
        
        self.movableRequest = nil;
    }
}

@end
