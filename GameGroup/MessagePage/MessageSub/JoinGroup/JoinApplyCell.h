//
//  JoinApplyCell.h
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface JoinApplyCell : UITableViewCell
@property(nonatomic,strong)EGOImageView * groupImageV;
@property(nonatomic,strong)UILabel * groupNameLable;
@property(nonatomic,strong)UILabel * groupCreateTimeLable;

@property(nonatomic,strong)EGOImageView *userImageV;
@property(nonatomic,strong)UILabel * userNameLable;
@property(nonatomic,strong)UILabel * joinReasonLable;

@property(nonatomic,strong)UIButton * agreeBtn;//同意
@property(nonatomic,strong)UIButton * desAgreeBtn;//拒绝
@property(nonatomic,strong)UIButton * ignoreBtn;//忽略

@end
