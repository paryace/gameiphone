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

@interface NewFriendPageController (){
    
    UILabel*        m_titleLabel;
    MJRefreshHeaderView *m_header;
    NSMutableDictionary *resultArray;//数据集合
    NSMutableArray * keyArr;//字母集合
    
    UITableView*  m_myTableView;
    NSString *fansNum;
    NSString *fanstr;
    UISearchBar *m_searchBar;
    UISearchDisplayController * searchController;
    NSMutableArray * m_searchArray;
    NSMutableArray * m_allSearchArray;
}
@end

@implementation NewFriendPageController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[Custom_tabbar showTabBar] hideTabBar:NO];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"" withBackButton:NO];
    
    UIButton *addFriendBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [addFriendBtn setBackgroundImage:KUIImage(@"friends_add_normal") forState:UIControlStateNormal];
    [addFriendBtn setBackgroundImage:KUIImage(@"friends_add_click") forState:UIControlStateHighlighted];
    [addFriendBtn setBackgroundImage:KUIImage(@"friends_add_click") forState:UIControlStateSelected];
    addFriendBtn.backgroundColor = [UIColor clearColor];
    [addFriendBtn addTarget:self action:@selector(addFriends:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addFriendBtn];

    self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContentList:) name:kReloadContentKey object:nil];
    resultArray =[NSMutableDictionary dictionary];
    m_allSearchArray = [NSMutableArray array];
    keyArr=[NSMutableArray array];
    m_searchArray = [NSMutableArray array];
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"联系人";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
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
    
    UIView * mSearchView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    mSearchView.backgroundColor = [UIColor clearColor];
    //初始化搜索条
    m_searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 340, 44)];
    [m_searchBar setPlaceholder:@"关键字搜索服务器"];
    m_searchBar.delegate = self;
    [m_searchBar sizeToFit];
    [mSearchView addSubview:m_searchBar];
    //初始化UISearchDisplayController
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:m_searchBar contentsController:self];
    [searchController setDelegate:self];
    [searchController setSearchResultsDataSource:self];
    [searchController setSearchResultsDelegate:self];
//    if (KISHighVersion_7) {
//        searchController.searchResultsTableView.tableHeaderView = mSearchView;
//    }
    m_myTableView.tableHeaderView = mSearchView;
//    searchController.searchResultsTableView.frame =CGRectMake(0, 100, 320, 200);
//    UIView *footView =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
//    footView.backgroundColor = [UIColor clearColor];
//    
//    UIImageView *iconImg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 15, 20, 20)];
//    iconImg.image =KUIImage(@"phoneNote");
//    [footView addSubview:iconImg];
//    
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 1, 320, 50)];
//    label.backgroundColor = [UIColor clearColor];
//    label.text = @"手机通讯录";
//    label.font = [UIFont boldSystemFontOfSize:18];
//    label.textAlignment = NSTextAlignmentCenter;
//    [footView addSubview:label];
//    
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame = CGRectMake(10, 3, 300,44);
//    
//    button.backgroundColor = [UIColor clearColor];
//    [button addTarget:self action:@selector(enterPhoneAddress:) forControlEvents:UIControlEventTouchUpInside];
//    [footView addSubview:button];
//    
//    m_myTableView.tableFooterView = footView;
    
    [self getFriendDateFromDataSore];
    [self addheadView];
}
-(void)addFriends:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    AddFriendsViewController * addV = [[AddFriendsViewController alloc] init];
    [self.navigationController pushViewController:addV animated:YES];

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
//            MessageAddressViewController *addVC = [[MessageAddressViewController alloc]init];
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
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0&&tableView ==m_myTableView) {
        static NSString * stringCellTop = @"cellTop";
        //            FriendTopCell * cellTop = [[FriendTopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCellTop];
        //            cellTop.friendTabDelegate=self;
        //            cellTop.lable1.text=fanstr;
        //            CGSize textSize =[fanstr sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        //            cellTop.lable1.frame=CGRectMake(((80-textSize.width)/2),40, 80 ,20);
        //            return cellTop;
        FriendFirstCell *cell = [tableView dequeueReusableCellWithIdentifier:stringCellTop];
        if (!cell) {
            cell = [[FriendFirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCellTop];
        }
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        if (indexPath.row ==0) {
            cell.headImageView.image = KUIImage(@"search_role");
            cell.titleLabel.text = @"查找游戏角色";
        }else if(indexPath.row ==1){
            cell.headImageView.image = KUIImage(@"my_team");
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

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
    cell.nameLabel.frame = CGRectMake(80, 5, nameSize.width + 5, 20);
    cell.sexImg.frame = CGRectMake(80 + nameSize.width, 5, 20, 20);
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
//返回索引的字母
#pragma mark 索引
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    if (tableView ==searchController.searchResultsTableView) {
        return nil;
    }else{
    if (section==0) {
        return @"";
    }
    NSString * keyName =[keyArr objectAtIndex:section];
    return keyName;
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
        return 20;
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



#pragma mark---searchbar delegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar setShowsCancelButton:NO];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[searchController.searchResultsTableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController setActive:NO animated:YES];
	[searchController.searchResultsTableView reloadData];
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    return YES;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchController.searchResultsTableView.frame = CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50);
    NSLog(@"%@",searchText);
    if ([searchText isEqualToString:@""]) {
        [m_searchArray removeAllObjects];
        [searchController.searchResultsTableView reloadData];
        return;
    }
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i<m_allSearchArray.count; i++) {
        NSDictionary *dic = m_allSearchArray[i];
        [arr addObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")]];
    }
    
//    NSString *keyName = @"";
//    if (_searchState == DataSearchStateBank) {
//        keyName = [Bank keyName];
//    }
    /**< 模糊查找*/
//    NSDictionary *tempDict = [NSDictionary dictionaryWithObjectsAndKeys:searchText,@"nickname", nil];
//    [tempDict setObject:searchText forKey:@"nickname"];
    NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@", searchText];
    /**< 精确查找*/
    //  NSPredicate *predicateString = [NSPredicate predicateWithFormat:@"%K == %@", keyName, searchText];
    
    NSLog(@"predicate %@",predicateString);
    
    NSMutableArray  *filteredArray = [NSMutableArray arrayWithArray:[arr filteredArrayUsingPredicate:predicateString]];
    
    for (NSDictionary *tempdic in m_allSearchArray) {
        for (NSString  *predicateStr in filteredArray) {
            if ([[tempdic objectForKey:@"nickname"]isEqualToString:predicateStr]&&![m_searchArray containsObject:tempdic]) {
                [m_searchArray addObject:tempdic];
            }
        }
    }
    
//    m_searchArray = filteredArray;
    [searchController.searchResultsTableView reloadData];

}
- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    return YES;
}




- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar
{
    
}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
