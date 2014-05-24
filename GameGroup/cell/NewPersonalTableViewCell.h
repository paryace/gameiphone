//
//  NewPersonalTableViewCell.h
//  GameGroup
//
//  Created by Apple on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface NewPersonalTableViewCell : UITableViewCell
@property (strong,nonatomic) UIImageView * backgroudImageV;//背景
@property (strong,nonatomic) EGOImageView * headImageV;// 头像
@property (nonatomic,strong) UIImageView* sexImg;//性别
@property (strong,nonatomic) UILabel * nameLabel;//昵称
//@property (nonatomic,strong) UIImageView* gameImg_one;//游戏图标
@property (strong,nonatomic) UILabel* distLabel;//头衔

-(void)setGameIconUIView:(NSArray*)gameIds;
@end
