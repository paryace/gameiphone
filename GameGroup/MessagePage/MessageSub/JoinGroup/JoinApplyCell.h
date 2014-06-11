//
//  JoinApplyCell.h
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol DetailDeleGate;

@interface JoinApplyCell : UITableViewCell
@property(nonatomic,strong)EGOImageView * groupImageV;
@property(nonatomic,strong)UILabel * groupNameLable;
@property(nonatomic,strong)UILabel * groupCreateTimeLable;

@property(nonatomic,strong)EGOImageView *userImageV;
@property(nonatomic,strong)UILabel * userNameLable;
@property(nonatomic,strong)UILabel * joinReasonLable;

@property(nonatomic,strong)UIButton *agreeBtn ;
@property(nonatomic,strong)UIButton * desAgreeBtn;
@property(nonatomic,strong)UIButton * ignoreBtn;


@property(nonatomic,strong)UILabel * applicationState;

@property(nonatomic,assign)id<DetailDeleGate>detailDeleGate;

@end

@protocol DetailDeleGate <NSObject>

-(void)agreeMsg:(JoinApplyCell*)sender;

-(void)desAgreeMsg:(JoinApplyCell*)sender;

-(void)ignoreMsg:(JoinApplyCell*)sender;

@end
