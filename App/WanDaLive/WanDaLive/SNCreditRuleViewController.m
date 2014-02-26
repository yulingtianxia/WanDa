//
//  SNCreditRuleViewController.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-16.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNCreditRuleViewController.h"
#import "SNCreditRuleCell.h"
#import "SNTopModel.h"
#import "SNShop.h"
#import "URLManager.h"
@interface SNCreditRuleViewController ()

@end

@implementation SNCreditRuleViewController
@synthesize creditRuleTable;
@synthesize creditRuleRequest;
@synthesize shops;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated{
//    creditRuleRequest = [SNRequest getRequestWithParams:nil delegate:self requestURL:[URLManager fetchCreditRules]];
//    [creditRuleRequest connect];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    shops=[[NSMutableArray alloc]init];
    creditRuleRequest = [SNRequest getRequestWithParams:nil delegate:self requestURL:[URLManager fetchCreditRules]];
    [creditRuleRequest connect];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backToPrev:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark UITableViewDelegate

#pragma mark TableDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (shops!=nil) {
        return shops.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	//加载自定义cell
    static NSString *identifier = @"creditruleCell";
    SNCreditRuleCell *cell = (SNCreditRuleCell*)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    SNShop * shop = shops[[indexPath row]];
    //显示shop信息
    if (cell.shopLogo.imageURL==nil) {
        [cell initCellWithLogoUrl:[URLManager imageUrl:shop.logo] shopName:shop.name shopCredit:shop.credits];
    }
    
    return cell;

}

#pragma mark RequestDelegate
-(void)request:(SNRequest *)request didLoad:(id)result{
    if (result!=NULL&&request==creditRuleRequest) {
        NSArray *arr = result;
        
        for (int i=0; i<arr.count; i++) {

            NSString *sid = [(NSDictionary*)arr[i] objectForKey:@"sid"];
            NSString *credit =[NSString stringWithFormat:@"%@",[(NSDictionary*)arr[i] objectForKey:@"credits"]] ;
            SNShop * shop = [[SNTopModel sharedInstance].shopsInfo objectForKey:sid];
            shop.credits = credit;
            [shops addObject:shop];
            
        }
    }
    [creditRuleTable reloadData];
}
@end
