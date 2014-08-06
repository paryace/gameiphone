//
//  MessagePageViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "MessagePageViewController.h"
#import "IntroduceViewController.h"
#import "SRRefreshView.h"
#import "KKChatController.h"
#import "AppDelegate.h"
#import "MessageCell.h"
#import "AttentionMessageViewController.h"
#import "BangdingRolesViewController.h"
#import "OtherMsgsViewController.h"
#import "NewFriendRecommendViewController.h"
#import "AddAddressBookViewController.h"
#import "EveryDataNewsViewController.h"
#import "ReconnectMessage.h"
#import "UserManager.h"
#import "DataNewsViewController.h"
#import "ImageService.h"
#import "JoinApplyViewController.h"
#import "OpenImgViewController.h"
#import "WQPlaySound.h"
#define mTime 0.5
@interface MessagePageViewController ()<NewRegisterViewControllerDelegate>
{
    UITableView * m_messageTable;
    SystemSoundID soundID;
    NSMutableArray * allMsgArray;
    NSMutableDictionary * firstSayHiMsg;
    UIButton *deltButton;
    NSTimeInterval markTime;
}
@end

@implementation MessagePageViewController
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([[TempData sharedInstance]isShowOpenImg]) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        OpenImgViewController *openImg = [[OpenImgViewController alloc]init];
        [self presentViewController:openImg animated:NO completion:^{
            
        }];
    }
    else{
        
        [[Custom_tabbar showTabBar] hideTabBar:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if (![[TempData sharedInstance] isHaveLogin]) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        IntroduceViewController* vc = [[IntroduceViewController alloc] init];
        vc.delegate = self;
        UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:vc];
            [self presentViewController:navi animated:NO completion:^{
        }];
    }
    else{
        if([self.appDel.xmppHelper isConnected]){
            self.titleLabel.text = @"消息";
        }else if([self.appDel.xmppHelper isConnecting]){
            self.titleLabel.text = @"消息(连接中)";
        }else if([self.appDel.xmppHelper isDisconnected]){
            self.titleLabel.text = @"消息(未连接)";
        }
        [self.view bringSubviewToFront:hud];
        [self setFirstSayHiMsg];
        [self refreMsgAndTable];
        if (![[TempData sharedInstance]isBindingRoles]) {
            [self enterBangdingView];
        }

    }
}

//如果没有打招呼消息 删除打招呼的条目
-(void)setFirstSayHiMsg
{
    firstSayHiMsg = [DataStoreManager qSayHiMsg:@"2"];
    if (!firstSayHiMsg) {
        
        [DataStoreManager deleteThumbMsgWithSender:[NSString stringWithFormat:@"%@",@"1234567wxxxxxxxxx"] Successcompletion:^(BOOL success, NSError *error) {
            
        }];
    }
}
-(void)NewRegisterViewControllerFinishRegister
{
    [self enterBangdingView];
}
-(void)enterBangdingView
{
    
    BangdingRolesViewController* addressVC = [[BangdingRolesViewController alloc]init];
    addressVC.delegate = self;
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:addressVC];
    [self presentViewController:navi animated:NO completion:^{
    }];
 
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getFriendForHttpToRemindBegin) name:@"StartGetFriendListForNet" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getFriendForHttpToRemind) name:@"getFriendListForNet_wx" object:nil];
    //好友动态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedFriendDynamicMsg:) name:@"frienddunamicmsgChange_WX"object:nil];
    //与我相关
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedMyDynamicMsg:)name:@"mydynamicmsg_wx" object:nil];
    //群公告消息广播接收
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:Billboard_msg object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMesgReceived:) name:kNewMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sayHelloReceived:) name:kFriendHelloReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePersonReceived:) name:kDeleteAttention object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherMsgReceived:) name:kOtherMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendFriendMessageReceived:) name:kRecommendMessage object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dailynewsReceived:) name:kNewsMessage object:nil];
    //申请加入群完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinGroupReceived:) name:kJoinGroupMessage object:nil];
    //群信息更新完成通知
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupInfoUploaded:) name:groupInfoUpload object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onTeamUpdate:) name:teamInfoUpload object:nil];
    //更新组队人数
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamMemberCountChang:) name:UpdateTeamMemberCount object:nil];
    //解散群通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMesgReceived:) name:kDisbandGroup object:nil];
    //组队消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamMsgUploaded:) name:kteamMessage object:nil];
    
    //获取xmpp服务器是否连接成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectSuccess:) name:@"connectSuccess" object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startConnect:) name:@"startConnect" object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectFail:) name:@"connectFail" object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdate:) name:userInfoUpload object:nil];
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchStatus:) name:@"Notification_disconnect" object:nil];
    //重连
    
    
    [self setTopViewWithTitle:@"" withBackButton:NO];

    self.view.backgroundColor=UIColorFromRGBA(0xf7f7f7, 1);
    
    allMsgArray = [NSMutableArray array];
    UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [delButton setBackgroundImage:KUIImage(@"delete_normal") forState:UIControlStateNormal];
    [delButton setBackgroundImage:KUIImage(@"delete_click") forState:UIControlStateHighlighted];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    

    m_messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - ( 50 + startX)) style:UITableViewStylePlain];
    [self.view addSubview:m_messageTable];
    m_messageTable.dataSource = self;
    m_messageTable.rowHeight = 70;
    m_messageTable.delegate = self;
    m_messageTable.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [GameCommon setExtraCellLineHidden:m_messageTable];
    self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, startX - 44, 320, 44)];
    self.titleLabel.backgroundColor=[UIColor clearColor];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    
    self.appDel = (AppDelegate *)[UIApplication sharedApplication] .delegate;
    
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [self initTeamRecommendMsg];
    hud = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:hud];
    hud.labelText = @"获取好友信息中...";
    //调用测试
}

#pragma mark ----获取XMPP服务器成功
-(void)getConnectSuccess:(NSNotification*)notification
{
    self.titleLabel.text = @"消息";
    [m_messageTable reloadData];
}

#pragma mark ----开始连接xmpp服务器
-(void)startConnect:(NSNotification*)notification
{
    self.titleLabel.text = @"连接中";
    [m_messageTable reloadData];
}
#pragma mark ----获取XMPP服务器失败
-(void)getConnectFail:(NSNotification*)notification
{
     self.titleLabel.text = @"消息(未连接)";
    [m_messageTable reloadData];

}
- (void)dailynewsReceived:(NSNotificationCenter*)notification
{
    [self displayMsgsForDefaultView];
}
#pragma mark 收到聊天消息或其他消息
- (void)newMesgReceived:(NSNotification*)notification
{
    [self displayMsgsForDefaultView];
}

#pragma mark 收到验证好友请求
- (void)sayHelloReceived:(NSNotification*)notification
{
    [self displayMsgsForDefaultView];
}

#pragma mark 收到取消关注 删除好友请求
-(void)deletePersonReceived:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}

#pragma mark - 其他消息 头衔、角色等
-(void)otherMsgReceived:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}
#pragma mark 收到推荐好友
-(void)recommendFriendMessageReceived:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}
//加入群
-(void)joinGroupReceived:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}
//群信息更新完成
-(void)groupInfoUploaded:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}
-(void)teamMsgUploaded:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}
#pragma mark 收到下线
- (void)catchStatus:(NSNotification *)notification
{
    self.titleLabel.text = @"消息(未连接)";
}

#pragma mark -清空
- (void)cleanBtnClick:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"将会清除所有的聊天消息" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 345;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [DataStoreManager clearAllChatMessage:^(BOOL success) {
                if (success) {
                    [self displayMsgsForDefaultView];
                }
            }];
        }
    }
}
#pragma mark - 根据存储初始化界面
- (void)displayMsgsForDefaultView
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTime)*100<mTime*1000) {
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        self.cellTimer = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(stopATime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.cellTimer forMode:NSRunLoopCommonModes];
        markTime = [[NSDate date] timeIntervalSince1970];
        return;
    }
    markTime = [[NSDate date] timeIntervalSince1970];
    [self refreMsgAndTable];
}

- (void)stopATime
{
    [self refreMsgAndTable];
    if ([self.cellTimer isValid]) {
        [self.cellTimer invalidate];
        self.cellTimer = nil;
    }
}
-(void)refreMsgAndTable
{
    NSMutableArray *array = (NSMutableArray *)[DataStoreManager qAllThumbMessagesWithType:@"1"];
    allMsgArray = [array mutableCopy];
    firstSayHiMsg = [DataStoreManager qSayHiMsg:@"2"];
    [m_messageTable reloadData];
    [self displayTabbarNotification];
}

//红点通知
-(void)displayTabbarNotification
{
    NSInteger msgCount  = [GameCommon getNoreadMsgCount:allMsgArray];
    if (msgCount>0) {
        [[Custom_tabbar showTabBar] notificationWithNumber:YES AndTheNumber:msgCount OrDot:NO WithButtonIndex:0];
    }
    else
    {
        [[Custom_tabbar showTabBar] removeNotificatonOfIndex:0];
    }
}

#pragma mark 表格

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return allMsgArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"userCell";
    MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[MessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSMutableDictionary * message = [allMsgArray objectAtIndex:indexPath.row];
    
    
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];//@"有新的打招呼信息"
    if ([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"sayHi"]) {//打招呼
        cell.headImageV.imageURL =nil;
        [cell.headImageV setImage:KUIImage(@"mess_guanzhu")];
        if (firstSayHiMsg) {
            NSString *sender=[GameCommon getNewStringWithId:KISDictionaryHaveKey(firstSayHiMsg,@"senderId")];
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:[NSString stringWithFormat:@"%@",sender]];
            NSString * nickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            NSString *msgContent=[GameCommon getNewStringWithId:KISDictionaryHaveKey(firstSayHiMsg,@"msgContent")];
            
            if (nickName&&msgContent) {
                cell.contentLabel.text =[NSString stringWithFormat:@"%@:%@",nickName,msgContent];
            }else{
                cell.contentLabel.text =@"";
            }
            cell.nameLabel.text = @"有新的打招呼信息";
            cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[KISDictionaryHaveKey(message,@"sendTime") substringToIndex:10]];

        }
    }
    else if ([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"character"] ||
             [KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"title"] ||
             [KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"pveScore"])
    {//角色，头衔，战斗力
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"mess_titleobj");
        NSDictionary * dict = [KISDictionaryHaveKey(message,@"msgContent") JSONValue];
        cell.contentLabel.text = KISDictionaryHaveKey(dict, @"msg");
        cell.nameLabel.text = KISDictionaryHaveKey(message,@"senderNickname");
    }
    else if ([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"recommendfriend"])
    {//好友推荐
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"mess_tuijian");
        cell.contentLabel.text = KISDictionaryHaveKey(message,@"msgContent");
        cell.nameLabel.text = KISDictionaryHaveKey(message,@"senderNickname");
    }
    else if ([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"dailynews"])
    {//每日一闻
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"every_data_news");
        cell.contentLabel.text = KISDictionaryHaveKey(message,@"msgContent");
        cell.nameLabel.text = KISDictionaryHaveKey(message,@"senderNickname");
    }
    else if([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"normalchat"]||[KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"payloadchat"])
    {//正常聊天
        NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message,@"senderId")]];
        NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
        NSString * nickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
        NSString * content = KISDictionaryHaveKey(message,@"msgContent");
        cell.contentLabel.text = content;
        cell.nameLabel.text = nickName;
        cell.headImageV.imageURL=[ImageService getImageStr:userImage Width:80];
        
    }else if([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"groupchat"])
    {//群组聊天消息
        NSString * groupId = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message,@"groupId")];
        NSString * sender = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message,@"senderId")];
        NSMutableDictionary * groupInfo = [[GroupManager singleton] getGroupInfo:groupId];
        NSString * nickName = KISDictionaryHaveKey(groupInfo, @"groupName");
        NSString * available = KISDictionaryHaveKey(groupInfo, @"available");
        NSString * backgroundImg = KISDictionaryHaveKey(groupInfo, @"backgroundImg");
        NSString * groupUsershipType = KISDictionaryHaveKey(groupInfo, @"groupUsershipType");
        NSString * content = KISDictionaryHaveKey(message,@"msgContent");
        NSString * senderNickname =[self getNickUserNameBySender:sender];
        cell.headImageV.placeholderImage = KUIImage(@"group_icon");
        if([available isEqualToString:@"1"]&&[groupUsershipType isEqualToString:@"3"]){
            if ([MsgTypeManager payloadType:message]==0) {//群聊天消息
                cell.nameLabel.text =nickName;
                cell.contentLabel.text = @"该群不可用";
            }else if([MsgTypeManager payloadType:message]==1){//组队通知消息
                NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"gameid")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"roomId")]];
                  cell.nameLabel.text =[NSString stringWithFormat:@"[%@/%@]%@",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(teamInfo, @"maxVol"),nickName];
                cell.contentLabel.text = [NSString stringWithFormat:@"组队信息:%@",content];
            }else if([MsgTypeManager payloadType:message]==2){//组队聊天消息
                NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"gameid")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"roomId")]];
                cell.nameLabel.text =[NSString stringWithFormat:@"[%@/%@]%@",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(teamInfo, @"maxVol"),nickName];
                cell.contentLabel.text = @"该组队不可用";
            }
        }else
        {
            if ([MsgTypeManager payloadType:message]==0) {//群聊天消息
                cell.nameLabel.text =nickName;
                 cell.contentLabel.text = [NSString stringWithFormat:@"%@%@",senderNickname?senderNickname:@"",content];
            }else if([MsgTypeManager payloadType:message]==1){//组队通知消息
                NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"gameid")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"roomId")]];
                cell.nameLabel.text =[NSString stringWithFormat:@"[%@/%@]%@",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(teamInfo, @"maxVol"),nickName];
                cell.contentLabel.text = [NSString stringWithFormat:@"组队信息:%@",content];
            }else if([MsgTypeManager payloadType:message]==2){//组队聊天消息
                 NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"gameid") RoomId:KISDictionaryHaveKey([KISDictionaryHaveKey(message, @"payload") JSONValue], @"roomId")];
                cell.nameLabel.text =[NSString stringWithFormat:@"[%@/%@]%@",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(teamInfo, @"maxVol"),nickName];
                cell.contentLabel.text = [NSString stringWithFormat:@"%@%@",senderNickname?senderNickname:@"",content];
            }
        }
        if ([GameCommon isEmtity:backgroundImg]) {
            cell.headImageV.image = KUIImage(@"group_icon");
        }else{
            cell.headImageV.imageURL = [ImageService getImageStr:backgroundImg Width:80];
        }
    } else if([KISDictionaryHaveKey(message,@"msgType") isEqualToString:GROUPAPPLICATIONSTATE]){//申请加入群组
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"group_msg_icon");
        cell.contentLabel.text = KISDictionaryHaveKey(message,@"msgContent");
        cell.nameLabel.text =@"群通知";
    }
    [cell setMsgState:message];
    [cell setNotReadMsgCount:message];
    //-- end
    
    
    if ([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"sayHi"]) {//打招呼
        if (firstSayHiMsg) {
            if (KISDictionaryHaveKey(firstSayHiMsg,@"sendTime")) {
                 cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[KISDictionaryHaveKey(firstSayHiMsg,@"sendTime") substringToIndex:10]];
            }
        }
    }else{
        if (KISDictionaryHaveKey(message,@"sendTime")) {
            cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[KISDictionaryHaveKey(message,@"sendTime") substringToIndex:10]];
            
        }
    }
    return cell;
}

-(NSDate*) convertDateFromString:(NSString*)uiDate
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSDate *date=[formatter dateFromString:uiDate];
    return date;
}


-(NSString*)getNickUserNameBySender:(NSString*)sender
{
    if ([GameCommon isEmtity:sender]) {
        return @"";
    }
    if ([sender isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
        return  [NSString stringWithFormat:@"%@%@",@"我",@":"];
    }
    NSMutableDictionary * simpleUserDic= [[UserManager singleton] getUser:sender];
    return [NSString stringWithFormat:@"%@%@",[simpleUserDic objectForKey:@"nickname"],@":"];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_messageTable deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    NSMutableDictionary * message = [allMsgArray objectAtIndex:indexPath.row];
    
    
    if ([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"sayHi"]) {
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        [self.navigationController pushViewController:friq animated:YES];
        [self cleanUnReadCountWithType:5 Content:@"" typeStr:@""];
        return;
        
    }
    if ([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"sayHello"] || [KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"deletePerson"]) {//关注
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        [self.navigationController pushViewController:friq animated:YES];
        [self cleanUnReadCountWithType:3 Content:@"" typeStr:@""];
        
        return;
    }
    if([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"recommendfriend"])//好友推荐  推荐的朋友
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        NewFriendRecommendViewController* VC = [[NewFriendRecommendViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        [self cleanUnReadCountWithType:2 Content:@"" typeStr:@""];
        return;
    }
    if([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"dailynews"])//新闻
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        DataNewsViewController *newsVC = [[DataNewsViewController alloc]init];
        [self.navigationController pushViewController:newsVC animated:YES];
        [self cleanUnReadCountWithType:4 Content:@"" typeStr:@""];
        return;
    }
    if([KISDictionaryHaveKey(message, @"msgType") isEqualToString:GROUPAPPLICATIONSTATE])//申请加入群
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        JoinApplyViewController *newsVC = [[JoinApplyViewController alloc]init];
        [self.navigationController pushViewController:newsVC animated:YES];
        [self cleanUnReadCountWithType:6 Content:@"" typeStr:@""];
        return;
    }
    if ([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"character"] ||
        [KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"title"] ||
        [KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"pveScore"])
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        OtherMsgsViewController* VC = [[OtherMsgsViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        [self cleanUnReadCountWithType:1 Content:@"" typeStr:@""];
        return;
    }
    if([KISDictionaryHaveKey(message, @"msgType") isEqualToString:@"groupchat"])// 群组聊天
    {
        NSDictionary * dict = [KISDictionaryHaveKey(message,@"payload") JSONValue];
        NSInteger unreadMsgCount = [KISDictionaryHaveKey(message, @"unRead") intValue];
        KKChatController * kkchat = [[KKChatController alloc] init];
        kkchat.unreadMsgCount  = unreadMsgCount;
        kkchat.chatWithUser = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message, @"groupId")];
        kkchat.type = @"group";
        if ([MsgTypeManager payloadType:message]==1||[MsgTypeManager payloadType:message]==2) {
            kkchat.isTeam = YES;
            kkchat.roomId = KISDictionaryHaveKey(dict, @"roomId");
            kkchat.gameId = KISDictionaryHaveKey(dict, @"gameid");
        }
        [self.navigationController pushViewController:kkchat animated:YES];
        return;
    }
    
    KKChatController * kkchat = [[KKChatController alloc] init];
    kkchat.chatWithUser = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message, @"senderId")];
    kkchat.type = @"normal";
    [self.navigationController pushViewController:kkchat animated:YES];
}

- (void)cleanUnReadCountWithType:(NSInteger)type Content:(NSString*)pre typeStr:(NSString*)typeStr
{
    if (1 == type) {//头衔、角色、战斗力
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            thumbMsgs.unRead = @"0";
        }
         completion:^(BOOL success, NSError *error) {
             
         }];//清数字
    }
    else if (2 == type)//推荐的人
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"12345"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            thumbMsgs.unRead = @"0";
        }
         completion:^(BOOL success, NSError *error) {
             
         }];//清数字
    }
    else if (3 == type)//关注
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            thumbMsgs.unRead = @"0";
        }
         completion:^(BOOL success, NSError *error) {
             
         }];//清数字
    }
    else if (4 == type)//新闻
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000011"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            thumbMsgs.unRead = @"0";
        }
         completion:^(BOOL success, NSError *error) {
             
         }];//清数字
    }
    else if (5 == type)//打招呼
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234567wxxxxxxxxx"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            thumbMsgs.unRead = @"0";
        }
         completion:^(BOOL success, NSError *error) {
             
         }];//清数字
    }
    else if (6 == type)//申请加入群
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",GROUPAPPLICATIONSTATE];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            thumbMsgs.unRead = @"0";
        }
         completion:^(BOOL success, NSError *error) {
             
         }];//清数字
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        if([KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"senderId") isEqual:@"1"])//角色
        {
            [DataStoreManager cleanOtherMsg];
        }
        else if ([KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"senderId") isEqual:@"sys00000011"])
        {
            [DataStoreManager deleteAllNewsMsgs];
        }
        else if([KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"msgType") isEqual:@"groupchat"]){
            NSString * groupId = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"groupId")];
            [DataStoreManager deleteThumbMsgWithGroupId:groupId];
            [DataStoreManager deleteGroupMsgWithSenderAndSayType:groupId];
            [DataStoreManager deleteTeamNotifityMsgStateByGroupId:groupId];
            [DataStoreManager deleteDSPreparedByGroupId:groupId];
            
        }else if([KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"msgType") isEqual:GROUPAPPLICATIONSTATE])
        {
            [DataStoreManager clearJoinGroupApplicationMsg:^(BOOL success) {
                
            }];
            [DataStoreManager deleteJoinGroupApplication];
        }
        else{
            if ([KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"senderId")isEqual:@"1234567wxxxxxxxxx"])
            {
                [DataStoreManager deleteThumbMsgWithSender:[NSString stringWithFormat:@"%@",@"1234567wxxxxxxxxx"] Successcompletion:^(BOOL success, NSError *error) {
                    
                }];//删除打招呼显示的消息
                [DataStoreManager deleteSayHiMsgWithSenderAndSayType:COMMONUSER SayHiType:@"2"];//删除打所有打招呼的消息
            }
            [DataStoreManager deleteMsgsWithSender:[NSString stringWithFormat:@"%@",KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row],@"senderId")] Type:COMMONUSER];
            
        }
        [allMsgArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
    }
}
#pragma mark 接收到于我相关消息通知
-(void)receivedMyDynamicMsg:(NSNotification*)sender
{
    [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:0 OrDot:YES WithButtonIndex:2];
}
#pragma mark 接收到好友动态消息通知
-(void)receivedFriendDynamicMsg:(NSNotification*)sender
{
    [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:0 OrDot:YES WithButtonIndex:2];
}
#pragma mark 接收到公告消息通知
-(void)receivedBillboardMsg:(NSNotification*)sender
{
    [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:0 OrDot:YES WithButtonIndex:2];
}
#pragma mark --接收到新的偏好消息刷新消息数量
-(void)receiceTeamRecommendMsg:(NSNotification*)notification{
    [self initTeamRecommendMsg];
}

-(void)initTeamRecommendMsg{
    NSInteger msgCount  = [[PreferencesMsgManager singleton]getNoreadMsgCount2];
    if (msgCount>0) {
        [[Custom_tabbar showTabBar] notificationWithNumber:YES AndTheNumber:msgCount OrDot:NO WithButtonIndex:2];
    }
    else
    {
        [[Custom_tabbar showTabBar] removeNotificatonOfIndex:2];
    }
}



#pragma mark 个人信息更新完毕通知
-(void) onUserUpdate:(NSNotification*)notification{
    [m_messageTable reloadData];
}
#pragma mark 组队信息更新完毕通知
-(void) onTeamUpdate:(NSNotification*)notification{
    [m_messageTable reloadData];
}
#pragma mark 更新组队人数消息通知
-(void)teamMemberCountChang:(NSNotification*)notification{
    [m_messageTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
