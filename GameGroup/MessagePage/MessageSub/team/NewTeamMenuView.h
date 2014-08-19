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

@interface NewTeamMenuView : UIView<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,HeadClickDelegate,TimeDelegate,OnClickDelegate>{
    MBProgressHUD* hud;//提示框
}
@property(nonatomic,assign)id<DetailDelegate>detaildelegate;
@property (nonatomic, strong) UIView * mSuperView;
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) UIButton *sendBtn ;
@property (nonatomic, strong) UIButton *agreeBtn ;
@property (nonatomic, strong) UIButton *refusedBtn ;
@property (nonatomic, strong) NSString *groipId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, nonatomic)  BOOL teamUsershipType;
@property (nonatomic, nonatomic)  BOOL isShow;
@property (strong, nonatomic)  NSMutableArray * memberList;
- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType;
-(void)showView;
-(void)hideView;
@end

@protocol DetailDelegate <NSObject>

-(void)buttonOnClick;
-(void)itemOnClick:(NSDictionary*)charaDic;
-(void)headImgClick:(NSString*)userId;
-(void)btnAction:(UIButton*)sender;
-(void)positionAction;
-(void)doShowView;
-(void)doHideView;
-(void)doShowOrHideViewControl;
@end
