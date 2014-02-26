//
//  self.m
//  NumberScrollTest
//
//  Created by 汪卓民 on 13-12-2.
//  Copyright (c) 2013年 sensoro. All rights reserved.
//

#import "Credit.h"
#define IncreaseSpeed 100

@implementation Credit

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.textAlignment = NSTextAlignmentCenter;
        [self setFont:[UIFont fontWithName:@"Helvetica" size:60.0]];
        [self setTextColor:[UIColor whiteColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [super drawRect:rect];
    [self setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:30.0]];

}
-(void)autochangeFontsize:(double) number{
    if (number<100000) {
        [self setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:60.0]];
    }
    else if (number<1000000){
        [self setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:50.0]];
    }
    else if (number<10000000){
        [self setFont:[UIFont fontWithName:@"FZLanTingHei-UL-GBK" size:40.0]];
    }
}
-(void)changeFromNumber:(double) originalnumber toNumber:(double) newnumber withAnimationTime:(NSTimeInterval)timeSpan{
    
    [UIView animateWithDuration:timeSpan delay:3 options:UIViewAnimationOptionTransitionNone animations:^{
        NSString *currencyStr = [NSNumberFormatter localizedStringFromNumber:[NSNumber numberWithDouble: originalnumber]  numberStyle:NSNumberFormatterCurrencyStyle];
        currencyStr = [currencyStr substringWithRange:NSMakeRange(1, currencyStr.length-2)];
        if ([[currencyStr substringFromIndex:currencyStr.length-1] isEqualToString:@"0"]) {
            currencyStr =[currencyStr substringToIndex:currencyStr.length-2];
        }
        [self autochangeFontsize:originalnumber];
        self.text = currencyStr;
    } completion:^(BOOL finished) {
        if (labs((newnumber-originalnumber)/IncreaseSpeed)<1) {
            [self changeFromNumber:newnumber toNumber:newnumber withAnimationTime:timeSpan];
        }
//        else if (originalnumber+(newnumber-originalnumber)/IncreaseSpeed<=newnumber) {
        else if(labs((newnumber-originalnumber)/IncreaseSpeed)<labs(newnumber-originalnumber)){
            [self changeFromNumber:originalnumber+(newnumber-originalnumber)/IncreaseSpeed toNumber:newnumber withAnimationTime:timeSpan];
            
        }
        else if(originalnumber==newnumber){
            //            [self changeFromNumber:newnumber toNumber:newnumber withAnimationTime:timeSpan];
            
        }
    }];
    
}

@end
