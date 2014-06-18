//
//  GroupMembersCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface GroupMembersCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *headImageView;
@property(nonatomic,strong)UILabel *nameLable;
@property(nonatomic,strong)UIImageView *sexImageView;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)EGOImageView *clazzImageView;
@property(nonatomic,strong)UILabel *roleLabel;
@property(nonatomic,strong)UILabel *numLabel;
@property(nonatomic,strong)UILabel *numOfLabel;
@property(nonatomic,strong)UIImageView *bgView;

@end
