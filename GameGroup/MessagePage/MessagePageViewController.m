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

#import "OtherMsgsViewController.h"
#import "FriendRecommendViewController.h"
#import "AddAddressBookViewController.h"
#import "EveryDataNewsViewController.h"
#import "ReconnectMessage.h"
#import "UserManager.h"
#import "DataNewsViewController.h"
#import "ImageService.h"
#import "GroupListViewController.h"
#import "JoinApplyViewController.h"

@interface MessagePageViewController ()<RegisterViewControllerDelegate>
{
    UITableView * m_messageTable;
    
    SystemSoundID soundID;
    
    NSMutableArray * allMsgArray;
    DSThumbMsgs * firstSayHiMsg;
    UIButton *deltButton;
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
    [[Custom_tabbar showTabBar] hideTabBar:NO];
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
    else
    {
        if([self.appDel.xmppHelper isConnected]){
            self.titleLabel.text = @"消息";
        }else if([self.appDel.xmppHelper isConnecting]){
            self.titleLabel.text = @"消息(连接中)";
        }else if([self.appDel.xmppHelper isDisconnected]){
            self.titleLabel.text = @"消息(未连接)";
        }
        [self.view bringSubviewToFront:hud];
        [self setFirstSayHiMsg];
        [self displayMsgsForDefaultView];
    }
}

//如果没有打招呼消息 删除打招呼的条目
-(void)setFirstSayHiMsg
{
    firstSayHiMsg = [DataStoreManager qureySayHiMsg:@"2"];
    if (!firstSayHiMsg) {
        [DataStoreManager deleteThumbMsgWithSender:[NSString stringWithFormat:@"%@",@"1234567wxxxxxxxxx"]];
    }
}
-(void)RegisterViewControllerFinishRegister
{
    AddAddressBookViewController* addressVC = [[AddAddressBookViewController alloc]init];
    UINavigationController * navi = [[UINavigationController alloc] initWithRootViewController:addressVC];
    [self presentViewController:navi animated:NO completion:^{
    }];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getFriendForHttpToRemindBegin) name:@"StartGetFriendListForNet" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getFriendForHttpToRemind) name:@"getFriendListForNet_wx" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMesgReceived:) name:kNewMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sayHelloReceived:) name:kFriendHelloReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePersonReceived:) name:kDeleteAttention object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherMessageReceived:) name:kOtherMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendFriendReceived:) name:kOtherMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dailynewsReceived:) name:kNewsMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(joinGroupReceived:) name:kJoinGroupMessage object:nil];
    
    //获取xmpp服务器是否连接成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectSuccess:) name:@"connectSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startConnect:) name:@"startConnect" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectFail:) name:@"connectFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdate:) name:@"userInfoUpdatedSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchStatus:) name:@"Notification_disconnect" object:nil];
    //重连
    
    
    [self setTopViewWithTitle:@"" withBackButton:NO];

    
    
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
    
    hud = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:hud];
    hud.labelText = @"获取好友信息中...";
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
-(void)otherMessageReceived:(NSNotification *)notification
{
    [self displayMsgsForDefaultView];
}
#pragma mark 收到推荐好友
-(void)recommendFriendReceived:(NSNotification *)notification
{
   // [self displayMsgsForDefaultView];
}
-(void)joinGroupReceived:(NSNotification *)notification
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
            [DataStoreManager deleteMsgByMsgType:@"normalchat"];//删除所有的normalchat消息
            [DataStoreManager deleteMsgByMsgType:@"groupchat"];//删除所有的groupchat消息
            [DataStoreManager deleteGroupMsgByMsgType:@"groupchat"];//删除所有的groupchat历史消息
            [self displayMsgsForDefaultView];
        }
    }
}

#pragma mark - 根据存储初始化界面
- (void)displayMsgsForDefaultView
{
    NSMutableArray *array = (NSMutableArray *)[DataStoreManager qureyAllThumbMessagesWithType:@"1"];
    allMsgArray = [array mutableCopy];
    firstSayHiMsg = [DataStoreManager qureySayHiMsg:@"2"];
    [m_messageTable reloadData];
    [self displayTabbarNotification];
}
//红点通知
-(void)displayTabbarNotification
{
    int allUnread = 0;
    for (int i = 0; i<allMsgArray.count; i++) {
        allUnread = allUnread+[[[allMsgArray objectAtIndex:i]unRead] intValue];
    }
    if (allUnread>0) {
        [[Custom_tabbar showTabBar] notificationWithNumber:YES AndTheNumber:allUnread OrDot:NO WithButtonIndex:0];
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
    
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];//@"有新的打招呼信息"
    if ([[[allMsgArray objectAtIndex:indexPath.row] msgType]isEqualToString:@"sayHi"]) {//打招呼
        cell.headImageV.imageURL =nil;
        [cell.headImageV setImage:KUIImage(@"mess_guanzhu")];
        if (firstSayHiMsg) {
            NSString *sender=[GameCommon getNewStringWithId:[firstSayHiMsg sender]];
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:[NSString stringWithFormat:@"%@",sender]];
            NSString * nickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            NSString *msgContent=[GameCommon getNewStringWithId:[firstSayHiMsg msgContent]];
            
            if (nickName&&msgContent) {
                cell.contentLabel.text =[NSString stringWithFormat:@"%@:%@",nickName,msgContent];
            }else{
                cell.contentLabel.text =@"";
            }
            cell.nameLabel.text = @"有新的打招呼信息";
        }
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"character"] ||
             [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"title"] ||
             [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"pveScore"])
    {//角色，头衔，战斗力
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"mess_titleobj");
        NSDictionary * dict = [[[allMsgArray objectAtIndex:indexPath.row] msgContent] JSONValue];
        cell.contentLabel.text = KISDictionaryHaveKey(dict, @"msg");
        cell.nameLabel.text = [[allMsgArray objectAtIndex:indexPath.row] senderNickname];
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"recommendfriend"])
    {//好友推荐
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"mess_tuijian");
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row] msgContent];
        cell.nameLabel.text = [[allMsgArray objectAtIndex:indexPath.row] senderNickname];
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"dailynews"])
    {//每日一闻
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"every_data_news");
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row]msgContent];
        cell.nameLabel.text = [[allMsgArray objectAtIndex:indexPath.row] senderNickname];
    }
    else if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"normalchat"])
    {//正常聊天
        NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:[NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]]];
        
        NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
        NSString * nickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
        NSString * content = [[allMsgArray objectAtIndex:indexPath.row]msgContent];
        cell.contentLabel.text = content;
        cell.nameLabel.text = nickName;
        cell.headImageV.imageURL=[ImageService getImageStr:userImage Width:80];

    }else if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"groupchat"])
    {//群组消息
        NSString * groupId = [NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]groupId]];
        NSString * sender = [NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]];
        
        NSMutableDictionary * groupInfo = [DataStoreManager queryGroupInfoByGroupId:groupId];
       
        NSString * nickName = KISDictionaryHaveKey(groupInfo, @"groupName");
        NSString * content = [[allMsgArray objectAtIndex:indexPath.row]msgContent];
        
        NSString * senderNickname =[self getNickUserNameBySender:sender];
        cell.headImageV.image = KUIImage(@"every_data_news");
        cell.contentLabel.text = [NSString stringWithFormat:@"%@%@%@",senderNickname?senderNickname:@"",@":",content];
        cell.nameLabel.text =nickName;
    } else if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"joinGroupApplication"]){//申请加入群组
        cell.headImageV.imageURL =nil;
        cell.headImageV.image = KUIImage(@"every_data_news");
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row]msgContent];
        cell.nameLabel.text = [[allMsgArray objectAtIndex:indexPath.row] senderNickname];
    }
    
    
    
    //设置红点 start
    if ([[[allMsgArray objectAtIndex:indexPath.row]unRead]intValue]>0) {
        cell.unreadCountLabel.hidden = NO;
        cell.notiBgV.hidden = NO;
        if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"recommendfriend"] |
            [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"sayHello"] ||
            [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"deletePerson"]) {
            cell.notiBgV.image = KUIImage(@"redpot");
            cell.unreadCountLabel.hidden = YES;
        }
        else
        {
            [cell.unreadCountLabel setText:[[allMsgArray objectAtIndex:indexPath.row]unRead]];
            if ([[[allMsgArray objectAtIndex:indexPath.row]unRead] intValue]>99) {
                [cell.unreadCountLabel setText:@"99+"];
                cell.notiBgV.image = KUIImage(@"redCB_big");
                cell.notiBgV.frame=CGRectMake(40, 8, 22, 18);
                cell.unreadCountLabel.frame =CGRectMake(0, 0, 22, 18);
            }
            else{
                cell.notiBgV.image = KUIImage(@"redCB.png");
                [cell.unreadCountLabel setText:[[allMsgArray objectAtIndex:indexPath.row]unRead]];
                cell.notiBgV.frame=CGRectMake(42, 8, 18, 18);
                cell.unreadCountLabel.frame =CGRectMake(0, 0, 18, 18);
            }
        }
    }
    else
    {
        cell.unreadCountLabel.hidden = YES;
        cell.notiBgV.hidden = YES;
    }
    //-- end
    NSTimeInterval uu = [[[allMsgArray objectAtIndex:indexPath.row] sendTime] timeIntervalSince1970];
    cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[[NSString stringWithFormat:@"%.f",uu] substringToIndex:10]];
    return cell;
}

-(NSString*)getNickUserNameBySender:(NSString*)sender
{
    if ([sender isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
        return  @"我";
    }
    NSMutableDictionary * simpleUserDic= [[UserManager singleton] getUser:sender];
    return [simpleUserDic objectForKey:@"nickname"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_messageTable deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"sayHi"]) {
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        [self.navigationController pushViewController:friq animated:YES];
        [self cleanUnReadCountWithType:5 Content:@"" typeStr:@""];
        return;
        
    }
    if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"sayHello"] || [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"deletePerson"]) {//关注
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        [self.navigationController pushViewController:friq animated:YES];
        [self cleanUnReadCountWithType:3 Content:@"" typeStr:@""];
        
        return;
    }
    if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"recommendfriend"])//好友推荐  推荐的朋友
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        FriendRecommendViewController* VC = [[FriendRecommendViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        [self cleanUnReadCountWithType:2 Content:@"" typeStr:@""];
        return;
    }
    if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"dailynews"])//新闻
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
//        EveryDataNewsViewController * newsVC = [[EveryDataNewsViewController alloc]init];
        DataNewsViewController *newsVC = [[DataNewsViewController alloc]init];
        [self.navigationController pushViewController:newsVC animated:YES];
        [self cleanUnReadCountWithType:4 Content:@"" typeStr:@""];
        return;
    }
    if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"joinGroupApplication"])//申请加入群
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        JoinApplyViewController *newsVC = [[JoinApplyViewController alloc]init];
        [self.navigationController pushViewController:newsVC animated:YES];
        [self cleanUnReadCountWithType:6 Content:@"" typeStr:@""];
        return;
    }
    if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"character"] ||
        [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"title"] ||
        [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"pveScore"])
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        OtherMsgsViewController* VC = [[OtherMsgsViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        [self cleanUnReadCountWithType:1 Content:@"" typeStr:@""];
        return;
    }
    int allUnread = 0;
    for (int i = 0; i<allMsgArray.count; i++) {
        allUnread = allUnread+[[[allMsgArray objectAtIndex:i]unRead] intValue];
    }
    if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"groupchat"])//新闻
    {
        MessageCell * cell =(MessageCell*)[self tableView:m_messageTable cellForRowAtIndexPath:indexPath] ;
        NSInteger no = [cell.unreadCountLabel.text intValue];
        KKChatController * kkchat = [[KKChatController alloc] init];
        kkchat.unreadNo = allUnread-no;
        kkchat.chatWithUser = [NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]groupId]];
        kkchat.type = @"group";
        [self.navigationController pushViewController:kkchat animated:YES];
        return;
    }
    
    MessageCell * cell =(MessageCell*)[self tableView:m_messageTable cellForRowAtIndexPath:indexPath] ;
    NSInteger no = [cell.unreadCountLabel.text intValue];
    KKChatController * kkchat = [[KKChatController alloc] init];
    kkchat.unreadNo = allUnread-no;
    kkchat.chatWithUser = [NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]];
    kkchat.type = @"normal";
    [self.navigationController pushViewController:kkchat animated:YES];
}

- (void)cleanUnReadCountWithType:(NSInteger)type Content:(NSString*)pre typeStr:(NSString*)typeStr
{
    if (1 == type) {//头衔、角色、战斗力
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            thumbMsgs.unRead = @"0";
        }];//清数字
    }
    else if (2 == type)//推荐的人
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"12345"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            thumbMsgs.unRead = @"0";
        }];//清数字
    }
    else if (3 == type)//关注
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            thumbMsgs.unRead = @"0";
        }];//清数字
    }
    else if (4 == type)//新闻
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000011"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            thumbMsgs.unRead = @"0";
        }];//清数字
    }
    else if (5 == type)//打招呼
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234567wxxxxxxxxx"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            thumbMsgs.unRead = @"0";
        }];//清数字
    }
    else if (6 == type)//申请加入群
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000013"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            thumbMsgs.unRead = @"0";
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
        if([[[allMsgArray objectAtIndex:indexPath.row]sender]isEqual:@"1"])//角色
        {
            [DataStoreManager cleanOtherMsg];
        }
        else if ([[[allMsgArray objectAtIndex:indexPath.row]sender] isEqual:@"sys00000011"])
        {
            [DataStoreManager deleteAllNewsMsgs];
        }
        else if([[[allMsgArray objectAtIndex:indexPath.row]msgType] isEqual:@"groupchat"]){
            NSString * groupId = [NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]];
            [DataStoreManager deleteThumbMsgWithSender:groupId];
            [DataStoreManager deleteGroupMsgWithSenderAndSayType:groupId];
            
        }
        else{
            if ([[[allMsgArray objectAtIndex:indexPath.row]sender]isEqual:@"1234567wxxxxxxxxx"])
            {
                [DataStoreManager deleteThumbMsgWithSender:[NSString stringWithFormat:@"%@",@"1234567wxxxxxxxxx"]];//删除打招呼显示的消息
                [DataStoreManager deleteSayHiMsgWithSenderAndSayType:COMMONUSER SayHiType:@"2"];//删除打所有打招呼的消息
            }
            [DataStoreManager deleteMsgsWithSender:[NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]] Type:COMMONUSER];
            
        }
        [allMsgArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self displayMsgsForDefaultView];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) onUserUpdate:(NSNotification*)notification{
    [self displayMsgsForDefaultView];
}

@end
