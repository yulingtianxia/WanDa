//
//  SNMyCreditsViewController.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMyCreditsViewController.h"
#import "Circle.h"
#import "Credit.h"
#import "SNWeiboAlert.h"
#import "SNRequest.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "SNMessageManager.h"
#import "SNMyCreditsCell.h"
#import "MJRefresh.h"
#import "SNCommonUtils.h"

#define radius 0.65
#define Yoffset 0.22
#define CreditHeight 100
#define payTFHeight 30
#define payBtHeight 35
#define payGuideHeight 60
#define payGuideContent @"在积分兑换处挑选礼物，输入相应积分数，确认后即可兑换"


#define USER_ID             @"123"
// ([SNTopModel sharedInstance].uid)
@interface SNMyCreditsViewController ()<MJRefreshBaseViewDelegate,CustomIOS7AlertViewDelegate>
{
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
}
@property (nonatomic,strong) NSString  * leastTimeStamp;//列表末尾的信息的时间戳
@property (nonatomic,strong) SNRequest * fetchMessagesRequest;//获取最新的20条信息，包括页面更新及下拉刷新
@property (nonatomic,strong) SNRequest * appendMessagesRequest;//用于上拉加载，扩充消息内容
@property (nonatomic) BOOL isBottom;

@end

@implementation SNMyCreditsViewController
@synthesize credit;
@synthesize bottomcredit;
@synthesize circle;
@synthesize bottomcircle;
@synthesize payScoreBt;
@synthesize CurCreditLabel;
@synthesize UseCreditGuideLabel;
@synthesize ChangeToPayModeBt;
@synthesize payScoreTF;
@synthesize fetchCreditsRequest;
@synthesize delCreditsRequest;
CGRect payBtFrame;
CGRect payTFFrame;
CGRect CurCreditLbFrame;
CGRect PayGuideLbFrame;
double newscore;
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    // Do any additional setup after loading the view.
    //设置支付积分输入框代理
    payScoreTF.delegate = self;
    //设置SNTriggerDelegate
    [[SNGlobalTrigger sharedInstance] addObserver:self];
    //获取设备分辨率
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    NSLog(@"scale:%f",[UIScreen mainScreen].scale);
    //    NSLog(@"%f,%f",size_screen.height,size_screen.width);
    [self.view setBackgroundColor:[UIColor colorWithRed:(255.0/255.0)green:(255.0/255.0) blue:(255.0/255.0) alpha:1.0]];
    CGRect circleFrame = CGRectMake(size_screen.width*(1-radius)/2, size_screen.height*Yoffset, size_screen.width*(radius), size_screen.width*(radius));
    CGRect creditFrame = CGRectMake(size_screen.width*(1-radius)/2, circleFrame.size.height/2+circleFrame.origin.y-CreditHeight/2, size_screen.width*(radius), CreditHeight);
    payTFFrame = CGRectMake(size_screen.width*(1-radius/2)/2, circleFrame.size.height*3/4+circleFrame.origin.y-payTFHeight/2, size_screen.width*(radius)/2, payTFHeight);
    payBtFrame = CGRectMake((size_screen.width-payBtHeight)/2, circleFrame.origin.y+circleFrame.size.height-payBtHeight/2, payBtHeight, payBtHeight);
    CurCreditLbFrame = CGRectMake(size_screen.width*(1-radius/2)/2, circleFrame.size.height*3/4+circleFrame.origin.y-payTFHeight/2, size_screen.width*(radius)/2, payTFHeight);
    PayGuideLbFrame = CGRectMake(circleFrame.origin.x, circleFrame.origin.y+circleFrame.size.height+20, circleFrame.size.width, payGuideHeight);
    //Circle
    circle = [[Circle alloc] initWithFrame:circleFrame];
    circle.color = [UIColor colorWithRed:(250.0/255.0) green:(179.0/255.0) blue:(106.0/255.0) alpha:1.0];
    
    [self.view insertSubview: circle atIndex:1];
    bottomcircle = [[Circle alloc] initWithFrame:circleFrame];
    bottomcircle.color = [UIColor colorWithRed:(254.0/255.0) green:(238.0/255.0) blue:(225.0/255.0) alpha:1.0];
    [self.view insertSubview:bottomcircle atIndex:0];
    //Credit
    credit = [[Credit alloc]initWithFrame:creditFrame];
    [self.view insertSubview:credit atIndex:3];
    bottomcredit = [[Credit alloc]initWithFrame:creditFrame];
    bottomcredit.textColor=[UIColor colorWithRed:(250.0/255.0) green:(179.0/255.0) blue:(106.0/255.0) alpha:1.0];
    [self.view insertSubview:bottomcredit atIndex:2];
    //当前积分Label
    CurCreditLabel = [[UILabel alloc]initWithFrame:CurCreditLbFrame];
    [CurCreditLabel setTextColor:[UIColor whiteColor]];
    [CurCreditLabel setText:@"当前积分"];
    [CurCreditLabel setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:15]];
    [CurCreditLabel setBackgroundColor:[UIColor clearColor]];
    [CurCreditLabel setTextAlignment:NSTextAlignmentCenter];
    [self.view insertSubview:CurCreditLabel atIndex:4];
    //使用积分向导
    UseCreditGuideLabel = [[UILabel alloc]initWithFrame:PayGuideLbFrame];
    [UseCreditGuideLabel setTextAlignment:NSTextAlignmentCenter];
    [UseCreditGuideLabel setTextColor:[UIColor colorWithRed:(250.0/255.0) green:(179.0/255.0) blue:(106.0/255.0) alpha:1.0]];
    [UseCreditGuideLabel setText:payGuideContent];
    [UseCreditGuideLabel setNumberOfLines:0];
    [UseCreditGuideLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [UseCreditGuideLabel setBackgroundColor:[UIColor clearColor]];
    UseCreditGuideLabel.alpha = 0.0;
    [self.view insertSubview:UseCreditGuideLabel atIndex:4];
    //积分文本输入框和支付按钮
    
    payScoreTF = [[UITextField alloc]initWithFrame:payTFFrame];
    [payScoreTF setTextColor:[UIColor whiteColor]];
    [payScoreTF setBackgroundColor:[UIColor colorWithRed:(247.0/255.0) green:(201.0/255.0) blue:(153.0/255.0) alpha:1.0]];
    payScoreTF.placeholder =@"使用积分";
    [payScoreTF setTextColor:[UIColor whiteColor]];
    [payScoreTF setBorderStyle:UITextBorderStyleRoundedRect];
    [payScoreTF setReturnKeyType:UIReturnKeyDone];
    [payScoreTF setDelegate:self];
    [payScoreTF setAlpha:0.0];
    [payScoreTF setKeyboardType:UIKeyboardTypeDecimalPad];
    [payScoreTF setReturnKeyType:UIReturnKeyDone];
    [payScoreTF setTextAlignment:NSTextAlignmentCenter];
    [self.view insertSubview:payScoreTF atIndex:4];
    payScoreBt = [[UIButton alloc]initWithFrame:payBtFrame];
    [payScoreBt setBackgroundImage:[UIImage imageNamed:@"ok"] forState:UIControlStateNormal];
    [payScoreBt addTarget:self action:@selector(payScore:) forControlEvents:UIControlEventTouchUpInside];
    [payScoreBt setAlpha:0.0];
    [self.view insertSubview:payScoreBt atIndex:4];
    
    //获取上一次的用户积分
    [self refreshCredits];
    //获取当前积分
    NSString *uid=[SNTopModel sharedInstance].userInfo.userID;
    fetchCreditsRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchCredits:uid]];
    [fetchCreditsRequest connect];
    //保存当前用户积分到本地
    [self saveUserScore:newscore];
    
    
    
    //my credits tables config
    //适配屏幕大小，从而使下拉刷新可用
    self.automaticallyAdjustsScrollViewInsets = NO;
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.backgroundColor = [UIColor clearColor];
    _header.delegate = self;
    _header.scrollView = self.myCreditsTable;
    
    // 上拉加载更多
    _footer = [[MJRefreshFooterView alloc] init];
    _footer.backgroundColor = [UIColor clearColor];
    _footer.delegate = self;
    _footer.scrollView = self.myCreditsTable;
    
    self.leastTimeStamp = [SNCommonUtils timeStamp];
    self.fetchMessagesRequest = [SNRequest getRequestWithParams:nil
                                                       delegate:self
                                                     requestURL:
                                 [URLManager fetchCriditsMessages:USER_ID
                                                 timestamp:_leastTimeStamp]];
    [self.myCreditsTable reloadData];
    [self.fetchMessagesRequest connect];
}

-(void)viewWillAppear:(BOOL)animated{
    //判断用户是否进入支付beacon，决定是否显示支付按钮
    if ([SNGlobalTrigger sharedInstance].isInVerifyArea == YES) {
        ChangeToPayModeBt.enabled = YES;
        ChangeToPayModeBt.alpha=1.0;
    }
    else{
        ChangeToPayModeBt.enabled = NO;
//        ChangeToPayModeBt.alpha = 0.0;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [[SNGlobalTrigger sharedInstance] removeObserver:self];
}

-(void) saveUserScore:(double) newscore{
    NSUserDefaults *userscore = [NSUserDefaults standardUserDefaults];
    [userscore setDouble:newscore forKey:@"userscore"];
    [userscore synchronize];
    [SNTopModel sharedInstance].userInfo.credits=newscore;
}

-(double)UserScore{
    NSUserDefaults *userscore = [NSUserDefaults standardUserDefaults];
    return [userscore doubleForKey:@"userscore"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)changeToPayView{
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        circle.alpha=0.0;
        credit.alpha=0.0;
        payScoreTF.alpha=1.0;
        payScoreBt.alpha=1.0;
        payScoreBt.frame =payBtFrame;
        payScoreTF.frame = payTFFrame;
        payScoreTF.placeholder =@"使用积分";
        [payScoreTF setText:@""];
        CurCreditLabel.alpha = 0.0;
        UseCreditGuideLabel.alpha = 1.0;
    } completion:^(BOOL finished) {
        //可以消费积分啦
    }];
}

-(void)changeToViewScore{
    [UIView animateWithDuration:1.0f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        circle.alpha=1.0;
        credit.alpha=1.0;
        payScoreTF.alpha=0.0;
        payScoreBt.alpha=0.0;
        CurCreditLabel.alpha = 1.0;
        UseCreditGuideLabel.alpha = 0.0;
        payScoreBt.frame =payBtFrame;
        payScoreTF.frame = payTFFrame;
    } completion:^(BOOL finished) {
        //
    }];
}

- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)changeToPayScore:(id)sender{
    [self changeToPayView];
    
}

- (void) refreshCredits{
    [credit changeFromNumber:[self UserScore] toNumber:newscore withAnimationTime:10];
    [credit autochangeFontsize:credit.text.doubleValue];
    [bottomcredit changeFromNumber:[self UserScore] toNumber:newscore withAnimationTime:10];
    [bottomcredit autochangeFontsize:credit.text.doubleValue];
}

- (IBAction)payScore:(id)sender{
    NSString *uid=[SNTopModel sharedInstance].uid;
    //sid从哪获得？
    NSString *sid;
    if ([SNGlobalTrigger sharedInstance].isInVerifyArea) {
        sid = [SNGlobalTrigger sharedInstance].verifySID;
    }
    
    delCreditsRequest = [SNRequest getDeleteRequestWithParams:[NSMutableDictionary dictionaryWithObject:payScoreTF.text forKey:@"credits"] delegate:self requestURL:[URLManager delCredits:uid withsid:sid]];
    [delCreditsRequest connect];
//    fetchCreditsRequest = [SNRequest getRequestWithParams:Nil delegate:self requestURL:[URLManager fetchCredits:uid]];
//    [fetchCreditsRequest connect];
    [self refreshCredits];
    [self changeToViewScore];
    [self.view setNeedsDisplay];
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    
}
#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Message get was failed");
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    [_footer endRefreshing];
}
- (void)request:(SNRequest *)request didLoad:(id)result //TODOS
{
    
    if(result!=NULL&&request == fetchCreditsRequest){
        if (result[@"credits"]!=[NSNull null]) {
            newscore = [result[@"credits"] doubleValue] ;
        }
        [self refreshCredits];
    }
    if (result!=NULL&&request == delCreditsRequest) {
        NSLog(@"%@",result);
        if (result[@"credits"]!=[NSNull null]) {
            newscore = [result[@"credits"] doubleValue] ;
        }
        [self refreshCredits];
        
        //[[SNMessageManager sharedInstance] updateMessageNumber:1];
    }
    
    [self.view setNeedsDisplay];
    
    
    //读取my credits信息
    if (request == self.fetchMessagesRequest) {
        [[SNMessageManager sharedInstance] removeAllMessages];
    }
    if(request == self.fetchMessagesRequest  || request == self.appendMessagesRequest){
        // 让刷新控件恢复默认的状态
        [_header endRefreshing];
        [_footer endRefreshing];
        
        NSArray * array = (NSArray*) result;
        //NSNumber * status = [array objectAtIndex:(int)0];
        //NSArray * list = [array objectAtIndex:(int)1];
        //if([status integerValue] == 0){
        NSLog(@"result:%@",array);
        //}else{
        
        if ([array count] != 0) {
            //根据获取的数据格式生成消息串，并添加进消息列表
            [[SNMessageManager sharedInstance] setUpCreditMsgs:array];
            //获取最后一条消息的时间戳，上拉加载时使用该时间戳获取该时间之前的消息
            double lTimeStamp = [[array lastObject][@"timestamp"] doubleValue];
            self.leastTimeStamp = [NSString stringWithFormat:@"%.0f",lTimeStamp - 1];
            _isBottom = NO;
        }
        if ([array count] < 20){
            _isBottom = YES;
        }
        [_myCreditsTable reloadData];
        /*  NSString *incr = [dict objectForKey:@"incr"];
         NSString *sid = [dict objectForKey:@"sid"];
         NSString *time = [dict objectForKey:@"time"];
         
         NSString * msg = [NSString stringWithFormat:@"get %@ credits from shop %@ at %@", incr,sid,time];
         */
    }
    
    
}

#pragma mark UITextFieldDelegate
- (IBAction)ViewTouchDown:(id)sender {
    // 发送resignFirstResponder.
    
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{ //当点触textField内部，开始编辑都会调用这个方法。textField将成为first responder
    
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y -=116;
    frame.size.height +=116;
    self.view.frame = frame;
    [UIView beginAnimations:@"ResizeView"context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSTimeInterval animationDuration = 0.30f;
    CGRect frame = self.view.frame;
    frame.origin.y +=116;
    frame.size. height -=116;
    self.view.frame = frame;
    //self.view移回原位置
    [UIView beginAnimations:@"ResizeView"context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.view.frame = frame;
    [UIView commitAnimations];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark SNTriggerDelegate

-(void)enterVerifyArea:(NSString *)sid{
    ChangeToPayModeBt.enabled = YES;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseInOut animations:^{
        ChangeToPayModeBt.alpha=1.0;
    } completion:^(BOOL finished) {
        ;
    }];
}

-(void)leaveVerifyArea{
    ChangeToPayModeBt.enabled = NO;
    [UIView animateWithDuration:0.5 delay:0 options:(UIViewAnimationOptions)UIViewAnimationCurveEaseInOut animations:^{
        ChangeToPayModeBt.alpha=0.0;
    } completion:^(BOOL finished) {
        ;
    }];
}
#pragma mark CustomIOS7AlertView

- (IBAction)shareScore:(id)sender
{
    // Here we need to pass a full frame
    SNWeiboAlert *alertView = [[SNWeiboAlert alloc] init];
    
    // Add some custom content to the alert view
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    double mycredit = [ud doubleForKey:@"userscore"];
    [alertView setUpWeiboAlertWithMsg:[NSString stringWithFormat:@"我在使用万达U乐汇，现在已经有%.0f积分了哦，可以直接当钱花！传送门www.wanda.com，小伙伴们快来抢钱吧！",mycredit]];
    
    [alertView setDelegate:self];
    
    
    
    // And launch the dialog
    [alertView show];
}

- (void)customIOS7dialogButtonTouchUpInside: (CustomIOS7AlertView *)alertView clickedButtonAtIndex: (NSInteger)buttonIndex
{
    //    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", buttonIndex, [alertView tag]);
    //    [alertView close];
}

- (UIView *)createDemoView
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    double mycredit = [ud doubleForKey:@"userscore"];
    UITextView *tv = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 290, 120)];
    [tv setEditable:YES];
    [tv setTextColor:[UIColor orangeColor]];
    [tv setText:[NSString stringWithFormat:@"我在使用万达U乐汇，现在已经有%.0f积分了哦，可以直接当钱花！传送门www.wanda.com，小伙伴们快来抢钱吧！",mycredit]];
    [tv setFont:[UIFont fontWithName:@"Helvetica" size:20]];
    [tv setKeyboardType:UIKeyboardTypeDefault];
    tv.layer.borderColor = [UIColor clearColor].CGColor;
    tv.layer.borderWidth =1.0;
    tv.layer.cornerRadius =5.0;
    tv.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    return tv;
}
#pragma mark 代理方法-进入刷新状态就会调用

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    //顶部刷新
    if (_header == refreshView) {
        //更新最新的20条信息
        self.leastTimeStamp = [SNCommonUtils timeStamp];
        self.fetchMessagesRequest = [SNRequest getRequestWithParams:nil
                                                           delegate:self
                                                         requestURL:[URLManager fetchCriditsMessages:USER_ID
                                                                                           timestamp:_leastTimeStamp]];
        [self.fetchMessagesRequest connect];
    }
    //底部加载
    else {
        self.appendMessagesRequest = [SNRequest getRequestWithParams:nil
                                                            delegate:self
                                                          requestURL:[URLManager fetchCriditsMessages:USER_ID
                                                                                     timestamp:_leastTimeStamp]];
        [self.appendMessagesRequest connect];
    }
    
}

- (void)dealloc
{
    // 释放资源
    [_footer free];
    [_header free];
}
#pragma mark TableDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [SNMessageManager sharedInstance].allMessage.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//加载自定义cell
    static NSString *identifier = @"myCreditsCell";
    if (indexPath.row < [[SNMessageManager sharedInstance].allMessage count]) {
        SNMyCreditsCell *cell = (SNMyCreditsCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        NSUInteger row = [indexPath row];
        //显示message信息
        SNMessage * message = ([SNMessageManager sharedInstance].allMessage)[row];
        int index = (int)[indexPath row];
        [cell setupCell:message AtIndex:index];
//        if ([SNMessageManager sharedInstance].allMessage.count==1) {
//            [cell setupCell:message AtIndex:2];
//        }
//        else if(index==0){
//            [cell setupCell:message AtIndex:1];
//        }
//        else if(index==[SNMessageManager sharedInstance].allMessage.count-1){
//            [cell setupCell:message AtIndex:-1];
//        }
//        else{
//            [cell setupCell:message AtIndex:0];
//        }
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row >= [[SNMessageManager sharedInstance].allMessage count]) {
        return;
    }
    SNMessage * message = ([SNMessageManager sharedInstance].allMessage)[indexPath.row];
//    if ([message.type isEqualToString:@"credits"]) {
//        [self performSegueWithIdentifier:@"showPersonInfo" sender:self];
//    }else if ([message.type isEqualToString:@"shop"]){
//        [self performSegueWithIdentifier:@"showURL" sender:self];
//    }else if ([message.type isEqualToString:@"fixedcorner"]){
//        [self performSegueWithIdentifier:@"showDiscount" sender:self];
//    }else if ([message.type isEqualToString:@"hunt"]){
//        [self performSegueWithIdentifier:@"showHunt" sender:self];
//    }
    
}
@end
