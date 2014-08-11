//
//  MyFansPageViewController.m
//  GameGroup
//
//  Created by Apple on 14-5-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyFansPageViewController.h"
#import "PersonTableCell.h"
#import "TestViewController.h"
#import "MJRefresh.h"
#import "ImageService.h"

@interface MyFansPageViewController ()
{
    UILabel*        m_titleLabel;
    UITableView * m_myFansTableView;
    NSMutableDictionary*  m_sortTypeDic;
    NSMutableArray * m_otherSortFansArray;
    NSInteger        m_currentPage;
    NSInteger        m_allcurrentPage;
    MJRefreshHeaderView *m_fansheader;
    MJRefreshFooterView *m_fansfooter;
    
}
@end

@implementation MyFansPageViewController

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
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadFansList:) name:kReloadFansKey object:nil];
    
    m_sortTypeDic= [NSMutableDictionary dictionary];
    m_otherSortFansArray = [NSMutableArray array];
    m_currentPage=0;
    m_allcurrentPage =0;
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"粉丝";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    m_myFansTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_myFansTableView.dataSource = self;
    m_myFansTableView.delegate = self;
    [self.view addSubview:m_myFansTableView];
    [GameCommon setExtraCellLineHidden:m_myFansTableView];

    [self addFooter];
    [self addHeader];
    [m_fansheader beginRefreshing];
    [m_fansfooter endRefreshing];
}

- (void)reloadFansList:(NSNotification*)notification
{
    NSString *fansTabIndex=notification.object?notification.object:@"0";
    NSInteger fansInteger=[fansTabIndex intValue];
    if (fansInteger>=0&&fansInteger< m_otherSortFansArray.count) {
        [m_otherSortFansArray removeObjectAtIndex:fansInteger];
        [self refreTitle:[NSString stringWithFormat:@"%d",m_otherSortFansArray.count]];
    }
    [m_myFansTableView reloadData];
}
#pragma mark -粉丝列表 只有距离排序
- (void)getFansBySort
{
    [hud show:YES];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.userId forKey:@"userid"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    [paramDict setObject:@"3" forKey:@"shiptype"];
    [paramDict setObject:[NSString stringWithFormat:@"%d", m_currentPage] forKey:@"pageIndex"];
//    [paramDict setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLat]] forKey:@"latitude"];
//    [paramDict setObject:[NSString stringWithFormat:@"%f",[[TempData sharedInstance] returnLon]] forKey:@"longitude"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"221" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (m_currentPage == 0) {//默认展示存储的
                m_allcurrentPage = [KISDictionaryHaveKey(responseObject, @"totalResults") intValue];
                [self refreFansNum:m_allcurrentPage];
                [self refreTitle:[NSString stringWithFormat:@"%d",m_allcurrentPage]];
                NSMutableArray *fans=KISDictionaryHaveKey(responseObject, @"users");
                m_otherSortFansArray=fans;
                [self endLoad];
            }
            else{
                NSMutableArray *fans=KISDictionaryHaveKey(responseObject, @"users");
                [m_otherSortFansArray addObjectsFromArray:fans];
                [self endLoad];
            }
            m_currentPage ++;//从0开始
            
        }else{
            
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
        [self endLoad];
        
    }];
}
//刷新title
-(void)refreFansNum:(NSInteger)fansInteger
{
    NSString *fansNum=[NSString stringWithFormat: @"%d",fansInteger];
    [[NSUserDefaults standardUserDefaults] setObject:fansNum forKey:[FansCount stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//结束刷新
-(void)endLoad
{
    [m_myFansTableView reloadData];
    [m_fansheader endRefreshing];
    [m_fansfooter endRefreshing];
}

//刷新title
-(void)refreTitle:(NSString*)fansNum
{
    m_titleLabel.text = [[@"粉丝(" stringByAppendingString:fansNum] stringByAppendingString:@")"];
}

-(NSMutableDictionary*)getTitleInfo:(NSDictionary*)titleDic
{
    NSMutableDictionary *titled=[[NSMutableDictionary alloc]init];
    NSString * titleObj = @"";
    NSString * titleObjLevel = @"";
    NSDictionary* titleD = KISDictionaryHaveKey(titleDic, @"title");
    if ([titleD isKindOfClass:[NSDictionary class]]) {
        titleObj = KISDictionaryHaveKey(KISDictionaryHaveKey(titleD, @"titleObj"), @"title");
        titleObjLevel = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleDic, @"rarenum")];
    }
    else
    {
        titleObj = @"暂无头衔";
        titleObjLevel = @"6";
    }
    [titled setObject:titleObj forKey:@"titleName"];
    [titled setObject:titleObjLevel forKey:@"rarenum"];
    return titled;
}

#pragma mark 表格
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_otherSortFansArray count];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    PersonTableCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[PersonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * tempDict;
    
    tempDict = [m_otherSortFansArray objectAtIndex:indexPath.row];
    NSString * gender=KISDictionaryHaveKey(tempDict, @"gender");
    NSString * age=KISDictionaryHaveKey(tempDict, @"age");
    NSString * img = KISDictionaryHaveKey(tempDict, @"img");
    NSString * updateTime=KISDictionaryHaveKey(tempDict, @"updateUserLocationDate");
    NSString * distance= KISDictionaryHaveKey(tempDict, @"distance");
    
    
    
    
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        cell.ageLabel.text = [@"♂ " stringByAppendingString:[GameCommon getNewStringWithId:age]];
        cell.ageLabel.backgroundColor = kColorWithRGB(33, 193, 250, 1.0);
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else
    {
        cell.ageLabel.text = [@"♀ " stringByAppendingString:[GameCommon getNewStringWithId:age]];
        cell.ageLabel.backgroundColor = kColorWithRGB(238, 100, 196, 1.0);
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    
    cell.headImageV.imageURL=[ImageService getImageStr:img Width:80];
    cell.nameLabel.text = [tempDict objectForKey:@"nickname"];
    
    
    NSString *titleName=KISDictionaryHaveKey(tempDict, @"titleName");
    cell.distLabel.text = (titleName==nil||[titleName isEqualToString:@""]) ? @"暂无头衔" : titleName;
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(tempDict, @"rarenum") integerValue]];
    
    cell.timeLabel.text = [GameCommon getTimeAndDistWithTime:[GameCommon getNewStringWithId:updateTime] Dis:[GameCommon getNewStringWithId:distance]];
    
    [cell refreshCell];
    
    NSArray * gameidss=[GameCommon getGameids:KISDictionaryHaveKey(tempDict, @"gameids")];
    [cell setGameIconUIView:gameidss];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    [m_myFansTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * tempDict= [m_otherSortFansArray objectAtIndex:indexPath.row];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    TestViewController *detailVC = [[TestViewController alloc]init];
    detailVC.userId = KISDictionaryHaveKey(tempDict, @"userid");
    detailVC.fansTestRow = indexPath.row;
    detailVC.isFansPage = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    
    footer.scrollView = m_myFansTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        if (m_otherSortFansArray.count<m_allcurrentPage) {
            NSLog(@"加载更多");
            [self getFansBySort];
        }else{
            [m_fansfooter endRefreshing];
        }
    };
    m_fansfooter = footer;
    
}
- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    
    header.scrollView = m_myFansTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currentPage = 0;
        [self getFansBySort];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    m_fansheader = header;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end