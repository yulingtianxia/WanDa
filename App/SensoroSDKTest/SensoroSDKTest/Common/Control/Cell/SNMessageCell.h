//
//  SNMessageCell.h
//  WanDaLive
//
//  Created by David Yang on 13-11-28.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SNMessage;
@interface SNMessageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView * iconImg;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
-(void)setupCell:(SNMessage *)model;
-(IBAction)share:(id)sender;
@end
