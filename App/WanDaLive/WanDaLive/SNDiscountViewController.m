//
//  SNDiscountViewController.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-12.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNDiscountViewController.h"
#import "SNTopModel.h"
#import "URLManager.h"
#import "SNMessageCell.h"
#import "SNCouponCell.h"
#import "SNCommonUtils.h"
#import "SNMessageManager.h"
#import "MJRefresh.h"
#define ROW_HEIGHT      150
#define USER_ID         @"123"
//([SNTopModel sharedInstance].uid)

@interface SNDiscountViewController ()<MJRefreshBaseViewDelegate>
{
    MJRefreshHeaderView * _header;
}
//@property (nonatomic,strong) SNRequest * userDetailRequest;
@property (nonatomic,strong) SNRequest * couponsListRequest;
@property (nonatomic,strong) SNRequest * deleteCouponRequest;
@property (nonatomic,strong) NSIndexPath* deletedIndexPath;

- (NSMutableArray *)getDataSource;

@end

@implementation SNDiscountViewController

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
    
    
    //coupon table 初始设置
	// Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.couponTableView.backgroundColor = RGB(223, 239, 247);
    self.view.backgroundColor = RGB(223, 239, 247);
    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.backgroundColor = [UIColor clearColor];
    _header.delegate = self;
    _header.scrollView = self.couponTableView;
    
    //设置刷新timer 刷新倒计时label
    NSTimer * timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Fire:) userInfo:self repeats:YES];
    
    //发送请求
    NSMutableDictionary *params = nil;
    self.couponsListRequest = [SNRequest getRequestWithParams:params delegate:self
                                                   requestURL:[URLManager listUserConpons:USER_ID]];
    [self.couponsListRequest connect];
}

//根据现在时间计算倒计时label的显示方式
-(void)Fire:(NSTimer *)timer
{
    NSMutableArray *couponsTable = nil;
    if([SNGlobalTrigger sharedInstance].isInVerifyArea){
        couponsTable = [SNTopModel sharedInstance].useableCoupons;
    }else{
        couponsTable = [SNTopModel sharedInstance].coupons;
    }
    for (int i=0; i<[couponsTable count]; i++) {
        SNCouponCell * cell = (SNCouponCell *)[self.couponTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        SNCoupons * coupon = couponsTable[i];
        cell.lblTime.text = [coupon getTimeStr];
    }
}
// 什么时候会调用呢？

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[SNGlobalTrigger sharedInstance] addObserver:self];
    
    [[SNMessageManager sharedInstance] clearCouponUpdate];
    
    //判断用户是否进入支付beacon，决定是否显示支付按钮
    if ([SNGlobalTrigger sharedInstance].isInVerifyArea) {
        [[SNTopModel sharedInstance] initUseableCoupons:[SNTopModel sharedInstance].coupons
                                                 shopId:[SNGlobalTrigger sharedInstance].verifySID];
        [self.couponTableView reloadData];
    }
    else{
    }
    //判断是否有更新，有更新刷新页面
    if ([SNMessageManager sharedInstance].newCouponCount != 0) {
        //发送请求
        NSMutableDictionary *params = nil;
        self.couponsListRequest = [SNRequest getRequestWithParams:params delegate:self
                                                       requestURL:[URLManager listUserConpons:USER_ID]];
        [self.couponsListRequest connect];
    }
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

- (void)onUseButton:(UIButton *)sender {
    NSMutableArray *coupons = [self getDataSource];
    SNCoupons * item = [coupons objectAtIndex:sender.tag];
    [self onDeleteCoupons:item];
    _deletedIndexPath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
}

#pragma mark private methods
//如果在区域内，返回可用coupons，如果不在则返回所有coupons
- (NSMutableArray *)getDataSource
{
    NSMutableArray *couponsTable = nil;
    if([SNGlobalTrigger sharedInstance].isInVerifyArea){
        couponsTable = [SNTopModel sharedInstance].useableCoupons;
    }else{
        couponsTable = [SNTopModel sharedInstance].coupons;
    }return couponsTable;
}

//发送删除coupon的请求
- (void)onDeleteCoupons:(SNCoupons *)coupons
{
    self.deleteCouponRequest = [SNRequest getDeleteRequestWithParams:nil
                                                            delegate:self
                                                          requestURL:[URLManager
                                                                      deleteCoupon:coupons.sid
                                                                      couponID:coupons.cid
                                                                      endTime:coupons.endTime]];
    [self.deleteCouponRequest connect];
}
#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    [_header endRefreshing];
    NSLog(@"coupon request failed %@",error);
}

- (void)request:(SNRequest *)request didLoad:(id)result
{
    [_header endRefreshing];
    if(request == self.couponsListRequest){
        NSArray * arry = (NSArray *) result;
        [[SNTopModel sharedInstance] initCoupons: arry];
        
        if ([SNGlobalTrigger sharedInstance].isInVerifyArea) {
            [[SNTopModel sharedInstance] initUseableCoupons:[SNTopModel sharedInstance].coupons
                                                     shopId:[SNGlobalTrigger sharedInstance].verifySID];
        }
        
        [self.couponTableView reloadData];
    }
//    NSLog(@"%@",result);
    
    
    //删除或使用优惠券操作
    if(request == self.deleteCouponRequest){
        NSDictionary * dic = (NSDictionary *) result;
        NSLog(@"%@",dic);
        if ([[dic objectForKey:@"results"] boolValue]) {
            if([SNGlobalTrigger sharedInstance].isInVerifyArea){
                [[SNTopModel sharedInstance].useableCoupons removeObjectAtIndex:_deletedIndexPath.row];
            }else{
                [[SNTopModel sharedInstance].coupons removeObjectAtIndex:_deletedIndexPath.row];
            }
            [self.couponTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_deletedIndexPath]withRowAnimation:YES];
        }
        [self.couponTableView reloadData];
    }
}


#pragma mark MJRefreshViewDelegate

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    if (_header == refreshView) {
        NSMutableDictionary *params = nil;
        self.couponsListRequest = [SNRequest getRequestWithParams:params delegate:self
                                                       requestURL:[URLManager listUserConpons:USER_ID]];
        [self.couponsListRequest connect];
    }
}



#pragma mark tableDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self getDataSource] count];
}

/**
 4、返回指定的 row 的 cell
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray *couponsTable = [self getDataSource];
    
    // 1. cell标示符，使cell能够重用
    static NSString *couponCell = @"discountShop";
    
    // 2. 从TableView中获取标示符为paperCell的Cell
    SNCouponCell *cell = (SNCouponCell *)[tableView dequeueReusableCellWithIdentifier:couponCell];
    
    // 如果 cell = nil , 则表示 tableView 中没有可用的闲置cell
    if(cell == nil){
        
        // 3. 把 WPaperCell.xib 放入数组中
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"discountShop" owner:self options:nil] ;
        
        // 获取nib中的第一个对象
        for (id oneObject in nib){
            
            // 判断获取的对象是否为自定义cell
            if ([oneObject isKindOfClass:[SNCouponCell class]]){
                
                // 4. 修改 cell 对象属性
                cell = [(SNCouponCell *)oneObject initWithStyle:UITableViewCellStyleDefault reuseIdentifier:couponCell];
            }
        }
    }
    // 5. 设置单元格属性
    [cell setupCell: couponsTable[indexPath.row]];
    cell.useButton.tag = indexPath.row;
    if ([SNGlobalTrigger sharedInstance].isInVerifyArea) {
        cell.useButton.alpha = 1.0;
        cell.useButton.enabled = YES;
    }else{
        cell.useButton.alpha = 0.0;
        cell.useButton.enabled = NO;
    }
    [cell.useButton addTarget:self action:@selector(onUseButton:) forControlEvents:UIControlEventTouchUpInside];
    //double deadLine = 1386220911 + timeInterval*indexPath.row;
    //cell.lblTime.text = [NSString stringWithFormat:@"%.0f",[SNCommonUtils intervalSinceNow:[NSDate dateWithTimeIntervalSince1970:deadLine]]];
    //cell.imPath.image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://wanda.cloudapp.net:3000/image/1386224697446.png"]]];
    
    return cell;
}

/**
 5、点击单元格时的处理
 */
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //    SNCoupons *couponModel = [[SNTopModel sharedInstance].coupons objectAtIndex: indexPath.row];
    //    NSLog(@"coupon title -> %@", couponModel.title);
    //    NSLog(@"coupon time -> %@", couponModel.endTime);
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ROW_HEIGHT;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *coupons = [self getDataSource];
        SNCoupons * item = [coupons objectAtIndex:indexPath.row];
        [self onDeleteCoupons:item];
        _deletedIndexPath = indexPath;
    }
}

#pragma mark SNBusinessDelegate

- (void) enterVerifyArea:(NSString*) sid;
{
    // 取可用的
    NSMutableArray *arry = [SNTopModel sharedInstance].coupons;
    [[SNTopModel sharedInstance] initUseableCoupons: arry shopId:sid ];
    [self.couponTableView reloadData];
    // showCoupons(coupons);
    
}
- (void) leaveVerifyArea
{
    // showCoupons(coupons);
    [self.couponTableView reloadData];
}

@end