//
//  NewFirstCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface NewFirstCell : UITableViewCell
@property (strong,nonatomic) EGOImageView * headImageV;// 头像
@property (nonatomic,strong) UIImageView* sexImg;//性别
@property (strong,nonatomic) UILabel * nameLabel;//昵称
@property (strong,nonatomic) UILabel* distLabel;//头衔
@property (strong,nonatomic) UIView * bgView;
@property (nonatomic,strong) UILabel *cardLabel;
@property (nonatomic,strong) UILabel *timeLabel;
@property (nonatomic,strong) UIImageView *stopImg;
@property (strong,nonatomic) MsgNotifityView * dotV;
-(void)setTime:(NSString*)msgTime;


@end
