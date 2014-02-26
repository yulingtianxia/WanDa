//
//  SNCreditRuleCell.m
//  WanDaLive
//
//  Created by 森哲 on 13-12-16.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNCreditRuleCell.h"

@implementation SNCreditRuleCell
@synthesize shopName;
@synthesize orangeCircle;
@synthesize shopLogo;
@synthesize creditNum;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)initCellWithLogoUrl:(NSString*)url shopName:(NSString*)name shopCredit:(NSString*)credit{
    [orangeCircle setColor:[UIColor orangeColor]];
    [shopLogo setImageURL:[NSURL URLWithString:url]];
    [shopName setText:name];
    NSString *TitleString = [NSString stringWithFormat:@"%@分",credit];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:TitleString];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"黑体-简" size:18.0] range:NSMakeRange(0, str.length-1)];
    [str addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"黑体-简" size:10.0] range:NSMakeRange(str.length-1,1)];
    [creditNum setAttributedText:str];
}
@end
