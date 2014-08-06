//
//  TeamChatListView.m
//  GameGroup
//
//  Created by Apple on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamChatListView.h"
#import "CardCell.h"
#import "CardTitleView.h"
#import "JoinTeamCell.h"
#import "ItemManager.h"
#import "InplaceCell.h"
#import "TestViewController.h"

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))

@implementation TeamChatListView


- (id)initWithFrame:(CGRect)frame dataSource:(id)datasource delegate:(id) delegate SuperView:(UIView*)supView GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changPosition:) name:kChangPosition object:nil];//位置改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMemberList:) name:kChangMemberList object:nil];//组队人数变化
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changInplaceState:) name:kChangInplaceState object:nil];//收到确认或者取消就位确认状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendChangInplaceState:) name:kSendChangInplaceState object:nil];//发起就位确认状态
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetChangInplaceState:) name:kResetChangInplaceState object:nil];//初始化就位确认状态
        
        
        currentExtendSection = -1;
        self.dropDownDataSource = datasource;
        self.dropDownDelegate = delegate;
        self.groipId = groupId;
        self.teamUsershipType = teamUsershipType;
        self.roomId = roomId;
        self.gameId = gameId;
        
        NSInteger sectionNum =0;
        if ([self.dropDownDataSource respondsToSelector:@selector(numberOfSections)] ) {
            sectionNum = [self.dropDownDataSource numberOfSections];
        }
        if (sectionNum == 0) {
            self = nil;
        }
        UIImageView * bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 320, frame.size.height)];
        UIImage * bgImage = [[UIImage imageNamed:@"chat_bg_image.png"]stretchableImageWithLeftCapWidth:1 topCapHeight:10];
        bgImageView.image = bgImage;
        bgImageView.userInteractionEnabled = YES;
        [self addSubview:bgImageView];
        //初始化默认显示view
        CGFloat sectionWidth = (1.0*(frame.size.width)/sectionNum);
        for (int i = 0; i <sectionNum; i++) {
            UIButton *sectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(sectionWidth*i, 1, sectionWidth, frame.size.height)];
            sectionBtn.tag = SECTION_BTN_TAG_BEGIN + i;
            [sectionBtn addTarget:self action:@selector(sectionBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
            NSString *sectionBtnTitle = @"--";
            if ([self.dropDownDataSource respondsToSelector:@selector(titleInSection:index:)]) {
                sectionBtnTitle = [self.dropDownDataSource titleInSection:i index:[self.dropDownDataSource defaultShowSection:i]];
            }
            sectionBtn.backgroundColor = [UIColor clearColor];
            [sectionBtn  setTitle:sectionBtnTitle forState:UIControlStateNormal];
            [sectionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            [bgImageView addSubview:sectionBtn];
            
            UIImageView *sectionBtnIv = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i +(sectionWidth - 16), (self.frame.size.height-12)/2, 15, 15)];
            [sectionBtnIv setImage:[UIImage imageNamed:@"down_dark_normal.png"]];
            [sectionBtnIv setContentMode:UIViewContentModeScaleToFill];
            sectionBtnIv.tag = SECTION_IV_TAG_BEGIN + i;
            [bgImageView addSubview: sectionBtnIv];
            if (i<sectionNum && i != 0) {
                UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i, frame.size.height/4, 1, frame.size.height/2)];
                lineView.image = KUIImage(@"chat_ vertical_line");
                [bgImageView addSubview:lineView];
            }
        }
        hud = [[MBProgressHUD alloc] initWithView:supView];
        hud.frame = CGRectMake((320-80)/2, (960-80)/2, 80, 80);
        hud.labelText = @"加载中...";
        [supView addSubview:hud];
    }
    return self;
}



-(void)sectionBtnTouch:(UIButton *)btn
{
    NSInteger section = btn.tag - SECTION_BTN_TAG_BEGIN;
    [self showOrHideControl:section];
}

//显示或者隐藏控制
-(void)showOrHideControl:(NSInteger)section{
    BOOL isOpen = [self.dropDownDelegate clickAtSection:section];
    if (!isOpen) {
        return;
    }
    if (section == 1) {//申请
        [self getZU];
        if (!self.teamNotifityMsg||self.teamNotifityMsg.count==0) {
            [self showErrorAlertView];
            return;
        }
    }else if(section == 2){//就位确认
        [self getmemberList];
    }
    [self showOrHideView:section];
}

//显示或者隐藏布局
-(void)showOrHideView:(NSInteger)section{
//    [self hideView];
    UIImageView *currentIV= (UIImageView *)[self viewWithTag:(SECTION_IV_TAG_BEGIN +currentExtendSection)];
    [UIView animateWithDuration:0.3 animations:^{
        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
        [currentIV setImage:[UIImage imageNamed:@"down_dark_normal.png"]];
    }];
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +currentExtendSection];
    [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
    if (currentExtendSection == section) {
        [self hideExtendedChooseView];
    }else{
        currentExtendSection = section;
//        [self showView];
        currentIV = (UIImageView *)[self viewWithTag:SECTION_IV_TAG_BEGIN + currentExtendSection];
        [UIView animateWithDuration:0.3 animations:^{
            currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
            [currentIV setImage:[UIImage imageNamed:@"down_dark_click.png"]];
        }];
        btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +currentExtendSection];
        [btn setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];
        [self showChooseListViewInSection:currentExtendSection choosedIndex:[self.dropDownDataSource defaultShowSection:currentExtendSection]];
    }
}


-(void)hideView{
    UIImageView *currentIV= (UIImageView *)[self viewWithTag:(SECTION_IV_TAG_BEGIN +currentExtendSection)];
    [UIView animateWithDuration:0.3 animations:^{
        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
        [currentIV setImage:[UIImage imageNamed:@"down_dark_normal.png"]];
    }];
    
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +currentExtendSection];
    [btn setTitleColor:[UIColor blackColor]forState:UIControlStateNormal];
}
-(void)showView{
    UIImageView *currentIV = (UIImageView *)[self viewWithTag:SECTION_IV_TAG_BEGIN + currentExtendSection];
    [UIView animateWithDuration:0.3 animations:^{
        currentIV.transform = CGAffineTransformRotate(currentIV.transform, DEGREES_TO_RADIANS(180));
        [currentIV setImage:[UIImage imageNamed:@"down_dark_click.png"]];
    }];
    
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +currentExtendSection];
    [btn setTitleColor:[UIColor blueColor]forState:UIControlStateNormal];

}

//设置title
- (void)setTitle:(NSString *)title inSection:(NSInteger) section
{
    UIButton *btn = (id)[self viewWithTag:SECTION_BTN_TAG_BEGIN +section];
    [btn setTitle:title forState:UIControlStateNormal];
}

- (BOOL)isShow
{
    if (currentExtendSection == -1) {
        return NO;
    }
    return YES;
}
-  (void)hideExtendedChooseView
{
    if (currentExtendSection != -1) {
        currentExtendSection = -1;
        [self.mBgView removeFromSuperview];
        [self.mTableBaseView removeFromSuperview];
    }
}

-(void)showChooseListViewInSection:(NSInteger)section choosedIndex:(NSInteger)index
{
    float tableHight = self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40;
    if (!self.customPhotoCollectionView&&!self.mTableView) {
        self.mTableBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height , self.frame.size.width, self.mSuperView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
        self.mTableBaseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTappedAction:)];
        [self.mTableBaseView addGestureRecognizer:bgTap];
        self.mBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y + self.frame.size.height, 320, tableHight )];
        self.mBgView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    }
    
    if (!self.bottomMenuView){
        self.bottomMenuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, tableHight-15, 320, 15)];
        self.bottomMenuView.image = KUIImage(@"bottom_memu.png");
        self.bottomMenuView.userInteractionEnabled = YES;
        UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuOnCLick:)];
        [self.bottomMenuView addGestureRecognizer:menuTap];
        [self.mBgView addSubview:self.bottomMenuView];
    }
    
    if (section == 0) {
        if (self.bottomView) {
            [self hideButton];
        }
        
        if (!self.customPhotoCollectionView){
            self.layout = [[UICollectionViewFlowLayout alloc]init];
            self.layout.minimumInteritemSpacing = 10;
            self.layout.minimumLineSpacing =10;
            self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
            self.layout.itemSize = CGSizeMake(88, 30);
            self.customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10,10,300,tableHight-20) collectionViewLayout:self.layout];
            self.customPhotoCollectionView.delegate = self;
            self.customPhotoCollectionView.showsHorizontalScrollIndicator = NO;
            self.customPhotoCollectionView.showsVerticalScrollIndicator = NO;
            self.customPhotoCollectionView.dataSource = self;
            [self.customPhotoCollectionView registerClass:[CardCell class] forCellWithReuseIdentifier:@"ImageCell"];
            self.customPhotoCollectionView.backgroundColor = [UIColor clearColor];
            [self.mTableView removeFromSuperview];
            self.mTableView = nil;
            [self.mBgView addSubview:self.customPhotoCollectionView];
        }
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        [self.customPhotoCollectionView reloadData];
    }else{
        if (!self.mTableView) {
            self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320,tableHight) style:UITableViewStylePlain];
            self.mTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
            self.mTableView.delegate = self;
            self.mTableView.dataSource = self;
            [self.customPhotoCollectionView removeFromSuperview];
            self.customPhotoCollectionView = nil;
            [self.mBgView addSubview:self.mTableView];
        }
        if (section == 2) {
            if (!self.bottomView){
                self.bottomView = [[UIButton alloc] initWithFrame:CGRectMake(0, tableHight-90, 320, 90-15)];
                self.bottomView.backgroundColor = [UIColor whiteColor];
                [self.mBgView addSubview:self.bottomView];
                
                
                self.msgLable= [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 290, 20)];
                self.msgLable.backgroundColor = [UIColor clearColor];
                [self.msgLable setTextAlignment:NSTextAlignmentCenter];
                [self.msgLable setFont:[UIFont systemFontOfSize:14]];
                [self.msgLable setTextColor:[UIColor redColor]];
                self.msgLable.text = @"请确认就位确认";
//                [self.bottomView addSubview:self.msgLable];
                
                if (self.teamUsershipType) {
                    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 25, 290, 35)];
                    [self.sendBtn setBackgroundImage:KUIImage(@"longBtn_normal") forState:UIControlStateNormal];
                    [self.sendBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateHighlighted];
                    [self.sendBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateSelected];
                    [self.sendBtn setTitle:@"发起就位确认" forState:UIControlStateNormal];
                    [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    self.sendBtn.backgroundColor = [UIColor clearColor];
                    self.sendBtn.layer.cornerRadius = 3;
                    self.sendBtn.layer.masksToBounds=YES;
                    [self.sendBtn addTarget:self action:@selector(sendButton:) forControlEvents:UIControlEventTouchUpInside];
                    [self.bottomView addSubview:self.sendBtn];
                }else{
                    self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 25, (320-40)/2, 35)];
                    [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
                    [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
                    [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
                    [self.agreeBtn setTitle:@"确定就位" forState:UIControlStateNormal];
                    [self.agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    self.agreeBtn.backgroundColor = [UIColor clearColor];
                    self.agreeBtn.layer.cornerRadius = 3;
                    self.agreeBtn.layer.masksToBounds=YES;
                    [self.agreeBtn addTarget:self action:@selector(agreeButton:) forControlEvents:UIControlEventTouchUpInside];
                    [self.bottomView addSubview:self.agreeBtn];
                    
                    self.refusedBtn = [[UIButton alloc] initWithFrame:CGRectMake(15+10+(320-40)/2,25, (320-40)/2, 35)];
                    [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
                    [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
                    [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
                    [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
                    [self.refusedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    self.refusedBtn.backgroundColor = [UIColor clearColor];
                    self.refusedBtn.layer.cornerRadius = 3;
                    self.refusedBtn.layer.masksToBounds=YES;
                    [self.refusedBtn addTarget:self action:@selector(refusedButton:) forControlEvents:UIControlEventTouchUpInside];
                    [self.bottomView addSubview:self.refusedBtn];
                }
            }
        }
        if (section==1) {
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        }else{
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            [GameCommon setExtraCellLineHidden:self.mTableView];
        }
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        [self setBtnState];
        [self.mTableView reloadData];
    }
}
//设置按钮状态
-(void)setBtnState{
    NSInteger onClickState = [DataStoreManager getTeamUser:self.groipId UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    if(onClickState == 0){
        [self reset];
        [self normal];
    }else if(onClickState == 1){
        [self showButton];
        [self send];
    }else if(onClickState == 2){
        [self showButton];
        [self ok];
    }else if(onClickState == 3){
        [self showButton];
        [self cancel];
    }
}


-(void)normal{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = NO;
        self.sendBtn.enabled = YES;
        
    }else{
        self.agreeBtn.selected = NO;
        self.agreeBtn.enabled = YES;
        self.refusedBtn.selected = NO;
        self.refusedBtn.enabled = YES;
    }
}

//已经发送
-(void)send{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;

    }else{
        self.agreeBtn.selected = NO;
        self.agreeBtn.enabled = YES;
        self.refusedBtn.selected = NO;
        self.refusedBtn.enabled = YES;
    }
}

//没有就位确认消息的时候
-(void)reset{
    if (self.teamUsershipType) {
        [self showButton];
    }else{
        [self hideButton];
    }
}

//已经确定
-(void)ok{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;
    }else{
        self.agreeBtn.selected = YES;
        self.agreeBtn.enabled = NO;
        self.refusedBtn.selected = YES;
        self.refusedBtn.enabled = NO;
    }
}


//已经取消
-(void)cancel{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;
    }else{
        self.agreeBtn.selected = YES;
        self.agreeBtn.enabled = NO;
        self.refusedBtn.selected = YES;
        self.refusedBtn.enabled = NO;
    }
}
//隐藏按钮
-(void)hideButton{
    self.bottomView.hidden=YES;
    self.mTableView.frame = CGRectMake(0, 0, 320,self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40);
}
//显示按钮
-(void)showButton{
    self.bottomView.hidden=NO;
    self.mTableView.frame = CGRectMake(0, 0, 320,self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40-90);
}

//发起就位确认
-(void)sendButton:(UIButton*)sender{
    [hud show:YES];
    [[ItemManager singleton] sendTeamPreparedUserSelect:self.roomId GameId:self.gameId reSuccess:^(id responseObject) {
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
//确定就位
-(void)agreeButton:(UIButton*)sender{
    if ([self.dropDownDataSource respondsToSelector:@selector(buttonOnClick:)] ) {
        [self.dropDownDataSource buttonOnClick:sender];
    }
    [hud show:YES];
    [[ItemManager singleton] teamPreparedUserSelect:self.roomId GameId:self.gameId Value:@"1" reSuccess:^(id responseObject) {
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
//取消就位
-(void)refusedButton:(UIButton*)sender{
    if ([self.dropDownDataSource respondsToSelector:@selector(buttonOnClick:)] ) {
        [self.dropDownDataSource buttonOnClick:sender];
    }
    [hud show:YES];
    [[ItemManager singleton] teamPreparedUserSelect:self.roomId GameId:self.gameId Value:@"0" reSuccess:^(id responseObject){
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
 //申请通知数控
-(void)getZU
{
    self.teamNotifityMsg = [DataStoreManager queDSTeamNotificationMsgByMsgTypeAndGroupId:@"requestJoinTeam" GroupId:self.groipId];
}
//就位确认数据
-(void)getmemberList{
    self.memberList = [DataStoreManager getMemberList:self.groipId];
}

-(void)showErrorAlertView
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"暂无队友申请" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

-(void)bgTappedAction:(UITapGestureRecognizer *)tap
{
    [self showOrHideView:currentExtendSection];
}

-(void)menuOnCLick:(UITapGestureRecognizer *)tap
{
    [self showOrHideView:currentExtendSection];
}

//----------
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.dropDownDataSource numberOfRowsInSection:currentExtendSection];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CardCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.bgImgView.image = KUIImage(@"tagBtn_normal");
    cell.tag = indexPath.section*1000+indexPath.row;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        NSString *chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
        UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
        [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
        [self.dropDownDelegate chooseAtSection:currentExtendSection index:indexPath.row];
        [self showOrHideView:currentExtendSection];
    }
}

//-------

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return 140;
    }
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        if (currentExtendSection==1) {
            NSMutableDictionary *dic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
            [self.dropDownDataSource itemOnClick:dic];
        }else{
            [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
            NSMutableDictionary *dic = [self.memberList objectAtIndex:indexPath.row];
            [self.dropDownDataSource itemOnClick:[self createCharaDic:dic]];
        }
    }
}

-(NSDictionary*)createCharaDic:(NSMutableDictionary*)dic{
    NSDictionary * charadic = @{@"characterId":[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"characterId")],
                           @"characterName":[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"teamUser"), @"characterName")],
                                @"gameid":[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")]};
    return charadic;
}

#pragma mark -- UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (currentExtendSection==1) {
        return self.teamNotifityMsg.count;
    }else{
        return self.memberList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (currentExtendSection==1) {
        static NSString *identifier = @"simpleApplicationCell";
        JoinTeamCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[JoinTeamCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        cell.tag = indexPath.row;
        NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.headImageV.placeholderImage = KUIImage([self headPlaceholderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
        cell.headImageV.imageURL=[ImageService getImageStr:KISDictionaryHaveKey(msgDic, @"userImg") Width:80];
        cell.genderImageV.image = KUIImage([self genderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
        NSString * gameImageId=[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(msgDic, @"gameid")];
        if ([GameCommon isEmtity:gameImageId]) {
            cell.gameImageV.image=KUIImage(@"clazz_0");
        }else{
            cell.gameImageV.imageURL= [ImageService getImageUrl4:gameImageId];
        }
        cell.groupNameLable.text = KISDictionaryHaveKey(msgDic, @"nickname");
        cell.positionLable.hidden=YES;
        cell.realmLable.text = KISDictionaryHaveKey(msgDic, @"value1");
        cell.pveLable.text = KISDictionaryHaveKey(msgDic, @"value2");
        if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"0"]) {
            if (self.teamUsershipType) {
                cell.detailLable.hidden=YES;
            }else {
                [cell.agreeButton setUserInteractionEnabled:NO];
                [cell.refuseButton setUserInteractionEnabled:NO];
                cell.detailLable.hidden=NO;
                cell.detailLable.text=@"审核中";
            }
        }else{
            [cell.agreeButton setUserInteractionEnabled:NO];
            [cell.refuseButton setUserInteractionEnabled:NO];
            cell.detailLable.hidden=NO;
            if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"1"]) {
                cell.detailLable.text=@"已同意";
            }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"2"]){
                cell.detailLable.text=@"已拒绝";
            }else {
                cell.detailLable.text=@"已处理";
            }
        }
        
        CGSize nameSize = [cell.groupNameLable.text sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.groupNameLable.frame = CGRectMake(75, 12, nameSize.width, 20);
        cell.genderImageV.frame = CGRectMake(75+nameSize.width+5, 10, 20, 20);
        [cell setTime:KISDictionaryHaveKey(msgDic, @"senTime")];
        return cell;
    }else{
        static NSString *identifier = @"simpleInplaceCell";
        InplaceCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[InplaceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.tag = indexPath.row;
        cell.headCkickDelegate = self;
        NSMutableDictionary * msgDic = [self.memberList objectAtIndex:indexPath.row];
        NSMutableDictionary * teamUserDic = KISDictionaryHaveKey(msgDic, @"teamUser");
        
        
        
        cell.headImageV.placeholderImage = KUIImage([self headPlaceholderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
        cell.headImageV.imageURL=[ImageService getImageStr:KISDictionaryHaveKey(msgDic, @"img") Width:80];
        cell.genderImageV.image = KUIImage([self genderImage:KISDictionaryHaveKey(msgDic, @"gender")]);
        NSString * gameImageId=[GameCommon putoutgameIconWithGameId:KISDictionaryHaveKey(msgDic, @"gameid")];
        if ([GameCommon isEmtity:gameImageId]) {
            cell.gameImageV.image=KUIImage(@"clazz_0");
        }else{
            cell.gameImageV.imageURL= [ImageService getImageUrl4:gameImageId];
        }
        cell.groupNameLable.text = KISDictionaryHaveKey(msgDic, @"nickname");
        if ([teamUserDic isKindOfClass:[NSDictionary class]]) {
            cell.realmLable.text = [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"realm"),@"-",KISDictionaryHaveKey(msgDic, @"nickname")];
            cell.pveLable.text = KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"memberInfo");

        }else{
            cell.realmLable.text = @"";
            cell.pveLable.text = @"";
        }
        cell.positionLable.text = [GameCommon isEmtity:KISDictionaryHaveKey(msgDic, @"value")]?@"未选":KISDictionaryHaveKey(msgDic, @"value");
        if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"0"]){//未发起
            cell.stateView.hidden = YES;
        }else{
            cell.stateView.hidden = NO;
            if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"1"]) {//未处理
                cell.stateView.backgroundColor = [UIColor grayColor];
            }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"2"]){//确认
                cell.stateView.backgroundColor = [UIColor greenColor];
            }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"3"]){//取消
                cell.stateView.backgroundColor = [UIColor redColor];
            }
        }
        
        CGSize nameSize = [cell.groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.groupNameLable.frame = CGRectMake(80, 8, nameSize.width, 20);
        cell.genderImageV.frame = CGRectMake(80+nameSize.width+3, 8, 20, 20);
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return @"删除";
    }
   return @"";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return YES;
    }
    return NO;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
        [DataStoreManager deleteTeamNotifityMsgStateByMsgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msgId")] Successcompletion:^(BOOL success, NSError *error) {
            [self.teamNotifityMsg removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        }];
    }
}
//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}

-(void)headImgClick:(JoinTeamCell*)Sender{
    NSMutableDictionary *dic = [self.teamNotifityMsg objectAtIndex:Sender.tag];
    [self.dropDownDataSource headImgClick:KISDictionaryHaveKey(dic, @"userid")];
}
- (void)userHeadImgClick:(id)Sender{
    InplaceCell * iCell = (InplaceCell*)Sender;
     NSMutableDictionary *dic = [self.memberList objectAtIndex:iCell.tag];
    [self.dropDownDataSource headImgClick:KISDictionaryHaveKey(dic, @"userid")];
}
//同意288
-(void)onAgreeClick:(JoinTeamCell*)sender
{
     [hud show:YES];
    NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] agreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
         [hud hide:YES];
         [self changState:msgDic State:@"1"];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"同意加入成功" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } reError:^(id error) {
         [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}
//拒绝273
-(void)onDisAgreeClick:(JoinTeamCell*)sender
{
    [hud show:YES];
    NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] disAgreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
         [hud hide:YES];
        [self changState:msgDic State:@"2"];
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"您已拒绝加入" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    } reError:^(id error) {
         [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}

//弹出提示框
-(void)showErrorAlertView:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

//改变消息状态
-(void)changState:(NSMutableDictionary*)dict State:(NSString*)state
{
    [self changState:KISDictionaryHaveKey(dict, @"userid") GroupId:self.groipId State:state];
}

-(void)changState:(NSString*)userId GroupId:(NSString*)groupId State:(NSString*)state
{
    for (NSMutableDictionary * clickDic in self.teamNotifityMsg) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:userId]
            && [KISDictionaryHaveKey(clickDic, @"state") isEqualToString:@"0"]
            &&[KISDictionaryHaveKey(clickDic, @"groupId") isEqualToString:groupId]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
    [self.mTableView reloadData];
    [DataStoreManager updateTeamNotifityMsgState:userId State:state GroupId:groupId];
}
#pragma mark 改变位置
-(void)changPosition:(NSNotification*)notification{
    NSDictionary * positionDic = notification.userInfo;
    NSLog(@"positipon-->>>>%@",positionDic);
}
#pragma mark 人数变化
-(void)changMemberList:(NSNotification*)notification{
    [self getmemberList];
    [self.mTableView reloadData];
}

#pragma mark 接收到确认或者取消消息通知,改变就位确认状态
-(void)changInplaceState:(NSNotification*)notification{
    NSDictionary * memberUserInfo = notification.userInfo;
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:self.groipId]]) {
        [self changPState:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] State:[self getState:KISDictionaryHaveKey(memberUserInfo, @"type")]];
        [self.mTableView reloadData];
        [self setBtnState];
    }
}
#pragma mark 接收到发起就位确认消息通知,改变就位确认状态
-(void)sendChangInplaceState:(NSNotification*)notification{
    [self showButton];
    [self changPState:@"1"];
    [self.mTableView reloadData];
    [self setBtnState];
}
#pragma mark 接收到初始化就位确认消息通知,改变就位确认状态
-(void)resetChangInplaceState:(NSNotification*)notification{
    [self resetPState];
    [self.mTableView reloadData];
    [self setBtnState];
}

//改变列表就位确认状态
-(void)changPState:(NSString*)userId GroupId:(NSString*)groupId State:(NSString *)state{
    for (NSMutableDictionary * clickDic in self.memberList) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:userId]
            &&[KISDictionaryHaveKey(clickDic, @"groupId") isEqualToString:groupId]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
}
//改变列表就位确认状态
-(void)changPState:(NSString*)state{
    for (NSMutableDictionary * clickDic in self.memberList) {
        if ([KISDictionaryHaveKey(clickDic, @"teamUsershipType") intValue]==0) {
            [clickDic setObject:@"2" forKey:@"state"];
        }else{
            [clickDic setObject:state forKey:@"state"];
        }
    }
}
//重置列表就位确认状态
-(void)resetPState{
    for (NSMutableDictionary * clickDic in self.memberList) {
        [clickDic setObject:@"0" forKey:@"state"];
    }
}

-(NSString*)getState:(NSString*)result{
    if([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectOk"]){
        return @"2";
    }else if ([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectCancel"]) {
        return @"3";
    }
    return @"1";
}
- (void)dealloc
{
    if (self.mTableView) {
        self.mTableView.delegate=nil;
        self.mTableView.dataSource=nil;
    }
}
@end
