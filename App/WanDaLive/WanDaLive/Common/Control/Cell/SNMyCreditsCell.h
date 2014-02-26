//
//  SNMyCreditsCell.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-13.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Circle.h"
#import "Line.h"
@class SNMessage;

@interface SNMyCreditsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (strong, nonatomic) IBOutlet Circle *orangeCircle;
@property (strong, nonatomic) IBOutlet Line *orangeLine;

-(void)setupCell:(SNMessage *)message AtIndex:(int)index;

@end
