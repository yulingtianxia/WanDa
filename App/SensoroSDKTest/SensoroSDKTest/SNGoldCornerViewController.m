//
//  SNGoldCornerViewController.m
//  WanDaLive
//
//  Created by David Yang on 13-11-25.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNGoldCornerViewController.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "URLManager.h"
#import "SNTopModel.h"
#import "SNMessageManager.h"
#import "SNGlobalTrigger.h"
#import "TMToast.h"

@interface SNGoldCornerViewController ()

@property (nonatomic,strong) AVAudioPlayer *audioPlayer;
@property (nonatomic,strong) AVAudioPlayer *successPlayer;
@property (nonatomic,strong) SNRequest * cornerRequest;

@end

@implementation SNGoldCornerViewController

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
    
    CGFloat round = 5;
    self.goldMessage.layer.cornerRadius = round;
    
    NSURL* musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"shake_sound_male" ofType:@"m4r"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];

    musicFile = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"shake_match" ofType:@"m4r"]];
    self.successPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile error:nil];
    
    //initialize request

}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [self updateGoldStatus];
    
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

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        // call the following function when the sound is no longer used
        // (must be done AFTER the sound is done playing)
        if (self.cornerRequest != nil) {
            [TMToast showToastWithText:@"正在获取中。。。"];
        }else{
            if ([SNGlobalTrigger sharedInstance].isInGloldCorner){
                [self.audioPlayer play];
                
                NSMutableDictionary *params = nil;
                //self.cornerRequest = [SNRequest getRequestWithParams:params delegate:self requestURL:[URLManager cornerTitle:[SNTopModel sharedInstance].userInfo.userID]];
                self.cornerRequest = [SNRequest getRequestWithParams:params
                                                            delegate:self
                                                          requestURL:[URLManager cornerAward:[SNTopModel sharedInstance].uid]];
                [self.cornerRequest connect];
            }else{
                [TMToast showToastWithText:@"请在淘金角区域摇动手机"];
            }
        }
    }
}

#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"gold corner request war failed");
    self.cornerRequest = nil;
}

- (void)request:(SNRequest *)request didLoad:(id)result
{
    if (request == self.cornerRequest) {
        NSString * title = [result objectForKey:@"title"];
        if([title isEqualToString:@"nothing"])
        {
            self.goldTip.text = @"您啥都没有摇到。";
        } else
        {
            [self.successPlayer play];

            NSString *congratulate = @"恭喜您，摇到了 ";
            NSString * tipMessage = [[congratulate stringByAppendingString:title] stringByAppendingString:@"一张"];
            self.goldTip.text = tipMessage;
//            [[SNMessageManager sharedInstance] addMessageWithTitle:@"aaa" message:tipMessage];
            [[SNMessageManager sharedInstance] updateCouponNumber:1];
            [[SNMessageManager sharedInstance] updateMessageNumber:1];
        }
        
        self.cornerRequest = nil;
    }
}

#pragma mark SNBusinessTrigger

- (void)enterGoldCorner
{
//    self.goldTip.text = @"请摇动您的手机！";
    [self updateGoldStatus];
}

- (void)leaveGoldCorner
{
//    self.goldTip.text = @"您已离开淘金角！";
    [self updateGoldStatus];
}

- (void) updateGoldStatus{
    if ([SNGlobalTrigger sharedInstance].isInGloldCorner) {
        self.goldTip.text = @"请摇动您的手机";
        self.goldImage.image = [UIImage imageNamed:@"gold-enable"];
    } else
    {
        self.goldTip.text = @"您不在淘金角";
        self.goldImage.image = [UIImage imageNamed:@"gold-disable"];
    }
}

@end
