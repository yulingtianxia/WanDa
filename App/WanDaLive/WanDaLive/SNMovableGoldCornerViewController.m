//
//  SNMovableGoldCornerViewController.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMovableGoldCornerViewController.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "SNMessageManager.h"

@interface SNMovableGoldCornerController ()

@property (nonatomic,strong) SNRequest * movableRequest;

@end

@implementation SNMovableGoldCornerController
@synthesize page;
@synthesize imageScrollView;
@synthesize timeCount;
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
    //设置滚动视图的页数和每页的frame
    imageScrollView.contentSize= CGSizeMake(PAGENUM * 320.0f, imageScrollView.frame.size.height);
    imageScrollView.pagingEnabled= YES;
    imageScrollView.showsHorizontalScrollIndicator= NO;
    imageScrollView.delegate= self;
    //这里为滚动视图添加了子视图
    
    for(int i = 0; i < PAGENUM; i++) {
        NSString* fileName = [NSString stringWithFormat:@"myinfo_0%d",i+1];
        UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(i * 320.0f,  0.0f, 320.0f, 150.0f)];
        [image setImage:[UIImage imageNamed:fileName]];
        [imageScrollView addSubview:image];
        
    }
    //定义PageController 设定总页数，当前页，定义当控件被用户操作时,要触发的动作。
    
    page.numberOfPages= PAGENUM;
    page.currentPage= 0;
    
    [page addTarget:self action:@selector(pageTurn:) forControlEvents:UIControlEventValueChanged];
    //使用NSTimer实现定时触发滚动控件滚动的动作。
    timeCount= 0;
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scrollTimer) userInfo:nil repeats:YES];
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
//滚图的动画效果
#pragma mark PageControllViewDelegate
-(void)pageTurn:(id)sender{
    
    int whichPage = page.currentPage;
    
    [UIView beginAnimations:nil context:NULL];
    
    [UIView setAnimationDuration:0.3f];
    
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    
    [imageScrollView setContentOffset:CGPointMake(320.0f * whichPage, 0.0f) animated:YES];
    
    [UIView commitAnimations];
    
}
#pragma mark ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int curpage = scrollView.contentOffset.x /320;//通过滚动的偏移量来判断目前页面所对应的小白点
    page.currentPage = curpage;//pagecontroll响应值的变化
}
#pragma mark NSTimerDelegate
-(void)scrollTimer{
    
    timeCount++;
    if(timeCount == PAGENUM){
        timeCount= 0;
    }
    [imageScrollView scrollRectToVisible:CGRectMake(timeCount * 320.0, 65.0, 320.0, 218.0) animated:YES];
    
}
@end
