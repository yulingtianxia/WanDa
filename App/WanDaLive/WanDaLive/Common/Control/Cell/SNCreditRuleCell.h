//
//  SNCreditRuleCell.h
//  WanDaLive
//
//  Created by 森哲 on 13-12-16.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Circle.h"
@interface SNCreditRuleCell : UITableViewCell
@property (strong, nonatomic) IBOutlet EGOImageView *shopLogo;
@property (strong, nonatomic) IBOutlet UILabel *shopName;
@property (strong, nonatomic) IBOutlet Circle *orangeCircle;
@property (strong, nonatomic) IBOutlet UILabel *creditNum;

-(void)initCellWithLogoUrl:(NSString*)url shopName:(NSString*)name shopCredit:(NSString*)credit;
@end
