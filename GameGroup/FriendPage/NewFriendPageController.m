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
#import "SearchJSViewController.h"
#import "MessageAddressViewController.h"
#import "AddContactViewController.h"
#import "FunsOfOtherViewController.h"
#import "NearFriendsViewController.h"
#import "TestViewController.h"
#import "AddFriendsViewController.h"
#import "MyFansPageViewController.h"
#import "ImageService.h"
#import "InterestingPerpleViewController.h"
#import "MJRefresh.h"
#import "FriendTopCell.h"
#import "MyGroupCell.h"
#import "MyGroupViewController.h"
#import "FriendFirstCell.h"
#import "MySearchBar.h"

@interface NewFriendPageController (){
    
    UILabel*        m_titleLabel;
    UIImageView* topImageView;
    MJRefreshHeaderView *m_header;
    NSMutableDictionary *resultArray;//数据集合
    NSMutableArray * keyArr;//字母集合
    
    UITableView*  m_myTableView;
    NSString *fansNum;
    NSString *fanstr;
    MySearchBar *m_searchBar;
    SearchResultView * searchResultView;
    UISearchDisplayController * searchController;
    NSMutableArray * m_searchArray;
    NSMutableArray * m_allSearchArray;
    UIActivityIndicatorView *m_loginActivity;
}
@end

@implementation NewFriendPageController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
    //判断是从那个页面的返回
    if (searchResultView.hidden == NO) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
    }else{
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    }
    
    
    if (![[TempData sharedInstance] isHaveLogin]) {
        [[Custom_tabbar showTabBar] when_tabbar_is_selected:0];
        return;
    }
    if (![[NSUserDefaults standardUserDefaults]objectForKey:isFirstOpen]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isFirstOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self getFriendListFromNet];
    }
}
- (void)viewDidAppear:(BOOL)animated
{
     [super viewDidAppear:YES];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *hideImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 20 : 0)];
    hideImage.userInteractionEnabled = YES;
    hideImage.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    hideImage.image = KUIImage(@"nav_bg");
    [self.view addSubview:hideImage];
    
    
    topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44)];
    topImageView.userInteractionEnabled = YES;
    topImageView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
    topImageView.image = KUIImage(@"nav_bg");
    [self.view addSubview:topImageView];
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, KISHighVersion_7 ? 20 : 0, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [topImageView addSubview:m_titleLabel];
    UIButton *addFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [addFriendBtn setBackgroundImage:KUIImage(@"addPerson") forState:UIControlStateNormal];
    [addFriendBtn setBackgroundImage:KUIImage(@"addPerson2") forState:UIControlStateHighlighted];
    [addFriendBtn setBackgroundImage:KUIImage(@"addPerson2") forState:UIControlStateSelected];
    addFriendBtn.backgroundColor = [UIColor clearColor];
    [addFriendBtn addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
    [topImageView addSubview:addFriendBtn];

    self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContentList:) name:kReloadContentKey object:nil];
    resultArray =[NSMutableDictionary dictionary];
    m_allSearchArray = [NSMutableArray array];
    keyArr=[NSMutableArray array];
    m_searchArray = [NSMutableArray array];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    m_myTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    if(KISHighVersion_7){
        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    m_myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    m_myTableView.sectionIndexColor = UIColorFromRGBA(0xbcbcbc, 1);
        
    [self.view addSubview:m_myTableView];
    self.view.backgroundColor=[UIColor blackColor];
    
    UIButton *searchV = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    searchV.backgroundColor = [UIColor clearColor];
    [searchV addTarget:self action:@selector(searchResult:) forControlEvents:UIControlEventTouchUpInside];
    [topImageView addSubview:searchV];
    //初始化搜索条
    m_searchBar = [[MySearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [m_searchBar setPlaceholder:@"关键字搜索"];
    m_searchBar.delegate = self;
    m_searchBar.showsCancelButton=NO;
    [m_searchBar sizeToFit];
    [m_searchBar addSubview:searchV];
    m_myTableView.tableHeaderView = m_searchBar;
    
    searchResultView = [[SearchResultView alloc] initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-(KISHighVersion_7 ? 20 : 0))];
    searchResultView.hidden = YES;
    searchResultView.delegate = self;
    [self.view addSubview:searchResultView];
    

   
    [self getFriendDateFromDataSore];
    [self addheadView];
}

-(void)addFriends:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    AddFriendsViewController * addV = [[AddFriendsViewController alloc] init];
    [self.navigationController pushViewController:addV animated:YES];

}
-(void)searchResult:(id)sender{
    [searchResultView showSelf];
    [self showSearchResultView];
}
#pragma mark 刷新表格
- (void)reloadContentList:(NSNotification*)notification
{
    [self getFriendDateFromDataSore];
}

- (void)topBtnAction:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            NSString *userid=[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
            MyFansPageViewController *fans = [[MyFansPageViewController alloc]init];
            fans.userId = userid;
            [self.navigationController pushViewController:fans animated:YES];
        }
            break;
        case 1:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            NearFriendsViewController *addVC = [[NearFriendsViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 2:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            InterestingPerpleViewController *addVC = [[InterestingPerpleViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 3:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            AddFriendsViewController * addV = [[AddFriendsViewController alloc] init];
            [self.navigationController pushViewController:addV animated:YES];

        }
            break;
        default:
            break;
    }
}
//返回组的数量
#pragma mark 表格
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView ==searchController.searchResultsTableView) {
        return 1;
    }else{
    return  keyArr.count;
    }
}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView ==searchController.searchResultsTableView) {
        return m_searchArray.count;
    }else{
    if (section==0) {
        return 3;
    }
    if (keyArr.count>section) {
        return [[resultArray objectForKey:[keyArr objectAtIndex:section]] count];
    }
    return 1;
    }
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 56;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&tableView ==m_myTableView) {
        static NSString * stringCellTop = @"cellTop";
        FriendFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:stringCellTop];
        if (!cell) {
            cell = [[FriendFirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCellTop];
        }
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row ==0) {
            cell.headImageView.image = KUIImage(@"search_role");
            cell.titleLabel.text = @"查找游戏角色";
        }else if(indexPath.row ==1){
            cell.headImageView.image = KUIImage(@"my_team_friend");
            cell.titleLabel.text = @"我的组织";
        }else{
            cell.headImageView.image = KUIImage(@"iphone_address");
            cell.titleLabel.text = @"手机通讯录";
 
        }
        return cell;
    }
    
    static NSString * stringCell3 = @"cell";
    NewPersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewPersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSDictionary * tempDict;
    if (tableView ==searchController.searchResultsTableView) {
        tempDict =[m_searchArray objectAtIndex:indexPath.row];
    }else{
    if (resultArray.count==0||keyArr.count==0) {
        return nil;
    }
    
    tempDict =[[resultArray objectForKey:[keyArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    }
    NSString *str = [GameCommon getNewStringWithId:[tempDict objectForKey:@"shiptype"]];
    if ([str isEqualToString:@"1"]||[str isEqualToString:@"2"]) {
        
    }else{
        NSString *strr= [tempDict objectForKey:@"nickname"];
        NSString * userid  = KISDictionaryHaveKey(tempDict, @"userid");
        NSString *tit = [NSString stringWithFormat:@"昵称为%@ userid=%@出现了",strr,userid];
        [self showAlertViewWithTitle:@"提示" message:tit buttonTitle:@"确定"];
    }
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.headImageV.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageV.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.sexImg.image =KUIImage(genderimage);
    
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    cell.nameLabel.text = nickName;
    
    NSString *titleName=KISDictionaryHaveKey(tempDict, @"titleName");
    cell.distLabel.text = (titleName==nil||[titleName isEqualToString:@""]) ? @"暂无头衔" : titleName;
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(tempDict, @"rarenum") integerValue]];
    CGSize nameSize = [cell.nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.nameLabel.frame = CGRectMake(55, 5, nameSize.width + 5, 20);
    cell.sexImg.frame = CGRectMake(55 + nameSize.width, 5, 20, 20);
    NSArray * gameids=[GameCommon getGameids:KISDictionaryHaveKey(tempDict, @"gameids")];
    [cell setGameIconUIView:gameids];

    return cell;
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
//点击Table进入个人详情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    if (tableView == searchController.searchResultsTableView) {
        NSDictionary * tempDict =[m_searchArray objectAtIndex:indexPath.row];
        TestViewController *detailVC = [[TestViewController alloc]init];
        detailVC.userId = KISDictionaryHaveKey(tempDict, @"userid");
        [self.navigationController pushViewController:detailVC animated:YES];
        return;
    }

    if (indexPath.section==0) {
        if (indexPath.row ==0) {
            SearchJSViewController *search_role = [[SearchJSViewController alloc]init];
            [self.navigationController pushViewController:search_role animated:YES];
        }else if(indexPath.row==1){
            MyGroupViewController * my_group = [[MyGroupViewController alloc]init];
            [self.navigationController pushViewController:my_group animated:YES];
        }else{
            MessageAddressViewController * my_group = [[MessageAddressViewController alloc]init];
            [self.navigationController pushViewController:my_group animated:YES];
 
        }
        return;
    }
    NSDictionary * tempDict =[[resultArray objectForKey:[keyArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    TestViewController *detailVC = [[TestViewController alloc]init];
    detailVC.userId = KISDictionaryHaveKey(tempDict, @"userid");
    [self.navigationController pushViewController:detailVC animated:YES];
}
#pragma mark 索引
- (void)itemClick:(MenuTableView*)Sender DateDic:(NSMutableDictionary*)dataDic{
    TestViewController *detailVC = [[TestViewController alloc]init];
    detailVC.userId = KISDictionaryHaveKey(dataDic, @"userid");
    [self.navigationController pushViewController:detailVC animated:YES];
}
#pragma mark 索引
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView ==m_myTableView) {
        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 20)];
//        view.backgroundColor = [UIColor yellowColor];
        view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        NSString * keyName =[keyArr objectAtIndex:section];
        UILabel *lb = [[UILabel alloc]initWithFrame:CGRectMake(5, 3, 20, 20)];
        lb.textColor = UIColorFromRGBA(0x999999, 1);
        lb.backgroundColor = [UIColor clearColor];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.text =keyName;
        lb.font = [UIFont boldSystemFontOfSize:12];
        [view addSubview:lb];
        
        //添加一条线
//        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 24, kScreenWidth, 1)];
//        lineLabel.backgroundColor = [UIColor whiteColor];
//        [view addSubview:lineLabel];
        return view;

    }
    else{
        return nil;
    }
}
// 返回索引列表的集合
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView ==searchController.searchResultsTableView) {
        return nil;
    }
    return keyArr;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView ==searchController.searchResultsTableView) {
        return 0;
    }else{
        if (section==0) {
            return 0;
        }else{
            return 25;
        }
    }
}
#pragma mark 请求数据
- (void)getFriendListFromNet
{
    
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"212" forKey:@"method"];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]) {
        [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];

    }else {
        [postDict setObject:@"" forKey:@"token"];

    }
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        [self dealResponse:responseObject];
                        [m_header endRefreshing];
                        
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, id error) {
                    if ([error isKindOfClass:[NSDictionary class]]) {
                        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                        {
                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                    
                    [m_header endRefreshing];
                }];
}
//处理返回结果
-(void)dealResponse:(id)responseObject
{
    fansNum=[[responseObject objectForKey:@"fansnum"] stringValue];
    [[NSUserDefaults standardUserDefaults] setObject:fansNum forKey:[FansCount stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSMutableDictionary* result = [responseObject objectForKey:@"contacts"];
    NSMutableArray* keys = [NSMutableArray arrayWithArray:[result allKeys]];
    [keys sortUsingSelector:@selector(compare:)];
    [keyArr removeAllObjects];
    [resultArray removeAllObjects];
    //清除总数组数据
    [m_allSearchArray removeAllObjects];
    [keyArr addObject:@"^"];
    [keyArr addObjectsFromArray:keys];
    resultArray = result;
    [m_myTableView reloadData];
    [self setFansNum];
    [self saveFriendsList:result];
    
    
    for (int i = 0; i<keys.count; i++) {
        [m_allSearchArray addObjectsFromArray:[result objectForKey:keys[i]]];
    }
}

//保存用户列表信息
-(void)saveFriendsList:(NSDictionary*)result
{
    NSMutableArray* keys = [NSMutableArray arrayWithArray:[result allKeys]];
    [keys sortUsingSelector:@selector(compare:)];
    if (result.count>0) {
        for (int i=0; i<[keys count]; i++) {
            NSString *key=[keys objectAtIndex:i];
            for (NSMutableDictionary * userInfo in [result objectForKey:key]) {
                [userInfo setObject:key forKey:@"nameIndex"];                
                [[UserManager singleton] saveUserInfoToDb:userInfo ShipType:KISDictionaryHaveKey(userInfo, @"shiptype")];
            }
        }
    }
}

//查询用户列表
-(void) getFriendDateFromDataSore
{
    
    NSMutableDictionary *userinfo=[DataStoreManager  newQuerySections:@"1" ShipType2:@"2"];
    NSMutableDictionary* result = [userinfo objectForKey:@"userList"];
    NSMutableArray* keys = [userinfo objectForKey:@"nameKey"];
    
    for (int i = 0; i<keys.count; i++) {
        [m_allSearchArray addObjectsFromArray:[result objectForKey:keys[i]]];
    }

    [keyArr removeAllObjects];
    [resultArray removeAllObjects];
    [keyArr addObject:@"^"];
    [keyArr addObjectsFromArray:keys];
    resultArray = result;
    fansNum = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",FansCount,[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [m_myTableView reloadData];
    [self setFansNum];
    
}

//刷新title
-(void)refreTitle
{
    int count=0;
    for (int i=0; i<keyArr.count; i++) {
        count+=[[resultArray objectForKey:[keyArr objectAtIndex:i]] count];
    }
    m_titleLabel.text = [[@"联系人(" stringByAppendingString:[NSString stringWithFormat: @"%d",count]] stringByAppendingString:@")"];
}

//设置粉丝数量
-(void)setFansNum
{
    [self refreTitle];
    [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@%@",FansCount,[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    if ([GameCommon isEmtity:fansNum]) {
        fanstr=@"粉丝";
    }else {
        int intfans = [fansNum intValue];
        if (intfans>9999) {
            fanstr=[fansNum stringByAppendingString:@"粉"];
        }else{
            fanstr=[fansNum stringByAppendingString:@"位粉丝"];
        }
    }
}

-(void)addheadView
{
    
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        [self getFriendListFromNet];
        
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
    };
    m_header = header;
}

-(void)enterPhoneAddress:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    MessageAddressViewController *mas = [[MessageAddressViewController alloc]init];
    [self.navigationController pushViewController:mas animated:YES];
}

-(void)showSearchResultView{
    [UIView animateWithDuration:0.3 animations:^{
        searchResultView.hidden = NO;
        topImageView.frame = CGRectMake(0, -(KISHighVersion_7 ? 64 : 44), 320, KISHighVersion_7 ? 64 : 44);
        m_myTableView.frame = CGRectMake(0, 20, 320, self.view.bounds.size.height-20-50);
        searchResultView.frame = CGRectMake(0, 0, 320, self.view.bounds.size.height-20-50);
    }];
}
-(void)hideSearchResultView{
    [searchResultView hideSelf];
    [UIView animateWithDuration:0.3 animations:^{
        searchResultView.hidden = YES;
        topImageView.frame = CGRectMake(0, 0, 320, KISHighVersion_7 ? 64 : 44);
        m_myTableView.frame = CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50);
        searchResultView.frame = CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-44-50);
    }completion:^(BOOL finished) {
    }];
}

-(void)reloadSearchList:(NSString*)searchText{
//    [self getFriendDateFromDataSore];
//    [self getFriendListFromNet];
    NSMutableArray *arr = [NSMutableArray array];
    NSMutableArray *aliasArr = [NSMutableArray array]; //别称数组（备注姓名）
    for (int i = 0; i<m_allSearchArray.count; i++) {
        NSDictionary *dic = m_allSearchArray[i];
        [arr addObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")]];
        [aliasArr addObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"alias")]];
    }
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    NSMutableArray  *filteredArray = [NSMutableArray arrayWithArray:[arr filteredArrayUsingPredicate:predicateString]];
    //取别名的数组
    NSMutableArray  *aliasFilteredArray = [NSMutableArray arrayWithArray:[aliasArr filteredArrayUsingPredicate:predicateString]];
 
    
    //第一次从 备注姓名的数组取出符合条件的数据添加到搜索列表
    for (NSDictionary *tempdic in m_allSearchArray) {
        for (NSString *aliaStr in aliasFilteredArray) {
            if ([[tempdic objectForKey:@"alias"]isEqualToString:aliaStr]&&![m_searchArray containsObject:tempdic]) {
                
                     [m_searchArray addObject:tempdic];
                
            }
        }
        
    // 第二次从 昵称的数组取出符合条件的数据添加到搜索列表
        for (NSString  *predicateStr in filteredArray) {
            
            if ([[tempdic objectForKey:@"nickname"]isEqualToString:predicateStr]&&![m_searchArray containsObject:tempdic]) {
                
                [m_searchArray addObject:tempdic];
            }
        }
    }
    searchResultView.searchResultView = m_searchArray;
    [searchResultView.mTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
   
}
@end
