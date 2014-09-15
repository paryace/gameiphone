//
//  MessageAddressViewController.m
//  GameGroup
//
//  Created by wangxr on 14-3-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MessageUI.h>
#import "MessageAddressViewController.h"
#import "MyHeadView.h"
#import "InDoduAddressTableViewCell.h"
#import "OutDodeAddressTableViewCell.h"
#import "TeachMeViewController.h"
#import "PuthMessageViewController.h"
#import "TestViewController.h"
#import "MySearchBar.h"

@interface MessageAddressViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,DodeAddressCellDelegate,MFMessageComposeViewControllerDelegate,testViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    BOOL systemAllowGetAddress;
    BOOL appAllowGetAddress;
    UITableView * _tableView;

    MySearchBar * mSearchBar;
    UISearchDisplayController *searchController;
}
//@property (nonatomic,retain)UISwitch* swith;
@property (nonatomic,retain)NSMutableArray * addressArray;
@property (nonatomic,retain)NSMutableArray * outAddressArray;
@property (nonatomic,retain)UIView * unAllowView;

@property (nonatomic,retain)NSMutableArray * searchAddressArray;
@property (nonatomic,retain)NSMutableArray * searchOutAddressArray;

@property (nonatomic,retain)NSMutableArray * keysAddressArray;
@property (nonatomic,retain)NSMutableArray * keysOutAddressArray;
@end

@implementation MessageAddressViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined//用户未设置权限
            ||ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized)//用户允许设置权限
        {
            systemAllowGetAddress = YES;
        }else{
            systemAllowGetAddress = NO;
        }
        NSUserDefaults * userdefaults = [NSUserDefaults standardUserDefaults];
        if ([userdefaults objectForKey:@"wxr_systemAllowGetAddress"]) {
            if ([[userdefaults objectForKey:@"wxr_systemAllowGetAddress"] intValue] == 0) {
                appAllowGetAddress = NO;
            }else
            {
                appAllowGetAddress = YES;
            }
        }else{
            appAllowGetAddress = systemAllowGetAddress;
            if (systemAllowGetAddress) {
                [userdefaults setObject:@"1" forKey:@"wxr_systemAllowGetAddress"];
                [userdefaults synchronize];
            }else{
                [userdefaults setObject:@"0" forKey:@"wxr_systemAllowGetAddress"];
                [userdefaults synchronize];
            }
        }
        self.addressArray = [NSMutableArray array];
        
        self.searchAddressArray = [NSMutableArray array];
        self.searchOutAddressArray = [NSMutableArray array];
        self.keysAddressArray = [NSMutableArray array];
        self.keysOutAddressArray = [NSMutableArray array];
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"手机通讯录" withBackButton:YES];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"addressArray"]) {
        self.addressArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"addressArray"];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"keysAddressArray"]) {
        self.keysAddressArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"keysAddressArray"];
    }

    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 60;
    _tableView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];

//    UIView * headV = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 100)];
//    UIImageView *imageV = [[UIImageView alloc]initWithFrame:CGRectMake(10, 27.5, 40, 45)];
//    imageV.image = [UIImage imageNamed:@"addressBookIcon"];
//    [headV addSubview:imageV];
//    UILabel * label1 = [[UILabel alloc]initWithFrame:CGRectMake(60, 30, 200, 20)];
//    label1.text = @"启动手机通讯录";
//    label1.backgroundColor = [UIColor clearColor];
//    label1.textColor = [UIColor blackColor];
//    [headV addSubview:label1];
//    UILabel * label2 = [[UILabel alloc]initWithFrame:CGRectMake(60, 50, 200, 20)];
//    label2.text = @"与通讯录中好友建立联系";
//    label2.backgroundColor = [UIColor clearColor];
//    label2.textColor = [UIColor grayColor];
//    label2.font = [UIFont systemFontOfSize:14];
//    [headV addSubview:label2];
//    self.swith = [[UISwitch alloc]initWithFrame:CGRectMake(250, 30, 40, 60)];
//    [headV addSubview:_swith];
    
//    [_swith addTarget:self action:@selector(SwithCellChangeSwith:) forControlEvents:UIControlEventValueChanged];
//    _tableView.tableHeaderView = headV;
//    _tableView.backgroundColor = [UIColor clearColor];
//    _swith.on = appAllowGetAddress;
    
//    self.unAllowView = [[UIView alloc]initWithFrame:CGRectMake(0, 100, 320, _tableView.frame.size.height-100)];
//    _unAllowView.backgroundColor = [UIColor clearColor];
//    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(136, 40, 48, 62)];
//    imageView.image = [UIImage imageNamed:@"addressBook3"];
//    [_unAllowView addSubview:imageView];
//    UILabel * label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 130, 320, 80)];
//    label3.backgroundColor = [UIColor clearColor];
//    label3.textColor = [UIColor grayColor];
//    label3.textAlignment = NSTextAlignmentCenter;
//    label3.numberOfLines = 0;
//    label3.text = @"启动通讯录后,你可以立即联系到您游戏中\n的好友,也能够邀请到通讯录中的好友.\n\n陌游尊重用户隐私,不会泄露你的个人信息.";
//    label3.font = [UIFont systemFontOfSize:14];
//    [_unAllowView addSubview:label3];
//    [_tableView addSubview:_unAllowView];
//    _unAllowView.hidden = appAllowGetAddress;
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"激活中...";
//    if (appAllowGetAddress) {
        [self setLocalAddressBook];
//    }
    
    //初始化搜索条
    mSearchBar = [[MySearchBar alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    [mSearchBar setPlaceholder:@"关键字搜索"];
    mSearchBar.delegate = self;
    [mSearchBar sizeToFit];
    //初始化UISearchDisplayController
    searchController = [[UISearchDisplayController alloc] initWithSearchBar:mSearchBar contentsController:self];
    [searchController setDelegate:self];
    [searchController setSearchResultsDataSource:self];
    [searchController setSearchResultsDelegate:self];
    searchController.searchResultsTableView.tableHeaderView = mSearchBar;
    _tableView.tableHeaderView = mSearchBar;
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setLocalAddressBook];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *cellIdentifier = @"headerView";
    MyHeadView * view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:cellIdentifier];
    if (view == nil) {
        view = [[MyHeadView alloc]initWithReuseIdentifier:cellIdentifier];
    }
    view.titleL.text = @"尚未加入陌游的好友";
    return view;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0;
    }
    return 33;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (appAllowGetAddress) {
        return 2;
    }else
    {
        return 0;
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (appAllowGetAddress) {
        if (tableView == searchController.searchResultsTableView) {
            if (section == 0) {
                return self.searchAddressArray.count;
            }else
            {
                return self.searchOutAddressArray.count;
            }
        }else{
            if (section == 0) {
                return self.addressArray.count;
            }else
            {
                return self.outAddressArray.count;
            }
        }
    }else
    {
        return 0;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    if (tableView == searchController.searchResultsTableView) {
        if (indexPath.section == 0) {
            static NSString *identifier = @"inDoduCell";
            InDoduAddressTableViewCell *cell = (InDoduAddressTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[InDoduAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.indexPath = indexPath;
            cell.isSearch = YES;
            cell.delegate = self;
            cell.nameL.text = [self.searchAddressArray[indexPath.row] objectForKey:@"nickname"];
            cell.photoNoL.text = [NSString stringWithFormat:@"手机联系人:%@",[self.searchAddressArray[indexPath.row] objectForKey:@"addressName"]];
            
            NSString* imageIds = [self.searchAddressArray[indexPath.row] objectForKey:@"img"];
            cell.headerImage.imageURL = [ImageService getImageStr:imageIds Width:80];
            if ([[self.searchAddressArray[indexPath.row] objectForKey:@"friendShipType"] intValue] == 1) {
                [cell.addFriendB setTitle:@"" forState:UIControlStateNormal];
                cell.addFriendB.userInteractionEnabled = NO;
                [cell.addFriendB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateHighlighted];
            }
            if ([[self.searchAddressArray[indexPath.row] objectForKey:@"friendShipType"] intValue] == 2) {
                [cell.addFriendB setTitle:@"等待验证" forState:UIControlStateNormal];
                cell.addFriendB.userInteractionEnabled = NO;
                [cell.addFriendB setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:nil forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:nil forState:UIControlStateHighlighted];
            }
            if ([[self.searchAddressArray[indexPath.row] objectForKey:@"friendShipType"] isEqualToString:@"unkown"]||[[self.searchAddressArray[indexPath.row] objectForKey:@"friendShipType"] isEqualToString:@"3"]) {
                if ([[self.searchAddressArray[indexPath.row] objectForKey:@"iCare"] integerValue] == 0) {
                    [cell.addFriendB setTitle:@"加为好友" forState:UIControlStateNormal];
                    cell.addFriendB.userInteractionEnabled = YES;
                    [cell.addFriendB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"addfriend2"] forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"addfriend1"] forState:UIControlStateHighlighted];
                }else
                {
                    [cell.addFriendB setTitle:@"等待验证" forState:UIControlStateNormal];
                    cell.addFriendB.userInteractionEnabled = NO;
                    [cell.addFriendB setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:nil forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:nil forState:UIControlStateHighlighted];
                }
            }
            return cell;
        }else
        {
            static NSString *identifier = @"outDoduCell";
            OutDodeAddressTableViewCell *cell = (OutDodeAddressTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[OutDodeAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.nameL.text = [self.searchOutAddressArray[indexPath.row] objectForKey:@"name"];
            cell.photoNoL.text = [self.searchOutAddressArray[indexPath.row] objectForKey:@"mobileid"];
            return cell;
        }
    }
    else{
        if (indexPath.section == 0) {
            static NSString *identifier = @"inDoduCell";
            InDoduAddressTableViewCell *cell = (InDoduAddressTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[InDoduAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.indexPath = indexPath;
            cell.isSearch = NO;
            cell.delegate = self;
            cell.nameL.text = [self.addressArray[indexPath.row] objectForKey:@"nickname"];
            cell.photoNoL.text = [NSString stringWithFormat:@"手机联系人:%@",[self.addressArray[indexPath.row] objectForKey:@"addressName"]];
            
            NSString* imageIds = [self.addressArray[indexPath.row] objectForKey:@"img"];
            cell.headerImage.imageURL = [ImageService getImageStr:imageIds Width:80];
            if ([[self.addressArray[indexPath.row] objectForKey:@"friendShipType"] intValue] == 1) {
                [cell.addFriendB setTitle:@"" forState:UIControlStateNormal];
                cell.addFriendB.userInteractionEnabled = NO;
                [cell.addFriendB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"added"] forState:UIControlStateHighlighted];
            }
            if ([[self.addressArray[indexPath.row] objectForKey:@"friendShipType"] intValue] == 2) {
                [cell.addFriendB setTitle:@"等待验证" forState:UIControlStateNormal];
                cell.addFriendB.userInteractionEnabled = NO;
                [cell.addFriendB setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:nil forState:UIControlStateNormal];
                [cell.addFriendB setBackgroundImage:nil forState:UIControlStateHighlighted];
            }
            else if ([[self.addressArray[indexPath.row] objectForKey:@"friendShipType"] isEqualToString:@"unkown"]||[[self.addressArray[indexPath.row] objectForKey:@"friendShipType"] isEqualToString:@"3"]) {
                if ([[self.addressArray[indexPath.row] objectForKey:@"iCare"] integerValue] == 0) {
                    [cell.addFriendB setTitle:@"加为好友" forState:UIControlStateNormal];
                    cell.addFriendB.userInteractionEnabled = YES;
                    [cell.addFriendB setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"addfriend2"] forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:[UIImage imageNamed:@"addfriend1"] forState:UIControlStateHighlighted];
                }else
                {
                    [cell.addFriendB setTitle:@"等待验证" forState:UIControlStateNormal];
                    cell.addFriendB.userInteractionEnabled = NO;
                    [cell.addFriendB setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:nil forState:UIControlStateNormal];
                    [cell.addFriendB setBackgroundImage:nil forState:UIControlStateHighlighted];
                }
            }
            return cell;
        }else
        {
            static NSString *identifier = @"outDoduCell";
            OutDodeAddressTableViewCell *cell = (OutDodeAddressTableViewCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[OutDodeAddressTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.indexPath = indexPath;
            cell.delegate = self;
            cell.nameL.text = [self.outAddressArray[indexPath.row] objectForKey:@"name"];
            cell.photoNoL.text = [self.outAddressArray[indexPath.row] objectForKey:@"mobileid"];
            return cell;
        }
    }
    
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    return YES;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    if (tableView == searchController.searchResultsTableView) {
        if (indexPath.section == 0) {
            TestViewController *testVC = [[TestViewController alloc]init];
            testVC.myDelegate = self;
            testVC.testRow = indexPath.row;
            NSLog(@"点击位置行数%d----%d",indexPath.row,testVC.testRow);
            
            
            testVC.userId = [self.searchAddressArray[indexPath.row] objectForKey:@"userid"];
            testVC.titleImage = [self.searchAddressArray[indexPath.row] objectForKey:@"userid"];
            testVC.nickName = [self.searchAddressArray[indexPath.row] objectForKey:@"nickname"];
            if ([[self.searchAddressArray[indexPath.row] objectForKey:@"friendshiptype"] intValue] == 1) {
                testVC.viewType = VIEW_TYPE_FriendPage1;
            }else if ([[self.searchAddressArray[indexPath.row] objectForKey:@"friendshiptype"] intValue] == 2)
            {
                testVC.viewType = VIEW_TYPE_AttentionPage1;
            }else if ([[self.searchAddressArray[indexPath.row] objectForKey:@"friendshiptype"] intValue] == 3){
                testVC.viewType = VIEW_TYPE_FansPage1;
            }else{
                testVC.viewType = VIEW_TYPE_STRANGER1;
            }
            
            [self.navigationController pushViewController:testVC animated:YES];
            
        }else{
            PuthMessageViewController * puthmsgVC = [[PuthMessageViewController alloc]init];
            puthmsgVC.addressDic = self.searchOutAddressArray[indexPath.row];
            [self.navigationController pushViewController:puthmsgVC animated:YES];
        }
    }
    else{
        if (indexPath.section == 0) {
            TestViewController *testVC = [[TestViewController alloc]init];
            testVC.myDelegate = self;
            testVC.testRow = indexPath.row;
            testVC.userId = [self.addressArray[indexPath.row] objectForKey:@"userid"];
            testVC.titleImage = [self.addressArray[indexPath.row] objectForKey:@"userid"];
            testVC.nickName = [self.addressArray[indexPath.row] objectForKey:@"nickname"];
            if ([[self.addressArray[indexPath.row] objectForKey:@"friendshiptype"] intValue] == 1) {
                testVC.viewType = VIEW_TYPE_FriendPage1;
            }else if ([[self.addressArray[indexPath.row] objectForKey:@"friendshiptype"] intValue] == 2)
            {
                testVC.viewType = VIEW_TYPE_AttentionPage1;
            }else if ([[self.addressArray[indexPath.row] objectForKey:@"friendshiptype"] intValue] == 3){
                testVC.viewType = VIEW_TYPE_FansPage1;
            }else{
                testVC.viewType = VIEW_TYPE_STRANGER1;
            }
            
            [self.navigationController pushViewController:testVC animated:YES];
        }else{
            PuthMessageViewController * puthmsgVC = [[PuthMessageViewController alloc]init];
            puthmsgVC.addressDic = self.outAddressArray[indexPath.row];
            [self.navigationController pushViewController:puthmsgVC animated:YES];
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString];
    [self setTopViewWithTitle:@"手机通讯录" withBackButton:YES];;
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:mSearchBar.text];
    return YES;
}

-(void)filterContentForSearchText:(NSString*)searchText{
    [self.searchAddressArray removeAllObjects];
    [self.searchOutAddressArray removeAllObjects];
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchText];
    NSMutableArray * resultKeys = (NSMutableArray*)[self.keysAddressArray filteredArrayUsingPredicate:resultPredicate];
    for (NSString * key in resultKeys) {
        for (NSMutableDictionary * ddic in self.addressArray) {
            if ([KISDictionaryHaveKey(ddic, @"nickname") isEqualToString:key]) {
                [self.searchAddressArray addObject:ddic];
            }
        }
    }
    
    NSMutableArray * resultKeys2 = (NSMutableArray*)[self.keysOutAddressArray filteredArrayUsingPredicate:resultPredicate];
    for (NSString * key in resultKeys2) {
        for (NSMutableDictionary * ddic in self.outAddressArray) {
            if ([KISDictionaryHaveKey(ddic, @"name") isEqualToString:key]) {
                [self.searchOutAddressArray addObject:ddic];
            }
        }
    }
    [_tableView reloadData];
}

-(void)isAttention:(TestViewController *)view attentionSuccess:(NSInteger)i backValue:(NSString *)valueStr
{
    if ([valueStr isEqualToString:@"off"]) {
        NSMutableDictionary * dic = self.addressArray[i];
        [dic setObject:@"unkown" forKey:@"friendshipType"];
        [dic setObject:@"0" forKey:@"iCare"];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        if (self.searchAddressArray&&self.searchAddressArray.count>0) {
            NSMutableDictionary *dict = self.searchAddressArray[i];
            [dict setObject:@"unkown" forKey:@"friendshipType"];
            [dict setObject:@"0" forKey:@"iCare"];

            [searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        }

    }else{
        NSMutableDictionary * dic = self.addressArray[i];
        [dic setObject:@"unkown" forKey:@"friendshipType"];
        [dic setObject:@"1" forKey:@"iCare"];
        [_tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
        if (self.searchAddressArray&&self.searchAddressArray.count>0) {
  
        NSMutableDictionary *dict = self.searchAddressArray[i];
        [dict setObject:@"unkown" forKey:@"friendshipType"];
        [dict setObject:@"1" forKey:@"iCare"];
        [searchController.searchResultsTableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];

        }
    }
}
-(void)SwithCellChangeSwith:(UISwitch*)swith
{
    if (!systemAllowGetAddress&&swith.on) {
        [swith setOn:!swith.on animated:YES];
        UIAlertView * alertV = [[UIAlertView alloc]initWithTitle:@"通讯录已禁用" message:@"请在 设置-隐私-通讯录 启用陌游" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"告诉我怎么做", nil];
        [alertV show];
        return;
    }
    appAllowGetAddress = swith.on;
    _unAllowView.hidden = appAllowGetAddress;
    if (swith.on) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"wxr_systemAllowGetAddress"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        if (self.addressArray.count<=0) {
            [self setLocalAddressBook];
        }
        
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"wxr_systemAllowGetAddress"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [_tableView reloadData];
}


-(void)reloadTableView:(NSString*)userId{
    for (NSMutableDictionary * dic in self.searchAddressArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:userId]) {
            [dic setObject:@"1" forKey:@"iCare"];
        }
    }
    [searchController.searchResultsTableView reloadData];
    for (NSMutableDictionary * dic in self.addressArray) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]isEqualToString:userId]) {
            [dic setObject:@"1" forKey:@"iCare"];
        }
    }
    [_tableView reloadData];
}

-(void)DodeAddressCellTouchButtonWithIndexPath:(NSIndexPath *)indexPath IsSearch:(BOOL)isSearch
{
    if (indexPath.section == 0) {
        NSMutableDictionary * dic;
        if (isSearch) {
            dic = self.searchAddressArray[indexPath.row];
        }else{
            dic = self.addressArray[indexPath.row];
        }
        [self reloadTableView:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]];
        
        
        
        
        [self showMessageWindowWithContent:@"添加成功" imageType:0];
        NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
        NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
        [paramDict setObject:dic[@"userid"] forKey:@"frienduserid"];
        [paramDict setObject:@"5" forKey:@"type"];
        [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [postDict setObject:paramDict forKey:@"params"];
        [postDict setObject:@"109" forKey:@"method"];
        [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }
        }];
    }else
    {
        if ([MFMessageComposeViewController canSendText]) {
            MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
            picker.messageComposeDelegate = self;
            picker.recipients = [NSArray arrayWithObject:[self.outAddressArray[indexPath.row] objectForKey:@"mobileid"]];
            picker.body=[NSString stringWithFormat:@"游戏里找不到我的时候, 来陌游找我. 下载地址:www.momotalk.com"];
            [self presentViewController:picker animated:YES completion:^{
                
            }];
        }
        else {
            UIAlertView *alertV = [[UIAlertView alloc]initWithTitle:nil message:@"您的设备不支持短信功能" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles: nil];
            [alertV show];
        }
    }
}
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    [self dismissViewControllerAnimated:YES completion:^{
        switch (result) {
            case MessageComposeResultSent:{
                [self showMessageWindowWithContent:@"发送成功" imageType:0];
            }break;
            case MessageComposeResultFailed:{
                [self showMessageWindowWithContent:@"发送失败" imageType:0];
            }break;
            default:
                break;
        }
    }];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        TeachMeViewController * teachMeV = [[TeachMeViewController alloc]init];
        [self.navigationController pushViewController:teachMeV animated:YES];
    }
}



-(void)setLocalAddressBook{
    [hud show:YES];
    dispatch_queue_t queue = dispatch_queue_create("com.living.game.MessageAddressViewController", NULL);
    dispatch_async(queue, ^{
        self.outAddressArray = [self getAddressBook];
        [self getKeys];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
            [_tableView reloadData];
            [searchController.searchResultsTableView reloadData];
            [self uploadContacts:self.outAddressArray];
        });
    });
}

-(void)getKeys{
    for (NSMutableDictionary* dic in self.outAddressArray) {
        [self.keysOutAddressArray addObject:KISDictionaryHaveKey(dic, @"name")];
    }
}
- (NSMutableArray*)getAddressBook
{
    NSMutableArray * addressArray = [NSMutableArray array];
    //取得本地通信录名柄
    ABAddressBookRef tmpAddressBook = nil;
    tmpAddressBook=ABAddressBookCreateWithOptions(NULL, NULL);
    dispatch_semaphore_t sema=dispatch_semaphore_create(0);
    ABAddressBookRequestAccessWithCompletion(tmpAddressBook, ^(bool greanted, CFErrorRef error){
        dispatch_semaphore_signal(sema);
    });
    dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    //取得本地所有联系人记录
    if (tmpAddressBook==nil) {
        return nil;
    };
    NSArray* tmpPeoples = (__bridge NSArray*)ABAddressBookCopyArrayOfAllPeople(tmpAddressBook);
    for(id tmpPerson in tmpPeoples)
    {
        //获取的联系人单一属性:First name
        NSString* tmpFirstName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonFirstNameProperty);
        //获取的联系人单一属性:Last name
        NSString* tmpLastName = (__bridge NSString*)ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonLastNameProperty);
        //获取的联系人单一属性:Generic phone number
        ABMultiValueRef tmpPhones = ABRecordCopyValue((__bridge ABRecordRef)(tmpPerson), kABPersonPhoneProperty);
        for(NSInteger j = 0; j < ABMultiValueGetCount(tmpPhones); j++)
        {
            NSString* tmpPhoneIndex = (__bridge NSString*)ABMultiValueCopyValueAtIndex(tmpPhones, j);
            tmpPhoneIndex = [tmpPhoneIndex stringByReplacingOccurrencesOfString:@"-"withString:@""];
            NSMutableDictionary * dic = [NSMutableDictionary dictionary];
            if (tmpLastName&&tmpFirstName) {
                [dic setObject:[NSString stringWithFormat:@"%@%@",tmpLastName,tmpFirstName] forKey:@"name"];
                [dic setObject:tmpPhoneIndex forKey:@"mobileid"];
                [addressArray addObject:dic];
                
            }else if (tmpLastName)
            {
                [dic setObject:[NSString stringWithFormat:@"%@",tmpLastName] forKey:@"name"];
                [dic setObject:tmpPhoneIndex forKey:@"mobileid"];
                [addressArray addObject:dic];
            }else if (tmpFirstName)
            {
                [dic setObject:[NSString stringWithFormat:@"%@",tmpFirstName] forKey:@"name"];
                [dic setObject:tmpPhoneIndex forKey:@"mobileid"];
                [addressArray addObject:dic];
            }
        }
        CFRelease(tmpPhones);
    }
    CFRelease(tmpAddressBook);
    return addressArray;
}

-(void)uploadContacts:(NSMutableArray*)arr
{
    if (!arr) {
        UIAlertView * alertV = [[UIAlertView alloc]initWithTitle:nil message:@"您可能禁用了通讯录,请在 设置-隐私-通讯录 启用陌游" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"告诉我怎么做", nil];
        [alertV show];
        return;
    }
    if (arr.count<=0) {
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:nil message:@"未发现您的通讯录,您可以直接返回" delegate:nil cancelButtonTitle:@"知道啦" otherButtonTitles: nil];
        [alert show];
        return;
    }
    NSMutableDictionary* params = [[NSMutableDictionary alloc]init];
    [params setObject:arr forKey:@"contacts"];
    NSMutableDictionary* body = [[NSMutableDictionary alloc]init];
    [body addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [body setObject:params forKey:@"params"];
    [body setObject:@"162" forKey:@"method"];
    [body setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:body   success:^(AFHTTPRequestOperation *operation, id responseObject) {
       

        NSMutableArray *arr1 = [NSMutableArray array];
        NSMutableArray *arr2 = [NSMutableArray array];
        for (NSDictionary * dic in responseObject) {
            NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:dic];
            [dict setObject:@"0" forKey:@"iCare"];
            [arr1 addObject:dict];
            [arr2 addObject:[dic objectForKey:@"nickname"]];
            
        }
//        [self.keysAddressArray removeAllObjects];
//        [self.addressArray removeAllObjects];
        self.addressArray  = arr1;
        self.keysAddressArray =arr2;
        
        self.outAddressArray =  [self detail:arr JoinedMoyou:self.addressArray];


        [self.keysOutAddressArray removeAllObjects];
        [self getKeys];
        [[NSUserDefaults standardUserDefaults]setObject:self.addressArray forKey:@"addressArray"];
        [[NSUserDefaults standardUserDefaults]setObject:self.keysAddressArray forKey:@"keysAddressArray"];
        [[NSUserDefaults standardUserDefaults]setObject:self.keysOutAddressArray forKey:@"keysOutAddressArray"];
        [_tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}


-(NSMutableArray*)detail:(NSMutableArray*)arr JoinedMoyou:(NSMutableArray*)arr2{
    NSMutableArray* lingshiArray = [arr mutableCopy];
    for (NSMutableDictionary* dict in arr2) {
        for (NSDictionary* dic in arr) {
            if ([dic[@"mobileid"]isEqualToString:dict[@"username"]]) {
                [lingshiArray removeObject:dic];
                [dict setValue:dic[@"name"] forKey:@"addressName"];
            }
        }
    }
    return lingshiArray;
}

@end
