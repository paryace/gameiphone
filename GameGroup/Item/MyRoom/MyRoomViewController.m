//
//  MyRoomViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyRoomViewController.h"
#import "BaseItemCell.h"
#import "ItemInfoViewController.h"
@interface MyRoomViewController ()
{
    UITableView *m_myTableView;
    NSMutableDictionary *m_mainDict;
}
@end

@implementation MyRoomViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"我的队伍" withBackButton:NO];
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [backButton setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];

    m_mainDict = [NSMutableDictionary dictionary];
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:m_myTableView];
    [self.view addSubview:m_myTableView];
    
    [self getMyRoomFromNet];
    // Do any additional setup after loading the view.
}

-(void)back
{
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] popViewControllerAnimated:NO];

}



-(void)getMyRoomFromNet
{
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"272" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_mainDict = [NSMutableDictionary dictionaryWithDictionary:responseObject];
            [m_myTableView reloadData];
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
#pragma mark ----tableview delegate  datasourse
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[m_mainDict allKeys] count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [[m_mainDict objectForKey:@"OwnedRooms"] count];
            break;
        case 1:
            return [[m_mainDict objectForKey:@"joinedRooms"] count];
            break;
     
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    cell.backgroundColor =[ UIColor whiteColor];
    NSDictionary *dic;
    if (indexPath.section ==0) {
        dic = [[m_mainDict objectForKey:@"OwnedRooms"] objectAtIndex:indexPath.row];
    }else{
        dic = [[m_mainDict objectForKey:@"joinedRooms"] objectAtIndex:indexPath.row];
  
    }
    cell.headImg.placeholderImage = KUIImage(@"placeholder");
    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"img")];
    cell.headImg.imageURL =[ImageService getImageStr2:imageids] ;
    
    cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"nickname")];
    cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
    
    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",timeStr];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
    NSDictionary *dic;
    if (indexPath.section ==0) {
        dic = [[m_mainDict objectForKey:@"OwnedRooms"] objectAtIndex:indexPath.row];
    }else{
        dic = [[m_mainDict objectForKey:@"joinedRooms"] objectAtIndex:indexPath.row];
        
    }
    
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"createTeamUser"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    [self.navigationController pushViewController:itemInfo animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section ==0) {
        return @"我创建的队伍";
    }else{
        return @"我加入的队伍";
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
