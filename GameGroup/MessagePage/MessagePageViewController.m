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
#import "NotificationViewController.h"
#import "AttentionMessageViewController.h"

#import "OtherMsgsViewController.h"
#import "FriendRecommendViewController.h"
#import "AddAddressBookViewController.h"
#import "EveryDataNewsViewController.h"
#import "ReconnectMessage.h"
#import "UserManager.h"
//#import "Reachability.h"

@interface MessagePageViewController ()<RegisterViewControllerDelegate>
{
    UITableView * m_messageTable;
    
    SystemSoundID soundID;
    
    NSMutableArray * allMsgArray;
    
    NSMutableArray * allSayHelloArray;//id
    NSMutableArray * sayhellocoArray;//内容
    
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
                
       // [GameCommon cleanLastData];//因1.0是用username登陆xmpp 后面版本是userid 必须清掉聊天消息和关注表
        
        [self.view bringSubviewToFront:hud];
            if([self.appDel.xmppHelper ifXMPPConnected]){
                self.titleLabel.text = @"消息";
            }else{
                self.titleLabel.text = @"消息(未连接)";
                AppDelegate *app = [[UIApplication sharedApplication]delegate];
                if (app.reach.currentReachabilityStatus !=NotReachable) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"xmppReconnect_wx_xx" object:nil];
                }
            }
        
        if (![[NSUserDefaults standardUserDefaults]objectForKey:isFirstOpen]) {
            [[ReconnectMessage singleton] getFriendByHttp];
            [self getSayHiUserIdWithNet];
        }
        
        [self displayMsgsForDefaultView];
        
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
    
    //获取xmpp服务器是否连接成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectSuccess:) name:@"connectSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectFail:) name:@"connectFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdate:) name:@"userInfoUpdatedSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchStatus:) name:@"Notification_disconnect" object:nil];
    //重连
    
    
    [self setTopViewWithTitle:@"" withBackButton:NO];

    
    
    allMsgArray = [NSMutableArray array];
    allSayHelloArray = [NSMutableArray array];
    sayhellocoArray = [NSMutableArray array];
    
    UIButton *delButton=[UIButton buttonWithType:UIButtonTypeCustom];
    delButton.frame=CGRectMake(320-42, KISHighVersion_7?27:7, 37, 30);
    [delButton setBackgroundImage:KUIImage(@"delete_normal") forState:UIControlStateNormal];
    [delButton setBackgroundImage:KUIImage(@"delete_click") forState:UIControlStateHighlighted];
    [self.view addSubview:delButton];
    [delButton addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    

    
    
    
    m_messageTable = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - ( 50 + startX)) style:UITableViewStylePlain];
    [self.view addSubview:m_messageTable];
    m_messageTable.dataSource = self;
    m_messageTable.delegate = self;
    
    self.titleLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, startX - 44, 320, 44)];
    self.titleLabel.backgroundColor=[UIColor clearColor];
    [self.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor=[UIColor whiteColor];
    [self.view addSubview:self.titleLabel];
    
    self.appDel = [[UIApplication sharedApplication] delegate];
    
    //    hud = [[MBProgressHUD alloc] initWithView:self.view];
    UIWindow* window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    
    hud = [[MBProgressHUD alloc] initWithWindow:window];
    [window addSubview:hud];
    hud.labelText = @"获取好友信息中...";
}

#pragma mark --获取好友列表成功或者失败通知
-(void)getFriendForHttpToRemindBegin
{
    [hud show:YES];
}
-(void)getFriendForHttpToRemind
{
    [hud hide:YES];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"StartGetFriendListForNet" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"getFriendListForNet_wx" object:nil];
}

#pragma mark ----获取XMPP服务器成功
-(void)getConnectSuccess:(NSNotification*)notification
{
    self.titleLabel.text = @"消息";
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
#pragma mark 收到下线
- (void)catchStatus:(NSNotification *)notification
{
    self.titleLabel.text = @"消息(未连接)";
}
#pragma mark -清空
- (void)cleanBtnClick:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要清空消息页面吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 345;
    [alert show];
}

-(void)getSayHiUserIdWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"" forKey:@"touserid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"154" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"sayHello_wx_info_id"];
        
        [self displayMsgsForDefaultView];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
}

#pragma mark --获取打招呼id

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 345) {
        if (alertView.cancelButtonIndex != buttonIndex) {
            [DataStoreManager deleteAllThumbMsg];
            [self displayMsgsForDefaultView];
        }
    }
}

#pragma mark发送token
- (void)sendDeviceToken
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* locationDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [locationDict setObject:[GameCommon shareGameCommon].deviceToken forKey:@"deviceToken"];
    [locationDict setObject:appType forKey:@"appType"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[DataStoreManager getMyUserID] forKey:@"userid"];
    [postDict setObject:@"140" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
}

#pragma mark - 根据存储初始化界面
- (void)displayMsgsForDefaultView
{
    //获取所有聊过天人的id （你对他）
    [allSayHelloArray removeAllObjects];
    [allSayHelloArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
   NSMutableArray *array = (NSMutableArray *)[DataStoreManager qureyAllThumbMessagesWithType:@"1"];
   allMsgArray = [array mutableCopy];
    
    
    [m_messageTable reloadData];
    
    [self displayTabbarNotification];
}
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
    
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
        if ([[[allMsgArray objectAtIndex:indexPath.row] msgType]isEqualToString:@"sayHi"]) {
        cell.headImageV.imageURL =nil;
        [cell.headImageV setImage:KUIImage(@"mess_guanzhu")];
        cell.contentLabel.text =[NSString stringWithFormat:@"%@:%@",[[sayhellocoArray objectAtIndex:0]senderNickname],KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row], @"msg")];
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"character"] ||
             [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"title"] ||
             [[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"pveScore"])
    {
        cell.headImageV.imageURL =nil;
        
        cell.headImageV.image = KUIImage(@"mess_titleobj");
        NSDictionary * dict = [[[allMsgArray objectAtIndex:indexPath.row] msg] JSONValue];
        cell.contentLabel.text = KISDictionaryHaveKey(dict, @"msg");
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"recommendfriend"])
    {
        cell.headImageV.imageURL =nil;
        
        cell.headImageV.image = KUIImage(@"mess_tuijian");
        
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row] msgContent];
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"dailynews"])
    {
        cell.headImageV.imageURL =nil;
        
        cell.headImageV.image = KUIImage(@"mess_news");
        
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row]msgContent];
    }
    else if([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"normalchat"])
    {
        NSURL * theUrl;
        if ([[[allMsgArray objectAtIndex:indexPath.row] senderimg]isEqualToString:@""]||[[[allMsgArray objectAtIndex:indexPath.row]senderimg]isEqualToString:@" "]) {
            theUrl =nil;
        }else{
            theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80",[GameCommon getHeardImgId:[[allMsgArray objectAtIndex:indexPath.row]senderimg]]]];
        }
        cell.headImageV.imageURL = theUrl;
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row]msgContent];
        
    }
    
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
    cell.nameLabel.text = [[allMsgArray objectAtIndex:indexPath.row] senderNickname];
    cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[[[allMsgArray objectAtIndex:indexPath.row] sendTimeStr] substringToIndex:10]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_messageTable deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    if ([[[allMsgArray objectAtIndex:indexPath.row] msgType] isEqualToString:@"sayHi"]) {
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        friq.personCount = sayhellocoArray.count;
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
        EveryDataNewsViewController * newsVC = [[EveryDataNewsViewController alloc]init];
        [self.navigationController pushViewController:newsVC animated:YES];
        [self cleanUnReadCountWithType:4 Content:@"" typeStr:@""];
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
    MessageCell * cell =(MessageCell*)[self tableView:m_messageTable cellForRowAtIndexPath:indexPath] ;
    NSInteger no = [cell.unreadCountLabel.text intValue];
    KKChatController * kkchat = [[KKChatController alloc] init];
    kkchat.unreadNo = allUnread-no;
    kkchat.chatWithUser = [NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]];
    kkchat.nickName = [[allMsgArray objectAtIndex:indexPath.row]senderNickname];
    kkchat.chatUserImg = [[allMsgArray objectAtIndex:indexPath.row]senderimg];
    [self.navigationController pushViewController:kkchat animated:YES];
    kkchat.msgDelegate = self;
    //}
}

- (void)cleanUnReadCountWithType:(NSInteger)type Content:(NSString*)pre typeStr:(NSString*)typeStr
{
    if (1 == type) {//头衔、角色、战斗力
        //        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        //            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@ AND msgType==[c]%@",pre, typeStr];
        //            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        //            thumbMsgs.unRead = @"0";
        //        }];//清数字
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
            for (int i =0;i<sayhellocoArray.count;i++) {
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",[[sayhellocoArray objectAtIndex:i]sender]];
                DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
                thumbMsgs.unRead = @"0";
            }
            //            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            //            thumbMsgs.unRead = @"0";
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
            //            [DataStoreManager deleteThumbMsgWithUUID:[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"messageuuid"]];
            [DataStoreManager cleanOtherMsg];
        }
        else if ([[[allMsgArray objectAtIndex:indexPath.row]sender] isEqual:@"sys00000011"])
        {
            [DataStoreManager deleteAllNewsMsgs];
        }
        else{
            if ([[[allMsgArray objectAtIndex:indexPath.row]sender]isEqual:@"1234567wxxxxxxxxx"])
            {
                for (int i =0;i<sayhellocoArray.count;i++) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:[[sayhellocoArray objectAtIndex:i]sender] forKey:@"sender"];
                    [DataStoreManager deleteThumbMsgWithSender:KISDictionaryHaveKey(dic, @"sender")];
                }
            }
            [DataStoreManager deleteMsgsWithSender:[NSString stringWithFormat:@"%@",[[allMsgArray objectAtIndex:indexPath.row]sender]] Type:COMMONUSER];
            
        }
        [allMsgArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self displayMsgsForDefaultView];
    }
}

- (void)getMyUserInfoFromNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:[SFHFKeychainUtils getPasswordForUsername:ACCOUNT andServiceName:LOCALACCOUNT error:nil] forKey:@"username"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"106" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DataStoreManager saveUserInfo:KISDictionaryHaveKey(responseObject, @"user")];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        
    }];
    
}

-(void)getSayHelloWithUserid:(NSString*)userId
{
    NSMutableDictionary * postDict1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userId forKey:@"touserid"];
    [postDict1 addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict1 setObject:@"153" forKey:@"method"];
    [postDict1 setObject:paramDict forKey:@"params"];
    
    [postDict1 setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) onUserUpdate:(NSNotification*)notification{
    [self displayMsgsForDefaultView];
}

@end
