//
//  FindRoleCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface FindRoleCell : UITableViewCell
@property (nonatomic,strong)EGOImageView * headImgView;
@property (nonatomic,strong)UILabel * roleNameLabel;
@property (nonatomic,strong)UILabel * realmLabel;
@property (nonatomic,strong)EGOImageView *gameIconImg;
@property (nonatomic,strong)UILabel * zdlLabel;
@property (nonatomic,strong)UILabel * zdlNumLabel;
@end
