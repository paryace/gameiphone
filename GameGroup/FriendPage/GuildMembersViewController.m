//
//  GuildMembersViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GuildMembersViewController.h"
#import "TestViewController.h"
#import "MJRefresh.h"
@interface GuildMembersViewController ()
{
    MJRefreshHeaderView *m_head;
    MJRefreshFooterView *m_foot;
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;
    
   int  m_pageCount;
}
@end

@implementation GuildMembersViewController

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
    [self setTopViewWithTitle:self.guildStr withBackButton:YES];
    
    m_dataArray = [NSMutableArray array];
    m_pageCount = 0;
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.rowHeight = 60;
    [self.view addSubview:m_myTableView];
    UIImageView *topImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 176)];
    topImg.image = KUIImage(@"guildTop.jpg");
    m_myTableView.tableHeaderView = topImg;
    
    
    [self addheadView];
    [self addFootView];
    [self getguildMembersFromNet];
    
}
-(void)getguildMembersFromNet
{
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *postDic =[ NSMutableDictionary dictionary];
    [tempDic setObject:self.guildStr forKey:@"organizationName"];
    [tempDic setObject:self.gameidStr forKey:@"gameid"];
    [tempDic setObject:self.realmStr forKey:@"gamerealm"];
    [tempDic setObject:@(m_pageCount) forKey:@"pageIndex"];
    [tempDic setObject:@"20" forKey:@"maxSize"];
    [postDic setObject:tempDic forKey:@""];
    [postDic addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDic setObject:tempDic forKey:@"params"];
    [postDic setObject:@"219" forKey:@"method"];
    [postDic setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDic success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            if (m_pageCount ==0) {
                [m_dataArray removeAllObjects];
                [m_dataArray addObjectsFromArray:responseObject];
            }else{
                [m_dataArray addObjectsFromArray:responseObject];
            }
            
            m_pageCount ++;
            [m_myTableView reloadData];
            [m_head endRefreshing];
            [m_foot endRefreshing];
        }
        } failure:^(AFHTTPRequestOperation *operation, id error) {
                              
        }];

}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    RoleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[RoleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSDictionary *dict = m_dataArray[indexPath.row];
    
    cell.glazzImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dict, @"img")]]];
    
    cell.roleLabel.text =KISDictionaryHaveKey(dict, @"name");
    if ([KISDictionaryHaveKey(dict,@"user")isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dic = KISDictionaryHaveKey(dict, @"user");
        cell.nickNameLabel.text =KISDictionaryHaveKey(dic, @"nickname");
        
        NSString *sex = KISDictionaryHaveKey(dic, @"gender");
        if ([sex isEqualToString:@"1"]) {
            cell.genderImgView.image = KUIImage(@"gender_girl");
            cell.headImgBtn.placeholderImage = KUIImage(@"people_woman");
        }else{
            cell.genderImgView.image = KUIImage(@"gender_boy");
            cell.headImgBtn.placeholderImage = KUIImage(@"people_man");

        }
        cell.headImgBtn.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:[GameCommon getHeardImgId:KISDictionaryHaveKey(dic, @"img")]]];
    }else{
        cell.headImgBtn.imageURL = nil;
        cell.genderImgView.image = KUIImage(@"weibangding");
        cell.headImgBtn.placeholderImage = KUIImage(@"");
        cell.nickNameLabel.text = @"未绑定";
    }

         
    
    /*
    {
        id = 163272;
        img = " ";
        name = Candylol;
        user =             {
            alias = " ";
            gender = 0;
            id = 10110158;
            img = " ";
            nickname = "\U6211\U4e0d\U662f\U6d4b\U8bd5";
        };
    },

    */
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic =m_dataArray[indexPath.row];
    if ([KISDictionaryHaveKey(dic, @"user")isKindOfClass:[NSDictionary class]]) {
        TestViewController *testVC = [[TestViewController alloc]init];
        testVC.nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname")];
        testVC.userId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"id")];
        [self.navigationController pushViewController:testVC animated:YES];
    }
}



//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_pageCount = 0;
        [self getguildMembersFromNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    //  [header beginRefreshing];
    m_head = header;
}

//添加上拉加载更多
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;
    
    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getguildMembersFromNet];
    };
    m_foot = footer;
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
