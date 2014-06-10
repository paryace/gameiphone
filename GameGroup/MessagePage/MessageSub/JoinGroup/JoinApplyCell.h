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

@property(nonatomic,assign)id<DetailDeleGate>detailDeleGate;

@end

@protocol DetailDeleGate <NSObject>

-(void)agreeMsg:(id)sender;
-(void)desAgreeMsg:(id)sender;
-(void)ignoreMsg:(id)sender;

@end
