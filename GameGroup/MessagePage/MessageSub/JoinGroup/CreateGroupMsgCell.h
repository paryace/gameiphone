//
//  CreateGroupMsgCell.h
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@protocol CreateGroupDetailDeleGate;

@interface CreateGroupMsgCell : UITableViewCell

@property(nonatomic,strong)EGOImageView * groupImageV;
@property(nonatomic,strong)UILabel * groupNameLable;
@property(nonatomic,strong)UILabel * groupCreateTimeLable;

@property(nonatomic,strong)UILabel * contentLable;

@property(nonatomic,strong)UIButton *oneBtn ;
@property(nonatomic,strong)UIButton * twoBtn;
@property(nonatomic,strong)UIButton * threeBtn;

@property(nonatomic,assign)id<CreateGroupDetailDeleGate>detailDeleGate;

@end

@protocol CreateGroupDetailDeleGate <NSObject>

-(void)inviteClick:(CreateGroupMsgCell*)sender;

-(void)skillClick:(CreateGroupMsgCell*)sender;

-(void)detailClick:(CreateGroupMsgCell*)sender;

@end
