//
//  CreateGroupMsgCell.h
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseGroupMsgCell.h"
@protocol CreateGroupDetailDeleGate;

@interface CreateGroupMsgCell : BaseGroupMsgCell

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
