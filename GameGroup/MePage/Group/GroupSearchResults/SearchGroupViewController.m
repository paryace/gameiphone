//
//  SearchGroupViewController.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SearchGroupViewController.h"
#import "GroupCell.h"
#import "GroupInformationViewController.h"
#import "MJRefresh.h"
#import "LocationManager.h"

@interface SearchGroupViewController ()
{
    UITableView * m_GroupTableView;
    NSMutableArray * m_groupArray;
    NSInteger currentPageCount;
    
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    AppDelegate *app;
}
@end

@implementation SearchGroupViewController

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
    [self setTopViewWithTitle:@"搜索群列表" withBackButton:YES];
    
    m_groupArray = [NSMutableArray array];
    currentPageCount = 0;
    m_GroupTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.frame.size.height - startX) style:UITableViewStylePlain];
    m_GroupTableView.dataSource = self;
    m_GroupTableView.delegate = self;
    [self.view addSubview:m_GroupTableView];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];

    switch (self.ComeType) {
        case SETUP_Tags:
            [paramDict setObject:self.tagsId forKey:@"tagId"];
            [self getGroupListFromNetWithParam:paramDict method:@"245"];

            break;
        case SETUP_Search:
            [paramDict setObject:self.conditiona forKey:@"param"];
            [self getGroupListFromNetWithParam:paramDict method:@"234"];
            break;
        case SETUP_SAMEREALM:
            [paramDict setObject:self.gameid forKey:@"gameId"];
            [paramDict setObject:self.realmStr forKey:@"gameRealm"];
            [self getGroupListFromNetWithParam:paramDict method:@"243"];

            break;
        case SETUP_NEARBY:
            [self getLocationForNet];

            break;
    
        default:
            break;
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
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSMutableDictionary * cellDic = [m_groupArray objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = KUIImage(@"people_man.png");
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
    cell.levelLable.text = [NSString stringWithFormat:@"%@%@",@"lv.",level];
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


//获取群列表
-(void)getGroupListFromNetWithParam:(NSDictionary *)paramDict method:(NSString *)method
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:method forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray * groupList = responseObject;

            if (currentPageCount ==0) {
                m_groupArray = groupList;
            }else{
                [m_groupArray addObjectsFromArray:groupList];
            }
            currentPageCount +=groupList.count;
            [m_GroupTableView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
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
        
        switch (self.ComeType) {
            case SETUP_Tags:
                [paramDict setObject:self.tagsId forKey:@"tagId"];
                [self getGroupListFromNetWithParam:paramDict method:@"245"];
                
                break;
            case SETUP_Search:
                [paramDict setObject:self.conditiona forKey:@"param"];
                [self getGroupListFromNetWithParam:paramDict method:@"234"];
                break;
            case SETUP_SAMEREALM:
                [paramDict setObject:self.gameid forKey:@"gameId"];
                [paramDict setObject:self.realmStr forKey:@"gameRealm"];
                [self getGroupListFromNetWithParam:paramDict method:@"243"];
                
                break;
            case SETUP_NEARBY:
                [paramDict setObject:@([[TempData sharedInstance] returnLat]) forKey:@"latitude"];
                [paramDict setObject:@([[TempData sharedInstance] returnLon]) forKey:@"longitude"];
                [self getGroupListFromNetWithParam:paramDict method:@"234"];
                
                break;
                
            default:
                break;
        }
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
        
        switch (self.ComeType) {
            case SETUP_Tags:
                [paramDict setObject:self.tagsId forKey:@"tagId"];
                [self getGroupListFromNetWithParam:paramDict method:@"245"];
                
                break;
            case SETUP_Search:
                [paramDict setObject:self.conditiona forKey:@"param"];
                [self getGroupListFromNetWithParam:paramDict method:@"234"];
                break;
            case SETUP_SAMEREALM:
                [paramDict setObject:self.gameid forKey:@"gameId"];
                [paramDict setObject:self.realmStr forKey:@"gameRealm"];
                [self getGroupListFromNetWithParam:paramDict method:@"243"];
                
                break;
            case SETUP_NEARBY:
                
                [paramDict setObject:@([[TempData sharedInstance] returnLat]) forKey:@"latitude"];
                [paramDict setObject:@([[TempData sharedInstance] returnLon]) forKey:@"longitude"];
                [self getGroupListFromNetWithParam:paramDict method:@"234"];
                
                break;
                
            default:
                break;
        }

    };
    m_footer = footer;
}
-(void)getLocationForNet
{
    
//    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
//    [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
//    [paramDict setObject:@"20" forKey:@"maxSize"];
//    
//    [paramDict setObject:@([[TempData sharedInstance] returnLat]) forKey:@"latitude"];
//    [paramDict setObject:@([[TempData sharedInstance] returnLon]) forKey:@"longitude"];
//    [self getGroupListFromNetWithParam:paramDict method:@"237"];

    
        [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
            [[TempData sharedInstance] setLat:lat Lon:lon];
            NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
            [paramDict setObject:@(currentPageCount) forKey:@"firstResult"];
            [paramDict setObject:@"20" forKey:@"maxSize"];
            
            [paramDict setObject:@([[TempData sharedInstance] returnLat]) forKey:@"latitude"];
            [paramDict setObject:@([[TempData sharedInstance] returnLon]) forKey:@"longitude"];
            [self getGroupListFromNetWithParam:paramDict method:@"237"];

        } Failure:^{
            [self showAlertViewWithTitle:@"提示" message:@"定位失败，请确认设置->隐私->定位服务中陌游的按钮为打开状态" buttonTitle:@"确定"];
        }
         ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
