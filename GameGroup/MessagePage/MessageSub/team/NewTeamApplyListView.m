//
//  NewTeamApplyListView.m
//  GameGroup
//
//  Created by Apple on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewTeamApplyListView.h"
#define topHight 44

@implementation NewTeamApplyListView{
    UITableView * m_TableView;
    NSMutableArray * teamNotifityMsg;
    UILabel *m_alertLabel;
}

- (id)initWithFrame:(CGRect)frame GroupId:(NSString*)groupId RoomId:(NSString*)roomId GameId:(NSString*)gameId teamUsershipType:(BOOL)teamUsershipType
{
    self = [super initWithFrame:frame];
    if (self) {
        //申请加入组队通知
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinTeamReceived:) name:kJoinTeamMessage object:nil];
        self.groipId = groupId;
        self.teamUsershipType = teamUsershipType;
        self.roomId = roomId;
        self.gameId = gameId;
        
        UIImageView* bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320,topHight)];
        bgImageView.userInteractionEnabled = YES;
        bgImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
        bgImageView.image = KUIImage(@"nav_bg");
        [self addSubview:bgImageView];
        
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60,0, 200, 44)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"组队申请";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [bgImageView addSubview:titleLabel];
        
        
        UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 65, 44)];
        [backButton setBackgroundImage:KUIImage(@"backButton") forState:UIControlStateNormal];
        [backButton setBackgroundImage:KUIImage(@"backButton2") forState:UIControlStateHighlighted];
        backButton.backgroundColor = [UIColor clearColor];
        [backButton addTarget:self action:@selector(closeViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [bgImageView addSubview:backButton];
        
        [self addSubview:bgImageView];
        
        if (!m_TableView) {
            m_TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, topHight,kScreenWidth, kScreenHeigth-topHight) style:UITableViewStylePlain];
            m_TableView.dataSource = self;
            m_TableView.delegate = self;
            m_TableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
            [GameCommon setExtraCellLineHidden:m_TableView];
            m_TableView.separatorStyle=UITableViewCellSeparatorStyleNone;
            [self addSubview:m_TableView];
        }
        
        m_alertLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(0, 0, 320, 40) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
        m_alertLabel.center = self.center;
        m_alertLabel.text = @"暂无申请加入信息";
        m_alertLabel.hidden = YES;
        [self addSubview:m_alertLabel];
        
        hud = [[MBProgressHUD alloc] initWithView:self];
        hud.labelText = @"加载中...";
        [self addSubview:hud];
    }
    return self;
}
//关闭页面
-(void)closeViewAction:(UIButton*)sender{
    [self.detaildelegate doCloseApplyPage];
}
#pragma mark 表格

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return teamNotifityMsg.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 140;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"simpleApplicationCell";
    JoinTeamCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[JoinTeamCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    cell.tag = indexPath.row;
    NSMutableDictionary * msgDic = [teamNotifityMsg objectAtIndex:indexPath.row];
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
            [cell.agreeButton setUserInteractionEnabled:YES];
            [cell.refuseButton setUserInteractionEnabled:YES];
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
        }else if([KISDictionaryHaveKey(msgDic, @"state") isEqualToString:@"5"]){
            cell.detailLable.text=@"申请已经过期";
        }else {
            cell.detailLable.text=@"已处理";
        }
    }
    cell.timeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:KISDictionaryHaveKey(msgDic, @"senTime")]];
    [cell refreTitleFrame];
    return cell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dic = [teamNotifityMsg objectAtIndex:indexPath.row];
    [self.detaildelegate itemApplyListOnClick:dic];
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        NSMutableDictionary * msgDic = [teamNotifityMsg objectAtIndex:indexPath.row];
        [DataStoreManager deleteTeamNotifityMsgStateByMsgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msgId")] Successcompletion:^(BOOL success, NSError *error) {
            [teamNotifityMsg removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
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
                [self showToastAlertView:@"解散成功"];
            } reError:^(id error) {
                [hud hide:YES];
                [self showErrorAlertView:error];
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
//跳转个人详情
-(void)headImgClick:(JoinTeamCell*)Sender{
    NSMutableDictionary *dic = [teamNotifityMsg objectAtIndex:Sender.tag];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
    [self.detaildelegate headImgApplyListClick:userid];
}

//同意288
-(void)onAgreeClick:(JoinTeamCell*)sender
{
    [hud show:YES];
    NSMutableDictionary * msgDic = [teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] agreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
        [hud hide:YES];
        [self changState:msgDic State:@"1"];
    } reError:^(id error) {
        [hud hide:YES];
        [self changState:msgDic State:@"5"];
        [self showErrorAlertView:error];
    }];
}
//拒绝273
-(void)onDisAgreeClick:(JoinTeamCell*)sender
{
    [hud show:YES];
    NSMutableDictionary * msgDic = [teamNotifityMsg objectAtIndex:sender.tag];
    [[ItemManager singleton] disAgreeJoinTeam:KISDictionaryHaveKey(msgDic, @"gameid") UserId:KISDictionaryHaveKey(msgDic, @"userid") RoomId:KISDictionaryHaveKey(msgDic, @"roomId") reSuccess:^(id responseObject) {
        [hud hide:YES];
        [self changState:msgDic State:@"2"];
    } reError:^(id error) {
        [hud hide:YES];
        [self changState:msgDic State:@"5"];
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
    for (NSMutableDictionary * clickDic in teamNotifityMsg) {
        if ([KISDictionaryHaveKey(clickDic, @"userid") isEqualToString:userId]
            && [KISDictionaryHaveKey(clickDic, @"state") isEqualToString:@"0"]
            &&[KISDictionaryHaveKey(clickDic, @"groupId") isEqualToString:groupId]) {
            [clickDic setObject:state forKey:@"state"];
        }
    }
    [m_TableView reloadData];
    [DataStoreManager updateTeamNotifityMsgState:userId State:state GroupId:groupId];
}
-(void)showToastAlertView:(NSString*)msgText
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:msgText delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}
//申请通知数控
-(void)getZU
{
    teamNotifityMsg = [DataStoreManager queDSTeamNotificationMsgByMsgTypeAndGroupId:@"requestJoinTeam" GroupId:self.groipId];
    if (teamNotifityMsg &&teamNotifityMsg.count<=0) {
        m_alertLabel.hidden = NO;
    }else{
        m_alertLabel.hidden = YES;
    }

}

#pragma mark 申请加入组队消息
-(void)joinTeamReceived:(NSString *)groupId
{
    if (![groupId isEqualToString:[GameCommon getNewStringWithId:self.groipId]]) {
        return;
    }
    if (self.isShow) {
         [self.detaildelegate readAppMsgAction];
    }else{
        if (self.teamUsershipType) {
            [self.detaildelegate mShowApplyListTopMenuView];
        }else{
            [self.detaildelegate readAppMsgAction];
        }
    }
    [self getZU];
    [m_TableView reloadData];
}
//显示
-(void)showView{
    [self getZU];
    [self.detaildelegate readAppMsgAction];
    [m_TableView reloadData];
    self.isShow = YES;
}
//隐藏
-(void)hideView{
    self.isShow = NO;
}

@end
