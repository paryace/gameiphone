//
//  FindItemViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FindItemViewController.h"
#import "BaseItemCell.h"
#import "CreateItemViewController.h"
#import "ItemInfoViewController.h"
#import "MyRoomViewController.h"
#import "DropDownListView.h"
#import "CreateTeamCell.h"
#import "ItemManager.h"
#import "KxMenu.h"
#import "MJRefresh.h"

@interface FindItemViewController ()
{
    UITableView *m_myTabelView;
    DropDownListView * dropDownView;
    UITextField *roleTextf;
    UISearchBar * mSearchBar;
    UIView *tagView;
    UIView *screenView;
    UIButton *screenBtn;
    
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    NSInteger           m_totalPage;
    NSInteger           m_currentPage;
    
    NSArray *arrayTag;
    NSArray *arrayType;
    NSArray *arrayFilter;
    NSMutableArray *m_dataArray;
    NSMutableDictionary *roleDict;
    NSMutableArray *m_charaArray;
    
    NSMutableDictionary * selectCharacter ;
    NSMutableDictionary * selectType;
    NSMutableDictionary * selectFilter;
}
@end

@implementation FindItemViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    m_charaArray =[DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"寻找组队" withBackButton:YES];
    self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    
    //初始化数据源
    m_dataArray = [NSMutableArray array];
    m_charaArray = [NSMutableArray array];
    roleDict = [NSMutableDictionary dictionary];
    m_charaArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    arrayTag = [NSArray array];
    arrayType = [NSArray array];
    arrayFilter = [NSArray array];
    
    //创建
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [createBtn setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(didClickCreateItem:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    //菜单
    dropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(0,startX, 320, 40) dataSource:self delegate:self];
    dropDownView.mSuperView = self.view;
    [self.view addSubview:dropDownView];
    
    m_myTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX+40+44, kScreenWidth, kScreenHeigth-startX-50) style:UITableViewStylePlain];
    m_myTabelView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    m_myTabelView.delegate = self;
    m_myTabelView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:m_myTabelView];
    [self.view addSubview:m_myTabelView];
    
    
    //初始化搜索条
    mSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, startX+40,260, 44)];
    mSearchBar.backgroundColor = [UIColor clearColor];
    [mSearchBar setPlaceholder:@"输入搜索条件"];
    mSearchBar.showsCancelButton=NO;
    mSearchBar.delegate = self;
    [mSearchBar sizeToFit];
    [self.view addSubview:mSearchBar];
    mSearchBar.frame = CGRectMake(0, startX+40, 260, 44);
 
    screenView = [[UIView alloc] initWithFrame:CGRectMake(320-60, startX+40, 60, 44)];
    screenView.backgroundColor = kColorWithRGB(188, 188, 194, 0.8);
    [self.view addSubview:screenView];
    
    UIImageView * lineImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0, 60, 0.5)];
    lineImageV.backgroundColor = kColorWithRGB(169, 169, 171, 0.8);
    [screenView addSubview:lineImageV];
    
    screenBtn = [[UIButton alloc]initWithFrame:CGRectMake(5,(44-25)/2, 50, 25)];
    [screenBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [screenBtn setBackgroundImage:KUIImage(@"blue_small_normal") forState:UIControlStateNormal];
    [screenBtn setBackgroundImage:KUIImage(@"blue_small_click") forState:UIControlStateHighlighted];
    screenBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    screenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [screenBtn.layer setMasksToBounds:YES];
    [screenBtn.layer setCornerRadius:3];
    [screenView addSubview:screenBtn];
    
    //收藏
    UIButton* collectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-10-50, kScreenHeigth-10-50, 40, 40)];
    [collectionBtn setBackgroundImage:KUIImage(@"blue_small_normal") forState:UIControlStateNormal];
    [collectionBtn setBackgroundImage:KUIImage(@"blue_small_click") forState:UIControlStateHighlighted];
    [collectionBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [collectionBtn addTarget:self action:@selector(collectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:collectionBtn];

    
    //标签布局
    tagView = [[UIView alloc] initWithFrame:CGRectMake(0, startX+40+44, 320, kScreenHeigth-(startX+40))];
    tagView.hidden = YES;
    tagView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [tagView addGestureRecognizer:tapGr];
    
    tagList = [[DWTagList alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 300.0f)];
    tagList.tagDelegate=self;
    [tagView addSubview:tagList];
    [self.view addSubview:tagView];
    
    [self addFooter];
    [self addHeader];
    
    [dropDownView setTitle:@"请选择角色" inSection:0];
    [dropDownView setTitle:@"请选择分类" inSection:1];
    NSLog(@"mainDict%@",self.mainDict);
    if (self.isInitialize) {
        [self InitializeInfo];
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"搜索中...";
    [self.view addSubview:hud];
}

-(void)InitializeInfo
{
    [dropDownView setTitle:KISDictionaryHaveKey(self.mainDict, @"characterName") inSection:0];
    [dropDownView setTitle:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"type"), @"value") inSection:1];
    
    m_currentPage = 0;
    [self getInfoFromNetWithDic:KISDictionaryHaveKey(self.mainDict, @"gameid") CharacterId:KISDictionaryHaveKey(self.mainDict, @"characterId") TypeId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"type"), @"constId") Description:KISDictionaryHaveKey(self.mainDict, @"desc") FilterId:KISDictionaryHaveKey(KISDictionaryHaveKey(self.mainDict, @"filter"), @"constId")];
}

-(void)tagClick:(UIButton*)sender
{
    mSearchBar.text = KISDictionaryHaveKey([arrayTag objectAtIndex:sender.tag], @"value");
    m_currentPage = 0;
    [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:mSearchBar.text FilterId:KISDictionaryHaveKey(selectFilter, @"constId")];

    if([mSearchBar isFirstResponder]){
        [mSearchBar resignFirstResponder];
    }
}

-(void)viewTapped:(UITapGestureRecognizer*)sender
{
    if([mSearchBar isFirstResponder]){
        [mSearchBar resignFirstResponder];
    }
}
#pragma mark -- 分类请求成功通知
-(void)updateTeamType:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        arrayType = responseObject;
        [dropDownView.mTableView reloadData];
    }
}
#pragma mark -- 标签请求成功通知
-(void)updateTeamLable:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        arrayTag = responseObject;
        [tagList setTags:arrayTag];
    }
}
#pragma mark -- Filter请求成功通知
-(void)updateFilterId:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        arrayFilter = responseObject;
        [self showFilterMenu];
    }
}
//显示房间过滤菜单
-(void)showFilterMenu
{
    NSMutableArray *menuItems = [NSMutableArray array];
    for (int i = 0; i<arrayFilter.count; i++) {
       KxMenuItem *menuItem = [KxMenuItem menuItem:KISDictionaryHaveKey([arrayFilter objectAtIndex:i], @"value") image:nil target:self action:@selector(pushMenuItem:)];
        menuItem.tag =i;
        [menuItems addObject:menuItem];
    }
    KxMenuItem *first = [KxMenuItem menuItem:@"组队筛选" image:nil target:nil action:NULL];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(320-5-50, startX+40+10, 50, 25) menuItems:menuItems];
}
#pragma mark -- 筛选
- (void) pushMenuItem:(KxMenuItem*)sender
{
    selectFilter = [arrayFilter objectAtIndex:sender.tag];
    m_currentPage = 0;
    [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:nil FilterId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(selectFilter, @"constId")]];
}

#pragma mark -- dropDownListDelegate
-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    if (section==0) {
        selectCharacter = [m_charaArray objectAtIndex:index];
    }
    else if (section == 1){
        selectType =[arrayType objectAtIndex:index];
        m_currentPage = 0;
        [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:nil FilterId:nil];
    }
}

//点击选项
-(BOOL) clickAtSection:(NSInteger)section
{
    if (section==0) {
        return YES;
    }else if(section == 1){
        if(!selectCharacter){//还未选择游戏的状态
            [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏角色" buttonTitle:@"OK"];
            return NO;
        }
        [[ItemManager singleton] getTeamType:KISDictionaryHaveKey(selectCharacter, @"gameid")reSuccess:^(id responseObject) {
                [self updateTeamType:responseObject];
        } reError:^(id error) {
                [self showErrorAlertView:error];
        }];
        return YES;
    }
    return NO;
}

#pragma mark -- dropdownList DataSource
-(NSInteger)numberOfSections
{
    return 2;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return [m_charaArray count];
    }
    return arrayType.count;
}
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
{
    if (section==0) {
         return  [NSString stringWithFormat:@"%@--%@",KISDictionaryHaveKey(m_charaArray[index], @"simpleRealm"),KISDictionaryHaveKey(m_charaArray[index], @"name")];
    }else if (section == 1){
        if (arrayType.count>0) {
            return KISDictionaryHaveKey([arrayType objectAtIndex:index], @"value");
        }
        return @"";
    }
    return @"";
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}
//收藏
-(void)collectionBtn:(id)sender
{
    
    [[ItemManager singleton] collectionItem:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:mSearchBar.text FilterId:KISDictionaryHaveKey(selectFilter, @"constId")
    reSuccess:^(id responseObject) {
         [self showMessageWindowWithContent:@"收藏成功" imageType:0];
         [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshPreference_wx" object:responseObject];
    } reError:^(id error) {
        [self showErrorAlertView:error];
    }];
}
//创建组队
-(void)didClickCreateItem:(id)sender
{
    CreateItemViewController *cretItm = [[CreateItemViewController alloc]init];
    [self.navigationController pushViewController:cretItm animated:YES];
}
//筛选
-(void)didClickScreen:(UIButton *)sender
{
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择游戏" buttonTitle:@"OK"];
        return;
    }
    if (!selectType) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return;
    }
    [[ItemManager singleton] getFilterId:KISDictionaryHaveKey(selectCharacter, @"gameid")reSuccess:^(id responseObject) {
        [self updateFilterId:responseObject];
    } reError:^(id error) {
        [self showErrorAlertView:error];
    }];
}

#pragma mark ----tableview delegate  datasourse
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }
    return m_dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return 0;
    }else{
        return 20;
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) {
        if (indexPath.row == 0) {
            static NSString * stringCellTop = @"createTream";
            CreateTeamCell * cellTop = [[CreateTeamCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCellTop];
            cellTop.imageV.image = KUIImage(@"state_icon");
            return cellTop;
        }
    }
    static NSString *indifience = @"cell";
    BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    cell.headImg.placeholderImage = KUIImage(@"placeholder");
    cell.headImg.image = KUIImage(@"wow");
    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"img")];
    cell.headImg.imageURL =[ImageService getImageStr2:imageids] ;
    cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname")];
    cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
   cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
     [m_myTabelView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        if (indexPath.row == 0) {
            CreateItemViewController *cretItm = [[CreateItemViewController alloc]init];
            [self.navigationController pushViewController:cretItm animated:YES];
            return;
        }
    }
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"user"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
    itemInfo.infoDict = [NSMutableDictionary dictionaryWithDictionary:roleDict];
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    [self.navigationController pushViewController:itemInfo animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark ----取消按钮
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self doSearch:searchBar];
}

#pragma mark ----键盘搜索按钮
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar];
}

#pragma mark ----搜索
- (void)doSearch:(UISearchBar *)searchBar{
    NSLog(@"searchBar-Text-%@",searchBar.text);
    m_currentPage = 0;
    [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:searchBar.text FilterId:KISDictionaryHaveKey(selectFilter, @"constId")];
}

#pragma mark ----获得焦点
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择游戏" buttonTitle:@"OK"];
        return NO;
    }
    if (!selectType) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return NO;
    }
    
    if (tagView.hidden==YES) {
        tagView.hidden=NO;
        [[ItemManager singleton] getTeamLable:KISDictionaryHaveKey(selectCharacter, @"gameid") TypeId:KISDictionaryHaveKey(selectType, @"constId")reSuccess:^(id responseObject) {
            [self updateTeamLable:responseObject];
        } reError:^(id error) {
            [self showErrorAlertView:error];
        }];
        
    }
    [self reloadView:0 offWidth:60 offWidth2:0];
    return YES;
}
#pragma mark ----失去焦点
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    if (tagView.hidden==NO) {
        tagView.hidden=YES;
    }
    [self reloadView:40 offWidth:0 offWidth2:60];
    return YES;
}

-(void)reloadView:(float)offHight offWidth:(float)offWidth offWidth2:(float)offWidth2
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    mSearchBar.frame = CGRectMake(0, startX+offHight, 260+offWidth, 44);
    tagView.frame = CGRectMake(0, startX+offHight+44, 320, kScreenHeigth-(startX+offHight));
    screenView.frame =CGRectMake(320-offWidth2, startX+offHight, 60, 44);
    [UIView commitAnimations];
}
#pragma mark ----NET
-(void)getInfoFromNetWithDic:(NSString*)gameid CharacterId:(NSString*)characterId TypeId:(NSString*)typeId Description:(NSString*)description FilterId:(NSString*)filterId
{
    [hud show:YES];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:characterId] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:typeId] forKey:@"typeId"];
    if (![GameCommon isEmtity:description]) {
        [paramDict setObject:description forKey:@"description"];
    }
    if (![GameCommon isEmtity:[GameCommon getNewStringWithId:filterId]]) {
        [paramDict setObject:[GameCommon getNewStringWithId:filterId] forKey:@"filterId"];
    }
    [paramDict setObject:[NSString stringWithFormat:@"%ld", (long)m_currentPage] forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"264" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_footer endRefreshing];
        [m_header endRefreshing];
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:responseObject];
            [m_myTabelView reloadData];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_footer endRefreshing];
        [m_header endRefreshing];
        [hud hide:YES];
        [m_dataArray removeAllObjects];
        [m_myTabelView reloadData];
        [self showErrorAlertView:error];
    }];
}
//弹出提示框
-(void)showErrorAlertView:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}


#pragma mark --加载刷新
- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTabelView;
        footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
            if (!selectCharacter) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择游戏" buttonTitle:@"OK"];
                [m_footer endRefreshing];
                [m_header endRefreshing];
                return;
            }
            if (!selectType) {
                [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
                [m_footer endRefreshing];
                [m_header endRefreshing];
                return;
            }
            m_currentPage=m_dataArray.count;
            [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:mSearchBar.text FilterId:KISDictionaryHaveKey(selectFilter, @"constId")];
        
    };
    m_footer = footer;
    
}
- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTabelView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        if (!selectCharacter) {
            [self showAlertViewWithTitle:@"提示" message:@"请选择游戏" buttonTitle:@"OK"];
            [m_footer endRefreshing];
            [m_header endRefreshing];
            return;
        }
        if (!selectType) {
            [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
            [m_footer endRefreshing];
            [m_header endRefreshing];
            return;
        }
        m_currentPage = 0;
        [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:mSearchBar.text FilterId:KISDictionaryHaveKey(selectFilter, @"constId")];
    };
    m_header = header;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
