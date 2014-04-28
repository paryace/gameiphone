//
//  UITableViewCell_KKchatCell.h
//  GameGroup
//
//  Created by admin on 14-4-27.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"

@interface KKChatCell : UITableViewCell

@property(nonatomic, retain) NSMutableDictionary *message; //ChatCell对应的数据源
@property(nonatomic, retain) EGOImageButton * headImgV;   //头像
@property(nonatomic, retain) UILabel *senderAndTimeLabel;     //时间与发送人 标签
@property(nonatomic, retain) UIButton *bgImageView; //气泡背景

//初始化cell， 通过一条Message消息
-(KKChatCell* )loadMessage:(NSMutableDictionary *)theMessage;

@end

