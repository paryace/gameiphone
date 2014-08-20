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
@interface NewTeamApplyListView : UIView<UITableViewDataSource,UITableViewDelegate,TeamDetailDelegate>
@property(nonatomic,assign)id<ApplyDetailDelegate>detaildelegate;
@property (nonatomic, strong) UIView * mSuperView;
@property (nonatomic, strong) NSString *groipId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, nonatomic)  BOOL teamUsershipType;
@property (nonatomic, nonatomic)  BOOL isShow;
- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType;
-(void)showView;
-(void)hideView;
@end

@protocol ApplyDetailDelegate <NSObject>
-(void)buttonApplyListOnClick;
-(void)itemApplyListOnClick:(NSDictionary*)charaDic;
-(void)headImgApplyListClick:(NSString*)userId;
-(void)doApplyListShowOrHideViewControl;
-(void)mHideApplyListTopMenuView;
-(void)mShowApplyListTopMenuView;
@end
