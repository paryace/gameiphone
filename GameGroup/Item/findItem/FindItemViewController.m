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

@interface FindItemViewController ()
{
    UITableView *m_myTabelView;
    DropDownListView * dropDownView;
    UITextField *roleTextf;
    UISearchBar * mSearchBar;
    UIView *tagView;
    UIView *screenView;
    
    NSArray *arrayTag;
    NSMutableArray *m_dataArray;
    NSMutableDictionary *roleDict;
    NSMutableArray *m_charaArray;
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
    [dropDownView.mTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"寻找组队" withBackButton:YES];
    self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //初始化数据源
    m_dataArray = [NSMutableArray array];
    m_charaArray = [NSMutableArray array];
    roleDict = [NSMutableDictionary dictionary];
    m_charaArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    
    arrayTag = [[NSArray alloc] initWithObjects:@"Foo", @"Tag Label 1", @"Tag Label 2", @"Tag Label 3", @"Tag Label 4", @"Tag Label 5",@"Foo", @"Tag Label 1", @"Tag Label 2", @"Tag Label 3", @"Tag Label 4", @"Tag Label 5",@"Fooasdasdasdasdad",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo", nil];
    
    [self getTeamType];
//    [self getTeamLable];
    //收藏
    UIButton* collectionBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [collectionBtn setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [collectionBtn setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    [collectionBtn setTitle:@"收藏" forState:UIControlStateNormal];
    collectionBtn.backgroundColor = [UIColor clearColor];
    [collectionBtn addTarget:self action:@selector(collectionBtn:) forControlEvents:UIControlEventTouchUpInside];
    //    [self.view addSubview:collectionBtn];
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
    screenView.backgroundColor = UIColorFromRGBA(0xbbbbbb, 0.6);
    [self.view addSubview:screenView];
    
    UIButton *screenBtn = [[UIButton alloc]initWithFrame:CGRectMake(5,(44-25)/2, 50, 25)];
    [screenBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [screenBtn setBackgroundImage:KUIImage(@"blue_small_normal") forState:UIControlStateNormal];
    [screenBtn setBackgroundImage:KUIImage(@"blue_small_click") forState:UIControlStateHighlighted];
    screenBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    screenBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
    [screenBtn.layer setMasksToBounds:YES];
    [screenBtn.layer setCornerRadius:3];
    [screenView addSubview:screenBtn];

    
    
    tagView = [[UIView alloc] initWithFrame:CGRectMake(0, startX+40+44, 320, kScreenHeigth-(startX+40))];
    tagView.hidden = YES;
    tagView.backgroundColor = [UIColor whiteColor];
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [tagView addGestureRecognizer:tapGr];
    
    tagList = [[DWTagList alloc] initWithFrame:CGRectMake(20.0f, 20.0f, 280.0f, 300.0f)];
    [tagList setTags:arrayTag];
    tagList.tagDelegate=self;
    [tagView addSubview:tagList];
    
    [self.view addSubview:tagView];

}

-(void)tagClick:(UIButton*)sender
{
    mSearchBar.text = [arrayTag objectAtIndex:sender.tag];
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

#pragma mark -- dropDownListDelegate
-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    NSLog(@"选了section:%d ,index:%d",section,index);
}

#pragma mark -- dropdownList DataSource
-(NSInteger)numberOfSections
{
    return 2;
}
-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    return [m_charaArray count];
}
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
{
    return  [NSString stringWithFormat:@"%@--%@",KISDictionaryHaveKey(m_charaArray[index], @"simpleRealm"),KISDictionaryHaveKey(m_charaArray[index], @"name")];
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}

-(void)collectionBtn:(id)sender
{
    //[self showMessageWindowWithContent:@"没有收藏" imageType:1];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    MyRoomViewController *myRoom = [[MyRoomViewController alloc]init];
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    transition.subtype = kCATransitionFromLeft;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] pushViewController:myRoom animated:NO];
    //    [UIView  beginAnimations:nil context:NULL];
    //    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    //    [UIView setAnimationDuration:0.75];
    //    [self.navigationController pushViewController:myRoom animated:NO];
    //    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.navigationController.view cache:NO];
    //    [UIView commitAnimations];
    
    //    [self.navigationController pushViewController:myRoom animated:YES];
}
-(void)didClickCreateItem:(id)sender
{
    CreateItemViewController *cretItm = [[CreateItemViewController alloc]init];
    [self.navigationController pushViewController:cretItm animated:YES];
}
-(void)didClickScreen:(UIButton *)sender
{
    sender.titleLabel.textColor = [UIColor grayColor];
    [self getInfoFromNetWithDic:roleDict];
    
}

#pragma mark ----NET
-(void)getInfoFromNetWithDic:(NSDictionary *)dic
{
    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"id")] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")] forKey:@"gameid"];
    [paramDict setObject:@"1" forKey:@"typeIds"];
    [paramDict setObject:@"0" forKey:@"firstResult"];
    [paramDict setObject:@"20" forKey:@"maxSize"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"264" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [m_dataArray removeAllObjects];
            [m_dataArray addObjectsFromArray:responseObject];
            [m_myTabelView reloadData];
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
//    return m_dataArray.count;
    return 10;
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
//    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
    cell.headImg.placeholderImage = KUIImage(@"placeholder");
    cell.headImg.image = KUIImage(@"wow");
//    NSString *imageids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"img")];
//    cell.headImg.imageURL =[ImageService getImageStr2:imageids] ;
//    
//    cell.titleLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"), @"nickname")];
//    cell.contentLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
//    
//    NSString *timeStr = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
//    NSString *personStr = [NSString stringWithFormat:@"%@/%@人",[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")],[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")]];
//    
//    cell.timeLabel.text = [NSString stringWithFormat:@"%@|%@",timeStr,personStr];
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
//    NSDictionary *dic = [m_dataArray objectAtIndex:indexPath.row];
//    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
//    NSString *userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dic , @"user"), @"userid")];
//    if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
//        itemInfo.isCaptain = YES;
//    }else{
//        itemInfo.isCaptain =NO;
//    }
//    itemInfo.infoDict = [NSMutableDictionary dictionaryWithDictionary:roleDict];
//    itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
//    [self.navigationController pushViewController:itemInfo animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar{
    [self doSearch:searchBar];
}

/*取消按钮*/
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [self doSearch:searchBar];
}

/*键盘搜索按钮*/
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    [self doSearch:searchBar];
}

/*搜索*/
- (void)doSearch:(UISearchBar *)searchBar{
    NSLog(@"searchBar-Text-%@",searchBar.text);
}


#pragma mark UI/UE :键盘显示
- (void)keyboardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (tagView.hidden==YES) {
        tagView.hidden=NO;
    }
    if (screenView.hidden==NO) {
        screenView.hidden=YES;
    }
    [self reloadView:0 offWidth:60];
}

#pragma mark UI/UE :键盘隐藏
- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (tagView.hidden==NO) {
        tagView.hidden=YES;
    }
    if (screenView.hidden==YES) {
        screenView.hidden=NO;
    }
    [self reloadView:40 offWidth:0];
}

-(void)reloadView:(float)offHight offWidth:(float)offWidth
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    mSearchBar.frame = CGRectMake(0, startX+offHight, 260+offWidth, 44);
    tagView.frame = CGRectMake(0, startX+offHight+44, 320, kScreenHeigth-(startX+offHight));
    [UIView commitAnimations];
}

#pragma mark ----获取组队分类
-(void)getTeamType
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:@"1" forKey:@"gameid"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"277" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlertView:error];
        [hud hide:YES];
    }];
}

#pragma mark ----获取组队偏好标签 gameid，typeId
-(void)getTeamLable
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:@"1" forKey:@"gameid"];
    [paramDict setObject:@"1" forKey:@"typeId"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"278" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self showErrorAlertView:error];
        [hud hide:YES];
    }];
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
