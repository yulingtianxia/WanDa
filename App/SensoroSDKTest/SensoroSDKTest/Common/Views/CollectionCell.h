//
//  CollectionCell.h
//  WanDaLive
//
//  Created by 汪卓民 on 13-12-5.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Circle.h"
@interface CollectionCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet EGOImageView *ShopLogo;
@property (strong, nonatomic) IBOutlet UILabel *ShopName;
@property (strong, nonatomic) Circle* grayview;
-(UIImage*)GrayImage:(UIImage*)sourceImage;

@end
