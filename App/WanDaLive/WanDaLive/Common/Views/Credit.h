//
//  Credit.h
//  NumberScrollTest
//
//  Created by 汪卓民 on 13-12-2.
//  Copyright (c) 2013年 sensoro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Credit : UILabel
-(void)autochangeFontsize:(double) number;
-(void)changeFromNumber:(double) originalnumber toNumber:(double) newnumber withAnimationTime:(NSTimeInterval)timeSpan;
@end
