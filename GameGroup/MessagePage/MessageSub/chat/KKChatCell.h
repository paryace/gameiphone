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
#import "SendFileMessageDelegate.h"

#define padding 20 //边距常数
#define mSendTime 20.0 //最长重试时间

@protocol KKChatCellDelegate;

@interface KKChatCell : UITableViewCell

@property (nonatomic, retain) NSMutableDictionary *message;//ChatCell对应的数据源
@property (nonatomic, retain) EGOImageButton * headImgV;//头像
@property (assign, nonatomic)id<KKChatCellDelegate> myChatCellDelegate;//头像点击代理
@property (nonatomic, retain) UILabel *senderAndTimeLabel;//时间与发送人 标签
@property (nonatomic, retain) UILabel *senderNickName;
@property (nonatomic, retain) UIButton *bgImageView; //气泡背景
@property (nonatomic, retain) UIButton* failImage; //发送失败红色叹号
@property (nonatomic, retain) UIActivityIndicatorView *activityView; //正在发送指示器，转圈圈
@property (nonatomic, retain) UILabel*  statusLabel;//已读 送达
@property (nonatomic, retain) UILabel*  levelLable;//位置

//初始化方法
- (id)initWithMessage:(NSMutableDictionary *)msg reuseIdentifier:(NSString *)reuseIdentifier; //用这个比较好， 直接赋值
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier; //不要用这个
- (void)setMsgTime:(NSString*)timeStr lastTime:(NSString*)lasttime previousTime:(NSString*)previoustime;
- (void)refreshStatusPoint:(CGPoint)point status:(NSString*)status; //在指定位置刷新重连标记
- (void)setMessageDictionary:(NSMutableDictionary*)msg;
- (void)setHeadImgByMe:(NSString*) myHeadImg; //头像是自己
- (void)setHeadImgByChatUser:(NSString*) chatUserImg; //把头像设置为聊天对像
- (void)setMePosition:(BOOL)isTeam TeanPosition:(NSString*)teamPosition;
- (void)setUserPosition:(BOOL)isTeam TeanPosition:(NSString*)teamPosition;
- (void)hideStateView;
- (void)setViewState:(NSString*)status;
@end

@protocol KKChatCellDelegate <NSObject>
- (void)myHeadImgClicked:(id)Sender;    //自己的头像被点击
- (void)chatUserHeadImgClicked:(id)Sender; //对方的头像被点击
- (void)onCellBgClick:(UIButton*)sender;//Cell点击
- (void)onCellBgLongClick:(UITapGestureRecognizer*)sender;//Cell长按
@end