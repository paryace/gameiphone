//
//  NewInvitationViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-8.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewInvitationViewController.h"
#import "EGOImageView.h"
#import "ImgCollCell.h"
#import "LocationManager.h"
#import "MJRefresh.h"
#import "TestViewController.h"
@interface NewInvitationViewController ()
{
    UIScrollView     *  m_mainScroll;
    UITableView      *  m_rTableView;
    UITableView      *  m_gTableView;
    UITableView      *  m_bTableView;
    NSMutableArray   *  m_rArray;
    NSMutableArray   *  m_gArray;
    NSMutableArray   *  m_bArray;
    NSMutableArray   *  addMemArray;
    
    UIButton         *  m_button;
    UICollectionView *  m_customCollView;
    UICollectionViewFlowLayout   *  m_layout;
    UIView           *  m_listView;
    
    NSInteger           m_nearByCount;
    NSInteger           m_sameRealmCount;
    BOOL                isFirstNearBy;
    BOOL                isFirstSameRealm;
    MJRefreshFooterView *m_foot1;
    MJRefreshFooterView *m_foot2;

    AddGroupMemberCell*cell1;
    
    UIButton *m_btn1;
    UIButton *m_btn2;
    UIButton *m_btn3;
    
    NSInteger      m_tabTag;
    UIButton * chooseAllBtn;
    
    NSString *m_realmStr;
    
}
@end

@implementation NewInvitationViewController

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
    [self setTopViewWithTitle:@"添加成员" withBackButton:YES];
    
    chooseAllBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseAllBtn.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [chooseAllBtn setImage:KUIImage(@"choose_all_normal") forState:UIControlStateNormal];
    [chooseAllBtn setImage:KUIImage(@"choose_no_normal") forState:UIControlStateSelected];
    [self.view addSubview:chooseAllBtn];
    [chooseAllBtn addTarget:self action:@selector(didClickChooseAll:) forControlEvents:UIControlEventTouchUpInside];

    
    m_rArray = [NSMutableArray array];
    m_gArray = [NSMutableArray array];
    m_bArray = [NSMutableArray array];
    m_nearByCount =0;
    m_sameRealmCount =0;
    isFirstNearBy = YES;
    isFirstSameRealm = YES;
    m_tabTag = 1;
    addMemArray = [NSMutableArray array];
    
[addMemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil]];
    
    [self buildTopView];
    [self buildMainView];
    [self buildlistView];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"获取中...";
    
    
    [self getInfo];
    [self addFootView1];
    [self addFootView2];
    // Do any additional setup after loading the view.
}

-(void)buildTopView
{

    m_btn1 = [self buildButtonWithFrame:CGRectMake(0, startX, kScreenWidth/3, 56) img1:@"seg1_normal" img2:@"seg1_click"];
    m_btn1.tag =100001;
    m_btn1.selected = YES;
    [m_btn1 addTarget:self action:@selector(qiehuantype:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_btn1];
    m_btn2 = [self buildButtonWithFrame:CGRectMake(kScreenWidth/3, startX, kScreenWidth/3, 56) img1:@"seg2_normal" img2:@"seg2_click"];
    m_btn2.tag = 100002;
    [m_btn2 addTarget:self action:@selector(qiehuantype:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_btn2];

    
    m_btn3 = [self buildButtonWithFrame:CGRectMake(kScreenWidth/3*2, startX, kScreenWidth/3, 56) img1:@"seg3_normal" img2:@"seg3_click"];
    m_btn3.tag = 100003;
    [m_btn3 addTarget:self action:@selector(qiehuantype:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_btn3];

}

-(UIButton *)buildButtonWithFrame:(CGRect)frame img1:(NSString *)img1 img2:(NSString*)img2
{
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    [button setImage:KUIImage(img1) forState:UIControlStateNormal];
    [button setImage:KUIImage(img2) forState:UIControlStateSelected];
    return button;
}

-(void)buildlistView
{
    m_listView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-50-(KISHighVersion_7?0:20), 320, 40)];
    m_listView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    [self.view addSubview:m_listView];
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 15;
    m_layout.minimumLineSpacing = 5;
    m_layout.itemSize = CGSizeMake(34, 34);
    [m_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    m_customCollView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 5, 240, 40) collectionViewLayout:m_layout];
    [m_customCollView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_customCollView.delegate = self;
    m_customCollView.dataSource = self;
    m_customCollView.backgroundColor = [UIColor clearColor];
    [m_listView addSubview:m_customCollView];
    
    m_button = [[UIButton alloc]initWithFrame:CGRectMake(260, 10, 55, 25)];
    [m_button setBackgroundImage:KUIImage(@"addmembers_ok") forState:UIControlStateNormal];
    [m_button setTitle:@"确定" forState:UIControlStateNormal];
    m_button.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [m_button addTarget:self action:@selector(addMembers:) forControlEvents:UIControlEventTouchUpInside];
    [m_listView addSubview:m_button];
}

-(void)DetectNetwork
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        [hud hide:YES];
        [self showMessageWithContent:@"请求数据失败，请检查网络" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
}

-(void)didClickChooseAll:(UIButton *)sender
{
    NSDictionary *customDic = [NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil];
    switch (m_tabTag) {
        case 1:
            if (sender.selected) {
                sender.selected = NO;
                for (NSMutableDictionary *dic in m_rArray) {
                    [dic setObject:@"1" forKey:@"choose"];
                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];
                }
                

            }else{
                sender.selected = YES;
                for (NSMutableDictionary *dic in m_rArray) {
                    [dic setObject:@"2" forKey:@"choose"];

                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if ([addMemArray containsObject:customDic]) {
                    [addMemArray removeObject:customDic];
                }
                [addMemArray addObjectsFromArray:m_rArray];
                [addMemArray addObject:customDic];
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];            }
                

            }
            
            [m_rTableView reloadData];


            
            break;
        case 2:
            if (sender.selected) {
                sender.selected = NO;
                for (NSMutableDictionary *dic in m_gArray) {
                    [dic setObject:@"1" forKey:@"choose"];

                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];            }
                

            }else{
                sender.selected = YES;
                for (NSMutableDictionary *dic in m_gArray) {
                    [dic setObject:@"2" forKey:@"choose"];

                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if ([addMemArray containsObject:customDic]) {
                    [addMemArray removeObject:customDic];
                }
                [addMemArray addObjectsFromArray:m_gArray];
                [addMemArray addObject:customDic];

                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];            }
                

            }
            [m_gTableView reloadData];

            break;
        case 3:
            if (sender.selected) {
                sender.selected = NO;
                for (NSMutableDictionary *dic in m_bArray) {
                    [dic setObject:@"1" forKey:@"choose"];

                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];            }
                

            }else{
                sender.selected = YES;
                for (NSMutableDictionary *dic in m_bArray) {
                    [dic setObject:@"2" forKey:@"choose"];

                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if ([addMemArray containsObject:customDic]) {
                    [addMemArray removeObject:customDic];
                }
                [addMemArray addObjectsFromArray:m_bArray];
                [addMemArray addObject:customDic];
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];            }
                

            }
            [m_bTableView reloadData];

            break;
   
        default:
            break;
    }
    [m_customCollView reloadData];
    
}


-(void)qiehuantype:(UIButton *)seg
{
//    UISegmentedControl *segmentedControl = (UISegmentedControl *)seg;
//    NSInteger segment = segmentedControl.selectedSegmentIndex;
    UIButton *button = (UIButton *)seg;
    
    switch (button.tag) {
        case 100001:
            if (button.selected) {
                return;
            }
            m_btn1.selected =YES;
            m_btn2.selected = NO;
            m_btn3.selected = NO;
            chooseAllBtn.selected = NO;
            m_tabTag = 1;
            m_mainScroll.contentOffset = CGPointMake(0, 0);
            
            break;
        case 100002:
            if (button.selected) {
                return;
            }
            m_btn1.selected =NO;
            m_btn2.selected = YES;
            m_btn3.selected = NO;
            chooseAllBtn.selected = NO;
            m_tabTag = 2;
            m_mainScroll.contentOffset = CGPointMake(320, 0);
            if (isFirstNearBy) {
                [self DetectNetwork];
                [hud show:YES];

                [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
                    isFirstNearBy = NO;
                    [[TempData sharedInstance] setLat:lat Lon:lon];
                    [self getMembersFromNetWithMethod:@"293"];
                } Failure:^{
                    [hud hide:YES];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位失败，请确认设置->隐私->定位服务中陌游的按钮为打开状态" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
                        [alert show];
                }
                 ];
              }
            
            NSLog(@"222222");
            break;
        case 100003:
            if (button.selected) {
                return;
            }
            m_btn1.selected =NO;
            m_btn2.selected = NO;
            m_btn3.selected = YES;
            chooseAllBtn.selected = NO;
            m_tabTag =3;
            m_mainScroll.contentOffset = CGPointMake(640, 0);
            if (isFirstSameRealm) {
                [self getMembersFromNetWithMethod:@"294"];
            }
            NSLog(@"333333");
            break;
    
        default:
            break;
    }
}

-(void)buildMainView
{
    m_mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, startX+56, kScreenWidth, kScreenHeigth-startX-96)];
    m_mainScroll.scrollEnabled = NO;
    m_mainScroll.contentSize  = CGSizeMake(960, 0);
    [self.view addSubview:m_mainScroll];
    
    m_rTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeigth-startX-96)];
    m_rTableView.delegate = self;
    m_rTableView.dataSource =self;
    [m_mainScroll addSubview:m_rTableView];
    
    m_gTableView = [[UITableView alloc]initWithFrame:CGRectMake(kScreenWidth,0, kScreenWidth, kScreenHeigth-startX-96)];
    m_gTableView.delegate = self;
    m_gTableView.dataSource =self;
    [m_mainScroll addSubview:m_gTableView];
    
    m_bTableView = [[UITableView alloc]initWithFrame:CGRectMake(kScreenWidth*2,0,  kScreenWidth, kScreenHeigth-startX-96)];
    m_bTableView.delegate = self;
    m_bTableView.dataSource =self;
    [m_mainScroll addSubview:m_bTableView];
    
}
-(void)getMembersFromNetWithMethod:(NSString *)method
{
    
    
    [hud show:YES];
    
    [self DetectNetwork];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    if ([method isEqualToString:@"293"]) {
        [paramDict setObject:@(m_nearByCount) forKey:@"firstResult"];
        [paramDict setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
        [paramDict setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    }
    else if([method isEqualToString:@"294"])
    {
        [paramDict setObject:@(m_sameRealmCount) forKey:@"firstResult"];
    }
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if ([method isEqualToString:@"293"])
            {
                isFirstNearBy = NO;
                if (m_nearByCount==0) {
                    [m_gArray removeAllObjects];
                    [m_gArray addObjectsFromArray:responseObject];
                }else{
                    [m_gArray addObjectsFromArray:responseObject];
                }
                
                for (int i =0 ;i <m_gArray.count;i++) {
                    NSMutableDictionary *dic = [m_gArray objectAtIndex:i];
                    [dic setObject:[NSString stringWithFormat:@"%d",i] forKey:@"row"];
                }
                
                m_nearByCount+=20;
                [m_gTableView reloadData];
                [m_foot1 endRefreshing];
                [m_foot2 endRefreshing];

            }
            else if ([method isEqualToString:@"294"])
            {
                isFirstSameRealm = NO;
                if (m_sameRealmCount==0) {
                    
                    NSArray *arr = responseObject;
                    if (arr.count>0) {
                        m_realmStr = [[responseObject objectAtIndex:0]objectForKey:@"groupRealm"];
                    }else{
                        m_realmStr = @" ";
                    }

                    [m_bArray removeAllObjects];
                    [m_bArray addObjectsFromArray:responseObject];
                }else{
                    [m_bArray addObjectsFromArray:responseObject];
                }
                for (int i =0 ;i <m_bArray.count;i++) {
                    NSMutableDictionary *dic = [m_bArray objectAtIndex:i];
                    [dic setObject:[NSString stringWithFormat:@"%d",i] forKey:@"row"];
                }

                m_sameRealmCount+=20;
                [m_bTableView reloadData];
                [m_foot1 endRefreshing];
                [m_foot2 endRefreshing];

            }
        }

    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
                alert.tag = 789;
                [alert show];
            }
        }
        [m_foot1 endRefreshing];
        [m_foot2 endRefreshing];
    }];
}


-(void)getInfo
{
    hud.labelText = @"获取中...";
    //    [hud showAnimated:YES whileExecutingBlock:^{
    NSMutableDictionary *userinfo=[DataStoreManager  newQuerySections:@"1" ShipType2:@"2"];
    
    
    
    NSMutableDictionary* result = [userinfo objectForKey:@"userList"];
    NSMutableArray* keys = [userinfo objectForKey:@"nameKey"];
    
    for (int i =0; i<keys.count; i++) {
        NSArray *array = [result objectForKey:keys[i]];
        for (NSMutableDictionary *dic in array) {
            [dic setValue:@"1" forKey:@"choose"];
            [dic setValue:@"friends" forKeyPath:@"tabType"];
            [dic setObject:[NSString stringWithFormat:@"%d",i] forKey:@"row"];
        }
        [m_rArray addObjectsFromArray:array];
    }
    [m_rTableView reloadData];
}




-(void)addMembers:(id)sender
{
    if (addMemArray.count>1) {
        
        NSMutableArray *customArr = [NSMutableArray arrayWithArray:addMemArray];
        [customArr removeLastObject];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic  in customArr) {
            
            NSString *userid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
            
            if (![arr containsObject:userid]) {
                [arr addObject:userid];
            }
        }
        
        [self updataInfoWithId:[self getImageIdsStr:arr]];
    }

}

-(NSString*)getImageIdsStr:(NSArray*)imageIdArray
{
    NSString* headImgStr = @"";
    for (int i = 0;i<imageIdArray.count;i++) {
        NSString * temp1 = [imageIdArray objectAtIndex:i];
        headImgStr = [headImgStr stringByAppendingFormat:@"%@,",temp1];
    }
    return headImgStr;
}
-(void)updataInfoWithId:(NSString *)str
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.groupId forKey:@"groupId"];
    [paramDict setObject:str forKey:@"userids"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"258" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView * alertView_1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView_1 show];
            }
        }
        [hud hide:YES];
    }];
    
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView ==m_bTableView) {
        return 30;
    }else{
        return 0;
    }
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == m_bTableView) {
        return m_realmStr?m_realmStr:@"";
    }else{
        return nil;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView ==m_rTableView)
    {
        return m_rArray.count;
    }
    else if (tableView ==m_gTableView)
    {
        return m_gArray.count;
    }
    else if (tableView ==m_bTableView)
    {
        return m_bArray.count;
    }else{
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *indefine = @"cell";
    AddGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:indefine];
    if (!cell) {
        cell = [[AddGroupMemberCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefine];
    }
    
    cell.tag = 100+indexPath.row;
    cell.myDelegate = self;
    
    NSDictionary * tempDict ;
    if (tableView ==m_rTableView)
    {
        tempDict = m_rArray[indexPath.row];
        cell.disLabel.hidden = YES;
    }
    else if (tableView ==m_gTableView)
    {
        cell.nameLabel.frame = CGRectMake(60, 10, 200, 20);
        cell.disLabel.frame = CGRectMake(60, 30, 200, 20);
        tempDict = m_gArray[indexPath.row];
        cell.disLabel.hidden = NO;
        NSString *distance = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"distance")];
        double dis = [distance doubleValue];
        double gongLi = dis/1000;
        
        NSString* allStr = @"";
        if (gongLi < 0 || gongLi == 9999) {//距离-1时 存的9999000
            allStr = @"未知";
        }
        else
            allStr = [allStr stringByAppendingFormat:@"%.2fkm", gongLi];
        cell.disLabel .text = allStr;
        
    }
    else if (tableView ==m_bTableView)
    {
        tempDict = m_bArray[indexPath.row];
        cell.disLabel.hidden = YES;
    }
    
    
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    
    cell.headImg.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImg.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"choose")]intValue]==1) {
        cell.chooseImg.image = KUIImage(@"unchoose");
    }else{
        cell.chooseImg.image = KUIImage(@"choose");
    }
    cell.nameLabel.text = nickName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddGroupMemberCell*cell;
    NSMutableDictionary * tempDict;
    if (tableView ==m_rTableView)
    {
        cell =(AddGroupMemberCell*)[m_rTableView cellForRowAtIndexPath:indexPath];
        tempDict = m_rArray[indexPath.row];
    }
    else if (tableView ==m_gTableView)
    {
        cell =(AddGroupMemberCell*)[m_gTableView cellForRowAtIndexPath:indexPath];
        tempDict = m_gArray[indexPath.row];
    }
    else if (tableView ==m_bTableView)
    {
        cell =(AddGroupMemberCell*)[m_bTableView cellForRowAtIndexPath:indexPath];
        tempDict = m_bArray[indexPath.row];
    }
    
    if (cell.chooseImg.image ==KUIImage(@"unchoose")) {
        cell.chooseImg.image = KUIImage(@"choose");
        NSDictionary *dic = tempDict;
        [tempDict setObject:@"2" forKey:@"choose"];
//        [dic setValue:@(indexPath.row) forKey:@"row"];
        [addMemArray insertObject:dic atIndex:addMemArray.count-1];
        
    }else{
        cell.chooseImg.image =KUIImage(@"unchoose");
        NSDictionary *dic = tempDict;
        [tempDict setObject:@"1" forKey:@"choose"];
        
//        [dic setValue:@(indexPath.row) forKey:@"row"];
        
        [addMemArray removeObject:dic];
    }
    [m_customCollView reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];
    int count = addMemArray.count;
    NSString *title = [NSString stringWithFormat:@"确定(%d)",count-1];
    [m_button setTitle:title forState:UIControlStateNormal];
    
    
}

#pragma mark ---collectionview delegate  datasourse

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return addMemArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    if (indexPath.row ==addMemArray.count-1) {
        cell.imageView.placeholderImage = KUIImage(imageids);
        cell.imageView.imageURL = nil;
    }else{
        cell.imageView.placeholderImage = [UIImage imageNamed:headplaceholderImage];
        cell.imageView.imageURL=[ImageService getImageStr:imageids Width:80];
    }
    return cell;
}

-(void)enterMembersInfoPageWithCell:(AddGroupMemberCell*)cell
{
    NSDictionary * tempDict =[NSDictionary dictionary];
    switch (m_tabTag) {
        case 1:
            tempDict = m_rArray[cell.tag-100];
            break;
        case 2:
            tempDict = m_gArray[cell.tag-100];
            break;
        case 3:
            tempDict = m_bArray[cell.tag-100];
            break;
   
        default:
            break;
    }
    TestViewController *test =[[ TestViewController alloc]init];
    test.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"userid")];
    test.nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"nickname")];
    [self.navigationController pushViewController:test animated:YES];
}




-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==addMemArray.count-1) {
        return;
    }
    
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    
    
    int row = [KISDictionaryHaveKey(tempDict, @"row")intValue];
    
    NSString *tabCut = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"tabType")];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"row")]intValue] inSection:0];

    
    NSMutableDictionary *dic;
    
    if ([tabCut isEqualToString:@"friends"])
    {
        dic = [m_rArray objectAtIndex:row];
        cell1 = (AddGroupMemberCell*)[m_rTableView cellForRowAtIndexPath:path];

    }else if ([tabCut isEqualToString:@"location"])
    {
        dic = [m_gArray objectAtIndex:row];
        cell1 = (AddGroupMemberCell*)[m_gTableView cellForRowAtIndexPath:path];
  
    }else if ([tabCut isEqualToString:@"realm"])
    {
        dic = [m_bArray objectAtIndex:row];
        cell1 = (AddGroupMemberCell*)[m_bTableView cellForRowAtIndexPath:path];
    }
    
    [dic setObject:@"1" forKey:@"choose"];
    cell1.chooseImg.image = KUIImage(@"unchoose");
    
    [addMemArray removeObject:tempDict];
    [m_customCollView reloadData];
    int count = addMemArray.count-1;
    NSString *title;
    if (count==0) {
        title = [NSString stringWithFormat:@"确定"];
    }else{
        title = [NSString stringWithFormat:@"确定(%d)",addMemArray.count-1];
    }
    [m_button setTitle:title forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];
    
}

//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";
    }
}
//性别图标
-(NSString*)genderImage:(NSString*)gender
{
    if ([gender intValue]==0)
    {
        return @"gender_boy";
    }else
    {
        return @"gender_girl";
    }
}
//添加上拉加载更多
-(void)addFootView1
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_gTableView;
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getMembersFromNetWithMethod:@"293"];
    };
    m_foot1 = footer;
}
-(void)addFootView2
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_bTableView;
    
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getMembersFromNetWithMethod:@"294"];
    };
    m_foot2 = footer;
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
