//
//  NewTeamApplyListView.h
//  GameGroup
//
//  Created by Apple on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoinTeamCell.h"
#import "H5CharacterDetailsViewController.h"
@protocol ApplyDetailDelegate;
@interface NewTeamApplyListView : UIView<UITableViewDataSource,UITableViewDelegate,TeamDetailDelegate>{
     MBProgressHUD* hud;//提示框
}
@property(nonatomic,assign)id<ApplyDetailDelegate>detaildelegate;
@property (nonatomic, strong) UIView * mSuperView;
@property (nonatomic, strong) NSString *groipId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, nonatomic)  BOOL teamUsershipType;
@property (nonatomic, nonatomic)  BOOL isShow;
- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType;
-(void)showView;//显示视图view
-(void)hideView;//隐藏视图view
-(void)deallocContro;
@end

@protocol ApplyDetailDelegate <NSObject>
-(void)readAppMsgAction;
-(void)itemApplyListOnClick:(NSDictionary*)charaDic;//点击item
-(void)headImgApplyListClick:(NSString*)userId;//点击头像
-(void)doApplyListShowOrHideViewControl;//显示或者隐藏视图view

-(void)mHideApplyListTopMenuView;//隐藏头部消息通知view
-(void)mShowApplyListTopMenuView;//显示头部消息通知view
@end
