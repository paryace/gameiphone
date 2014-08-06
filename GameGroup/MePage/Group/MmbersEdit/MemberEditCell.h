//
//  MemberEditCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "HeadClickDelegate.h"

@interface MemberEditCell : UITableViewCell
@property (nonatomic, assign) id<HeadClickDelegate> headCkickDelegate;
@property(nonatomic,strong)EGOImageView *headImageView;
@property(nonatomic,strong)UIButton *bgImageView;
@property(nonatomic,strong)UILabel *nameLable;
@property(nonatomic,strong)UILabel *sfLb;
@property (nonatomic,strong) UIImageView* sexImg;//性别

@property(nonatomic)      NSIndexPath * indexPath;
@end
