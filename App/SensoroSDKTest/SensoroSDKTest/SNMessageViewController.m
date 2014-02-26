//
//  SNMessageViewController.m
//  WanDaLive
//
//  Created by David Yang on 13-11-25.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMessageViewController.h"
#import "SNMessageManager.h"
#import "SNMessageCell.h"
#import "SNLoadMoreCell.h"
#import "SNCommonUtils.h"
#import "SNSharedResource.h"
#import "URLManager.h"
#import "SNRequest.h"
#import "MJRefresh.h"
#import "SNTopModel.h"
#import "EGOImageView.h"

#define MSG_FONT ([[SNSharedResource sharedInstance] commonSmallFont])

@interface SNMessageViewController ()<MJRefreshBaseViewDelegate>
{
    MJRefreshFooterView *_footer;
    MJRefreshHeaderView *_header;
}

@property (nonatomic,strong) SNRequest * fetchMessagesRequest;//获取最新的20条信息，包括页面更新及下拉刷新
@property (nonatomic,strong) SNRequest * appendMessagesRequest;//用于上拉加载，扩充消息内容
@property (nonatomic,strong) NSString  * leastTimeStamp;//列表末尾的信息的时间戳
@property (nonatomic) BOOL isBottom;

@end

@implementation SNMessageViewController

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
    //适配屏幕大小，从而使下拉刷新可用
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.messageTable.backgroundColor = RGB(223, 239, 247);
    self.view.backgroundColor = RGB(223, 239, 247);
    
//    //测试用数据
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    formatter.dateFormat = @"HH : mm : ss.SSS";
//    for (int i = 0; i < 10; i++) {
//        [[SNMessageManager sharedInstance]addMessageWithTitle:@"淘金角" message:[formatter stringFromDate:[NSDate date]]];
//    }

    // 下拉刷新
    _header = [[MJRefreshHeaderView alloc] init];
    _header.backgroundColor = [UIColor clearColor];
    _header.delegate = self;
    _header.scrollView = self.messageTable;
    
    // 上拉加载更多
    _footer = [[MJRefreshFooterView alloc] init];
    _footer.backgroundColor = [UIColor clearColor];
    _footer.delegate = self;
    _footer.scrollView = self.messageTable;
    
    self.leastTimeStamp = [SNCommonUtils timeStamp];
    self.fetchMessagesRequest = [SNRequest getRequestWithParams:nil
                                                       delegate:self
                                                     requestURL:
                                 [URLManager fetchMessages:[SNTopModel sharedInstance].uid
                                                 timestamp:_leastTimeStamp]];
    [self.messageTable reloadData];
    [self.fetchMessagesRequest connect];
	// Do any additional setup after loading the view.
}

- (void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [[SNMessageManager sharedInstance] clearMessageUpdate];
    
    if ([SNMessageManager sharedInstance].newMessageCount != 0) {
        self.leastTimeStamp = [SNCommonUtils timeStamp];
        self.fetchMessagesRequest = [SNRequest getRequestWithParams:nil
                                                           delegate:self
                                                         requestURL:[URLManager fetchMessages:[SNTopModel sharedInstance].uid
                                                                                    timestamp:_leastTimeStamp]];
        [self.messageTable reloadData];
        [self.fetchMessagesRequest connect];
    }
    
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadMore {
    self.appendMessagesRequest = [SNRequest getRequestWithParams:nil
                                                        delegate:self
                                                      requestURL:[URLManager fetchMessages:[SNTopModel sharedInstance].uid
                                                                                 timestamp:_leastTimeStamp]];
    [self.appendMessagesRequest connect];
}

#pragma mark 代理方法-进入刷新状态就会调用

- (void)refreshViewBeginRefreshing:(MJRefreshBaseView *)refreshView
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH : mm : ss.SSS";
    
    //顶部刷新
    if (_header == refreshView) {
        //更新最新的20条信息
        self.leastTimeStamp = [SNCommonUtils timeStamp];
    self.fetchMessagesRequest = [SNRequest getRequestWithParams:nil
                                                       delegate:self
                                                     requestURL:
                                 [URLManager fetchMessages:[SNTopModel sharedInstance].uid
                                                 timestamp:_leastTimeStamp]];
    [self.fetchMessagesRequest connect];
    }
    //底部加载
    else {
        self.appendMessagesRequest = [SNRequest getRequestWithParams:nil
                                                            delegate:self
                                                          requestURL:[URLManager fetchMessages:[SNTopModel sharedInstance].uid
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
    return [SNMessageManager sharedInstance].allMessage.count+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//加载自定义cell
    static NSString *identifier = @"messageCell";
    if (indexPath.row < [[SNMessageManager sharedInstance].allMessage count]) {
        SNMessageCell *cell = (SNMessageCell*)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
	
        NSUInteger row = [indexPath row];
        //显示message信息
        SNMessage * message = [[SNMessageManager sharedInstance].allMessage objectAtIndex:row];
        [cell setupCell:message];
        return cell;
    }
    if (indexPath.row == [SNMessageManager sharedInstance].allMessage.count){
        SNLoadMoreCell * cell = (SNLoadMoreCell *)[tableView dequeueReusableCellWithIdentifier:@"loadMoreCell" forIndexPath:indexPath];
        
        return cell;
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < [[SNMessageManager sharedInstance].allMessage count]) {
    SNMessage * message = [[SNMessageManager sharedInstance].allMessage objectAtIndex:indexPath.row];
    
    CGSize size = [SNCommonUtils calHeightForWidth:160 withString:message.content font:MSG_FONT];
    int h = size.height;
    return h+60;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    SNMessage * message = [[SNMessageManager sharedInstance].allMessage objectAtIndex:indexPath.row];
    if ([message.type isEqualToString:@"credits"]) {
        [self performSegueWithIdentifier:@"showPersonInfo" sender:self];
    }else if ([message.type isEqualToString:@"shop"]){
        [self performSegueWithIdentifier:@"showURL" sender:self];
    }else if ([message.type isEqualToString:@"fixedcorner"]){
        [self performSegueWithIdentifier:@"showDiscount" sender:self];
    }else if ([message.type isEqualToString:@"hunt"]){
        [self performSegueWithIdentifier:@"showHunt" sender:self];
    }

}

//当页面加载到最后一个cell的时候判断是否需要继续加载
-(void)tableView:(UITableView *)tableView  willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[SNLoadMoreCell class]]){
            //未到达所有数据的底部，则调用读取方法
            SNLoadMoreCell *loadCell = (SNLoadMoreCell *)cell;
            if (indexPath.row > 0 && !_isBottom) {
                [self performSelector:@selector(loadMore) withObject:nil afterDelay:1.5];
                loadCell.lblLoadMore.text = @"读取中，请稍后...";
                [loadCell.loadMoreProgress startAnimating];
                [loadCell.loadMoreProgress setAlpha:1.0];
            }
            //是否已经到达数据底部，已加载到底部显示结束
            else if(_isBottom){
                loadCell.lblLoadMore.text = @"已加载至列表底部";
                [loadCell.loadMoreProgress setAlpha:0.0];
            }
    }
}

#pragma mark Segue Value

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showURL"]) {
        id des = segue.destinationViewController;
        
        NSIndexPath * selected = [self.messageTable indexPathForSelectedRow];
        
        if (selected != nil) {
            NSInteger row = [selected row];
            SNMessage * message = [[SNMessageManager sharedInstance].allMessage objectAtIndex:row];
            if (message != nil && message.url != nil) {
                [des setValue:message.url forKey:@"url"];
            }
        }
    }
}

#pragma mark request delegate

- (void)request:(SNRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"Message get was failed");
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    [_footer endRefreshing];
}
- (void)request:(SNRequest *)request didLoad:(id)result //TODOS
{
    // 让刷新控件恢复默认的状态
    [_header endRefreshing];
    [_footer endRefreshing];
    
    if (request == self.fetchMessagesRequest) {
        [[SNMessageManager sharedInstance] removeAllMessages];
    }
    if(request == self.fetchMessagesRequest  || request == self.appendMessagesRequest){
        NSArray * array = (NSArray*) result;
        //NSNumber * status = [array objectAtIndex:(int)0];
        //NSArray * list = [array objectAtIndex:(int)1];
        //if([status integerValue] == 0){
            NSLog(@"result:%@",array);
        //}else{
        
        if ([array count] != 0) {
            //根据获取的数据格式生成消息串，并添加进消息列表
            [[SNMessageManager sharedInstance] setupMessages:array];
            //获取最后一条消息的时间戳，上拉加载时使用该时间戳获取该时间之前的消息
            double lTimeStamp = [[[array lastObject] objectForKey:@"timestamp"] doubleValue];
            self.leastTimeStamp = [NSString stringWithFormat:@"%.0f",lTimeStamp - 1];
            _isBottom = NO;
        }
        if ([array count] < 20){
            _isBottom = YES;
        }
        [self.messageTable reloadData];
      /*  NSString *incr = [dict objectForKey:@"incr"];
        NSString *sid = [dict objectForKey:@"sid"];
        NSString *time = [dict objectForKey:@"time"];
        
        NSString * msg = [NSString stringWithFormat:@"get %@ credits from shop %@ at %@", incr,sid,time];
        */
    }
}
@end
