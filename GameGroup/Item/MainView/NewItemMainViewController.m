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
@interface NewItemMainViewController ()
{
    UIView *customView;
    FirstView  *firstView;
    MyRoomView  *room;
    UITableView * m_mylistTableView;
    UIImageView *customImageView;
    UISegmentedControl *seg ;
    UIButton* sortingBtn;
    MsgNotifityView * dotV;
}
@end

@implementation NewItemMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    if (seg.selectedSegmentIndex==1) {
        [sortingBtn setBackgroundImage:KUIImage(@"team_create") forState:UIControlStateNormal];
    }else{
        [sortingBtn setBackgroundImage:KUIImage(@"team_sorting") forState:UIControlStateNormal];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyList:) name:@"refreshTeamList_wx" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPreference:) name:@"shuaxinRefreshPreference_wxx" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPreferMsgReceive:) name:kNewPreferMsg object:nil];
    
    UIImageView* topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44)];
    //    topImageView.image = KUIImage(@"top");
    topImageView.userInteractionEnabled = YES;
    topImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    topImageView.image = KUIImage(@"nav_bg");
    [self.view addSubview:topImageView];
    
    
    UIImageView *segBgImg = [[UIImageView alloc]initWithImage:KUIImage(@"team_seg_black")];
    segBgImg.frame = CGRectMake(74.5f, KISHighVersion_7 ? 27 : 7, 171, 30);
    [self.view addSubview:segBgImg];
    seg = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"搜索",@"队伍", nil]];
    seg.frame = CGRectMake(74.5f, KISHighVersion_7 ? 27 : 7, 171, 30);
    seg.selectedSegmentIndex = 0;
    
    if (KISHighVersion_7) {
        seg.backgroundColor = [UIColor clearColor];
        //    seg.segmentedControlStyle = UISegmentedControlStyleBezeled;
        seg.tintColor = [UIColor whiteColor];
        
        
        [seg setBackgroundImage:KUIImage(@"team_seg_black") forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [seg setBackgroundImage:KUIImage(@"team_seg_white") forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    }


    [seg addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:seg];
    
    
    sortingBtn = [[UIButton alloc] initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [sortingBtn setBackgroundImage:KUIImage(@"team_sorting") forState:UIControlStateNormal];
    
//    [sortingBtn setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    sortingBtn.backgroundColor = [UIColor clearColor];
    [sortingBtn addTarget:self action:@selector(sortingList:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sortingBtn];

    
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"team_notifation") forState:UIControlStateNormal];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(tishiing:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    
    dotV = [[MsgNotifityView alloc] initWithFrame:CGRectMake(40, KISHighVersion_7 ? 25 : 5, 22, 18)];
    [self.view addSubview:dotV];

    customView = [[UIView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX-50)];
    customView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:customView];
    
    room = [[MyRoomView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-startX-50)];
    room.myDelegate = self;
    [customView addSubview:room];

    firstView = [[FirstView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-startX-50)];
    firstView.backgroundColor = [UIColor whiteColor];
    firstView.myDelegate = self;
    [customView addSubview:firstView];
    [self getMyRoomFromNet];
    [self reloadMsgCount];
    [firstView initSearchConditions];//使用上次的搜索条件

}

-(void)sortingList:(id)sender
{
    if (seg.selectedSegmentIndex ==0) {
        [firstView didClickScreen];//排序
    }else{
        NSArray *arr =[room.listDict objectForKey:@"OwnedRooms"];
        if (arr.count==2) {
            [self showAlertViewWithTitle:@"提示" message:@"您的队伍已达到创建上线" buttonTitle:@"确定"];
            return;
        }
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        NewCreateItemViewController *create =[[NewCreateItemViewController alloc]init];
        [self.navigationController pushViewController: create animated:YES];
    }
}

-(void)tishiing:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    PreferenceViewController *perf = [[PreferenceViewController alloc]init];
    perf.mydelegate =self;
    [self.navigationController pushViewController: perf animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"LoignRefreshPreference_wx"];
    if ([str isEqualToString:@"refreshPreference"]) {
        [self getMyRoomFromNet];
    }
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
    if (seg.selectedSegmentIndex ==1) {
    }else{
        seg.selectedSegmentIndex = 1;
        [self changeView:nil];
    }
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
    NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"272" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:[NSString stringWithFormat:@"item_myRoom_%@",userid]];
            [room initMyRoomListData:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showAlertDialog:error];
    }];
    
}

-(void)changeView:(UISegmentedControl*)segment
{
    switch (segment.selectedSegmentIndex) {
        case 0:
            [UIView beginAnimations:@"animation" context:nil];
            [UIView setAnimationDuration:1.0f];
            [sortingBtn setBackgroundImage:KUIImage(@"team_sorting") forState:UIControlStateNormal];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:customView cache:YES];
            [customView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
            [UIView commitAnimations];
            
            //            [customView bringSubviewToFront:firstView];
            break;
        case 1:
            [UIView beginAnimations:@"animation1" context:nil];
            [UIView setAnimationDuration:1.0f];
            [sortingBtn setBackgroundImage:KUIImage(@"team_create") forState:UIControlStateNormal];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:customView cache:YES];
            [UIView commitAnimations];
            [customView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
            [customView bringSubviewToFront:room];
            
            break;
            
        default:
            break;
    }
    //  交换本视图控制器中2个view位置
    
}


-(void)didClickMyRoomWithView:(MyRoomView*)view dic:(NSDictionary *)dic
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"createTeamUser"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
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
    [[ItemManager singleton] dissoTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] reSuccess:^(id responseObject) {
        [self showMessageWindowWithContent:@"解散成功" imageType:1];
    } reError:^(id error) {
        [self showAlertDialog:error];
    }];
    
}
#pragma mark --退出队伍
-(void)exitTeam:(MyRoomView *)view dic:(NSDictionary *)dic{
    [[ItemManager singleton] exitTeam:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] MemberId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"myMemberId")] reSuccess:^(id responseObject) {
        [self showMessageWindowWithContent:@"退出成功" imageType:1];
    } reError:^(id error) {
        [self showAlertDialog:error];
    }];
}

-(void)didClickTableViewCellEnterNextPageWithController:(UIViewController *)vc
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)enterDetailPage:(NSDictionary*)dic{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"createTeamUser"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    itemInfo.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
    [self.navigationController pushViewController:itemInfo animated:YES];
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
    [self displayTabbarNotification];
}

-(void)didClickSuccessWithText:(NSString *)text tag:(NSInteger)tag
{
    [self showMessageWindowWithContent:text imageType:tag];
}

@end
