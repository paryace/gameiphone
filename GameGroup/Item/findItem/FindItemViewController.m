//
//  FindItemViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//
#define knewsTimeFormat @"yyyyMMddHHmmss" //你要传过来日期的格式
#define kLocaleIdentifier @"en_US"


#import "FindItemViewController.h"
#import "BaseItemCell.h"
#import "CreateItemViewController.h"
#import "NewCreateItemViewController.h"
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
    
    NSMutableDictionary * selectCharacter ;//角色
    NSMutableDictionary * selectType;//分类
    NSMutableDictionary * selectFilter;//筛选
    NSString * selectPreferenceId;
    NSString * selectDescription;
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
    
    //排序
    UIButton *createBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [createBtn setTitle:@"排序" forState:UIControlStateNormal];
    createBtn.backgroundColor = [UIColor clearColor];
    [createBtn addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:createBtn];
    //菜单
    dropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(0,startX, 320, 40) dataSource:self delegate:self];
    dropDownView.mSuperView = self.view;
    [self.view addSubview:dropDownView];
    
    m_myTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX+40+44, kScreenWidth, kScreenHeigth-startX-60-44) style:UITableViewStylePlain];
    m_myTabelView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    m_myTabelView.delegate = self;
    m_myTabelView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:m_myTabelView];
    [self.view addSubview:m_myTabelView];
    
    
    //初始化搜索条
    mSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, startX+40,260, 44)];
    mSearchBar.backgroundColor = kColorWithRGB(27, 29, 35, 1);
    [mSearchBar setPlaceholder:@"请输入你想找得队伍信息"];
    if ([[[UIDevice currentDevice] systemVersion] floatValue]<7.0) {
        [[[mSearchBar subviews] objectAtIndex:0] removeFromSuperview];
    }
    if ([mSearchBar respondsToSelector:@selector(barTintColor)]) {
        [mSearchBar setBarTintColor:[UIColor clearColor]];
        [mSearchBar setBarTintColor:kColorWithRGB(27, 29, 35, 1)];
    }
    mSearchBar.showsCancelButton=NO;
    mSearchBar.delegate = self;
    [mSearchBar sizeToFit];
    [self.view addSubview:mSearchBar];
    mSearchBar.frame = CGRectMake(0, startX+40, 260, 44);
 
    screenView = [[UIView alloc] initWithFrame:CGRectMake(320-60, startX+40, 60, 44)];
    screenView.backgroundColor = kColorWithRGB(27, 29, 35, 1);
    [self.view addSubview:screenView];
    screenBtn = [[UIButton alloc]initWithFrame:CGRectMake(5,(44-25)/2, 50, 25)];
    [screenBtn setTitle:@"收藏" forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(collectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    [screenBtn setBackgroundImage:KUIImage(@"blue_small_normal") forState:UIControlStateNormal];
    [screenBtn setBackgroundImage:KUIImage(@"blue_small_click") forState:UIControlStateHighlighted];
    screenBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    screenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [screenBtn.layer setMasksToBounds:YES];
    [screenBtn.layer setCornerRadius:3];
    [screenView addSubview:screenBtn];
    
    //标签布局
    tagView = [[UIView alloc] initWithFrame:CGRectMake(0, startX+40+44, 320, kScreenHeigth-(startX+40))];
    tagView.hidden = YES;
    tagView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [tagView addGestureRecognizer:tapGr];
    
    tagList = [[DWTagList alloc] initWithFrame:CGRectMake(10.0f, 20.0f, 310.0f, 300.0f)];
    tagList.tagDelegate=self;
    [tagView addSubview:tagList];
    [self.view addSubview:tagView];
    [self addFooter];
    [self addHeader];
    
    [dropDownView setTitle:@"请选择角色" inSection:0];
    [dropDownView setTitle:@"请选择分类" inSection:1];
    [dropDownView.mTableView reloadData];
    if (self.isInitialize) {
        [self InitializeInfo];
    }else{
        [self initSearchConditions];
    }
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"搜索中...";
    [self.view addSubview:hud];
}

-(void)InitializeInfo
{
    NSMutableDictionary * dic = KISDictionaryHaveKey(self.mainDict, @"createTeamUser");
    selectCharacter =[NSMutableDictionary dictionaryWithObjectsAndKeys:KISDictionaryHaveKey(dic, @"characterId"),@"id",KISDictionaryHaveKey(dic, @"characterName"),@"name",KISDictionaryHaveKey(dic, @"gameid"),@"gameid",KISDictionaryHaveKey(dic, @"realm"),@"simpleRealm", nil];
    
    if ([[self.mainDict allKeys]containsObject:@"type"]&&[KISDictionaryHaveKey(self.mainDict, @"type") isKindOfClass:[NSDictionary class]]) {
        selectType  = KISDictionaryHaveKey(self.mainDict, @"type");
    }else{
        selectType = [[ItemManager singleton] createType];
    }
    if ([KISDictionaryHaveKey(self.mainDict, @"filter") isKindOfClass:[NSDictionary class]]) {
        selectFilter = KISDictionaryHaveKey(self.mainDict, @"filter");
    }else{
        selectFilter=nil;
    }
    selectPreferenceId= KISDictionaryHaveKey(self.mainDict, @"preferenceId");
    [self reloInfo:YES];
}
//选择标签
-(void)tagClick:(UIButton*)sender
{
    selectDescription = KISDictionaryHaveKey([arrayTag objectAtIndex:sender.tag], @"value");
    [self reloInfo:YES];
    if([mSearchBar isFirstResponder]){
        [mSearchBar resignFirstResponder];
    }
}

//设置按钮文字
-(void)setTitleInfo{
    mSearchBar.text = selectDescription?selectDescription:@"";
    if (selectCharacter) {
        [dropDownView setTitle:KISDictionaryHaveKey(selectCharacter, @"name") inSection:0];
    }else{
        [dropDownView setTitle:@"请选择角色" inSection:0];
    }
    if (selectType) {
        [dropDownView setTitle:KISDictionaryHaveKey(selectType, @"value") inSection:1];
    }else{
        [dropDownView setTitle:@"请选择分类" inSection:1];
    }
}

-(void)reloInfo:(BOOL)isRefre{
    m_currentPage = 0;
    [self startToSearch:isRefre];
}


-(void)startToSearch:(BOOL)isRefre{
    NSString * selectTypeId;
    NSString * selectFilterId;
    if (selectType) {
        selectTypeId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectType,@"constId")];
    }else{
        selectTypeId = @"0";
        selectType = [[ItemManager singleton] createType];
    }
    if (selectFilter) {
        selectFilterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(selectFilter, @"constId")];
    }else{
        selectFilterId = @"";
    }
    [self setTitleInfo];
    [self cacheSearchConditions];
    [self getInfoFromNetWithDic:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:selectTypeId Description:KISDictionaryHaveKey(self.mainDict, @"desc") FilterId:selectFilterId PreferenceId:selectPreferenceId IsRefre:isRefre];
}
//缓存搜索条件
-(void)cacheSearchConditions{
    [[NSUserDefaults standardUserDefaults]setObject:selectCharacter forKey:[NSString stringWithFormat:@"%@%@",@"selectCharacter_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [[NSUserDefaults standardUserDefaults]setObject:selectType forKey:[NSString stringWithFormat:@"%@%@",@"selectType_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [[NSUserDefaults standardUserDefaults]setObject:selectFilter forKey:[NSString stringWithFormat:@"%@%@",@"selectFilter_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [[NSUserDefaults standardUserDefaults]setObject:selectDescription forKey:[NSString stringWithFormat:@"%@%@",@"selectDescription_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    [[NSUserDefaults standardUserDefaults]setObject:selectPreferenceId forKey:[NSString stringWithFormat:@"%@%@",@"selectPreferenceId_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
}
//初始化上次的搜索条件
-(void)initSearchConditions{
   selectCharacter =  [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",@"selectCharacter_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    selectType =  [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",@"selectType_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    selectFilter =  [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",@"selectFilter_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    selectDescription =  [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",@"selectDescription_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    selectPreferenceId =  [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",@"selectPreferenceId_",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    if (!selectCharacter) {
        [dropDownView showHide:0];
        return;
    }
    [self reloInfo:YES];
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
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(320-5-50, startX-40, 50, 25) menuItems:menuItems];
}
#pragma mark -- 筛选
- (void) pushMenuItem:(KxMenuItem*)sender
{
    selectFilter = [arrayFilter objectAtIndex:sender.tag];
    [self reloInfo:YES];
}

#pragma mark -- dropDownListDelegate
-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    if (section==0) {//选择角色
        selectCharacter = [m_charaArray objectAtIndex:index];
        [self reloInfo:YES];
    }
    else if (section == 1){//选择分类
        selectType =[arrayType objectAtIndex:index];
        [self reloInfo:YES];
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
    if (section == 1){
        if (arrayType.count>0) {
            return KISDictionaryHaveKey([arrayType objectAtIndex:index], @"value");
        }
        return @"";
    }
    return @"";
}

-(NSDictionary *)contentInsection:(NSInteger)section index:(NSInteger)index
{
    if (section ==0) {
        return m_charaArray[index];
    }else{
        return nil;
    }
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}
//收藏
-(void)collectionBtn:(id)sender
{
    
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
        return;
    }
    if (!selectType) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return;
    }
    [[ItemManager singleton] collectionItem:KISDictionaryHaveKey(selectCharacter, @"gameid") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") TypeId:KISDictionaryHaveKey(selectType, @"constId") Description:mSearchBar.text FilterId:KISDictionaryHaveKey(selectFilter, @"constId")
    reSuccess:^(id responseObject) {
         [self showMessageWindowWithContent:@"收藏成功" imageType:0];
        
        if (self.isInitialize) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"replacePreference_wx" object:nil userInfo:self.mainDict];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"shuaxinRefreshPreference_wxx" object:responseObject];
        }
        [self.navigationController popViewControllerAnimated:YES];
        
    } reError:^(id error) {
        [self showErrorAlertView:error];
    }];
}
//创建组队
-(void)didClickCreateItem:(id)sender
{
    NewCreateItemViewController *cretItm = [[NewCreateItemViewController alloc]init];
    cretItm.selectRoleDict = selectCharacter;
    cretItm.selectTypeDict = selectType;
    [self.navigationController pushViewController:cretItm animated:YES];
}
//筛选
-(void)didClickScreen:(UIButton *)sender
{
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
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
    return  1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (m_dataArray&&[m_dataArray isKindOfClass:[NSArray class]]&&m_dataArray.count>0) {
        return 30;
    }else{
        return 0;
 
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1  ];
    UIImageView *imageV= [[UIImageView alloc] initWithFrame:CGRectMake(110, 5, 20, 20)];
    imageV.layer.cornerRadius = 5;
    imageV.layer.masksToBounds=YES;
    imageV.backgroundColor = [UIColor clearColor];
    [view addSubview:imageV];
    
    UILabel * lable = [[UILabel alloc] initWithFrame:CGRectMake(130, 0, 60, 30)];
    [lable setTextAlignment:NSTextAlignmentCenter];
    lable.text = @"创建组队";
    [lable setFont:[UIFont boldSystemFontOfSize:13.0]];
    [lable setBackgroundColor:[UIColor clearColor]];
    [lable setTextColor:[UIColor grayColor ]];
    [view addSubview:lable];
    
    [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(createTeam:)]];
    
    return view;

}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *indifience = @"cell";
    BaseItemCell *cell = [tableView dequeueReusableCellWithIdentifier:indifience];
    if (!cell) {
        cell = [[BaseItemCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indifience];
    }
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    cell.headImg.placeholderImage = KUIImage(@"placeholder");
    cell.headImg.image = KUIImage(@"wow");

    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"img")];
    cell.headImg.imageURL =[ImageService getImageStr2:imageids] ;
    
    NSString *title = [NSString stringWithFormat:@"[%@/%@]%@",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"createTeamUser"), @"nickname")]];

    cell.titleLabel.text = title;
    cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
//    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
    
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")] doubleValue]];
    NSString *timeStr = [GameCommon getShowTime:sendTime];
    cell.timeLabel.text = timeStr;
    return cell;
}





-(void)createTeam:(id)sender
{
    NewCreateItemViewController *cretItm = [[NewCreateItemViewController alloc]init];
    cretItm.selectRoleDict = selectCharacter;
    cretItm.selectTypeDict = selectType;
    [self.navigationController pushViewController:cretItm animated:YES];

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [m_myTabelView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"createTeamUser"), @"userid")];
    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        itemInfo.isCaptain = YES;
    }else{
        itemInfo.isCaptain =NO;
    }
    itemInfo.infoDict = [NSMutableDictionary dictionaryWithDictionary:roleDict];
    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    itemInfo.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
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
    selectDescription = searchBar.text;
    [self reloInfo:YES];
}

#pragma mark ----获得焦点
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    if (!selectCharacter) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
        return NO;
    }
    if (!selectType) {
        [self showAlertViewWithTitle:@"提示" message:@"请选择分类" buttonTitle:@"OK"];
        return NO;
    }
    
    if (tagView.hidden==YES) {
        tagView.hidden=NO;
        [[ItemManager singleton] getTeamLable:KISDictionaryHaveKey(selectCharacter, @"gameid") TypeId:KISDictionaryHaveKey(selectType, @"constId") CharacterId:KISDictionaryHaveKey(selectCharacter, @"id") reSuccess:^(id responseObject) {
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
-(void)getInfoFromNetWithDic:(NSString*)gameid CharacterId:(NSString*)characterId TypeId:(NSString*)typeId Description:(NSString*)description FilterId:(NSString*)filterId PreferenceId:(NSString*)preferenceId IsRefre:(BOOL)isRefre
{
    if (isRefre) {
        [hud show:YES];
    }
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
    if (![GameCommon isEmtity:[GameCommon getNewStringWithId:preferenceId]]) {
        [paramDict setObject:[GameCommon getNewStringWithId:preferenceId] forKey:@"preferenceId"];
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
            if (m_currentPage == 0 ) {
                [m_dataArray removeAllObjects];
            }
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
                [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
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
            [self startToSearch:NO];
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
            [self showAlertViewWithTitle:@"提示" message:@"请选择角色" buttonTitle:@"OK"];
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
        [self reloInfo:NO];
    };
    m_header = header;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
