//
//  NewTeamMenuView.m
//  GameGroup
//
//  Created by Apple on 14-8-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewTeamMenuView.h"
#import "TagCell.h"
#import "CardTitleView.h"
#import "JoinTeamCell.h"
#import "ItemManager.h"
#import "InplaceCell.h"
#import "TestViewController.h"
#import "ChineseString.h"
#import "pinyin.h"
#import "InplaceTimer.h"
#define bottomHight 40.5
#define btnHight 40.5
#define topHight 150
#define bottomPadding 0

@implementation NewTeamMenuView

- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGBA(0x000000, 0.6);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changPosition:) name:kChangPosition object:nil];//位置改变
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changMemberList:) name:kChangMemberList object:nil];//组队人数变化
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
        self.groipId = groupId;
        self.teamUsershipType = teamUsershipType;
        self.roomId = roomId;
        self.gameId = gameId;
        
        UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320,topHight)];
        bgImageView.userInteractionEnabled = YES;
        bgImageView.backgroundColor = UIColorFromRGBA(0x000000, 0.6);
        [self addSubview:bgImageView];
        
        UIView * uiTableViewBg = [[UIView alloc] initWithFrame:CGRectMake(0, topHight, 320, kScreenHeigth-topHight)];
        uiTableViewBg.backgroundColor = [UIColor whiteColor];
         [self addSubview:uiTableViewBg];

        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,18, 200, 44)];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = @"队员列表";
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [bgImageView addSubview:self.titleLabel];
        
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(320-65, 20, 65, 44);
        [button setBackgroundImage:[UIImage imageNamed:@"team_menu_icon_open"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeViewAction:)forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [bgImageView addSubview:button];
        
        
        NSArray * texts = @[@"邀请",@"提醒",@"详情",@"申请"];
        for (int i = 0; i<texts.count; i++) {
            UIButton *menubutton = [UIButton buttonWithType:UIButtonTypeCustom];
            menubutton.tag = i;
            float itemWight = 320/texts.count;
            menubutton.frame = CGRectMake(i*itemWight + ((itemWight-54)/2), 70, 54, 54);
            [menubutton addTarget:self action:@selector(btnAction:)forControlEvents:UIControlEventTouchUpInside];
            if (i == 1) {
                 NSString * msgState = [[GroupManager singleton] getMsgSettingStateByGroupId:self.groipId];
                [self setMsgStateBg:menubutton State:msgState];
            }else{
                [menubutton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"team_menu_normal%d",i+1]]forState:UIControlStateNormal];
                [menubutton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"team_menu_click%d",i+1]]forState:UIControlStateHighlighted];
            }
            [menubutton setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
            [bgImageView addSubview:menubutton];
            
            
            UILabel *menuLable = [[UILabel alloc] init];
            menuLable.frame = CGRectMake(i*itemWight,125,itemWight,20);
            menuLable.font = [UIFont systemFontOfSize:12];
            menuLable.textAlignment = NSTextAlignmentCenter;
            menuLable.textColor=UIColorFromRGBA(0xf7f7f7, 1);
            menuLable.backgroundColor=[UIColor clearColor];
            menuLable.text = [texts objectAtIndex:i];
            [bgImageView addSubview:menuLable];
        }
        
        UILabel * pveLable = [[UILabel alloc]initWithFrame:CGRectMake(0, (kScreenHeigth-topHight-20)/2+80, 320, 20)];
        pveLable.backgroundColor = [UIColor clearColor];
        pveLable.textAlignment = NSTextAlignmentCenter;
        pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        pveLable.text = self.teamUsershipType?@"队长可以滑动名单进行管理":@"队员滑动自己可以退出房间";
        pveLable.font =[ UIFont systemFontOfSize:20];
        
        if (!self.mTableView) {
            self.mTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320,kScreenHeigth-topHight-bottomHight-(KISHighVersion_7?0:20)) style:UITableViewStylePlain];
            self.mTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 0.6);
            self.mTableView.delegate = self;
            self.mTableView.dataSource = self;
            self.mTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
            self.mTableView.tableFooterView = pveLable;
            self.mTableView.tableFooterView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 0.6);
            [GameCommon setExtraCellLineHidden:self.mTableView];
            [uiTableViewBg addSubview:self.mTableView];
        }
        
        if (!self.bottomView){
            self.bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0,self.mTableView.frame.size.height, 320, bottomHight)];
            self.bottomView.backgroundColor = [UIColor greenColor];
            self.bottomView.image =KUIImage(@"bottom_bg");
            self.bottomView.userInteractionEnabled = YES;
            [uiTableViewBg addSubview:self.bottomView];
            if (self.teamUsershipType) {
                self.sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomPadding, 320, btnHight)];
                [self.sendBtn setBackgroundImage:KUIImage(@"team_sendBtn_normal") forState:UIControlStateNormal];
                [self.sendBtn setBackgroundImage:KUIImage(@"team_sendBtn_click") forState:UIControlStateHighlighted];
                [self.sendBtn setBackgroundImage:KUIImage(@"team_sendBtn_select") forState:UIControlStateSelected];
                [self.sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.sendBtn.backgroundColor = [UIColor clearColor];
                [self.sendBtn addTarget:self action:@selector(sendButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:self.sendBtn];
                
                self.timeLable = [[UILabel alloc] initWithFrame:CGRectMake(320-120, bottomPadding, 80, btnHight)];
                self.timeLable.textColor = [UIColor grayColor];
                self.timeLable.font = [UIFont systemFontOfSize:14];
                self.timeLable.hidden = YES;
                self.timeLable.backgroundColor = [UIColor clearColor];
                self.timeLable.textAlignment = NSTextAlignmentCenter;
                self.timeLable.text = @"(180)";
                [self.bottomView addSubview:self.timeLable];
            }else{
                self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, bottomPadding, 160, btnHight)];
                [self.agreeBtn setBackgroundImage:KUIImage(@"tean_agreeBtn_normal") forState:UIControlStateNormal];
                [self.agreeBtn setBackgroundImage:KUIImage(@"tean_agreeBtn_click") forState:UIControlStateHighlighted];
                [self.agreeBtn setBackgroundImage:KUIImage(@"tean_agreeBtn_select") forState:UIControlStateSelected];
                [self.agreeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.agreeBtn.backgroundColor = [UIColor clearColor];

                [self.agreeBtn addTarget:self action:@selector(agreeButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:self.agreeBtn];
                
                self.refusedBtn = [[UIButton alloc] initWithFrame:CGRectMake(160,bottomPadding,160, btnHight)];
                [self.refusedBtn setBackgroundImage:KUIImage(@"team_refusedBtn_normal") forState:UIControlStateNormal];
                [self.refusedBtn setBackgroundImage:KUIImage(@"team_refusedBtn_click") forState:UIControlStateHighlighted];
                [self.refusedBtn setBackgroundImage:KUIImage(@"team_refusedBtn_select") forState:UIControlStateSelected];
                [self.refusedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                self.refusedBtn.backgroundColor = [UIColor clearColor];

                [self.refusedBtn addTarget:self action:@selector(refusedButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:self.refusedBtn];
            }
        }
        
        hud = [[MBProgressHUD alloc] initWithView:self];
        hud.labelText = @"加载中...";
        [self addSubview:hud];
    }
    return self;
}

//0：正常 2：无声
-(void)btnAction:(UIButton*)sender{
    NSInteger tag = sender.tag;
    
    if (tag == 1) {
        NSString * newstate ;
        NSString * msgState = [[GroupManager singleton] getMsgSettingStateByGroupId:self.groipId];
        if ([msgState isEqualToString:@"0"]) {
            newstate = @"2";
        }else{
            newstate = @"0";
        }
        [[GroupManager singleton] SettingGroupMsgState:self.groipId MsgState:newstate reSuccess:^(id responseObject) {
            [self setMsgStateBg:sender State:newstate];
        } reError:^(id error) {
            
        }];
    }
    [self.detaildelegate menuOnClick:tag];
}

-(void)setMsgStateBg:(UIButton*)btn State:(NSString*)state{
    if ([state isEqualToString:@"2"]) {
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"team_menu_normal%d",22]]forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"team_menu_click%d",22]]forState:UIControlStateHighlighted];
    }else{
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"team_menu_normal%d",2]]forState:UIControlStateNormal];
        [btn setImage:[UIImage imageNamed:[NSString stringWithFormat:@"team_menu_click%d",2]]forState:UIControlStateHighlighted];
    }
}


-(void)settTitleMsg:(NSString*)titleText{
    self.titleLabel.text = titleText;
}

//关闭页面
-(void)closeViewAction:(UIButton*)sender{
    [self.detaildelegate doCloseInpacePageAction];
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



-(void)sendBtnEnable{
    [self.sendBtn setBackgroundImage:KUIImage(@"team_sendBtn_normal") forState:UIControlStateNormal];
    [self.sendBtn setBackgroundImage:KUIImage(@"team_sendBtn_click") forState:UIControlStateHighlighted];
    [self.sendBtn setUserInteractionEnabled:YES];
}
-(void)sendBtnUnEnable{
    [self.sendBtn setBackgroundImage:KUIImage(@"team_sendBtn_select") forState:UIControlStateNormal];
    [self.sendBtn setUserInteractionEnabled:NO];
}


-(void)agreeBtnEnable{
    self.agreeBtn.frame = CGRectMake(0, bottomPadding, 160, btnHight);
    [self.agreeBtn setBackgroundImage:KUIImage(@"tean_agreeBtn_normal") forState:UIControlStateNormal];
    [self.agreeBtn setBackgroundImage:KUIImage(@"tean_agreeBtn_click") forState:UIControlStateHighlighted];
    [self.agreeBtn setUserInteractionEnabled:YES];
}
-(void)agreeBtnUnEnable{
    self.agreeBtn.frame = CGRectMake(0, bottomPadding, 320, btnHight);
    [self.agreeBtn setBackgroundImage:KUIImage(@"tean_agreeBtn_select") forState:UIControlStateNormal];
    [self.agreeBtn setUserInteractionEnabled:NO];
}



-(void)refusedBtnEnable{
    self.refusedBtn.frame = CGRectMake(160, bottomPadding, 160, btnHight);
    [self.refusedBtn setBackgroundImage:KUIImage(@"team_refusedBtn_normal") forState:UIControlStateNormal];
    [self.refusedBtn setBackgroundImage:KUIImage(@"team_refusedBtn_click") forState:UIControlStateHighlighted];
    [self.refusedBtn setUserInteractionEnabled:YES];
}
-(void)refusedBtnUnEnable{
    self.refusedBtn.frame = CGRectMake(0, bottomPadding, 320, btnHight);
    [self.refusedBtn setBackgroundImage:KUIImage(@"team_refusedBtn_select") forState:UIControlStateNormal];
    [self.refusedBtn setUserInteractionEnabled:NO];
}

//正常
-(void)normal{
    if (self.teamUsershipType) {
        self.timeLable.hidden = YES;
        [self sendBtnEnable];
        
    }else{
        self.agreeBtn.hidden = NO;
        self.refusedBtn.hidden = NO;
        [self agreeBtnEnable];
        [self refusedBtnEnable];
        
    }
}

//已经发送
-(void)send{
    if (self.teamUsershipType) {
        self.timeLable.hidden = NO;
        [self sendBtnUnEnable];
        self.agreeBtn.hidden = YES;
        self.refusedBtn.hidden = YES;
    }else{
        self.agreeBtn.hidden = NO;
        self.refusedBtn.hidden = NO;
        [self agreeBtnEnable];
        [self refusedBtnEnable];
    }
}
//已经确定
-(void)ok{
    if (self.teamUsershipType) {
        self.timeLable.hidden = NO;
        [self sendBtnUnEnable];
    }else{
        self.agreeBtn.hidden = NO;
        self.refusedBtn.hidden = YES;
        [self agreeBtnUnEnable];
        [self.refusedBtn setUserInteractionEnabled:NO];
    }
}

//已经取消
-(void)cancel{
    if (self.teamUsershipType) {
        self.timeLable.hidden = NO;
       [self sendBtnUnEnable];
    }else{
        self.agreeBtn.hidden = YES;
        self.refusedBtn.hidden = NO;
        [self refusedBtnUnEnable];
        [self.agreeBtn setUserInteractionEnabled:NO];
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


//隐藏按钮
-(void)hideButton{
    self.bottomView.hidden = YES;
    self.mTableView.frame = CGRectMake(0, 0, 320,kScreenHeigth-topHight);
}
//显示按钮
-(void)showButton{
    self.bottomView.hidden = NO;
    self.mTableView.frame = CGRectMake(0, 0, 320,kScreenHeigth-topHight-bottomHight);
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
//清除未读的就位确认消息
-(void)clearNorReadInpaceMsg{
    if ([self.detaildelegate respondsToSelector:@selector(readInpaceMsgAction)] ) {
        [self.detaildelegate readInpaceMsgAction];
    }
}

//确定就位
-(void)agreeButton:(UIButton*)sender{
    if (self.refusedBtn.isHighlighted) {
        return;
    }
    [hud show:YES];
    [[ItemManager singleton] teamPreparedUserSelect:self.roomId GameId:self.gameId Value:@"1" reSuccess:^(id responseObject) {
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
        [self btnOnclick:@"0" OnCLickState:@"0"];//
        [self showErrorAlertView:error];
    }];
}
//取消就位
-(void)refusedButton:(UIButton*)sender{
    if (self.agreeBtn.isHighlighted) {
        return;
    }
    [hud show:YES];
    [[ItemManager singleton] teamPreparedUserSelect:self.roomId GameId:self.gameId Value:@"0" reSuccess:^(id responseObject){
        [hud hide:YES];
    } reError:^(id error) {
        [hud hide:YES];
         [self btnOnclick:@"0" OnCLickState:@"0"];//
        [self showErrorAlertView:error];
    }];
}

-(void)btnOnclick:(NSString*)state OnCLickState:(NSString*)onCLickState{
    [[TeamManager singleton] updateTeamUserState:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] GroupId:self.groipId State:state OnClickState:onCLickState Successcompletion:^(BOOL success, NSError *error) {
        [self changInplaceStateMethods:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] GroupId:self.groipId State:state];
    }];
}

//就位确认数据
-(void)getmemberList{
    self.memberList = [self comm:[DataStoreManager getMemberList:[GameCommon getNewStringWithId:self.roomId] GameId:[GameCommon getNewStringWithId:self.gameId]]];
}

-(void)setMemberListss{
    [self getmemberList];
    [self.mTableView reloadData];
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


#pragma mark -- UITableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        [self.mTableView deselectRowAtIndexPath:indexPath animated:YES];
        NSMutableDictionary *dic = [self.memberList objectAtIndex:indexPath.row];
        if ([[dic allKeys]containsObject:@"teamUser"]) {
            [self.detaildelegate itemOnClick:[self createCharaDic:dic]];
        }else{
            hud.labelText = @"注意，这是坑位，请等小伙伴一下";
            hud.mode = MBProgressHUDModeText;
            [hud show:YES];
            [hud hide:YES afterDelay:2];
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
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return 0;
    }
    return self.memberList.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 50;
    }
    return 0;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 30, 320, 20)];
        view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 0.5);
        
        UILabel * pveLable = [[UILabel alloc]initWithFrame:CGRectMake(0,20, 320, 20)];
        pveLable.backgroundColor = UIColorFromRGBA(0xf3f3f3, 0.5);
        pveLable.textAlignment = NSTextAlignmentCenter;
        pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        pveLable.text = self.teamUsershipType?@"队长可以滑动名单进行管理":@"队员滑动自己可以退出房间";
        pveLable.font =[ UIFont systemFontOfSize:12];
        [view addSubview:pveLable];
        return view;
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        static NSString *identifier = @"simpleInplaceCell";
        InplaceCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[InplaceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.tag = indexPath.row;
        cell.headCkickDelegate = self;
        cell.positionCkickDelegate = self;
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
        
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"userid")] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
            NSDictionary *dic = [NSDictionary dictionary];
            if ([[msgDic objectForKey:@"position"] isKindOfClass:[NSDictionary class]]) {
                dic =[msgDic objectForKey:@"position"];
            }
            

            if ([GameCommon isEmtity:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"value")]]&&[GameCommon isEmtity:KISDictionaryHaveKey(msgDic, @"value")]) {
                cell.dotPosition.hidden = NO;
                [cell.dotPosition setMsgCount:1 IsSimple:YES];
                cell.positionLable.text = @"请选择";
            }else {
                cell.dotPosition.hidden = YES;
                [cell.dotPosition setMsgCount:0 IsSimple:YES];
                if ([[msgDic allKeys]containsObject:@"value"]) {
                    cell.positionLable.text =KISDictionaryHaveKey(msgDic, @"value");
                }else{
                    cell.positionLable.text = KISDictionaryHaveKey(dic, @"value");
                }
            }
            cell.positionLable.textColor = UIColorFromRGBA(0x339adf, 1);
            [cell.positionBtn setUserInteractionEnabled:YES];
        }else{
            cell.dotPosition.hidden = YES;
            [cell.dotPosition setMsgCount:0 IsSimple:YES];
            cell.positionLable.text = [GameCommon isEmtity:KISDictionaryHaveKey(msgDic, @"value")]?@"未选":KISDictionaryHaveKey(msgDic, @"value");
            cell.positionLable.textColor = [UIColor grayColor];
            [cell.positionBtn setUserInteractionEnabled:NO];
        }
        
        if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"0"]){//未发起
            cell.stateView.hidden = YES;
        }else{
            cell.stateView.hidden = NO;
            cell.bgV.backgroundColor = [UIColor whiteColor];
            if ([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"1"]) {//未处理
                cell.stateView.backgroundColor = [UIColor grayColor];
            }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"2"]){//确认
                cell.stateView.backgroundColor = UIColorFromRGBA(0x45d232, 1);
                cell.bgV.backgroundColor = UIColorFromRGBA(0xecfaea, 1);
            }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"3"]){//取消
                cell.stateView.backgroundColor = UIColorFromRGBA(0xd55656, 1);
                cell.bgV.backgroundColor = UIColorFromRGBA(0xfbeeee, 1);
            }
        }
        NSInteger shipType = [KISDictionaryHaveKey(msgDic, @"teamUsershipType") integerValue];
        if (shipType==0) {
            cell.MemberLable.hidden = NO;
        }else{
            cell.MemberLable.hidden = YES;
        }
        
        
        
        CGSize size = [cell.groupNameLable.text sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
        float w = size.width>((shipType==0)?119:145)?((shipType==0)?119:145):size.width;
        cell.groupNameLable.frame = CGRectMake(80, 9, w, 20);
        cell.genderImageV.frame = CGRectMake(80+w, 9, 20, 20);
        cell.MemberLable.frame = CGRectMake(80+w+20+2, 13, 26, 13);
        return cell;
    }
    return nil;
}

-(void)positionOnClick:(UIButton*)sender{
    [self.detaildelegate menuOnClick:4];
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
    if (indexPath.section == 1) {
        return @"";
    }
    if (self.teamUsershipType) {
        NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
        NSString *userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")] ;
        if ([userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
            return @"解散";
        }
        return @"删除";
    }else if(!self.teamUsershipType){
        NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
            return @"退出";
        }
        return @"";
    }
    return @"";
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return NO;
    }
    if (self.teamUsershipType) {
        return YES;
    }else if(!self.teamUsershipType){
        NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
            return YES;
        }
        return NO;
    }
    return NO;
    
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        return;
    }
    self.deleteIndex = indexPath.row;
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        tableView.editing = NO;
        NSMutableDictionary * dic = [self.memberList objectAtIndex:indexPath.row];
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:[GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]]) {
            
            if (self.teamUsershipType) {
                UIAlertView*  alert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要解散队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"必须解散", nil];
                alert.tag = 10000001;
                [alert show];
                return;
            }
            UIAlertView*  alert =[[ UIAlertView alloc]initWithTitle:@"提示" message:@"您确定要退出该队伍吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 10000002;
            [alert show];
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
    }
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag ==10000001) {
        if (buttonIndex==1) {
            hud.labelText = @"解散中...";
            [hud show:YES];
            [[ItemManager singleton] dissoTeam:self.roomId GameId:self.gameId reSuccess:^(id responseObject) {
                [hud hide:YES];
                [self.detaildelegate doCloseInpacePageAction];
                [self showToastAlertView:@"解散成功"];
            } reError:^(id error) {
                [hud hide:YES];
                [self showErrorAlertView:error];
            }];
        }
    }else if (alertView.tag ==10000002) {
        if (buttonIndex==1) {
            hud.labelText = @"请稍等...";
            [hud show:YES];
             NSMutableDictionary * dic = [self.memberList objectAtIndex:self.deleteIndex];
            [[ItemManager singleton] exitTeam:[GameCommon getNewStringWithId:self.roomId] GameId:[GameCommon getNewStringWithId:self.gameId] MemberId:[GameCommon getNewStringWithId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberId")]] reSuccess:^(id responseObject) {
                [hud hide:YES];
                [self.detaildelegate doCloseControllerAction];
                [self showToastAlertView:@"退出成功"];
            } reError:^(id error) {
                [hud hide:YES];
                [self showErrorAlertView:error];
            }];
        }
    }
}


//退出房间
-(void)gooutRoomWithNet
{
   
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

- (void)userHeadImgClick:(id)Sender{
    InplaceCell * iCell = (InplaceCell*)Sender;
    NSMutableDictionary *dic = [self.memberList objectAtIndex:iCell.tag];
    [self.detaildelegate headImgClick:KISDictionaryHaveKey(dic, @"userid")];
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
-(void)changInplaceState:(NSDictionary*)memberUserInfo{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:self.groipId]]) {
        [self changInplaceStateMethods:KISDictionaryHaveKey(memberUserInfo, @"userid") GroupId:KISDictionaryHaveKey(memberUserInfo, @"groupId") State:[self getState:KISDictionaryHaveKey(memberUserInfo, @"type")]];
    }
}

#pragma mark 接收到发起就位确认消息通知,改变就位确认状态
-(void)sendChangInplaceState{
    [self showButton];
    [self changPState:@"1"];
    [self.mTableView reloadData];
    [self setBtnState];
    [self.detaildelegate mHideOrShowTopMenuView];
}

#pragma mark 接收到初始化就位确认消息通知,改变就位确认状态
-(void)resetChangInplaceState{
    
    if (self.teamUsershipType) {
        [[InplaceTimer singleton] resetTimer:self.gameId RoomId:self.roomId];
    }
    [self setBtnState];
    [self.detaildelegate mHideOrShowTopMenuView];
    [self clearNorReadInpaceMsg];
    [self.detaildelegate hideMenuView];//隐藏就位确认页面
}


-(void)changInplaceStateMethods:(NSString*)userId GroupId:(NSString*)groupId State:(NSString*)state{
    [self changPState:[GameCommon getNewStringWithId:userId] GroupId:[GameCommon getNewStringWithId:groupId] State:state];
    [self.mTableView reloadData];
    [self clearNorReadInpaceMsg];
    [self setBtnState];
    [self.detaildelegate mHideOrShowTopMenuView];
}

//显示
-(void)showView{
    [self getmemberList];
    [self.mTableView reloadData];
    [self setBtnState];
    self.isShow = YES;
    if (self.teamUsershipType) {
    }
}
//隐藏
-(void)hideView{
    self.isShow = NO;
    if (self.teamUsershipType) {//停止计时
    }
}

-(void)restartTime{
    if (self.teamUsershipType) {
        [[InplaceTimer singleton] reStartTimer:self.gameId RoomId:self.roomId GroupId:self.groipId timeDeleGate:self];
    }
}

-(void)stopTime{
    if (self.teamUsershipType) {
        [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.groipId];
    }
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
#pragma mark
- (void)applicationWillResignActive:(NSNotification *)notification
{
     NSLog(@"从应用退到桌面或者锁屏");
    if (self.isShow) {
         [self stopTime];
    }
}
#pragma mark
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    NSLog(@"解锁或者从桌面回到应用");
    if (self.isShow) {
        [self restartTime];
    }
}
//计时
- (void)timingTime:(long long )time{
    NSLog(@"计时时间---->>>>>>%lld",time);
    [self sendBtnEnable];
    self.timeLable.text = [NSString stringWithFormat:@"(%lld)",time];
    [self sendBtnUnEnable];
}


- (void)dealloc
{
    if (self.mTableView) {
        self.mTableView.delegate=nil;
        self.mTableView.dataSource=nil;
    }
}
@end
