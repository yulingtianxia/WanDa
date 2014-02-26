//
//  SNWebViewController.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNWebViewController.h"

@interface SNWebViewController ()

@end

@implementation SNWebViewController

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
    self.webView.delegate = self;
    NSURL * url = [NSURL URLWithString:self.url];
    NSLog(@"%@",url);
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)closeView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)webViewDidStartLoad:(UIWebView *)webView{
    NSLog(@"didstartload");
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSLog(@"didfinishload");
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"didfailloadwitherror:%@",error);
}
@end
