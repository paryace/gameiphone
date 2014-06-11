//
//  BaseGroupMsgCell.h
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface BaseGroupMsgCell : UITableViewCell
@property(nonatomic,strong)UIImageView *bgV;
@property(nonatomic,strong)EGOImageView * groupImageV;
@property(nonatomic,strong)UILabel * groupNameLable;
@property(nonatomic,strong)UILabel * groupCreateTimeLable;
@end
