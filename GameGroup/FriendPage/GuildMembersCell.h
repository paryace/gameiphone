//
//  GuildMembersCell.h
//  GameGroup
//
//  Created by 魏星 on 14-5-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface GuildMembersCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *roleImageView;
@property(nonatomic,strong)EGOImageView *headImageView;
@property(nonatomic,strong)UIImageView *genderImgView;
@property(nonatomic,strong)UILabel *nickNameLabel;
@property(nonatomic,strong)UILabel *roleNameLabel;
@end
