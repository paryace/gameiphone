//
//  ItemBaseViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ItemBaseViewController.h"
#import "BaseItemCell.h"
#import "CreateItemViewController.h"
#import "ItemInfoViewController.h"
#import "MyRoomViewController.h"
#import "FindItemViewController.h"
#import "PreferenceEditViewController.h"
#import "ItemManager.h"
#import "NewCreateItemViewController.h"
#import "PreferencesMsgManager.h"
@interface ItemBaseViewController ()
{
    UIView *customView;
    FirstView  *firstView;
    MyRoomView  *room;
    UITableView * m_mylistTableView;
    UIImageView *customImageView;
    UISegmentedControl *seg ;
    
}
@end

@implementation ItemBaseViewController

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
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMyList:) name:@"refreshTeamList_wx" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshPreference:) name:@"shuaxinRefreshPreference_wxx" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(replacepreference:) name:@"replacePreference_wx" object:nil];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receiceTeamRecommendMsg:) name:kteamRecommend object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(roleRemove:) name:RoleRemoveNotify object:nil];
    
    UIImageView* topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44)];
    //    topImageView.image = KUIImage(@"top");
    topImageView.userInteractionEnabled = YES;
    topImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    topImageView.image = KUIImage(@"nav_bg");
    [self.view addSubview:topImageView];
    
    seg = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"组队提醒",@"我的组队", nil]];
    seg.frame = CGRectMake(90, KISHighVersion_7 ? 27 : 7, 140, 30);
    seg.selectedSegmentIndex = 0;
    seg.segmentedControlStyle = UISegmentedControlStyleBezeled;
    seg.tintColor = [UIColor whiteColor];
    [seg addTarget:self action:@selector(changeView:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:seg];

    
    customView = [[UIView alloc]initWithFrame:CGRectMake(0, startX, 320, kScreenHeigth-startX-50)];
    customView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:customView];
    
    room = [[MyRoomView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-startX-50)];
//    room.backgroundColor = [UIColor redColor];
    room.myDelegate = self;
    [customView addSubview:room];
    
    
    
    firstView = [[FirstView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-startX-50)];
    firstView.backgroundColor = [UIColor whiteColor];
    firstView.myDelegate = self;
    [customView addSubview:firstView];
    [self getMyRoomFromNet];
    [self getPreferencesWithNet];
//    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"firstItem"]) {
//        customImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-50-(KISHighVersion_7?0:20))];
//        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstItem"];
//        customImageView.image = KUIImage(@"item_test.jpg");
//        customImageView.userInteractionEnabled = YES;
//        [self.view addSubview:customImageView];
//        
//        UIButton *enterSearchBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, customImageView.bounds.size.height-200, 160, 44)];
//        [enterSearchBtn setTitle:@"去搜索群组" forState:UIControlStateNormal];
//        [enterSearchBtn addTarget:self action:@selector(enterSearchTape:) forControlEvents:UIControlEventTouchUpInside];
//        [customImageView addSubview:enterSearchBtn];
//    }
}

-(void)didRoleRomeve:(NSString*)characterId{
    for (NSMutableDictionary * dic in firstView.firstDataArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"characterId")] isEqualToString:[GameCommon getNewStringWithId:characterId]]) {
            [firstView.firstDataArray removeObject:dic];
        }
    }
    [firstView.myTableView reloadData];
    [self displayTabbarNotification];
}



-(NSMutableArray*)detailDataList:(NSMutableArray*)datas{
    NSMutableArray * tempArrayType = [datas mutableCopy];
    for (int i=0; i<tempArrayType.count; i++) {
        NSMutableDictionary * dic = (NSMutableDictionary*)[tempArrayType objectAtIndex:i];
        
         NSMutableDictionary * preDic = [DataStoreManager getPreferenceMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")]];
        NSString *str =[NSString stringWithFormat:@"%d",[[PreferencesMsgManager singleton] getPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(dic, @"preferenceId")]];
        
       [dic setObject:str forKey:@"receiveState"];
       if (preDic) {
           [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"characterName")] forKey:@"characterName"];
           [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"description")] forKey:@"description"];
           [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"msgCount")] forKey:@"msgCount"];
           [dic setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(preDic, @"msgTime")] forKey:@"msgTime"];
           [dic setObject:@"1" forKey:@"haveMsg"];
       }else{
           [dic setObject:@"0" forKey:@"msgCount"];
           [dic setObject:@"1000" forKey:@"msgTime"];
           [dic setObject:@"0" forKey:@"haveMsg"];
       }
    }
    [tempArrayType sortUsingComparator:^NSComparisonResult(__strong id obj1,__strong id obj2){
        return [KISDictionaryHaveKey(obj1, @"msgTime") intValue] < [KISDictionaryHaveKey(obj2, @"msgTime") intValue];
    }];
    return tempArrayType;
}

-(void)viewDidAppear:(BOOL)animated
{
//    NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];

    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"LoignRefreshPreference_wx"];
    if ([str isEqualToString:@"refreshPreference"]) {
//        if ([[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"item_preference_%@",userid]]) {
//           firstView.firstDataArray =  [self detailDataList:[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"item_preference_%@",userid]]];
//            [firstView.myTableView reloadData];
//            [self displayTabbarNotification];
//        }
        [self getPreferencesWithNet];
        [self getMyRoomFromNet];
    }

//    if ([[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"item_myRoom_%@",userid]]) {
//        room.listDict =[NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"item_myRoom_%@",userid]]];
//        [room.myListTableView reloadData];
//    }else{
//        [self getMyRoomFromNet];
//    }
}
//
-(void)displayTabbarNotification
{
    NSInteger msgCount  = [[PreferencesMsgManager singleton]getNoreadMsgCount:firstView.firstDataArray];
    if (msgCount>0) {
        [[Custom_tabbar showTabBar] notificationWithNumber:YES AndTheNumber:msgCount OrDot:NO WithButtonIndex:2];
    }
    else
    {
        [[Custom_tabbar showTabBar] removeNotificatonOfIndex:2];
    }
}

//
-(void)receiceTeamRecommendMsg:(NSNotification*)notification{
    NSDictionary * msg = notification.userInfo;
    [firstView receiveMsg:msg];
    [self displayTabbarNotification];
}

-(void)roleRemove:(NSNotification*)notification{
    NSDictionary * msg = notification.userInfo;
    [self didRoleRomeve:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"characterId")]];
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
-(void)refreshPreference:(id)sender
{
    if (seg.selectedSegmentIndex ==0) {
        
    }else{
    seg.selectedSegmentIndex = 0;
    [self changeView:nil];
    }
    [self getPreferencesWithNet];
}
-(void)replacepreference:(NSNotification*)sender
{
    NSDictionary *dic =sender.userInfo;
    NSMutableDictionary *paramDict =[ NSMutableDictionary dictionary];
    NSMutableDictionary *postDict =[ NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"gameid")] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"preferenceId")] forKey:@"preferenceId"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"289" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self getPreferencesWithNet];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}

-(void)getPreferencesWithNet
{
    NSString *userid = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [[PreferencesMsgManager singleton] getPreferencesWithNet:userid reSuccess:^(id responseObject) {
        [self setList:responseObject];
        firstView.firstDataArray =[self detailDataList:responseObject];
        [firstView.myTableView reloadData];
        [self displayTabbarNotification];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"LoignRefreshPreference_wx"];
    } reError:^(id error) {
        [hud hide:YES];
        [self showAlertDialog:error];
    }];
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


-(void)enterSearchRoomPageWithView:(FirstView *)view
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    FindItemViewController *find = [[FindItemViewController alloc]init];
    [self.navigationController pushViewController:find animated:YES];
}
-(void)enterSearchTape:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    FindItemViewController *find = [[FindItemViewController alloc]init];
    [self.navigationController pushViewController:find animated:YES];
    [customImageView removeFromSuperview];

}
-(void)refreWithRow:(NSInteger)row{
    [self displayTabbarNotification];
}
-(void)enterEditPageWithRow:(NSInteger)row isRow:(BOOL)isrow
{
    
//    if (isrow) {
//        [[Custom_tabbar showTabBar] hideTabBar:YES];
//
//        [self showMessageWindowWithContent:@"更改搜索条件" imageType:0];
//        PreferenceEditViewController *preferec = [[PreferenceEditViewController alloc]init];
//        preferec.mainDict = [firstView.firstDataArray objectAtIndex:row];
//        [self.navigationController pushViewController:preferec animated:YES];
//    }else{
//        [self showMessageWindowWithContent:@"查看队伍" imageType:0];
    
        NSMutableDictionary * didDic = [firstView.firstDataArray objectAtIndex:row];
        [self updateMsg:didDic];
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        FindItemViewController *findView = [[FindItemViewController alloc]init];
        findView.mainDict = [NSDictionary dictionaryWithDictionary:didDic];
        findView.isInitialize = YES;
        [self.navigationController pushViewController:findView animated:YES];
        
//    }
}


-(void)updateMsg:(NSMutableDictionary*)didDic{
    [DataStoreManager updatePreferenceMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(didDic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(didDic, @"preferenceId")] Successcompletion:^(BOOL success, NSError *error) {
        [firstView readMsg:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(didDic, @"createTeamUser"), @"gameid")] PreferenceId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(didDic, @"preferenceId")]];
        [firstView.myTableView reloadData];
        [self displayTabbarNotification];
    }];
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
            room.listDict = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            [room.myListTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        [hud hide:YES];
    }];
    
}


-(void)changeView:(UISegmentedControl*)segment
{
//    NSLog(@"%@",self.view.subviews)

    switch (segment.selectedSegmentIndex) {
        case 0:
            [UIView beginAnimations:@"animation" context:nil];
            [UIView setAnimationDuration:1.0f];
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:customView cache:YES];
           [customView exchangeSubviewAtIndex:1 withSubviewAtIndex:0];
            [UIView commitAnimations];

//            [customView bringSubviewToFront:firstView];
            break;
        case 1:
            [UIView beginAnimations:@"animation1" context:nil];
            [UIView setAnimationDuration:1.0f];
            
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation
 
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
