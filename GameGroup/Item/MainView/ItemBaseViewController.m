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
@interface ItemBaseViewController ()
{
    UIView *customView;
    FirstView  *firstView;
    MyRoomView  *room;
    UITableView * m_mylistTableView;
    UIImageView *customImageView;
    
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
    
    
    
    
    
    UIImageView* topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44)];
    //    topImageView.image = KUIImage(@"top");
    topImageView.userInteractionEnabled = YES;
    topImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    topImageView.image = KUIImage(@"nav_bg");
    [self.view addSubview:topImageView];
    
    UISegmentedControl *seg = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"主页",@"我的组队", nil]];
    seg.frame = CGRectMake(100, KISHighVersion_7 ? 25 : 5, 120, 34);
    seg.selectedSegmentIndex = 0;

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
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"firstItem"]) {
        customImageView =[[ UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-50-(KISHighVersion_7?0:20))];
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"firstItem"];
        customImageView.image = KUIImage(@"item_test.jpg");
        customImageView.userInteractionEnabled = YES;
        [self.view addSubview:customImageView];
        
        UIButton *enterSearchBtn = [[UIButton alloc]initWithFrame:CGRectMake(80, customImageView.bounds.size.height-200, 160, 44)];
        [enterSearchBtn setTitle:@"去搜索群组" forState:UIControlStateNormal];
        [enterSearchBtn addTarget:self action:@selector(enterSearchTape:) forControlEvents:UIControlEventTouchUpInside];
        [customImageView addSubview:enterSearchBtn];
    }
    
    
}
-(void)refreshMyList:(id)sender
{
    [self getMyRoomFromNet];
}
-(void)getPreferencesWithNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"276" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            firstView.firstDataArray = responseObject;
            [firstView.myTableView reloadData];
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
-(void)enterEditPageWithRow:(NSInteger)row isRow:(BOOL)isrow
{
    if (isrow) {
        [self showMessageWindowWithContent:@"更改搜索条件" imageType:0];
    }else{
        [self showMessageWindowWithContent:@"查看队伍" imageType:0];
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
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
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


-(void)changeView:(UISegmentedControl*)seg
{
//    NSLog(@"%@",self.view.subviews)

    switch (seg.selectedSegmentIndex) {
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
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"user"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    [self.navigationController pushViewController:itemInfo animated:YES];

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
