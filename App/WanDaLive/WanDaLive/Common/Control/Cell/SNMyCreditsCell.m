//
//  SNMyCreditsCell.m
//  WanDaLive
//
//  Created by Jarvis on 13-12-13.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import "SNMyCreditsCell.h"
#import "SNMessageManager.h"

@implementation SNMyCreditsCell

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
-(void)setupCell:(SNMessage *)message AtIndex:(int)index{
    
    self.msgLabel.text = message.content;
    self.titleLabel.text = message.title;
    
    [_orangeCircle setColor:[UIColor orangeColor]];
    [_orangeLine setColor:[UIColor orangeColor]];
    if ([SNMessageManager sharedInstance].allMessage.count==1) {
        [_orangeLine setStart:CGPointMake(3, 22)];
        [_orangeLine setStop:CGPointMake(3, 22)];
    }
    else if(index==0){
        [_orangeLine setStart:CGPointMake(3, 22)];
        [_orangeLine setStop:CGPointMake(3, 44)];
    }
    else if(index==[SNMessageManager sharedInstance].allMessage.count-1){
        [_orangeLine setStart:CGPointMake(3, 0)];
        [_orangeLine setStop:CGPointMake(3, 22)];
    }
    else{
        [_orangeLine setStart:CGPointMake(3, 0)];
        [_orangeLine setStop:CGPointMake(3, 44)];
    }
    [_orangeLine setNeedsDisplay];
//    if (index==0) {
//        [_orangeLine setStart:CGPointMake(3, 0)];
//        [_orangeLine setStop:CGPointMake(3, 44)];
//    }
//    else if(index==1){
//        [_orangeLine setStart:CGPointMake(3, 23)];
//        [_orangeLine setStop:CGPointMake(3, 44)];
//    }
//    else if(index==-1){
//        [_orangeLine setStart:CGPointMake(3, 0)];
//        [_orangeLine setStop:CGPointMake(3, 22)];
//    }
//    else{
//        [_orangeLine setStart:CGPointMake(3, 22)];
//        [_orangeLine setStop:CGPointMake(3, 22)];
//    }
}
@end
