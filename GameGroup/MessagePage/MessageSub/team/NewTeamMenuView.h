//
//  NewTeamMenuView.h
//  GameGroup
//
//  Created by Apple on 14-8-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownChooseDelegate.h"
#import "HeadClickDelegate.h"
#import "JoinTeamCell.h"
#import "TagCell.h"
#import "TimeDelegate.h"
#import "InplaceCell.h"
#define SECTION_BTN_TAG_BEGIN   1000
#define SECTION_IV_TAG_BEGIN    3000

@protocol DetailDelegate;

@interface NewTeamMenuView : UIView<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,HeadClickDelegate,TimeDelegate,PositionDelegate>{
    MBProgressHUD* hud;//提示框
}
@property(nonatomic,assign)id<DetailDelegate>detaildelegate;
@property (nonatomic, strong) UIView * mSuperView;
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) UILabel* titleLabel;
@property (nonatomic, strong) UIButton *sendBtn ;
@property (nonatomic, strong) UILabel *timeLable ;
@property (nonatomic, strong) UIButton *agreeBtn ;
@property (nonatomic, strong) UIButton *refusedBtn ;

@property (nonatomic, strong) NSString *groipId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, nonatomic)  BOOL teamUsershipType;
@property (nonatomic, nonatomic)  BOOL isShow;
@property (assign, nonatomic) NSInteger deleteIndex;
@property (strong, nonatomic)  NSMutableArray * memberList;

- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType;
-(void)showView;//显示视图view
-(void)hideView;//隐藏视图view
-(void)settTitleMsg:(NSString*)titleText;//设置title
-(void)setMemberListss;

-(void)changInplaceState:(NSDictionary*)memberUserInfo;
-(void)sendChangInplaceState;
-(void)resetChangInplaceState;
-(void)restartTime;
-(void)stopTime;
@end

@protocol DetailDelegate <NSObject>
-(void)readInpaceMsgAction;//读就位确认消息
-(void)itemOnClick:(NSDictionary*)charaDic;//点击item
-(void)headImgClick:(NSString*)userId;//点击头像
-(void)doCloseInpacePageAction;//关闭页面
-(void)doCloseControllerAction;//退出页面
-(void)mHideOrShowTopMenuView;//隐藏头部消息提示view
-(void)menuOnClick:(NSInteger)senderTag;
-(void)hideMenuView;
@end
