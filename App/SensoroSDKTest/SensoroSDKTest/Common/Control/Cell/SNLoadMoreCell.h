//
//  SNLoadMoreCell.h
//  WanDaLive
//
//  Created by Jarvis on 13-12-10.
//  Copyright (c) 2013年 David Yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SNLoadMoreCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *lblLoadMore;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadMoreProgress;

@end
