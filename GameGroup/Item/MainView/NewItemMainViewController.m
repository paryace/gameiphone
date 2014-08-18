//
//  NewItemMainViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-8-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewItemMainViewController.h"
#import "BaseItemCell.h"
#import "CreateItemViewController.h"
#import "ItemInfoViewController.h"
#import "MyRoomViewController.h"
#import "FindItemViewController.h"
#import "PreferenceEditViewController.h"
#import "ItemManager.h"
#import "NewCreateItemViewController.h"
#import "PreferencesMsgManager.h"
#import "NewCreateItemViewController.h"
#import "KKChatController.h"
@interface NewItemMainViewController ()
{
    UIView *customView;
    FirstView  *firstView;
    MyRoomView  *room;
    UITableView * m_mylistTableView;
    UIImageView *customImageView;
//    UISegmentedControl *seg ;
    UIButton* sortingBtn;//排序
    UIButton* createBtn;//创建
    MsgNotifityView * dotV;
    
    NSString *userid;
    
    UIButton *m_button1;
    UIButton *m_button2;
    
    
}
@end

@implementation NewItemMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        userid = [[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    
    if (![userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        userid =[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
        firstView.selectCharacter = nil;
        firstView.selectType = nil;
        [firstView setTitleInfo];
        [firstView initSearchConditions];
    }
    firstView.firstDataArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic  in firstView.firstDataArray) {
        if ([KISDictionaryHaveKey(dic, @"failedmsg") isEqualToString:@"notSupport"]||[KISDictionaryHaveKey(dic, @"failedmsg") isEqualToString:@"404"]) {
            NSLog(@"++++++++%@",dic);
        }else{
            [arr addObject:dic];
        }
    }
    [firstView.firstDataArray removeAllObjects];
    [firstView.firstDataArray  addObjectsFromArray:arr];
    
    

}
-(void)viewDidAppear:(BOOL)animated
{
//    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"LoignRefreshPreference_wx"];
//    if ([str isEqualToString:@"refreshPreference"]) {
        [self getMyRoomFromNet];
//    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyList:) name:@"refreshTeamList_wx" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPreference:) name:@"shuaxinRefreshPreference_wxx" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPreferMsgReceive:) name:kNewPreferMsg object:nil];
    
    UIImageView* topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44)];
    topImageView.userInteractionEnabled = YES;
    topImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    topImageView.image = KUIImage(@"nav_bg");
    [self.view addSubview:topImageView];
    
    UIImageView *segBgImg = [[UIImageView alloc]initWithImage:KUIImage(@"team_seg_black")];
    segBgImg.frame = CGRectMake(74.5f, KISHighVersion_7 ? 27 : 7, 171, 25);
    [self.view addSubview:segBgImg];
    
    m_button1 = [[UIButton alloc]initWithFrame:CGRectMake(74.5f, KISHighVersion_7 ? 27 : 7, 85.5f, 25)];
    [m_button1 setBackgroundImage:KUIImage(@"team_seg_search_click") forState:UIControlStateNormal];
    [m_button1 setBackgroundImage:KUIImage(@"team_seg_search_normal") forState:UIControlStateSelected];
    m_button1.selected = YES;
    [m_button1 addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_button1];
    
    m_button2 = [[UIButton alloc]initWithFrame:CGRectMake(160.0f, KISHighVersion_7 ? 27 : 7, 85.5f, 25)];
    [m_button2 setBackgroundImage:KUIImage(@"team_seg_team_click") forState:UIControlStateNormal];
    [m_button2 setBackgroundImage:KUIImage(@"team_seg_team_normal") forState:UIControlStateSelected];
    [m_button2 addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_button2];

    //排序
    sortingBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, KISHighVersion_7?18:0, 65, 44)];
    [sortingBtn setBackgroundImage:KUIImage(@"team_sorting") forState:UIControlStateNormal];
    sortingBtn.backgroundColor = [UIColor clearColor];
    [sortingBtn addTarget:self action:@selector(sortingList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sortingBtn];
    
    //创建
    createBtn = [[UIButton alloc] initWithFrame:CGRectMake(320-65, KISHighVersion_7?17:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"team_create") forState:UIControlStateNormal];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(create:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    

    //收藏提示
    UIButton *collectionBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [collectionBtn setBackgroundImage:KUIImage(@"team_notifation") forState:UIControlStateNormal];
    collectionBtn.backgroundColor = [UIColor clearColor];
    collectionBtn.hidden = YES;
    [collectionBtn addTarget:self action:@selector(tishiing:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:collectionBtn];
    //数字红点
    dotV = [[MsgNotifityView alloc] initWithFrame:CGRectMake(40, KISHighVersion_7 ? 25 : 5, 22, 18)];
//    [self.view addSubview:dotV];

    customView = [[UIView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50)];
    customView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:customView];
    
    room = [[MyRoomView alloc]initWithFrame:CGRectMake(0, 0, 320, customView.frame.size.height)];
    room.myDelegate = self;
    [customView addSubview:room];

    firstView = [[FirstView alloc]initWithFrame:CGRectMake(0, 0, 320, customView.frame.size.height)];
    firstView.backgroundColor = [UIColor whiteColor];
    firstView.myDelegate = self;
    firstView.firstDataArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    
    /*
     去除角色列表中的404 和notSupport 的角色
     */

    
    NSMutableArray *arr = [NSMutableArray array];
    for (NSDictionary *dic  in firstView.firstDataArray) {
        if ([KISDictionaryHaveKey(dic, @"failedmsg") isEqualToString:@"notSupport"]||[KISDictionaryHaveKey(dic, @"failedmsg") isEqualToString:@"404"]) {
            NSLog(@"++++++++%@",dic);
        }else{
            [arr addObject:dic];
        }
    }
    [firstView.firstDataArray removeAllObjects];
    [firstView.firstDataArray  addObjectsFromArray:arr];

    [customView addSubview:firstView];
    [self reloadMsgCount];
    [firstView initSearchConditions];//使用上次的搜索条件
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];

}


//-(void)getCharacter
//{
//    NSArray *arr = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
////    for (NSDictionary *dic in firstView.firstDataArray) {
////        if ([KISDictionaryHaveKey(dic, @"failedmsg")isEqualToString:@"404"]||[KISDictionaryHaveKey(dic, @"failedmsg")isEqualToString:@"notSupport"]) {
////            [firstView.firstDataArray removeObject:dic];
////        }
////    }
//
//    for (int i =0; i<arr.count; i++) {
//        NSDictionary *dic = [arr objectAtIndex:i];
//        if (![KISDictionaryHaveKey(dic, @"failedmsg")isEqualToString:@"404"]&&![KISDictionaryHaveKey(dic, @"failedmsg")isEqualToString:@"notSupport"]) {
//            [firstView.firstDataArray addObject:dic];
//        }
//
//    }
//    NSLog(@"dic.count--%d/n---%@",firstView.firstDataArray.count,firstView.firstDataArray);
//}


//排序
-(void)sortingList:(id)sender
{
    [firstView hideDrowList];
    [firstView didClickScreen];
}

//创建
-(void)create:(id)sender{
    NSArray *arr =[room.listDict objectForKey:@"OwnedRooms"];
    if (arr.count==2) {
        [self showAlertViewWithTitle:@"提示" message:@"您的队伍已达到创建上限" buttonTitle:@"确定"];
        return;
    }
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    NewCreateItemViewController *cretItm =[[NewCreateItemViewController alloc]init];
    cretItm.selectRoleDict = firstView. selectCharacter;
    cretItm.selectTypeDict = firstView.selectType;
    
    [self.navigationController pushViewController: cretItm animated:YES];
}

//进入偏好
-(void)tishiing:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    PreferenceViewController *perf = [[PreferenceViewController alloc]init];
    perf.mydelegate =self;
    [self.navigationController pushViewController: perf animated:YES];
}

//获取未读消息数量，刷新消息数量
-(void)displayTabbarNotification
{
    NSInteger msgCount  = [[PreferencesMsgManager singleton]getNoreadMsgCount2];
    [self setMsgCount:msgCount];
}
//设置消息数量
-(void)setMsgCount:(NSInteger)msgCount{
    [dotV setMsgCount:msgCount];
    if (msgCount>0) {
        [[Custom_tabbar showTabBar] notificationWithNumber:YES AndTheNumber:msgCount OrDot:NO WithButtonIndex:2];
    }
    else
    {
        [[Custom_tabbar showTabBar] removeNotificatonOfIndex:2];
    }
}
-(void)refreshMyList:(id)sender
{
//    if (m_button1.selected ==YES) {
//    }else{
    
        [self changeView:m_button2];
//    }
    [self getMyRoomFromNet];
}

-(void)showAlertDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

-(void)setList:(NSMutableArray*)array
{
    for (NSMutableDictionary * dic in array) {
        if (![KISDictionaryHaveKey(dic, @"type") isKindOfClass:[NSDictionary class]]) {
            [dic setObject:[[ItemManager singleton] createType] forKey:@"type"];
        }
    }
}

#pragma mark --获取我的组队列表
-(void)getMyRoomFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"272" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [room stopRefre];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:[NSString stringWithFormat:@"item_myRoom_%@",[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]];
            
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LoignRefreshPreference_wx"];
            [room initMyRoomListData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [room stopRefre];
        [self showAlertDialog:error];
    }];
    
}
-(void)changeView:(UIButton *)sender
{
    if (sender ==m_button1) {
        if (!m_button1.selected) {
            m_button1.selected = YES;
            m_button2.selected = NO;
            sortingBtn.hidden = NO;
            [UIView beginAnimations:@"animation" context:nil];
            [UIView setAnimationDuration:1.0f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:customView cache:YES];
            [customView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
            [UIView commitAnimations];

        }
    }else if (sender ==m_button2){
        if (!m_button2.selected) {
            m_button2.selected = YES;
            m_button1.selected = NO;
            sortingBtn.hidden = YES;
            [UIView beginAnimations:@"animation1" context:nil];
            [UIView setAnimationDuration:1.0f];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:customView cache:YES];
            [UIView commitAnimations];
            [customView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            [customView bringSubviewToFront:room];
        }
    }
}



//-(void)changeView:(UISegmentedControl*)segment
//{
//    switch (segment.selectedSegmentIndex) {
//        case 0:
//            [UIView beginAnimations:@"animation" context:nil];
//            [UIView setAnimationDuration:1.0f];
//            [sortingBtn setBackgroundImage:KUIImage(@"team_sorting") forState:UIControlStateNormal];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:customView cache:YES];
//            [customView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
//            [UIView commitAnimations];
//            
//            //            [customView bringSubviewToFront:firstView];
//            break;
//        case 1:
//            [UIView beginAnimations:@"animation1" context:nil];
//            [UIView setAnimationDuration:1.0f];
//            [sortingBtn setBackgroundImage:KUIImage(@"team_create") forState:UIControlStateNormal];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:customView cache:YES];
//            [UIView commitAnimations];
//            [customView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
//            [customView bringSubviewToFront:room];
//
//            break;
//            
//        default:
//            break;
//    }
//    //  交换本视图控制器中2个view位置
//    
//}


-(void)didClickMyRoomWithView:(MyRoomView*)view dic:(NSDictionary *)dic
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
//    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
//    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"createTeamUser"), @"userid")];
//    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
//        itemInfo.isCaptain = YES;
//    }else{
//        itemInfo.isCaptain =NO;
//    }
//    itemInfo.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
//    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
//    [self.navigationController pushViewController:itemInfo animated:YES];
   
    KKChatController *kkchat = [[KKChatController alloc]init];
    kkchat.unreadMsgCount  = 0;
    kkchat.chatWithUser =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")];
    kkchat.type = @"group";
    kkchat.roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    kkchat.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")];
    kkchat.isTeam = YES;
    [self.navigationController pushViewController:kkchat animated:YES];
}

-(void)didClickRoomInfoWithView:(MyRoomView*)view dic:(NSDictionary *)dic{
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
//    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"createTeamUser"), @"userid")];
//    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
//        itemInfo.isCaptain = YES;
//    }else{
//        itemInfo.isCaptain =NO;
//    }
    itemInfo.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    [self.navigationController pushViewController:itemInfo animated:YES];

}

-(void)didClickCreateTeamWithView:(MyRoomView *)view
{
    NewCreateItemViewController *cretItm = [[NewCreateItemViewController alloc]init];
    //    cretItm.selectRoleDict = selectCharacter;
    //    cretItm.selectTypeDict = selectType;
    [self.navigationController pushViewController:cretItm animated:YES];
}

#pragma mark --解散队伍
-(void)dissTeam:(MyRoomView *)view dic:(NSDictionary *)dic{
    hud.labelText = @"解散中...";
    [hud show:YES];
    [[ItemManager singleton] dissoTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] reSuccess:^(id responseObject) {
        [hud hide: YES];
        [self showMessageWindowWithContent:@"解散成功" imageType:0];
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];
    
}
#pragma mark --退出队伍
-(void)exitTeam:(MyRoomView *)view dic:(NSDictionary *)dic{
    hud.labelText = @"退出中...";
    [hud show:YES];
    [[ItemManager singleton] exitTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"myMemberId")] reSuccess:^(id responseObject) {
        [hud hide:YES];
        [self showMessageWindowWithContent:@"退出成功" imageType:1];
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];
}
#pragma mark --退出队伍
-(void)reloadRoomList{
    [self getMyRoomFromNet];
}

-(void)didClickTableViewCellEnterNextPageWithController:(UIViewController *)vc
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    [self.navigationController pushViewController:vc animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)searchTeamBackViewWithDic:(NSDictionary *)dic
{
    [firstView InitializeInfo:dic];
}

#pragma mark --刷新消息数量
-(void)newPreferMsgReceive:(NSNotification*)notification{
    NSInteger  msgCount =[notification.object intValue];
    [self setMsgCount:msgCount];
}

#pragma mark --刷新消息数量
-(void)reloadMsgCount{
//    [self displayTabbarNotification];
}

-(void)didClickSuccessWithText:(NSString *)text tag:(NSInteger)tag
{
    [self showMessageWindowWithContent:text imageType:tag];
}

@end
