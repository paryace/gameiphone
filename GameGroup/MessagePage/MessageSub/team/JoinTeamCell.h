//
//  JoinTeamCell.h
//  GameGroup
//
//  Created by Apple on 14-7-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol TeamDetailDelegate;

@interface JoinTeamCell : UITableViewCell
@property(nonatomic,strong)UIImageView *bgV;//背景
@property(nonatomic,strong)EGOImageView * headImageV;//群头像
@property(nonatomic,strong)UIButton *bgImageView;
@property(nonatomic,strong)UILabel * groupNameLable;//群名
@property(nonatomic,strong)UIImageView *genderImageV;//性别
@property(nonatomic,strong)UILabel * positionLable;//职位
@property(nonatomic,strong)EGOImageView * gameImageV;//游戏图标
@property(nonatomic,strong)UILabel * realmLable;//服务器
@property(nonatomic,strong)UILabel * pveLable;//战斗力
@property(nonatomic,strong)UILabel * timeLable;//时间
@property(nonatomic,strong)UILabel * detailLable;//处理
@property(nonatomic,assign)id<TeamDetailDelegate>delegate;
//同意，拒绝button
@property(nonatomic,strong)UIButton * agreeButton;  //同意
@property(nonatomic,strong)UIButton * refuseButton;       //拒绝
-(void)refreTitleFrame;
@end

@protocol TeamDetailDelegate <NSObject>

-(void)onAgreeClick:(JoinTeamCell*)sender;
-(void)onDisAgreeClick:(JoinTeamCell*)sender;
- (void)headImgClick:(JoinTeamCell*)Sender;


@end
