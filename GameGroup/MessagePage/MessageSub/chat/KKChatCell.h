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

#define padding 20 //边距常数
#define mSendTime 10.0 //最长重试时间

@protocol KKChatCellDelegate;

@interface KKChatCell : UITableViewCell

@property(nonatomic, retain) NSMutableDictionary *message; //ChatCell对应的数据源

@property(nonatomic, retain) EGOImageButton * headImgV;   //头像
@property(assign,nonatomic)id<KKChatCellDelegate> myChatCellDelegate;   //头像点击代理

@property(nonatomic, retain) UILabel *senderAndTimeLabel;     //时间与发送人 标签
@property(nonatomic, retain) UIButton *bgImageView; //气泡背景

//重连相关
@property (nonatomic, retain) UIButton* failImage; //重连图标
@property (nonatomic, retain) NSTimer* cellTimer;//发送5秒
@property (nonatomic, retain) UIActivityIndicatorView *activityView; //可用
@property (nonatomic, retain) UILabel*  statusLabel;//已读 送达

//初始化方法
- (id)initWithMessage:(NSMutableDictionary *)msg reuseIdentifier:(NSString *)reuseIdentifier; //用这个比较好， 直接赋值
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier; //不要用这个


//重连
- (void)refreshStatusPoint:(CGPoint)point status:(NSString*)status; //在指定位置刷新重连标记

//头像 
- (void)setHeadImgByMe; //头像是自己
- (void)setHeadImgByChatUser:(NSString*) chatUserImg; //把头像设置为聊天对像
@end

@protocol KKChatCellDelegate <NSObject>

- (void)myHeadImgClicked:(id)Sender;    //自己的头像被点击
-(void)chatUserHeadImgClicked:(id)Sender; //对方的头像被点击
@end