//
//  NewSearchGroupController.m
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewSearchGroupController.h"
#import "GroupInformationViewController.h"
#import "MJRefresh.h"
#import "LocationManager.h"
#import "AddGroupViewController.h"
#import "SearchGroupViewController.h"
#import "MySearchBar.h"


@interface NewSearchGroupController ()
{
    UITableView * m_GroupTableView;
    MySearchBar * mSearchBar;
    UIView * baseBgView;
    
    NSMutableArray * m_groupArray;
    NSInteger currentPageCount;
    
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    AppDelegate *app;
    UIAlertView *m_alertView;
    MenuTableView * menuTableView;
}
@end

@implementation NewSearchGroupController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self setTopViewWithTitle:@"推荐搜索" withBackButton:YES];
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(didClickCreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    
    mSearchBar = [[MySearchBar alloc]initWithFrame:CGRectMake(0, startX,320, 44)];
    [mSearchBar setPlaceholder:@"搜索群名或群号"];
    mSearchBar.showsCancelButton=NO;
    mSearchBar.delegate = self;
    //<---背景图片
    [self.view addSubview:mSearchBar];
    
    baseBgView = [[UIView alloc] initWithFrame:CGRectMake(0, startX+44, 320, self.view.frame.size.height-startX-44)];
    baseBgView.backgroundColor = [UIColor blackColor];
    baseBgView.alpha = 0.5;
    baseBgView.hidden = YES;
    
    UIImageView * uiImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, startX+44, 80, self.view.frame.size.height-startX-44)];
    uiImage.image = KUIImage(@"menu_bg");
    [self.view addSubview:uiImage];
    menuTableView = [[MenuTableView alloc] initWithFrame:CGRectMake(0, startX+44, 80, self.view.frame.size.height-startX-44)];
    menuTableView.backgroundColor = [UIColor clearColor];
    menuTableView.isSecion = NO;
    menuTableView.delegate = self;
    [self.view addSubview:menuTableView];
    
    UIView * lineView = [[UIView alloc] initWithFrame:CGRectMake(80, startX+44, 0.5, self.view.frame.size.height-startX-44)];
    lineView.backgroundColor = UIColorFromRGBA(0xf6f6f6, 1);
    [self.view addSubview:lineView];
    
    m_groupArray = [NSMutableArray array];
    m_GroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(80.5, startX+44, 320-80.5, self.view.frame.size.height - startX-44) style:UITableViewStylePlain];
    m_GroupTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    m_GroupTableView.backgroundColor = [UIColor whiteColor];;
    m_GroupTableView.dataSource = self;
    m_GroupTableView.delegate = self;
    [GameCommon setExtraCellLineHidden:m_GroupTableView];
    [self.view addSubview:m_GroupTableView];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [baseBgView addGestureRecognizer:tapGr];
    [self.view addSubview:baseBgView];
    

    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"搜索中...";
    [self.view addSubview:hud];
    [self addheadView];
    [self addFootView];

    
    NSArray *array = [NSArray arrayWithObjects:@{@"tagName":@"热门",@"tagId":@"hot"}, @{@"tagName": @"附近组织",@"tagId":@"nearby"},nil];
    [menuTableView addMenuTagList:array];
    [self getRealmList];
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"gameid", nil];
    [self getCardWithNetWithDic:dic];
}
-(void)viewTapped:(UITapGestureRecognizer*)sender
{
    [self hideBgView];
}

-(void)getRealmList{
    NSMutableArray * tempArray = [NSMutableArray array];
    NSMutableArray * tempRealmStrArray = [NSMutableArray array];
    NSMutableArray *coreArray =  [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    for (NSMutableDictionary * dic in coreArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] isEqualToString:self.gameid]) {
            if (![tempRealmStrArray containsObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")]]) {
                [tempRealmStrArray addObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")]];
                [tempArray addObject:@{@"tagName":[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"simpleRealm")],@"tagId":@"realm"}];
            }
        }
    }
    [menuTableView addMenuTagList:tempArray];
}

#pragma mark --- itemClick
- (void)itemClick:(MenuTableView*)Sender DateDic:(NSMutableDictionary*)dataDic{
    self.tagsId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dataDic, @"tagId")];
    if ([self.tagsId isEqualToString:@"realm"]) {
        self.realmStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dataDic, @"tagName")];
    }
    [self reloadData:NO];
}

-(void)getLocationForNet:(BOOL)isRefre
{
    if (!isRefre) {
        hud.labelText = @"正在定位...";
        [hud show:YES];
    }
    [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
        [[TempData sharedInstance] setLat:lat Lon:lon];
        [self reloadNearByData:isRefre];
    } Failure:^{
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位失败，请确认设置->隐私->定位服务中陌游的按钮为打开状态" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }];
}


#pragma mark ---获取网络请求数据
-(void)getCardWithNetWithDic:(NSMutableDictionary *)paramDict
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"311" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if (responseObject && [responseObject isKindOfClass:[NSArray class]]) {
             [menuTableView addMenuTagList:responseObject];
        }
       
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [self showDialog:error];
    }];
}

-(void)showDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }

}

#pragma mark 表格
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_groupArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 75;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    NewGroupCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewGroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = KUIImage(@"group_icon");
    cell.headImageV.imageURL = [ImageService getImageStr:KISDictionaryHaveKey(cellDic, @"backgroundImg") Width:100];
    cell.nameLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
    NSString * gameId = KISDictionaryHaveKey(cellDic, @"gameid");
    NSString * level = KISDictionaryHaveKey(cellDic, @"level");
    NSString * maxMemberNum = KISDictionaryHaveKey(cellDic, @"maxMemberNum");
    NSString * currentMemberNum = KISDictionaryHaveKey(cellDic, @"currentMemberNum");
    NSString * gameImageId = [GameCommon putoutgameIconWithGameId:gameId];
    cell.gameImageV.image = KUIImage(@"clazz_icon.png");
    cell.gameImageV.imageURL = [ImageService getImageStr:gameImageId Width:100];
    cell.numberLable.text = [NSString stringWithFormat:@"%@%@%@",currentMemberNum,@"/",maxMemberNum];
    cell.levelLable.text = [NSString stringWithFormat:@"%@",level];
    cell.cricleLable.text = KISDictionaryHaveKey(cellDic, @"info");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId = KISDictionaryHaveKey(cellDic, @"groupId");
    [self.navigationController pushViewController:gr animated:YES];
}


//获取群列表
-(void)getGroupListFromNetWithParam:(NSDictionary *)paramDict method:(NSString *)method isRefre:(BOOL)isRefre
{
    if (!isRefre) {
        hud.labelText = @"正在请求...";
        [hud show:YES];
    }
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * groupList = responseObject;
            if (groupList&&groupList.count>0) {
                if (currentPageCount ==0) {
                    [m_groupArray removeAllObjects];
                }
                [m_groupArray addObjectsFromArray:groupList];
                currentPageCount +=20;
                [m_GroupTableView reloadData];
            }else{
                if (currentPageCount ==0) {
                    if (!isRefre) {
                        [m_groupArray removeAllObjects];
                    }
                    [m_GroupTableView reloadData];
                }
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        [self showDialog:error];
    }];
}
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(20, 20);
    header.arrowImage.frame = headerRect;
    header.scrollView = m_GroupTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self reloadData:YES];
    };
    m_header = header;
}
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(20, 20);
    footer.arrowImage.frame = headerRect;
    footer.scrollView = m_GroupTableView;
    
    footer.scrollView = m_GroupTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self reloadData:YES];
    };
    m_footer = footer;
}

-(void)reloadData:(BOOL)isRefre{
    //服务器
    if ([[GameCommon getNewStringWithId:self.tagsId]isEqualToString:@"realm"]) {
        [self reloadRealmData:isRefre];
    }
    //热门
    else if ([[GameCommon getNewStringWithId:self.tagsId]isEqualToString:@"hot"]) {
        [self reloadHotData:isRefre];
    }
    //附近的组织
    else if ([[GameCommon getNewStringWithId:self.tagsId]isEqualToString:@"nearby"]) {
        [self getLocationForNet:isRefre];
    }
    //标签
    else {
        [self reloadTagData:isRefre];
    }
}
//标签
-(void)reloadTagData:(BOOL)isRefre{
    if (!self.tagsId) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        return;
    }
    currentPageCount = 0;
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:self.tagsId forKey:@"tagId"];
    [self getGroupListFromNetWithParam:paramDict method:@"245" isRefre:isRefre];
}
//服务器
-(void)reloadRealmData:(BOOL)isRefre{
    if (!self.tagsId) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        return;
    }
    currentPageCount = 0;
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:self.gameid forKey:@"gameid"];
    [paramDict setObject:self.realmStr forKey:@"gameRealm"];
    [self getGroupListFromNetWithParam:paramDict method:@"243" isRefre:isRefre];
}
//热门群组
-(void)reloadHotData:(BOOL)isRefre{
    if (!self.tagsId) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        return;
    }
    currentPageCount = 0;
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:self.gameid forKey:@"gameid"];
    [self getGroupListFromNetWithParam:paramDict method:@"257" isRefre:isRefre];
}
//附近的组织
-(void)reloadNearByData:(BOOL)isRefre{
    if (!self.tagsId) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        return;
    }
    currentPageCount = 0;
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:self.gameid forKey:@"gameid"];
    [paramDict setObject:@([[TempData sharedInstance] returnLat]) forKey:@"latitude"];
    [paramDict setObject:@([[TempData sharedInstance] returnLon]) forKey:@"longitude"];
    [self getGroupListFromNetWithParam:paramDict method:@"237" isRefre:isRefre];
}

#pragma mark ---创建群
-(void)didClickCreateGroup:(id)sender
{
    AddGroupViewController *addGroupView =[[ AddGroupViewController alloc]init];
    [self.navigationController pushViewController:addGroupView animated:YES];
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc
{
    m_alertView.delegate  =nil;
}

#pragma mark ----取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self hideBgView];
    searchBar.text = @"";
}

#pragma mark ----键盘搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar];
}

#pragma mark ----搜索
- (void)doSearch:(UISearchBar *)searchBar{
    [self hideBgView];
    if ([GameCommon isEmtity:searchBar.text])
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:@"搜索条件不能为空" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];
    groupView.conditiona = searchBar.text;
    groupView.ComeType = SETUP_Search;
    groupView.titleName = @"搜索结果";
    [self.navigationController pushViewController:groupView animated:YES];
    searchBar.text = @"";
}

#pragma mark ----获得焦点
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self showBgView];
    return YES;
}
#pragma mark ----失去焦点
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self hideBgView];
    return YES;
}

-(void)hideBgView{
    [UIView animateWithDuration:0.2 animations:^{
        baseBgView.alpha = 0.5;
        
        baseBgView.alpha = 0;
    }completion:^(BOOL finished) {
       baseBgView.hidden = YES;
    }];

   
    [mSearchBar resignFirstResponder];
    [mSearchBar setShowsCancelButton:NO animated:NO];
}
-(void)showBgView{
    baseBgView.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        baseBgView.alpha = 0;
        
        baseBgView.alpha = 0.5;
    }];
    [mSearchBar setShowsCancelButton:YES animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end