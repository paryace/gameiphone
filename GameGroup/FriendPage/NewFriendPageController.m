//
//  NewFriendPageController.m
//  GameGroup
//
//  Created by Apple on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewFriendPageController.h"
#import "MJRefreshHeaderView.h"
#import "NewPersonalTableViewCell.h"
#import "MessageAddressViewController.h"
#import "AddContactViewController.h"
#import "FunsOfOtherViewController.h"

@interface NewFriendPageController (){
     UITableView*  m_myTableView;
    MJRefreshHeaderView *m_Friendheader;
}
@property (nonatomic, strong) UIView *topView;
@end

@implementation NewFriendPageController

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
    [self setTopViewWithTitle:@"通讯录" withBackButton:NO];

    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    [self.view addSubview:m_myTableView];
    
    m_myTableView.tableHeaderView = self.topView;
    [self addHeader];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
    [self getFriendListFromNet];
}


- (UIView *)topView{
    
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0,0,320,83);
        _topView.backgroundColor = [UIColor blackColor];
        NSArray *topTitle = @[@"粉丝数量",@"附近的朋友",@"手机通讯录",@"添加好友"];
        for (int i = 0; i < 4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = CGRectMake(i*80, 0, 80, 60);
            [button addTarget:self action:@selector(topBtnAction:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"circleIcon.jpg"]]
                    forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"circleIcon.jpg"]]
                    forState:UIControlStateHighlighted];
            [button setImageEdgeInsets:UIEdgeInsetsMake(1, 1, 1, 1)];
            [_topView addSubview:button];
            
            UILabel *titleLable = [[UILabel alloc] init];
            CGSize textSize =[[topTitle objectAtIndex:i] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
            CGFloat textWidth = textSize.width;
            titleLable.frame=CGRectMake(i*80+((80-textWidth)/2),62, 80 ,20);
            titleLable.font = [UIFont systemFontOfSize:12];
            titleLable.textColor=[UIColor whiteColor];
            titleLable.text=[topTitle objectAtIndex:i];
            
            [_topView addSubview:titleLable];
           
        }
    }
    return _topView;
}

- (void)topBtnAction:(UIButton *)sender{
    NSLog(@"tab-->>%d",sender.tag);
    switch (sender.tag) {
        case 0:
        {
            NSString *userid=[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
            FunsOfOtherViewController *fans = [[FunsOfOtherViewController alloc]init];
            fans.userId = userid;
            [self.navigationController pushViewController:fans animated:YES];
        }
            break;
        case 1:
        {

        }
            break;
        case 2:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            MessageAddressViewController *addVC = [[MessageAddressViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 3:
        {
             [[Custom_tabbar showTabBar] hideTabBar:YES];
            AddContactViewController * addV = [[AddContactViewController alloc] init];
            [self.navigationController pushViewController:addV animated:YES];

        }
            break;
        default:
            break;
    }
}

//返回组的数量
//#pragma mark 表格
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
//   
//}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    NewPersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewPersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }

    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
}
////返回索引的字母
//#pragma mark 索引
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
//{
//
//}
//// 返回索引列表的集合
//- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//
//}


#pragma mark 请求数据
- (void)getFriendListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"212" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [hud hide:YES];
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        NSString *fansNum=[responseObject objectForKey:@"fansnum"];
                        NSLog(@"%@",fansNum);
                        NSDictionary* resultArray = [responseObject objectForKey:@"contacts"];
                        NSLog(@"--->>%@",resultArray);
                        NSArray* keyArr = [resultArray allKeys];
                        for (NSString* key in keyArr) {
                            for (NSMutableDictionary * dict in [resultArray objectForKey:key]) {
                                NSLog(@"%@",dict);
                            }
                        }
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, id error) {
                        [hud hide:YES];
                        [m_Friendheader endRefreshing];
                }];
}


- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [m_Friendheader endRefreshing];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    m_Friendheader = header;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
