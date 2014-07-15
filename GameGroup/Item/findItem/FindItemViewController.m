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
@interface FindItemViewController ()
{
    UITableView *m_myTabelView;
    DropDownListView * dropDownView;
    UITextField *roleTextf;
    UISearchBar * mSearchBar;
    UIView *tagView;
    
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
    [self setTopViewWithTitle:@"组队" withBackButton:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    //初始化数据源
    m_dataArray = [NSMutableArray array];
    m_charaArray = [NSMutableArray array];
    roleDict = [NSMutableDictionary dictionary];
    m_charaArray = [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    
    arrayTag = [[NSArray alloc] initWithObjects:@"Foo", @"Tag Label 1", @"Tag Label 2", @"Tag Label 3", @"Tag Label 4", @"Tag Label 5",@"Foo", @"Tag Label 1", @"Tag Label 2", @"Tag Label 3", @"Tag Label 4", @"Tag Label 5",@"Fooasdasdasdasdad",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo",@"Foo", nil];
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
    
    
    m_myTabelView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX+40, kScreenWidth, kScreenHeigth-startX-50) style:UITableViewStylePlain];
    m_myTabelView.delegate = self;
    m_myTabelView.dataSource  = self;
    [GameCommon setExtraCellLineHidden:m_myTabelView];
    [self.view addSubview:m_myTabelView];
    
    UIButton *screenBtn = [[UIButton alloc]initWithFrame:CGRectMake(260, kScreenHeigth-50-startX-(KISHighVersion_7?0:20), 40, 40)];
    screenBtn.backgroundColor = [UIColor blackColor];
    [screenBtn setTitle:@"筛选" forState:UIControlStateNormal];
    [screenBtn addTarget:self action:@selector(didClickScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:screenBtn];
    
    //初始化搜索条
    mSearchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, startX+40, 320, 44)];
    mSearchBar.backgroundColor = [UIColor grayColor];
    [mSearchBar setPlaceholder:@"输入搜索条件"];
    mSearchBar.delegate = self;
    [mSearchBar sizeToFit];
    [self.view addSubview:mSearchBar];
    
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
    [[Custom_tabbar showTabBar] hideTabBar:YES];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    
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
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self setTopViewWithTitle:@"组队" withBackButton:YES];
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
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



#pragma mark -
#pragma mark UI/UE : 响应各种交互操作
- (void)keyboardWillShow:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (tagView.hidden==YES) {
        tagView.hidden=NO;
    }
    [self reloadView:0];
}


- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary* userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    if (tagView.hidden==NO) {
        tagView.hidden=YES;
    }
    [self reloadView:40];
}

-(void)reloadView:(float)offHight
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    mSearchBar.frame = CGRectMake(0, startX+offHight, 320, 44);
    tagView.frame = CGRectMake(0, startX+offHight+44, 320, kScreenHeigth-(startX+offHight));
    [UIView commitAnimations];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
