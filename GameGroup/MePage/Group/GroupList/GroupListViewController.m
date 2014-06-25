//
//  GroupListViewController.m
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupCell.h"
#import "KKChatController.h"
#import "JoinGroupViewController.h"
#import "GroupInformationViewController.h"
#import "GroupSettingController.h"
#import "MJRefresh.h"

@interface GroupListViewController ()
{
    UITableView * m_GroupTableView;
    NSMutableArray * m_groupArray;
    
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    NSInteger  m_currPageCount;
    
}
@end

@implementation GroupListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getGroupListFromNet:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"群列表" withBackButton:YES];
    m_currPageCount = 0;
    m_groupArray = [NSMutableArray array];

    m_GroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_GroupTableView.dataSource = self;
    m_GroupTableView.delegate = self;
    [GameCommon setExtraCellLineHidden:m_GroupTableView];
    [self.view addSubview:m_GroupTableView];
    
    [self addheadView];
    [self addFootView];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"加载中...";
    [self.view addSubview:hud];
//    [self getGroupList];
    [self getGroupListFromNet:NO];
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
    GroupCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[GroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = KUIImage(@"group_icon");
    cell.headImageV.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(cellDic, @"backgroundImg")];
    cell.nameLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
    NSString * gameId = KISDictionaryHaveKey(cellDic, @"gameid");
    NSString * level = KISDictionaryHaveKey(cellDic, @"level");
    NSString * maxMemberNum = KISDictionaryHaveKey(cellDic, @"maxMemberNum");
    NSString * currentMemberNum = KISDictionaryHaveKey(cellDic, @"currentMemberNum");
    NSString * gameImageId = [GameCommon putoutgameIconWithGameId:gameId];
    cell.gameImageV.image = KUIImage(@"clazz_00.png");
    cell.gameImageV.imageURL = [ImageService getImageUrl4:gameImageId];
    cell.numberLable.text = [NSString stringWithFormat:@"%@%@%@",currentMemberNum,@"/",maxMemberNum];
    cell.levelLable.text = [NSString stringWithFormat:@"%@",level];
    cell.cricleLable.text = KISDictionaryHaveKey(cellDic, @"info");
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
     NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId = KISDictionaryHaveKey(cellDic, @"groupId");
    [self.navigationController pushViewController:gr animated:YES];
}

-(void)getGroupList
{
    m_groupArray = [DataStoreManager queryGroupInfoList];
    [m_GroupTableView reloadData];
}

//获取群列表
-(void)getGroupListFromNet:(BOOL)isRefre
{
    if (!isRefre) {
        [hud show:YES];
    }
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.userId forKey:@"userid"];
    [paramDict setObject:@(m_currPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"259" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * groupList = responseObject;
            if (m_currPageCount == 0) {
                m_groupArray = groupList;
            }
            else{
                [m_groupArray addObjectsFromArray:groupList];
            }
            [m_GroupTableView reloadData];
            
//            for (NSMutableDictionary * groupInfo in responseObject) {
//                [DataStoreManager saveDSGroupList:groupInfo];
//            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        NSLog(@"faile");
    }];
}


#pragma mark ---addRefreshHeadview and refreshFootView
//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_GroupTableView;
    
    header.scrollView = m_GroupTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currPageCount = 0;
        [self getGroupListFromNet:YES];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    m_header = header;
}

//添加上拉加载更多
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_GroupTableView;
    
    footer.scrollView = m_GroupTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currPageCount = m_groupArray.count;
        [self getGroupListFromNet:YES];
    };
    m_footer = footer;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
