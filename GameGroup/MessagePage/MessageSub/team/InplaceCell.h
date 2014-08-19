//
//  InplaceCell.h
//  GameGroup
//
//  Created by Apple on 14-8-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "JoinTeamCell.h"
#import "HeadClickDelegate.h"
@protocol OnClickDelegate;
@interface InplaceCell : UITableViewCell
@property (nonatomic, assign) id<HeadClickDelegate> headCkickDelegate;
@property(nonatomic,assign)id<OnClickDelegate>onclickdelegate;
@property(nonatomic,strong)EGOImageView * headImageV;//群头像
@property(nonatomic,strong)UIButton *bgImageView;
@property(nonatomic,strong)UILabel * groupNameLable;//群名
@property(nonatomic,strong)UIImageView *genderImageV;//性别
@property(nonatomic,strong)UILabel * positionLable;//职位
@property(nonatomic,strong)EGOImageView * gameImageV;//游戏图标
@property(nonatomic,strong)UILabel * realmLable;//服务器
@property(nonatomic,strong)UILabel * pveLable;//战斗力
@property(nonatomic,strong)UIView * lineView;//竖线
@property(nonatomic,strong)UIView * stateView;//状态
@property(nonatomic,strong)UILabel *MemberLable;
@property(nonatomic,strong)UIButton * positionBtn;
@end
@protocol OnClickDelegate <NSObject>
-(void)positionOnClick:(InplaceCell*)sender;
@end

