//
//  SNHuntTreasureViewController.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-11.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNHuntTreasureViewController.h"
#import "SNRequest.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "Circle.h"

@implementation SNHuntTreasureViewController
@synthesize scratchImage;
@synthesize page;
@synthesize HuntTreasureRequest;
@synthesize HuntProgressRequest;
@synthesize HuntRuleShops;
@synthesize ShopLogos;
@synthesize imageScrollView;
@synthesize shopLogo1,shopLogo2,shopLogo3,shopLogo4,shopLogo5;
@synthesize grayLogo1,grayLogo2,grayLogo3,grayLogo4,grayLogo5;
@synthesize timeCount;
@synthesize HintLabel;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSString * isnewrule = [userdefault objectForKey:@"isnewrule"];
    NSMutableArray* arr = [self HuntRuleShops];
    int notCompleteSum = arr.count;//没有完成的任务数量
    for (int i=0; i<arr.count; i++) {
        if ([((SNShops*)arr[i]).IsCompleted isEqualToString:@"YES"]) {
            notCompleteSum--;
        }
    }
    if ([isnewrule isEqualToString:@"yes"] || isnewrule==nil) {
        [userdefault setValue:@"no" forKey:@"isnewrule"];
        scratchImage.alpha=1.0;
    }else if ([isnewrule isEqualToString:@"no"]){
        scratchImage.alpha=0.0;
        if (notCompleteSum==0) {
            HintLabel.text=@"恭喜你点亮了所有的店铺！快打开宝箱吧！";
        }
        else
        {
            NSString *cnNumber;
            switch (notCompleteSum) {
                case 1:
                    cnNumber=@"一";
                    break;
                case 2:
                    cnNumber=@"二";
                    break;
                case 3:
                    cnNumber=@"三";
                    break;
                case 4:
                    cnNumber=@"四";
                    break;
                case 5:
                    cnNumber=@"五";
                    break;
                default:
                    break;
            }
            HintLabel.text=[NSString stringWithFormat:@"加油！再点亮%@家店铺就可以打开宝箱啦~哟！哟！嘿喂GO！",cnNumber];
        }
    }
    HuntProgressRequest = [SNRequest getRequestWithParams:nil
                                                 delegate:self
                                               requestURL:[URLManager fetchHuntProgressOfUser:[SNTopModel sharedInstance].userInfo.userID onDate:[self curTimeString]]];
    [HuntProgressRequest connect];
}

-(void)viewWillDisappear:(BOOL)animated{
    [[SNGlobalTrigger sharedInstance] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置EGOImageDelegate
    shopLogo1.delegate=self;
    shopLogo2.delegate=self;
    shopLogo3.delegate=self;
    shopLogo4.delegate=self;
    shopLogo5.delegate=self;
    grayLogo1.color = [UIColor grayColor];
    grayLogo2.color = [UIColor grayColor];
    grayLogo3.color = [UIColor grayColor];
    grayLogo4.color = [UIColor grayColor];
    grayLogo5.color = [UIColor grayColor];
    
    scratchImage.radius = 20;
    [scratchImage beginInteraction];
    scratchImage.imageMaskFilledDelegate = self;
    //设置SNTriggerDelegate
    [[SNGlobalTrigger sharedInstance] addObserver:self];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark MyFuncs
//满足寻宝的一个店
- (void)addFoundShop:(NSString*)sid toUser:(NSString*)uid onDate:(NSString *)date{
    HuntTreasureRequest = [SNRequest getPutRequestWithParams:nil delegate:self requestURL:[URLManager addFoundShop:sid toUser:uid onDate:date]];
    [HuntTreasureRequest connect];
}

-(NSMutableArray*)HuntRuleShops{
    NSUserDefaults *shops = [NSUserDefaults standardUserDefaults];
    NSMutableArray* arr = [shops objectForKey:@"shops"];
    NSMutableArray* newarr = [NSMutableArray arrayWithCapacity:arr.count];
    for (int i = 0;i<arr.count; i++) {
        SNShops *shop = [NSKeyedUnarchiver unarchiveObjectWithData:[arr objectAtIndex:i]];
        [newarr addObject:shop];
    }
    return newarr;
}

-(NSString*)curTimeString{
    NSDateFormatter *formater = [[ NSDateFormatter alloc] init];
    NSDate *curDate = [NSDate date];//获取当前日期
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    [formater setTimeZone:timeZone];
    [formater setDateFormat:@"yyyyMMdd"];//这里去掉 具体时间 保留日期
    return [formater stringFromDate:curDate];
}

-(void)reloadShopLogos{
    NSMutableArray* arr = [self HuntRuleShops];
    NSArray* shoplogoarr = @[shopLogo1,shopLogo2,shopLogo3,shopLogo4,shopLogo5];
    NSArray* graylogoarr = @[grayLogo1,grayLogo2,grayLogo3,grayLogo4,grayLogo5];

    for(int i=0;i<arr.count;i++){
        ((EGOImageView*)shoplogoarr[i]).placeholderImage=[UIImage imageNamed:@"logo"];
        [shoplogoarr[i] setImageURL:[NSURL URLWithString:((SNShops*)arr[i]).logo]];
        SNShops* shop=arr[i];
        
        if ([shop.IsCompleted isEqualToString:@"NO"]){
            ((Circle *)graylogoarr[i]).alpha = 0.7;
            
        }else{
            ((Circle *)graylogoarr[i]).alpha = 0.0;
        }
        
        //    // 设置商店名称
        //    [cell.ShopName setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:10]];
        //    cell.ShopName.text = ((SNShops*)[[self HuntRuleShops] objectAtIndex:indexPath.row]).name;
    }
}
#pragma mark RequestDelegate

- (void)request:(SNRequest *)request didLoad:(id)result //TODOS
{
    if(result!=NULL&&request == HuntTreasureRequest){
        if ([result objectForKey:@"outcome"]!=[NSNull null]) {
            NSString * outcome = [NSString stringWithString:[result objectForKey:@"outcome"]] ;
            if ([outcome isEqualToString:@"have already accomplished"]) {
                //该店铺之前已经完成
                NSLog(@"have already accomplished");
            }else if([outcome isEqualToString:@"accepted"]){
                [self reloadShopLogos];
                NSLog(@"accepted");
            }else if([outcome isEqualToString:@"congratulations"]){
                //完成寻宝活动，获得奖励
                [self reloadShopLogos];
                NSLog(@"congratulations");
            }
            [self reloadShopLogos];
        }
    }
    if(result!=NULL&&request == HuntProgressRequest){
        //获取寻宝进度
        NSUserDefaults *shops = [NSUserDefaults standardUserDefaults];
        NSMutableArray* arrdata = [shops objectForKey:@"shops"];
        NSMutableArray* arr = [NSMutableArray arrayWithCapacity:arrdata.count];
        NSMutableArray* newarrdata = [NSMutableArray arrayWithCapacity:arrdata.count];
        for (int i = 0;i<arrdata.count; i++) {
            SNShops *shop = [NSKeyedUnarchiver unarchiveObjectWithData:[arrdata objectAtIndex:i]];
            [arr addObject:shop];
        }
        NSArray * array = (NSArray*)result;
        for (int i=0; i<arr.count; i++) {
            for (int j=0; j<array.count; j++) {
                if ([((SNShops*)[arr objectAtIndex:i]).sid isEqualToString:[array objectAtIndex:j]]) {
                    ((SNShops*)[arr objectAtIndex:i]).IsCompleted=@"YES";
                    break;
                }
                
            }
            [newarrdata addObject:[NSKeyedArchiver archivedDataWithRootObject:(SNShops*)[arr objectAtIndex:i]]];
        }
        
        [shops setObject:newarrdata forKey:@"shops"];//将更新完成状态后的shop存入
        [shops synchronize];
        //        [self HuntRuleShops];
//        [ShopCollection reloadData];
        [self reloadShopLogos];
    }
    [self.view setNeedsDisplay];
}
#pragma mark NSTimerDelegate
-(void)scrollTimer{
    
    timeCount++;
    if(timeCount == PAGENUM){
        timeCount= 0;
    }
    [imageScrollView scrollRectToVisible:CGRectMake(timeCount * 320.0, 65.0, 320.0, 218.0) animated:YES];
    
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
#pragma mark ImageMaskFilledDelegate
- (void)imageMaskView:(ImageMaskView *)maskView clearPercentDidChanged:(float)clearPercent {
	NSLog(@"Cleared percentage: %.2f", clearPercent);
    
    // Detect minimum percentage scratched
    if (clearPercent > 50) {
        [UIView animateWithDuration:2
                         animations:^{
                             scratchImage.userInteractionEnabled = NO;
                             scratchImage.alpha = 0;
                             scratchImage.imageMaskFilledDelegate = nil;
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}


#pragma mark ScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int curpage = scrollView.contentOffset.x /320;//通过滚动的偏移量来判断目前页面所对应的小白点
    page.currentPage = curpage;//pagecontroll响应值的变化
}

#pragma mark SNBusinessTrigger

- (void) taskComplete: (NSString*) sid{
    
    //发送信息等已经在
    [self reloadShopLogos];
}

#pragma mark EGOImageViewDelegate

- (void)imageViewLoadedImage:(EGOImageView*)imageView{
    UIImage *mask = [UIImage imageNamed:@"maskImage.png"];
    CALayer* maskLayer = [[CALayer alloc]init];
    maskLayer.frame = CGRectMake(0, 0, 50, 50);
    maskLayer.contents = (id)[mask CGImage];
    [imageView.layer setMask:maskLayer];
//    NSLog(@"加载图片％@完毕",imageView);
}
@end
