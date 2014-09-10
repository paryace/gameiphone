//
//  NewSearchGroupController.m
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewSearchGroupController.h"
#import "GroupCell.h"
#import "GroupInformationViewController.h"
#import "MJRefresh.h"
#import "LocationManager.h"
#import "AddGroupViewController.h"


@interface NewSearchGroupController ()
{
    UITableView * m_GroupTableView;
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
    [self setTopViewWithTitle:self.titleName withBackButton:YES];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(didClickCreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
    
    
    menuTableView = [[MenuTableView alloc] initWithFrame:CGRectMake(0, startX, 100, kScreenHeigth)];
    menuTableView.isSecion = YES;
    menuTableView.delegate = self;
    [self.view addSubview:menuTableView];
    
    m_groupArray = [NSMutableArray array];
    currentPageCount = 0;
    m_GroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(100, startX, 320-100, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_GroupTableView.dataSource = self;
    m_GroupTableView.delegate = self;
    [GameCommon setExtraCellLineHidden:m_GroupTableView];
    [self.view addSubview:m_GroupTableView];

    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"搜索中...";
    [self.view addSubview:hud];
    [self addheadView];
    [self addFootView];

    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"1",@"gameid",@"212259",@"characterId", nil];
    [self getCardWithNetWithDic:dic];
}
#pragma mark --- itemClick
- (void)itemClick:(MenuTableView*)Sender DateDic:(NSMutableDictionary*)dataDic{
    self.tagsId = KISDictionaryHaveKey(dataDic, @"tagId");
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:self.tagsId forKey:@"tagId"];
    [self getGroupListFromNetWithParam:paramDict method:@"245" isRefre:NO];
}

#pragma mark ---获取网络请求数据
-(void)getCardWithNetWithDic:(NSMutableDictionary *)paramDict
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"236" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSMutableArray * sortListArray = KISDictionaryHaveKey(responseObject, @"sortList");
        [menuTableView setMenuTagList:sortListArray DateDic:responseObject];
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
    GroupCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[GroupCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
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
        [hud show:YES];
    }
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * groupList = responseObject;
            
            if (groupList&&groupList.count>0) {
                if (currentPageCount ==0) {
                    m_groupArray = groupList;
                }else{
                    [m_groupArray addObjectsFromArray:groupList];
                }
                currentPageCount +=20;
                [m_GroupTableView reloadData];
            }else{
                if (currentPageCount ==0) {
                    m_alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"查询无结果" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                    [m_alertView show];
                }
            }
            [m_header endRefreshing];
            [m_footer endRefreshing];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];
        [m_header endRefreshing];
        [m_footer endRefreshing];
        
    }];
}
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_GroupTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        currentPageCount =0;
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
        [paramDict setObject:@"20" forKey:@"maxSize"];
        [paramDict setObject:self.tagsId forKey:@"tagId"];
        [self getGroupListFromNetWithParam:paramDict method:@"245" isRefre:YES];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    m_header = header;
}
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
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
        [paramDict setObject:@"20" forKey:@"maxSize"];
        [paramDict setObject:self.tagsId forKey:@"tagId"];
        [self getGroupListFromNetWithParam:paramDict method:@"245" isRefre:YES];
    };
    m_footer = footer;
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end