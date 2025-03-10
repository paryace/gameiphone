//
//  BaseGroupMsgCell.h
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@protocol GroupImageDeleGate;

@interface BaseGroupMsgCell : UITableViewCell
@property(nonatomic,strong)UIImageView *bgV;//背景

@property(nonatomic,strong)EGOImageView * groupImageV;//群头像

@property(nonatomic,strong)UILabel * groupNameLable;//群名

@property(nonatomic,strong)UILabel * groupCreateTimeLable;//时间

@property(nonatomic,strong)UIButton * imageClickBtn;//

@property(nonatomic,assign)id<GroupImageDeleGate>groupImageDeleGate;

-(void)setGroupMsg:(NSString*)groupImage GroupName:(NSString*)groupName MsgTime:(NSString*)msgTime;
@end
@protocol GroupImageDeleGate <NSObject>

-(void)groupImageClick:(BaseGroupMsgCell*)sender;

@end
