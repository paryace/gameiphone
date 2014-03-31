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
    
    //搜索
    UISearchBar * searchBar;
    UISearchDisplayController * searchDisplay;
    
    NSMutableArray *allsayHelloImageArray;
    NSMutableArray *allsayHellonickNameArray;
    SystemSoundID soundID;
    
    NSMutableArray * newReceivedMsgArray;//新接收的消息
    NSMutableArray * allMsgArray;
    
    NSArray * searchResultArray;
    
    NSMutableArray * allMsgUnreadArray;
    
    NSMutableArray * allNickNameArray;
    NSMutableArray * allHeadImgArray;
    NSMutableArray * allSayHelloArray;//id
    NSMutableArray * sayhellocoArray;//内容
    NSMutableArray *sayHelloNickNameArray;
    
    NSMutableDictionary *deleteDic;
    NSMutableArray *dellArray;
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
    //    if (![self.appDel.xmppHelper ifXMPPConnected]) {
    //        self.titleLabel.text = @"消息(未连接)";
    //    }
    //    self.appDel.xmppHelper.buddyListDelegate = self;
    //    self.appDel.xmppHelper.chatDelegate = self;
    //    self.appDel.xmppHelper.processFriendDelegate = self;
    //    self.appDel.xmppHelper.addReqDelegate = self;
    //    self.appDel.xmppHelper.commentDelegate = self;
    //    self.appDel.xmppHelper.deletePersonDelegate = self;
    //    self.appDel.xmppHelper.otherMsgReceiveDelegate = self;
    //    self.appDel.xmppHelper.recommendReceiveDelegate = self;
    
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
                
      //  [GameCommon cleanLastData];//因1.0是用username登陆xmpp 后面版本是userid 必须清掉聊天消息和关注表
        
        [self.view bringSubviewToFront:hud];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:isFirstOpen])
        {
            if([self.appDel.xmppHelper ifXMPPConnected]){
                self.titleLabel.text = @"消息";
            }else{
                self.titleLabel.text = @"消息(未连接)";
                [[NSNotificationCenter defaultCenter]postNotificationName:@"xmppReconnect_wx_xx" object:nil];
            }
        }
        else
        {
            self.titleLabel.text = @"消息(未连接)";
            [self getFriendByHttp];
            [self getSayHiUserIdWithNet];
            [self sendDeviceToken];
            [self getMyUserInfoFromNet];//获得“我”信息
            
        }
        [self displayMsgsForDefaultView];
        
        //[self getSayHiUserIdWithNet];
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
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMesgReceived:) name:kNewMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sayHelloReceived:) name:kFriendHelloReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePersonReceived:) name:kDeleteAttention object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(otherMessageReceived:) name:kOtherMessage object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(recommendFriendReceived:) name:kOtherMessage object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dailynewsReceived:) name:kNewsMessage object:nil];
    
    //获取xmpp服务器是否连接成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectSuccess:) name:@"connectSuccess" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getConnectFail:) name:@"connectFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserUpdate:) name:@"userInfoUpdated" object:nil];
    
    
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(catchStatus:) name:@"Notification_disconnect" object:nil];
  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInToChatServer) name:@"Notification_BecomeActive" object:nil];
    //重连
    
    
    [self setTopViewWithTitle:@"" withBackButton:NO];

    
    
    allMsgArray = [NSMutableArray array];
    allMsgUnreadArray = [NSMutableArray array];
    newReceivedMsgArray = [NSMutableArray array];
    allNickNameArray = [NSMutableArray array];
    allHeadImgArray = [NSMutableArray array];
    searchResultArray = [NSArray array];
    allSayHelloArray = [NSMutableArray array];
    sayhellocoArray = [NSMutableArray array];
    sayHelloNickNameArray = [NSMutableArray array];
    deleteDic = [NSMutableDictionary dictionary];
    dellArray = [NSMutableArray array];
    allsayHelloImageArray =[NSMutableArray array];
    allsayHellonickNameArray =[NSMutableArray array];
    
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
    hud.labelText = @"获取信息中...";
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
    //[self conversionMsg:notification.userInfo];
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

-(void)conversionMsg:(NSDictionary*)dic
{
    NSString *str = KISDictionaryHaveKey(dic, @"sender");
    NSArray *array = [str componentsSeparatedByString:@"@"];
    NSString *str2 = [array objectAtIndex:0];

    if ([KISDictionaryHaveKey(dic, @"msgType")isEqualToString:@"normalchat"]) {
        if (![allSayHelloArray containsObject:str2]) {
            for (NSDictionary *dict in allMsgArray) {
                if ([KISDictionaryHaveKey(dict, @"sender")isEqualToString:@"1234567wxxxxxxxxx"]) {
                    [allMsgArray removeObject:dict];
                }
            }
            NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
            [dic1 setValue:@"1234567wxxxxxxxxx" forKeyPath:@"sender"];
            [dic1 setValue:KISDictionaryHaveKey(dic, @"msg") forKey:@"msg"];
            [dic1 setValue:@"sayHi" forKey:@"msgType"];
            [dic1 setValue:KISDictionaryHaveKey(dic, @"time") forKeyPath:@"time"];
            [allMsgArray insertObject:dic1 atIndex:0];
            [self readAllnickName];
        }
        else
        {
            NSInteger j ;
            for (int i =0; i<allMsgArray.count;i++) {
                NSDictionary *dict = [allMsgArray objectAtIndex:i];
                if ([KISDictionaryHaveKey(dict, @"sender")intValue ]==[str2 intValue]) {
                     j = [allMsgArray indexOfObject:dict];
                    [allMsgArray removeObject:dict];
                    
                }
            }
            NSInteger s ;
            s = [[allMsgUnreadArray objectAtIndex:j]intValue];
            [allMsgUnreadArray removeObjectAtIndex:j];
            [allMsgUnreadArray insertObject:[NSString stringWithFormat:@"%ld",(long)s+1] atIndex:0];
            
            NSMutableDictionary *dic2 = [NSMutableDictionary dictionary];
            [dic2 setValue:str2 forKeyPath:@"sender"];
            [dic2 setValue:KISDictionaryHaveKey(dic, @"msg") forKey:@"msg"];
            [dic2 setValue:@"normalchat" forKey:@"msgType"];
            [dic2 setValue:KISDictionaryHaveKey(dic, @"time") forKeyPath:@"time"];
            [allMsgArray insertObject:dic2 atIndex:0];
            NSLog(@"dict1%@",dic2);
        }
    }
    if ([KISDictionaryHaveKey(dic, @"msgType")isEqualToString:@"character"]||[KISDictionaryHaveKey(dic, @"msgType")isEqualToString:@"title"]||[KISDictionaryHaveKey(dic, @"msgType")isEqualToString:@"pveScore"]) {
        ;
    }
    if ([KISDictionaryHaveKey(dic, @"msgType")isEqualToString:@"recommendfriend"]) {
        if (![allSayHelloArray containsObject:str2]) {
            
            NSInteger j ;
            for (int i =0; i<allMsgArray.count;i++) {
                NSDictionary *dict = [allMsgArray objectAtIndex:i];
                if ([KISDictionaryHaveKey(dict, @"sender")intValue ]==12345) {
                    j = [allMsgArray indexOfObject:dict];
                    [allMsgArray removeObject:dict];
                    
                }
            }
//            NSInteger s ;
//            s = [[allMsgUnreadArray objectAtIndex:j]intValue];
//            [allMsgUnreadArray removeObjectAtIndex:j];
//            [allMsgUnreadArray insertObject:[NSString stringWithFormat:@"%ld",(long)s+1] atIndex:0];

            NSMutableDictionary *dic1 = [NSMutableDictionary dictionary];
            [dic1 setValue:@"12345" forKeyPath:@"sender"];
            [dic1 setValue:KISDictionaryHaveKey(dic, @"msg") forKey:@"msg"];
            [dic1 setValue:@"normalchat" forKey:@"msgType"];
            [dic1 setValue:KISDictionaryHaveKey(dic, @"time") forKeyPath:@"time"];
            [allMsgArray insertObject:dic1 atIndex:0];
            [self readAllnickName];
        }

;
    }

    [self readAllnickNameAndImage];
    [m_messageTable reloadData];
}




#pragma mark --获取打招呼id
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
        // if ([responseObject isKindOfClass:[NSArray class]]) {
        //            [allSayHelloArray removeAllObjects];
        //            [allSayHelloArray addObjectsFromArray:responseObject];
        //            [m_messageTable reloadData];
        //  }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
}

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
    [allMsgArray removeAllObjects];
    [sayhellocoArray removeAllObjects];
    [allSayHelloArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
    //获取所有消息
   NSMutableArray *thumbCommonMsgsArray = (NSMutableArray *)[DataStoreManager qureyAllThumbMessages];
    //获取所有未读
    NSMutableArray *numArray = [NSMutableArray array];
    
    for (int i = 0; i<thumbCommonMsgsArray.count; i++) {
        NSInteger j ;

        if (![allSayHelloArray containsObject:[[thumbCommonMsgsArray objectAtIndex:i] sender]]&&[[[thumbCommonMsgsArray objectAtIndex:i] msgType]isEqualToString:@"normalchat"]) {
            [sayhellocoArray addObject:[thumbCommonMsgsArray objectAtIndex:i]];
            j = [thumbCommonMsgsArray indexOfObject:[thumbCommonMsgsArray objectAtIndex:i]];
            [numArray addObject:[NSString stringWithFormat:@"%ld",(long)j]];
        }else{

        NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
        [thumbMsgsDict setObject:[[thumbCommonMsgsArray objectAtIndex:i] sender] forKey:@"sender"];
        [thumbMsgsDict setObject:[[thumbCommonMsgsArray objectAtIndex:i] msgContent] forKey:@"msg"];
        NSDate * tt = [[thumbCommonMsgsArray objectAtIndex:i] sendTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [thumbMsgsDict setObject:[NSString stringWithFormat:@"%.f", uu] forKey:@"time"];
        [thumbMsgsDict setObject:[[thumbCommonMsgsArray objectAtIndex:i] messageuuid] forKey:@"messageuuid"];
        [thumbMsgsDict setObject:[[thumbCommonMsgsArray objectAtIndex:i] msgType] forKey:@"msgType"];
            [allMsgArray addObject:thumbMsgsDict];
        }
    }
    
    NSArray *sortedArray = [numArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if ([obj1 intValue] < [obj2 intValue]){
            return NSOrderedDescending;
        }
        if ([obj1 intValue] > [obj2 intValue]){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    NSMutableArray *unReadsayHiArray = [NSMutableArray array];

    allMsgUnreadArray = (NSMutableArray *)[DataStoreManager queryUnreadCountForCommonMsg];
    for (int i =0;i <sortedArray.count;i++) {
        NSString *str = [sortedArray objectAtIndex:i];
        [unReadsayHiArray addObject:[allMsgUnreadArray objectAtIndex:[str intValue]]];
        [allMsgUnreadArray removeObjectAtIndex:[str intValue]];
    }
    int unreadCount = 0;
    for (NSString *str in unReadsayHiArray) {
        unreadCount += [str intValue];
    }
    
    
    //把打招呼的人综合 向消息界面放入一个条目
    if (sayhellocoArray.count!=0) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:@"1234567wxxxxxxxxx" forKeyPath:@"sender"];
        [dic setValue:[[sayhellocoArray objectAtIndex:0] msgContent] forKey:@"msg"];
        [dic setValue:@"sayHi" forKey:@"msgType"];
        NSDate * tt = [[sayhellocoArray objectAtIndex:0] sendTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [dic setValue:[NSString stringWithFormat:@"%.f", uu] forKeyPath:@"time"];
        
        [allMsgArray addObject:dic];
        
    }
    
    // 把消息按照时间重新排序
    NSArray *sortDescriptors1 = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"time" ascending:NO]];
    [allMsgArray sortUsingDescriptors:sortDescriptors1];

    NSInteger unreadSayhiCount=0;//打招呼未读位置
    for (int i = 0; i<allMsgArray.count; i++) {
        NSDictionary *dic =[allMsgArray objectAtIndex:i];
        if ([KISDictionaryHaveKey(dic, @"sender")isEqualToString:@"1234567wxxxxxxxxx" ]) {
            //获取打招呼cell在消息中的位置
            unreadSayhiCount  = [allMsgArray indexOfObject:dic];
        }
    }

    //把打招呼的未读重新放回未读消息条目中
    if (sayhellocoArray.count>0) {
        [allMsgUnreadArray insertObject:[NSString stringWithFormat:@"%d",unreadCount] atIndex:unreadSayhiCount];
    }
    if (sayhellocoArray.count>0) {
        [self readAllnickName];
    }
    [self readAllnickNameAndImage];
    [m_messageTable reloadData];
    [self displayTabbarNotification];
}

-(void)readAllnickNameAndImage
{
    NSMutableArray * nickName = [NSMutableArray array];
    NSMutableArray * headimg = [NSMutableArray array];
    NSMutableArray *sayHelloImg = [NSMutableArray array];
    NSMutableArray *sayHellonickName = [NSMutableArray array];
    for (int i = 0; i<allMsgArray.count; i++) {
        NSString * nickName2 = [DataStoreManager queryMsgRemarkNameForUser:[[allMsgArray objectAtIndex:i] objectForKey:@"sender"]];
        [nickName addObject:nickName2?nickName2 : @""];
        [headimg addObject:[DataStoreManager queryMsgHeadImageForUser:[[allMsgArray objectAtIndex:i] objectForKey:@"sender"]]];
    }
    for (int i = 0; i<sayhellocoArray.count; i++) {
        NSString * nickName2 = [DataStoreManager queryMsgRemarkNameForUser:[NSString stringWithFormat:@"%@",[[sayhellocoArray objectAtIndex:i]sender]]];
        [sayHellonickName addObject:nickName2?nickName2 : @""];
        [sayHelloImg addObject:[DataStoreManager queryMsgHeadImageForUser:[NSString stringWithFormat:@"%@",[[sayhellocoArray objectAtIndex:i]sender]]]];
    }
    allNickNameArray = nickName;
    allHeadImgArray = headimg;
    allsayHelloImageArray = sayHelloImg;
    allsayHellonickNameArray = sayHellonickName;
    
    
    
}

-(void)readAllnickName
{
    NSMutableArray * nickName = [NSMutableArray array];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",[[sayhellocoArray objectAtIndex:0] sender]];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        NSString * nickName2=nil;
        if (thumbMsgs) {
            if (thumbMsgs.senderNickname) {
                nickName2= thumbMsgs.senderNickname;
            }
            [nickName addObject:nickName2?nickName2 : @""];
        }
    sayHelloNickNameArray= nickName;
    NSLog(@"sayHelloNickNameArray%@",sayHelloNickNameArray);
}


-(void)displayTabbarNotification
{
    NSLog(@"allunread%d",allMsgUnreadArray.count);
    int allUnread = 0;
    for (int i = 0; i<allMsgUnreadArray.count; i++) {
        allUnread = allUnread+[[allMsgUnreadArray objectAtIndex:i] intValue];
    }
    if (allUnread>0) {
        [[Custom_tabbar showTabBar] notificationWithNumber:YES AndTheNumber:allUnread OrDot:NO WithButtonIndex:0];
    }
    else
    {
        [[Custom_tabbar showTabBar] removeNotificatonOfIndex:0];
    }
    
}

#pragma mark - 搜索
-(void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    //    if (KISHighVersion_7) {
    //        [searchBar setFrame:CGRectMake(0, 20, 320, 44)];
    //        searchBar.backgroundImage = [UIImage imageNamed:@"top.png"];
    //        [UIView animateWithDuration:0.3 animations:^{
    //            [m_messageTable setFrame:CGRectMake(0, 20, 320, self.view.frame.size.height- 50 - startX)];
    ////            m_messageTable.contentOffset = CGPointMake(0, -20);
    //        } completion:^(BOOL finished) {
    //
    //        }];
    //    }
}

-(void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    if (KISHighVersion_7) {
        
    }
}

-(void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
    //    if (KISHighVersion_7) {
    //        [UIView animateWithDuration:0.2 animations:^{
    //            [searchBar setFrame:CGRectMake(0, 0, 320, 44)];
    //            [m_messageTable setFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - 50 - startX)];
    //        } completion:^(BOOL finished) {
    //            searchBar.backgroundImage = nil;
    //        }];
    //    }
}
-(void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    if (KISHighVersion_7) {
        //        tableView.backgroundColor = [UIColor grayColor];
        [tableView setFrame:CGRectMake(0, 64, 320, self.view.frame.size.height - 50 - 64)];
        //        [tableView setContentOffset:CGPointMake(0, 20)];
    }
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    
}
#pragma mark 数据存储
-(void)makeMsgVStoreMsg:(NSDictionary *)messageContent
{
    //    [self storeNewMessage:messageContent];
}
//
//-(void)storeNewMessage:(NSDictionary *)messageContent
//{
//    NSString * type = KISDictionaryHaveKey(messageContent, @"msgType");
//    type = type?type:@"notype";
//    if ([type isEqualToString:@"reply"]||[type isEqualToString:@"zanDynamic"]) {
//        [DataStoreManager storeNewMsgs:messageContent senderType:SYSTEMNOTIFICATION];//系统消息
//    }
//    else if([type isEqualToString:@"normalchat"])
//    {
//        AudioServicesPlayAlertSound(1007);
//        [DataStoreManager storeNewMsgs:messageContent senderType:COMMONUSER];//普通聊天消息
//    }
//    else if ([type isEqualToString:@"sayHello"] || [type isEqualToString:@"deletePerson"])//关注和取消关注
//    {
//        AudioServicesPlayAlertSound(1007);
//
//        [DataStoreManager storeNewMsgs:messageContent senderType:SAYHELLOS];//打招呼消息
//    }
//    else if([type isEqualToString:@"recommendfriend"])
//    {
//        [DataStoreManager storeNewMsgs:messageContent senderType:RECOMMENDFRIEND];
//    }
//}


#pragma mark 表格

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchBar.text];
    //    NSLog(@"%@",searchBar.text);
    //
    //    searchResultArray = [pyChineseArray filteredArrayUsingPredicate:resultPredicate ]; //注意retain
    //    NSLog(@"%@",searchResultArray);
    //    if ([tableView isEqual:self.searchDisplayController.searchResultsTableView]) {
    //        return [searchResultArray count];
    //    }
    //    else
    
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
        if ([[[allMsgArray objectAtIndex:indexPath.row]objectForKey:@"msgType"]isEqualToString:@"sayHi"]) {
        cell.headImageV.imageURL =nil;
        [cell.headImageV setImage:KUIImage(@"mess_guanzhu")];
        cell.contentLabel.text =[NSString stringWithFormat:@"%@:%@",[sayHelloNickNameArray objectAtIndex:0],KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row], @"msg")];
           // cell.contentLabel.text = [NSString stringWithFormat:@"%@:%@",[allNickNameArray objectAtIndex:indexPath.row],KISDictionaryHaveKey([allMsgArray objectAtIndex:indexPath.row], @"msg")];
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"character"] ||
             [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"title"] ||
             [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"pveScore"])
    {
        cell.headImageV.imageURL =nil;
        
        cell.headImageV.image = KUIImage(@"mess_titleobj");
        NSDictionary * dict = [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msg"] JSONValue];
        cell.contentLabel.text = KISDictionaryHaveKey(dict, @"msg");
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"recommendfriend"])
    {
        cell.headImageV.imageURL =nil;
        
        cell.headImageV.image = KUIImage(@"mess_tuijian");
        
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
    }
    else if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"dailynews"])
    {
        cell.headImageV.imageURL =nil;
        
        cell.headImageV.image = KUIImage(@"mess_news");
        
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
    }
    //判断是否是打招呼
    //        else if ()
    //        {
    //            cell.headImageV.imageURL =nil;
    //            cell.headImageV.image = KUIImage(@"mess_guanzhu");
    //            cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
    //        }
    else
    {
        NSURL * theUrl;
        if ([[allHeadImgArray objectAtIndex:indexPath.row]isEqualToString:@""]||[[allHeadImgArray objectAtIndex:indexPath.row]isEqualToString:@" "]) {
            theUrl =nil;
        }else{
            theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80",[GameCommon getHeardImgId:[allHeadImgArray objectAtIndex:indexPath.row]]]];
        }
        cell.headImageV.imageURL = theUrl;
        cell.contentLabel.text = [[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msg"];
        
    }
    
    if ([[allMsgUnreadArray objectAtIndex:indexPath.row] intValue]>0) {
        cell.unreadCountLabel.hidden = NO;
        cell.notiBgV.hidden = NO;
        if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"recommendfriend"] |
            [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"sayHello"] ||
            [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"deletePerson"]) {
            cell.notiBgV.image = KUIImage(@"redpot");
            cell.unreadCountLabel.hidden = YES;
        }
        else
        {
            [cell.unreadCountLabel setText:[allMsgUnreadArray objectAtIndex:indexPath.row]];
            
            if ([[allMsgUnreadArray objectAtIndex:indexPath.row] intValue]>99) {
                [cell.unreadCountLabel setText:@"99+"];
                cell.notiBgV.image = KUIImage(@"redCB_big");
                cell.notiBgV.frame=CGRectMake(40, 8, 22, 18);
                cell.unreadCountLabel.frame =CGRectMake(0, 0, 22, 18);
            }
            else{
                cell.notiBgV.image = KUIImage(@"redCB.png");
                [cell.unreadCountLabel setText:[allMsgUnreadArray objectAtIndex:indexPath.row]];
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
    cell.nameLabel.text = [allNickNameArray objectAtIndex:indexPath.row];
    cell.timeLabel.text = [GameCommon CurrentTime:[[GameCommon getCurrentTime] substringToIndex:10]AndMessageTime:[[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"time"] substringToIndex:10]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
//    if (tableView.editing) {
//        NSLog(@"11111");
//        [deleteDic setObject:indexPath forKey:[allMsgArray objectAtIndex:indexPath.row]];
//        
//    }else{

    [m_messageTable deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
    
    [[Custom_tabbar showTabBar] hideTabBar:YES];
        // if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"normalchat"]&&![allSayHelloArray containsObject:[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"sender"]])
    if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"sayHi"]) {
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        friq.personCount = sayhellocoArray.count;
        friq.nickNameArray = allsayHellonickNameArray;
        friq.imgArray =allsayHelloImageArray;
        [self.navigationController pushViewController:friq animated:YES];
        [searchDisplay setActive:NO animated:NO];
        [self cleanUnReadCountWithType:5 Content:@"" typeStr:@""];
        
        return;
        
    }
    
    if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"sayHello"] || [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"deletePerson"]) {//关注
        AttentionMessageViewController * friq = [[AttentionMessageViewController alloc] init];
        [self.navigationController pushViewController:friq animated:YES];
        [searchDisplay setActive:NO animated:NO];
        [self cleanUnReadCountWithType:3 Content:@"" typeStr:@""];
        
        return;
    }
    if([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"recommendfriend"])//好友推荐  推荐的朋友
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        
        FriendRecommendViewController* VC = [[FriendRecommendViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        [searchDisplay setActive:NO animated:NO];
        
        [self cleanUnReadCountWithType:2 Content:@"" typeStr:@""];
        
        return;
    }
    if([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"dailynews"])//新闻
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        EveryDataNewsViewController * newsVC = [[EveryDataNewsViewController alloc]init];
        [self.navigationController pushViewController:newsVC animated:YES];
        [searchDisplay setActive:NO animated:NO];
        [self cleanUnReadCountWithType:4 Content:@"" typeStr:@""];
        return;
    }
    if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"character"] ||
        [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"title"] ||
        [[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"msgType"] isEqualToString:@"pveScore"])
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        
        OtherMsgsViewController* VC = [[OtherMsgsViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
        
        [searchDisplay setActive:NO animated:NO];
        
        [self cleanUnReadCountWithType:1 Content:@"" typeStr:@""];
        
        return;
    }
    int allUnread = 0;
    for (int i = 0; i<allMsgUnreadArray.count; i++) {
        allUnread = allUnread+[[allMsgUnreadArray objectAtIndex:i] intValue];
    }
    MessageCell * cell =(MessageCell*)[self tableView:m_messageTable cellForRowAtIndexPath:indexPath] ;
    NSInteger no = [cell.unreadCountLabel.text intValue];
    KKChatController * kkchat = [[KKChatController alloc] init];
    kkchat.unreadNo = allUnread-no;
    kkchat.chatWithUser = [[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"sender"];
    kkchat.nickName = [allNickNameArray objectAtIndex:indexPath.row];
    kkchat.chatUserImg = [allHeadImgArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:kkchat animated:YES];
    kkchat.msgDelegate = self;
    [searchDisplay setActive:NO animated:NO];
    //}
}

//- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (tableView.editing) {
//        NSLog(@"2222222");
//        [deleteDic removeObjectForKey:[allMsgArray objectAtIndex:indexPath.row]];
//    }
//    
//}


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

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
//}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        if([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"sender"] isEqualToString:@"1"])//角色
        {
            //            [DataStoreManager deleteThumbMsgWithUUID:[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"messageuuid"]];
            [DataStoreManager cleanOtherMsg];
        }
        else if ([[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"sender"] isEqualToString:@"sys00000011"])
        {
            [DataStoreManager deleteAllNewsMsgs];
        }
        else{
            if ([[[allMsgArray objectAtIndex:indexPath.row]objectForKey:@"sender"]isEqualToString:@"1234567wxxxxxxxxx"])
            {
                for (int i =0;i<sayhellocoArray.count;i++) {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
                    [dic setObject:[[sayhellocoArray objectAtIndex:i]sender] forKey:@"sender"];
                    [DataStoreManager deleteThumbMsgWithSender:KISDictionaryHaveKey(dic, @"sender")];
                }
            }
            [DataStoreManager deleteThumbMsgWithSender:[[allMsgArray objectAtIndex:indexPath.row] objectForKey:@"sender"]];
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

#pragma mark - 获得好友、关注、粉丝列表
-(void)getFriendByHttp
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    //    [paramDict setObject:@"1" forKey:@"shiptype"];// 1：好友   2：关注  3：粉丝
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sorttype_1]) {
        [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:sorttype_1] forKey:@"sorttype_1"];
    }
    else
    {
        [paramDict setObject:@"1" forKey:@"sorttype_1"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sorttype_2]) {
        [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:sorttype_2] forKey:@"sorttype_2"];
    }
    else
    {
        [paramDict setObject:@"1" forKey:@"sorttype_2"];
    }
    [paramDict setObject:@"2" forKey:@"sorttype_3"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"111" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    hud.labelText = @"正在获取好友列表...";
    // [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        //        [self parseFriendsList:KISDictionaryHaveKey(responseObject, @"1")];
        //        [self parseAttentionList:KISDictionaryHaveKey(responseObject, @"2")];
        //
        //        [self parseFansList:(KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"3"), @"users"))];
        
        
        [self parseContentListWithData:responseObject];
        

        
        //  [self getFriendId:responseObject];
        
        [[NSUserDefaults standardUserDefaults] setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"3"), @"totalResults")] forKey:FansCount];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //不再请求好友列表
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isFirstOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        //        [hud hide:YES];
    }];
}


-(void)getFriendId:(id)dic
{
    NSMutableArray *friendAllIdArray = [NSMutableArray array];
    NSArray *friendArray = [NSArray array];
    NSArray *attentionArray = [NSArray array];
    friendArray = [KISDictionaryHaveKey(dic, @"1")allKeys];
    for (int i =0; i<friendArray.count; i++) {
        NSMutableArray *array2 = [NSMutableArray array ];
        array2 = [KISDictionaryHaveKey(dic, @"1")objectForKey:friendArray[i]];
        for (NSDictionary *dic1 in array2) {
            [friendAllIdArray addObject:KISDictionaryHaveKey(dic1, @"id")];
        }
    }
    attentionArray =[KISDictionaryHaveKey(dic, @"2")allKeys];
    for (int i =0; i<attentionArray.count; i++) {
        NSMutableArray *array2 = [NSMutableArray array ];
        array2 = [KISDictionaryHaveKey(dic, @"1")objectForKey:attentionArray[i]];
        for (NSDictionary *dic1 in array2) {
            [friendAllIdArray addObject:KISDictionaryHaveKey(dic1, @"id")];
        }
    }
    NSMutableArray *array = [NSMutableArray array ];
    [array removeAllObjects];
    [array addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
    BOOL isAdd;
    isAdd =NO;
    for (NSString *idStr in friendAllIdArray) {
        if (![array containsObject:idStr]) {
            [self getSayHelloWithUserid:idStr];
            [array addObject:idStr];
            isAdd =YES;
        }
    }
    if (isAdd ==YES) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sayHello_wx_info_id"];
        [[NSUserDefaults standardUserDefaults]setObject:array forKey:@"sayHello_wx_info_id"];
        [self displayMsgsForDefaultView];
    }
    
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



- (void)parseContentListWithData:(NSDictionary*)dataDic
{
    [DataStoreManager cleanFriendList];//先清 再存
    [DataStoreManager cleanAttentionList];
    [DataStoreManager cleanFansList];
    
    id friendsList = KISDictionaryHaveKey(dataDic, @"1");
    id attentionList = KISDictionaryHaveKey(dataDic, @"2");
    id fansList = KISDictionaryHaveKey(KISDictionaryHaveKey(dataDic, @"3"), @"users");
    dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
    dispatch_async(queue, ^{
        //   [hud show:YES];
        
        if ([friendsList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [friendsList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [friendsList objectForKey:key]) {
                    //                    [dict setObject:key forKey:@"nameindex"];
                    [DataStoreManager saveUserInfo:dict];
                    if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                        [DataStoreManager saveAllUserWithUserManagerList:dict];
                    }

                }
            }
        }
        else if([friendsList isKindOfClass:[NSArray class]]){
            for (NSDictionary * dict in friendsList) {
                [DataStoreManager saveUserInfo:dict];
                if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                    [DataStoreManager saveAllUserWithUserManagerList:dict];
                }

            }
        }
        //关注
        if ([attentionList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [attentionList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [attentionList objectForKey:key]) {
                    //                    [dict setObject:key forKey:@"nameindex"];
                    [DataStoreManager saveUserAttentionInfo:dict];
                    if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                        [DataStoreManager saveAllUserWithUserManagerList:dict];
                    }

                }
            }
        }
        else if([attentionList isKindOfClass:[NSArray class]])
        {
            for (NSDictionary * dict in attentionList) {
                [DataStoreManager saveUserAttentionInfo:dict];
            }
        }
        //粉丝
        if ([fansList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [fansList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [fansList objectForKey:key]) {
                    [DataStoreManager saveUserFansInfo:dict];
                }
            }
        }
        else if ([fansList isKindOfClass:[NSArray class]]) {
            for (NSDictionary * dict in fansList) {
                [DataStoreManager saveUserFansInfo:dict];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];
            
        });
    });
}

#pragma mark - 好友状态更改(比如昵称啥修改了,收到消息 暂未处理)
-(void)processFriend:(XMPPPresence *)processFriend{
    //    NSString *username=[[processFriend from] user];
    NSLog(@"好友状态更改lalalala");
    //    [self requestPeopleInfoWithName:username ForType:1 Msg:nil];
}


#pragma mark ---做勾选删除用
/*
-(void)delMsg:(UIButton *)sender
{
    
    if (m_messageTable.editing) {
        deltButton.hidden = YES;
        [m_messageTable setEditing:NO animated:YES];
        [sender setTitle:@"删除" forState:UIControlStateNormal];
        m_messageTable.editing = NO;
    }else{
    m_messageTable.editing =YES;
        deltButton.hidden = NO;
        [m_messageTable setEditing:YES animated:YES];

        [sender setTitle:@"取消" forState:UIControlStateNormal];
    }
}
-(void)delttttMsg:(UIButton *)sender
{
    for (int i =0;i<[deleteDic allKeys].count;i++) {
        NSMutableDictionary *dic = [[deleteDic allKeys]objectAtIndex:i];
        int j = [[[NSArray arrayWithArray:[deleteDic allValues]] objectAtIndex:i]intValue];
    if([[dic objectForKey:@"sender"] isEqualToString:@"1"])//角色
    {
        [DataStoreManager cleanOtherMsg];
    }
    else if ([[dic objectForKey:@"sender"] isEqualToString:@"sys00000011"])
    {
        [DataStoreManager deleteAllNewsMsgs];
    }
    else{
        if ([[dic objectForKey:@"sender"]isEqualToString:@"1234567wxxxxxxxxx"])
        {
            for (NSDictionary *dic in sayhellocoArray) {
                [DataStoreManager deleteThumbMsgWithSender:KISDictionaryHaveKey(dic, @"sender")];
            }
        }
        [DataStoreManager deleteThumbMsgWithSender:[dic objectForKey:@"sender"]];
    }
    [allMsgArray removeObjectAtIndex:j];
    }
        [m_messageTable deleteRowsAtIndexPaths:[NSArray arrayWithArray:[deleteDic allValues]] withRowAnimation:UITableViewRowAnimationFade];
    [deleteDic removeAllObjects];

    [self displayMsgsForDefaultView];
}
*/
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void) onUserUpdate:(NSNotification*)notification{
    [self displayMsgsForDefaultView];
}

@end
