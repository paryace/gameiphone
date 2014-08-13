//
//  TeamChatListView.m
//  GameGroup
//
//  Created by Apple on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamChatListView.h"
#import "TagCell.h"
#import "CardTitleView.h"
#import "JoinTeamCell.h"
#import "ItemManager.h"
#import "InplaceCell.h"
#import "TestViewController.h"
#import "ChineseString.h"
#import "pinyin.h"
#import "InplaceTimer.h"

#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)
#define RADIANS_TO_DEGREES(radians) ((radians)*(180.0/M_PI))
#define bottomHight 55
#define bottomPadding 10


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
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                     name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
        
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
            sectionBtn.backgroundColor = [UIColor clearColor];
            [sectionBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            sectionBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14.0f];
            [bgImageView addSubview:sectionBtn];
            
            UIImageView *sectionBtnIv = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i +(sectionWidth - 16), (self.frame.size.height-12)/2, 12, 12)];
            [sectionBtnIv setImage:[UIImage imageNamed:@"down_dark_normal.png"]];
            [sectionBtnIv setContentMode:UIViewContentModeScaleToFill];
            sectionBtnIv.tag = SECTION_IV_TAG_BEGIN + i;
            [bgImageView addSubview: sectionBtnIv];
            if (i<sectionNum && i != 0) {
                UIImageView *lineView = [[UIImageView alloc] initWithFrame:CGRectMake(sectionWidth*i, frame.size.height/8, 1, frame.size.height-(frame.size.height/4))];
                lineView.image = KUIImage(@"chat_ vertical_line");
                [bgImageView addSubview:lineView];
            }
        }
        [self initButtonTitle];
        
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
    if (section == 1) {//就位确认
        [self getmemberList];
    }else if(section == 2){//申请
        [self getZU];
        if (!self.teamNotifityMsg||self.teamNotifityMsg.count==0) {
            [self showToastAlertView:@"暂无队友申请"];
            return;
        }
    }
    [self showOrHideView:section];
}

//显示或者隐藏布局
-(void)showOrHideView:(NSInteger)section{
    [self hideView];
    if (currentExtendSection == section) {
        [self hideExtendedChooseView];
    }else{
        currentExtendSection = section;
        [self showView];
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
    [btn setTitleColor:UIColorFromRGBA(0x339adf, 1)forState:UIControlStateNormal];

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
        if (currentExtendSection==1) {
            [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.groipId];
        }
        currentExtendSection = -1;
        [self.mBgView removeFromSuperview];
        [self.mTableBaseView removeFromSuperview];
    }
}

-(void)showChooseListViewInSection:(NSInteger)section choosedIndex:(NSInteger)index
{
    if (section==1) {
        [[InplaceTimer singleton] reStartTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
    }else{
        [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.groipId];
    }
    float tableHight = self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40;
    if (!self.customPhotoCollectionView&&!self.mTableView) {
        self.mTableBaseView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height , self.frame.size.width, self.mSuperView.frame.size.height - self.frame.origin.y - self.frame.size.height)];
        self.mTableBaseView.backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.5];
        UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bgTappedAction:)];
        [self.mTableBaseView addGestureRecognizer:bgTap];
        self.mBgView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.origin.y + self.frame.size.height, 320, tableHight)];
        self.mBgView.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    }
    
//    if (!self.bottomMenuView){
//        self.bottomMenuView = [[UIImageView alloc] initWithFrame:CGRectMake(0, tableHight-15, 320, 15)];
//        self.bottomMenuView.image = KUIImage(@"bottom_memu.png");
//        self.bottomMenuView.userInteractionEnabled = YES;
//        UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuOnCLick:)];
//        [self.bottomMenuView addGestureRecognizer:menuTap];
//        [self.mBgView addSubview:self.bottomMenuView];
//    }
    
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
            self.customPhotoCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(10,10,300,tableHight) collectionViewLayout:self.layout];
            self.customPhotoCollectionView.delegate = self;
            self.customPhotoCollectionView.showsHorizontalScrollIndicator = NO;
            self.customPhotoCollectionView.showsVerticalScrollIndicator = NO;
            self.customPhotoCollectionView.dataSource = self;
            [self.customPhotoCollectionView registerClass:[TagCell class] forCellWithReuseIdentifier:@"ImageCell"];
            self.customPhotoCollectionView.backgroundColor = [UIColor clearColor];
            [self.mTableView removeFromSuperview];
            self.mTableView = nil;
            [self.mBgView addSubview:self.customPhotoCollectionView];
        }
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        [self.customPhotoCollectionView reloadData];
        hud = [[MBProgressHUD alloc] initWithView:self.mSuperView];
        hud.labelText = @"加载中...";
        [self.mSuperView addSubview:hud];
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
        if (section == 1) {
            if (!self.bottomView){
                self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, tableHight-bottomHight, 320, bottomHight)];
                self.bottomView.backgroundColor = [UIColor whiteColor];
                self.bottomView.image =KUIImage(@"bottom_bg");
                self.bottomView.userInteractionEnabled = YES;
                [self.mBgView addSubview:self.bottomView];
                if (self.teamUsershipType) {
                    self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, bottomPadding, 290, 35)];
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
                    self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, bottomPadding, (320-40)/2, 35)];
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
                    
                    self.refusedBtn = [[UIButton alloc] initWithFrame:CGRectMake(15+10+(320-40)/2,bottomPadding, (320-40)/2, 35)];
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
        [self.mSuperView addSubview:self.mTableBaseView];
        [self.mSuperView addSubview:self.mBgView];
        [self.mTableView reloadData];
        if (section==1) {
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            [GameCommon setExtraCellLineHidden:self.mTableView];
            [self setBtnState];
        }else{
            if (self.bottomView) {
                [self hideButton];
            }
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        }
        hud = [[MBProgressHUD alloc] initWithView:self.mSuperView];
        hud.labelText = @"加载中...";
        [self.mSuperView addSubview:hud];
    }
}



-(void)initButtonTitle{
    NSInteger onClickState = [DataStoreManager getTeamUser:self.groipId UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    [self setButtonTitle:onClickState];
}

-(void)setButtonTitle:(NSInteger)onClickState{
    if (self.teamUsershipType) {
        [self setTitle:@"就位确认" inSection:1];
    }else{
        if(onClickState == 0){
            [self setTitle:@"队员列表" inSection:1];
        }else{
            [self setTitle:@"就位确认" inSection:1];
        }

    }
}

//设置按钮状态
-(void)setBtnState{
    NSInteger onClickState = [DataStoreManager getTeamUser:self.groipId UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    [self setButtonTitle:onClickState];
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

//正常
-(void)normal{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = NO;
        self.sendBtn.enabled = YES;
        
    }else{
        self.agreeBtn.hidden = NO;
        self.agreeBtn.frame = CGRectMake(15, bottomPadding, (320-40)/2, 35);
        [self.agreeBtn setTitle:@"确定就位" forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
        self.agreeBtn.selected = NO;
        self.agreeBtn.enabled = YES;
        
        self.refusedBtn.hidden = NO;
        self.refusedBtn.frame = CGRectMake(15+10+(320-40)/2,bottomPadding, (320-40)/2, 35);
        [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
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
        self.agreeBtn.hidden = NO;
        self.agreeBtn.frame = CGRectMake(15, bottomPadding, (320-40)/2, 35);
        [self.agreeBtn setTitle:@"确定就位" forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
        self.agreeBtn.selected = NO;
        self.agreeBtn.enabled = YES;
        
        self.refusedBtn.hidden = NO;
        self.refusedBtn.frame = CGRectMake(15+10+(320-40)/2,bottomPadding, (320-40)/2, 35);
        [self.refusedBtn setTitle:@"拒绝就位" forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_normal") forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateHighlighted];
        [self.refusedBtn setBackgroundImage:KUIImage(@"shortBtn_select") forState:UIControlStateSelected];
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
        self.agreeBtn.hidden = NO;
        self.agreeBtn.frame = CGRectMake(15, bottomPadding, 290, 35);
        [self.agreeBtn setTitle:@"已确认" forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"longBtn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateSelected];
        self.agreeBtn.selected = YES;
        self.agreeBtn.enabled = NO;
        
        self.refusedBtn.selected = YES;
        self.refusedBtn.enabled = NO;
        self.refusedBtn.hidden = YES;
    }
}


//已经取消
-(void)cancel{
    if (self.teamUsershipType) {
        [self.sendBtn setTitle:@"已经发起就位确认" forState:UIControlStateNormal];
        self.sendBtn.selected = YES;
        self.sendBtn.enabled = NO;
    }else{
        self.agreeBtn.hidden = YES;
        self.agreeBtn.selected = YES;
        self.agreeBtn.enabled = NO;
        
        self.refusedBtn.hidden = NO;
        self.refusedBtn.frame = CGRectMake(15, bottomPadding, 290, 35);
        [self.refusedBtn setTitle:@"已拒绝" forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"longBtn_normal") forState:UIControlStateNormal];
        [self.refusedBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateHighlighted];
        [self.refusedBtn setBackgroundImage:KUIImage(@"longBtn_select") forState:UIControlStateSelected];
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
    self.mTableView.frame = CGRectMake(0, 0, 320,self.superview.frame.size.height-(KISHighVersion_7 ? 64 : 44)-40-bottomHight);
}

//发起就位确认
-(void)sendButton:(UIButton*)sender{
    [hud show:YES];
    [[ItemManager singleton] sendTeamPreparedUserSelect:self.roomId GameId:self.gameId reSuccess:^(id responseObject) {
        [hud hide:YES];
        [[InplaceTimer singleton] startTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
    } reError:^(id error) {
        [hud hide:YES];
        [self showErrorAlertView:error];
    }];
}

-(void)clearNorReadMsg{
    if ([self.dropDownDataSource respondsToSelector:@selector(buttonOnClick)] ) {
        [self.dropDownDataSource buttonOnClick];
    }
}

//确定就位
-(void)agreeButton:(UIButton*)sender{
    [self clearNorReadMsg];
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
    [self clearNorReadMsg];
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
    self.memberList = [self comm:[DataStoreManager getMemberList:self.roomId GameId:self.gameId]];
}

//排序
-(NSMutableArray*)comm:(NSMutableArray*)array{
    NSMutableArray *chineseStringsArray=[NSMutableArray array];
    for(int i=0;i<[array count];i++){
        ChineseString *chineseString=[[ChineseString alloc]init];
        NSDictionary * memberDic = [array objectAtIndex:i];
        NSString * str = KISDictionaryHaveKey(memberDic, @"value");
        if ([GameCommon isEmtity:str]) {
            str = @"Z";
        }

        chineseString.string=[NSString stringWithString:str];
        chineseString.memberInfo = memberDic;
        if(chineseString.string==nil){
            chineseString.string=@"";
        }
        if(![chineseString.string isEqualToString:@""]){
            NSString *pinYinResult=[NSString string];
            for(int j=0;j<chineseString.string.length;j++){
                NSString *singlePinyinLetter=[[NSString stringWithFormat:@"%c",pinyinFirstLetter([chineseString.string characterAtIndex:j])]uppercaseString];
                
                pinYinResult=[pinYinResult stringByAppendingString:singlePinyinLetter];
            }
            chineseString.pinYin=pinYinResult;
        }else{
            chineseString.pinYin=@"";
        }
        [chineseStringsArray addObject:chineseString];
    }
    
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"pinYin" ascending:YES]];
    [chineseStringsArray sortUsingDescriptors:sortDescriptors];
    
    
    NSMutableArray *result=[NSMutableArray array];
    for(int i=0;i<[chineseStringsArray count];i++){
        [result addObject:((ChineseString*)[chineseStringsArray objectAtIndex:i]).memberInfo];
    }
    return result;
}


-(void)showToastAlertView:(NSString*)msgText
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:msgText delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
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
    TagCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    cell.tag = indexPath.row;
    cell.delegate = self;
    cell.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.titleLabel.text = [self.dropDownDataSource titleInSection:currentExtendSection index:indexPath.row];
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
}
-(void)tagOnClick:(TagCell*)sender{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        NSString *chooseCellTitle = [self.dropDownDataSource titleInSection:currentExtendSection index:sender.tag];
        UIButton *currentSectionBtn = (UIButton *)[self viewWithTag:SECTION_BTN_TAG_BEGIN + currentExtendSection];
        [currentSectionBtn setTitle:chooseCellTitle forState:UIControlStateNormal];
        [self.dropDownDelegate chooseAtSection:currentExtendSection index:sender.tag];
        [self showOrHideView:currentExtendSection];
    }

}

//-------

#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        return 80;
    }
    return 140;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.dropDownDelegate respondsToSelector:@selector(chooseAtSection:index:)]) {
        if (currentExtendSection==1) {
            [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
            NSMutableDictionary *dic = [self.memberList objectAtIndex:indexPath.row];
            if ([[dic allKeys]containsObject:@"teamUser"]) {
                [self.dropDownDataSource itemOnClick:[self createCharaDic:dic]];
            }else{
                hud.labelText = @"注意，这是坑位，请等小伙伴一下";
                hud.mode = MBProgressHUDModeText;
                [hud show:YES];
                [hud hide:YES afterDelay:2];
            }
        }else{
            NSMutableDictionary *dic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
            [self.dropDownDataSource itemOnClick:dic];
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
        return self.memberList.count;
    }else{
        return self.teamNotifityMsg.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (currentExtendSection==1) {
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
            cell.realmLable.text = [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"realm"),@"-",KISDictionaryHaveKey(KISDictionaryHaveKey(msgDic, @"teamUser"), @"characterName")];
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
        NSInteger shipType = [KISDictionaryHaveKey(msgDic, @"teamUsershipType") integerValue];
        if (shipType==0) {
            cell.MemberLable.hidden = NO;
            cell.MemberLable.backgroundColor = UIColorFromRGBA(0x2eac1d, 1);
            cell.MemberLable.text = @"队长";
        }else{
            cell.MemberLable.hidden = YES;
        }
        CGSize size = [cell.groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
        float w = size.width>((shipType==0)?119:145)?((shipType==0)?119:145):size.width;
        cell.groupNameLable.frame = CGRectMake(80, 9, w, 20);
        cell.genderImageV.frame = CGRectMake(80+w, 9, 20, 20);
        cell.MemberLable.frame = CGRectMake(80+w+20+2, 13, 26, 13);
        
        return cell;

    }else{
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
        cell.realmLable.text = [NSString stringWithFormat:@"%@%@%@",KISDictionaryHaveKey(msgDic, @"realm"),@"-",KISDictionaryHaveKey(msgDic, @"characterName")];
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
        cell.timeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:KISDictionaryHaveKey(msgDic, @"senTime")]];
        [cell refreTitleFrame];
        return cell;
    }
}
//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        if (self.teamUsershipType) {
            return @"删除";
        }
        return @"";
    }
    return @"删除";
   
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (currentExtendSection==1) {
        if (self.teamUsershipType) {
            return YES;
        }
        return NO;
    }
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        if (currentExtendSection==1) {
            tableView.editing = NO;
            NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
                 [self showToastAlertView:@"您不能踢出自己,如果想撤销队伍,点击择队伍设置,进入设置页面后解散队伍"];
                return;
            }
            [hud show:YES];
            [[ItemManager singleton] removeFromTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")] MemberTeamUserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberTeamUserId")] reSuccess:^(id responseObject) {
                [hud hide:YES];
                [self resetMemberList];
                [self showToastAlertView:@"删除成功"];
            } reError:^(id error) {
                [hud hide:YES];
                [self showErrorAlertView:error];
            }];
        }else if (currentExtendSection==2){
            NSMutableDictionary * msgDic = [self.teamNotifityMsg objectAtIndex:indexPath.row];
            [DataStoreManager deleteTeamNotifityMsgStateByMsgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msgId")] Successcompletion:^(BOOL success, NSError *error) {
                [self.teamNotifityMsg removeObjectAtIndex:indexPath.row];
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
                if (self.teamNotifityMsg.count==0) {
                    [self showOrHideView:currentExtendSection];
                }
            }];
        }
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
    [self resetMemberList];
}
#pragma mark 人数变化
-(void)changMemberList:(NSNotification*)notification{
    [self resetMemberList];
}

-(void)resetMemberList{
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
//    [self resetPState];
//    [self.mTableView reloadData];
    [[InplaceTimer singleton] resetTimer:self.gameId RoomId:self.roomId];
     [self clearNorReadMsg];
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

- (void)applicationWillResignActive:(NSNotification *)notification
{
    if ([self isShow]) {
        if (currentExtendSection==1) {
            [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.groipId];
        }
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ([self isShow]) {
        if (currentExtendSection==1) {
            [[InplaceTimer singleton] reStartTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
        }
    }
}
//计时
- (void)timingTime:(long long )time{
    [self.sendBtn setTitle:[NSString stringWithFormat:@"%@(%lld)",@"已经发起就位确认",time] forState:UIControlStateNormal];
    NSLog(@"计时时间---->>>>>>%lld",time);
}
- (void)finishTiming{
    NSLog(@"倒计时结束");
}
- (void)dealloc
{
    if (self.mTableView) {
        self.mTableView.delegate=nil;
        self.mTableView.dataSource=nil;
    }
}
@end
