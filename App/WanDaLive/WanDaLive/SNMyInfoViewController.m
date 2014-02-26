//
//  SNMyInfoViewController.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMyInfoViewController.h"

@interface SNMyInfoViewController ()

@end

@implementation SNMyInfoViewController

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
