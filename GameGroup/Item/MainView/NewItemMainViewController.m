//
//  NewItemMainViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-8-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewItemMainViewController.h"
#import "CreateItemViewController.h"
#import "ItemInfoViewController.h"
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
    UIButton* sortingBtn;//排序
    UIButton* createBtn;//创建
    MsgNotifityView * dotV;
    NSString *userid;
    UIButton *m_button1;
    UIButton *m_button2;
    
    UIButton * guideImage;
    
    UIView * view1;
    UIView * view2;
    UIView * view3;
    
    
}
@end

@implementation NewItemMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        userid = [[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];

    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    [firstView setCharacterData:[DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]];
    if ([firstView ifShowSelectCharacterMenu]) {
        return;
    }
    if (![[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:@"oldUserid"]]) {
        [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] forKey:@"oldUserid"];
        [firstView initSearchConditions];//使用上次的搜索条件
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [self getMyRoomFromNet];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyList:) name:@"refreshTeamList_wx" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPreference:) name:@"shuaxinRefreshPreference_wxx" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPreferMsgReceive:) name:kNewPreferMsg object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRoomState:) name:@"updateRoomState" object:nil];
    //删除角色
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(roleRemove:) name:RoleRemoveNotify object:nil];
    
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
    [sortingBtn setBackgroundImage:KUIImage(@"teamSorting") forState:UIControlStateNormal];
    sortingBtn.backgroundColor = [UIColor clearColor];
    [sortingBtn addTarget:self action:@selector(sortingList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sortingBtn];
    
    //创建
    createBtn = [[UIButton alloc] initWithFrame:CGRectMake(320-65, KISHighVersion_7?17:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"team_createA") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"team_createB") forState:UIControlStateHighlighted];
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
    [customView addSubview:firstView];
    
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firseGuide"]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"first" forKey:@"firseGuide"];
        guideImage = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height)];
        guideImage.backgroundColor = [UIColor blackColor];
        guideImage.alpha = 0.7;
        [guideImage addTarget:self action:@selector(nomath) forControlEvents:UIControlEventTouchUpInside];
    
        [self.view addSubview:guideImage];
        
        view1 = [[UIView alloc] initWithFrame:CGRectMake(320-247.5-22.5, 50, 247.5, 157.5)];
        view1.backgroundColor = [UIColor clearColor];
        
        UIImageView * guideImage11 = [[UIImageView alloc] initWithFrame:CGRectMake(247.5-57.5, 0, 57.5, 104)];
        guideImage11.image = KUIImage(@"guide_11");
        [view1 addSubview:guideImage11];
        
        UIButton * guideImage12 = [[UIButton alloc] initWithFrame:CGRectMake(0, 157.5-104, 190, 87.5)];
        [guideImage12 setBackgroundImage:KUIImage(@"guide_12") forState:UIControlStateNormal];
        [guideImage12 addTarget:self action:@selector(guideAction1:) forControlEvents:UIControlEventTouchUpInside];
        [view1 addSubview:guideImage12];
        [self.view addSubview:view1];
        
        
        
        view2 = [[UIView alloc] initWithFrame:CGRectMake(320-238-32.5, startX+30, 238, 125.5)];
        view2.hidden = YES;
        view2.backgroundColor = [UIColor clearColor];
        
        UIImageView * guideImage21 = [[UIImageView alloc] initWithFrame:CGRectMake(238-48.5, 0, 48.5, 66.5)];
        guideImage21.image = KUIImage(@"guide_31");
        [view2 addSubview:guideImage21];
        
        UIButton * guideImage22 = [[UIButton alloc] initWithFrame:CGRectMake(0,40, 189.5, 85.5)];
        [guideImage22 setBackgroundImage:KUIImage(@"guide_32") forState:UIControlStateNormal];
        [guideImage22 addTarget:self action:@selector(guideAction2:) forControlEvents:UIControlEventTouchUpInside];
        [view2 addSubview:guideImage22];
        [self.view addSubview:view2];
        
        
        view3 = [[UIView alloc] initWithFrame:CGRectMake(29, 50, 247.5, 125.5)];
        view3.hidden = YES;
        view3.backgroundColor = [UIColor clearColor];
        
        UIImageView * guideImage31 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 57.5, 104)];
        guideImage31.image = KUIImage(@"guide_21");
        [view3 addSubview:guideImage31];
        
        UIButton * guideImage32 = [[UIButton alloc] initWithFrame:CGRectMake(57.5,40, 190, 87.5)];
        [guideImage32 setBackgroundImage:KUIImage(@"guide_22") forState:UIControlStateNormal];
        [guideImage32 addTarget:self action:@selector(guideAction3:) forControlEvents:UIControlEventTouchUpInside];
        [view3 addSubview:guideImage32];
        [self.view addSubview:view3];
    }
    
    
    
    [self reloadMsgCount];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
}
-(void)nomath{
    
}


-(void)guideAction1:(id)sender
{
    [view1 removeFromSuperview];
    view2.hidden = NO;
}
-(void)guideAction2:(id)sender
{
    [view2 removeFromSuperview];
    view3.hidden = NO;
}
-(void)guideAction3:(id)sender
{
    [view3 removeFromSuperview];
    [guideImage removeFromSuperview];
}


//排序
-(void)sortingList:(id)sender
{
    [firstView hideDrowList];
    [firstView didClickScreen];
}

//创建
-(void)create:(id)sender{
    [self joumpToCreatePage];
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
    if (![[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]) {
        return;
    }
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
        }else{
            [room initMyRoomListData:nil];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [room initMyRoomListData:nil];
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
            [firstView hiddenSearchBarKeyBoard];

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


-(void)didClickMyRoomWithView:(MyRoomView*)view dic:(NSDictionary *)dic
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];

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
    itemInfo.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    [self.navigationController pushViewController:itemInfo animated:YES];

}

-(void)didClickCreateTeamWithView:(MyRoomView *)view
{
    [self joumpToCreatePage];
}

-(void)joumpToCreatePage{
    NSArray *arr =[room.listDict objectForKey:@"OwnedRooms"];
    if (arr.count==2) {
        [self showAlertViewWithTitle:@"提示" message:@"最多只能创建两个队伍" buttonTitle:@"确定"];
        return;
    }
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    CreateTeamController *cretItm =[[CreateTeamController alloc]init];
    cretItm.selectRoleDict = firstView. selectCharacter;
    cretItm.selectTypeDict = firstView.selectType;
    [self.navigationController pushViewController: cretItm animated:YES];
}

#pragma mark --解散队伍
-(void)dissTeam:(MyRoomView *)view dic:(NSDictionary *)dic{
    hud.labelText = @"解散中...";
    [hud show:YES];
    [[ItemManager singleton] dissoTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] reSuccess:^(id responseObject) {
        [hud hide: YES];
        [self showMessageWindowWithContent:@"解散成功" imageType:0];


        [firstView initSearchConditions];

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

#pragma mark -- 删除角色
-(void)roleRemove:(NSNotification*)notification{
    NSDictionary * msg = notification.userInfo;
    NSString * characterid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"characterId")];
    [room roleRemove:characterid];
    [firstView removeCharacterDetail:characterid];
}

-(void)updateRoomState:(NSNotification*)notification{
    NSDictionary * dic = notification.userInfo;
    NSString * gamdid = KISDictionaryHaveKey(dic, @"gameid");
    NSString * roomId = KISDictionaryHaveKey(dic, @"roomId");
    [firstView updateRoomList:roomId GameId:gamdid];
}

-(void)didClickSuccessWithText:(NSString *)text tag:(NSInteger)tag
{
    [self showMessageWindowWithContent:text imageType:tag];
}

@end
