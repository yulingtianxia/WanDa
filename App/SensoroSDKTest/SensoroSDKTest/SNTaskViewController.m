//
//  SNTaskViewController.m
//  WanDaLive
//
//  Created by David Yang on 13-12-2.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNTaskViewController.h"
#import "CollectionCell.h"
#import "TaskTitleView.h"
#import "SNRequest.h"
#import "URLManager.h"
#import "SNTopModel.h"
#import "Circle.h"
@interface SNTaskViewController ()

@end

@implementation SNTaskViewController
@synthesize ShopCollection;
@synthesize TitleView;
@synthesize TitleString;
@synthesize HuntTreasureRequest;
@synthesize HuntProgressRequest;
@synthesize HuntRuleShops;
@synthesize ShopLogos;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    
    HuntProgressRequest = [SNRequest getRequestWithParams:nil
                                                 delegate:self
                                               requestURL:[URLManager fetchHuntProgressOfUser:[SNTopModel sharedInstance].userInfo.userID onDate:[self curTimeString]]];
    [HuntProgressRequest connect];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //设置SNTriggerDelegate
    [[SNGlobalTrigger sharedInstance] addObserver:self];
    TitleView.backgroundColor = [UIColor clearColor];
    TitleView.radius=5;
    TitleString=@"土豪说：\n“点亮所有LOGO就有豪礼拿！！！“\n去以下店铺逛逛，中奖率100%";
    NSMutableParagraphStyle *paragrapStyle = [[NSMutableParagraphStyle alloc] init];
    paragrapStyle.alignment = NSTextAlignmentCenter;
    TitleView.title=[[NSMutableAttributedString alloc] initWithString:TitleString];
    [TitleView.title addAttribute:NSForegroundColorAttributeName value: [UIColor whiteColor] range:NSMakeRange(0, TitleString.length)];
    [TitleView.title addAttribute:NSBackgroundColorAttributeName value:[UIColor clearColor] range:NSMakeRange(0, TitleString.length)];
    [TitleView.title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:15.0] range:NSMakeRange(0, TitleString.length-8)];
    [TitleView.title addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:23.0] range:NSMakeRange(TitleString.length-8, 8)];
    [TitleView.title addAttribute:NSParagraphStyleAttributeName value:paragrapStyle range:NSMakeRange(0, TitleString.length)];
    [TitleView.title addAttribute:NSBaselineOffsetAttributeName value:[NSNumber numberWithFloat:10.0] range:NSMakeRange(0, TitleString.length)];
    
    
    
    ShopCollection.backgroundColor=self.view.backgroundColor;
    
    //测试满足寻宝中的一个店
//    [self taskComplete:@"10001"];
    
}

-(void)viewWillDisappear:(BOOL)animated{
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
                [ShopCollection reloadData];
                NSLog(@"accepted");
            }else if([outcome isEqualToString:@"congratulations"]){
                //完成寻宝活动，获得奖励
                [ShopCollection reloadData];
                NSLog(@"congratulations");
            }
            [ShopCollection reloadData];
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
        [ShopCollection reloadData];
    }
    [self.view setNeedsDisplay];
}

#pragma mark UICollectionViewDelegate

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    // 每个Section的item个数
    //这里需要从Userdefaults中读取寻宝规则店铺的数量
    NSInteger count = [[self HuntRuleShops]count];
    
    return count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell"
                                                                     forIndexPath:indexPath];
    //这里需要从Userdefaults中读取寻宝规则店铺的图片和名称
    // 图片的名称
    [cell.ShopLogo setDelegate:self];
    
    NSMutableArray* arr = [self HuntRuleShops];
    [cell.ShopLogo setImageURL:[NSURL URLWithString:((SNShops*)[arr objectAtIndex:indexPath.row]).logo]];
    SNShops* shop=[arr objectAtIndex:indexPath.row];
    
//    if (cell.grayview == nil) {
//        cell.grayview = [[Circle alloc]initWithFrame:cell.ShopLogo.frame];
//        cell.grayview.color=[UIColor grayColor];
//        [cell addSubview:cell.grayview];
//    }
//    
//    if ([shop.IsCompleted isEqualToString:@"NO"]){
//        cell.grayview.alpha = 0.7;
//    }else{
//        cell.grayview.alpha = 0.0;
//    }
//    
    Circle* grayview = nil;
    for( UIView * view in cell.subviews){
        if ([view isKindOfClass:[Circle class]]) {
            grayview = (Circle*)view;
            break;
        }
    }
    
    if (grayview == nil) {
        grayview = [[Circle alloc]initWithFrame:cell.ShopLogo.frame];
        grayview.color=[UIColor grayColor];
        [cell addSubview:grayview];
    }
    
    if ([shop.IsCompleted isEqualToString:@"NO"]){
        grayview.alpha = 0.7;
    }else{
        grayview.alpha = 0.0;
    }
    
    cell.backgroundColor=[UIColor clearColor];
    // 设置商店名称
    [cell.ShopName setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:10]];
    cell.ShopName.text = ((SNShops*)[[self HuntRuleShops] objectAtIndex:indexPath.row]).name;
    return cell;
    
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark SNBusinessTrigger

- (void) taskComplete: (NSString*) sid{
    
    //发送信息等已经在
    [ShopCollection reloadData];
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
