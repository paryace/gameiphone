//
//  TeamChatListView.h
//  GameGroup
//
//  Created by Apple on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DropDownChooseDelegate.h"
#import "HeadClickDelegate.h"
#import "JoinTeamCell.h"
#import "TagCell.h"
#import "TimeDelegate.h"


#define SECTION_BTN_TAG_BEGIN   1000
#define SECTION_IV_TAG_BEGIN    3000
@interface TeamChatListView : UIView<UITableViewDelegate,UITableViewDataSource,UICollectionViewDataSource,UICollectionViewDelegate,TeamDetailDelegate,HeadClickDelegate,TagOnCLicklDelegate,TimeDelegate>{
    NSInteger currentExtendSection;     //当前展开的section ，默认－1时，表示都没有展开
    MBProgressHUD* hud;//提示框
}

@property (nonatomic, assign) id<DropDownChooseDelegate> dropDownDelegate;
@property (nonatomic, assign) id<DropDownChooseDataSource> dropDownDataSource;


@property (nonatomic, strong) UIView * mSuperView;
@property (nonatomic, strong) UIView * mTableBaseView;
@property (nonatomic, strong) UIView * mBgView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;
@property (nonatomic, strong) UICollectionView *customPhotoCollectionView;
@property (nonatomic, strong) UITableView *mTableView;
@property (nonatomic, strong) UIImageView *bottomView;
@property (nonatomic, strong) UIImageView *bottomMenuView;
@property (nonatomic, strong) UIButton *sendBtn ;
@property (nonatomic, strong) UIButton *agreeBtn ;
@property (nonatomic, strong) UIButton *refusedBtn ;

@property (nonatomic, strong) NSString *groipId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, nonatomic)  BOOL teamUsershipType;

@property (strong, nonatomic)  NSMutableArray * teamNotifityMsg;
@property (strong, nonatomic)  NSMutableArray * memberList;

- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate SuperView:(UIView*)supView GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType;
- (void)setTitle:(NSString *)title inSection:(NSInteger) section;

- (BOOL)isShow;
- (void)hideExtendedChooseView;

@end

