//
//  FriendRecommendViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-31.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "FriendRecommendViewController.h"
#import "AddContactViewController.h"
#import "DSRecommendList.h"
#import "AppDelegate.h"
#import "TestViewController.h"
#import "ImageService.h"
#import "ImgCollCell.h"
@interface FriendRecommendViewController ()
{
    UITableView*   m_myTableView;
    
    NSMutableArray*       m_tableData;
    NSInteger      m_pageIndex;
    UICollectionView *m_customCollView;
    UICollectionViewFlowLayout *m_layout;
    NSMutableArray *addMemArray;
    UIButton *m_button;
    UIView *customView;
}
@end

@implementation FriendRecommendViewController

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

    [self setTopViewWithTitle:@"好友推荐" withBackButton:YES];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
//    [shareButton setBackgroundImage:KUIImage(@"share_normal.png") forState:UIControlStateNormal];
//    [shareButton setBackgroundImage:KUIImage(@"share_click.png") forState:UIControlStateHighlighted];
    [shareButton setTitle:@"多选" forState:UIControlStateNormal];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    m_tableData = [[NSMutableArray alloc] initWithCapacity:1];
    m_pageIndex = 0;
    addMemArray = [NSMutableArray array];
    
//    UIButton *addButton=[UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
//    [addButton setBackgroundImage:KUIImage(@"add_button_normal") forState:UIControlStateNormal];
//    [addButton setBackgroundImage:KUIImage(@"add_button_click") forState:UIControlStateHighlighted];
//    [addButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];


    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-(KISHighVersion_7?0:20))];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.allowsMultipleSelectionDuringEditing = YES;

    [self.view addSubview:m_myTableView];
    
    
    UIButton *chooseAllBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseAllBtn.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
//    [chooseAllBtn setBackgroundImage:KUIImage(@"delete_normal") forState:UIControlStateNormal];
//    [chooseAllBtn setBackgroundImage:KUIImage(@"delete_click") forState:UIControlStateHighlighted];
    [chooseAllBtn setTitle:@"全选" forState:UIControlStateNormal];
    [self.view addSubview:chooseAllBtn];
    [chooseAllBtn addTarget:self action:@selector(didClickChooseAll:) forControlEvents:UIControlEventTouchUpInside];
    
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.allowsMultipleSelectionDuringEditing = YES;
    [self.view addSubview:m_myTableView];
    hud = [[MBProgressHUD alloc] init];
    hud.labelText = @"查询中...";
    
//    [self buildAddMembersScroll];
    [self.view addSubview:hud];
}


-(void)buildAddMembersScroll
{
    customView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-50-(KISHighVersion_7?0:20), 320, 50)];
    
    UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 2)];
    lineImg.image = KUIImage(@"line");
    lineImg.backgroundColor = [UIColor clearColor];
    [customView addSubview:lineImg];
    
    customView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:customView];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    line1.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [customView addSubview:line1];
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0.5, 320, 0.5)];
    line2.backgroundColor = [UIColor grayColor];
    [customView addSubview:line2];
    
    
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 15;
    m_layout.minimumLineSpacing = 5;
    m_layout.itemSize = CGSizeMake(34, 34);
    [m_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    m_customCollView = [[UICollectionView alloc]initWithFrame:CGRectMake(10, 5, 240, 40) collectionViewLayout:m_layout];
    [m_customCollView registerClass:[ImgCollCell class] forCellWithReuseIdentifier:@"ImageCell"];
    m_customCollView.delegate = self;
    m_customCollView.dataSource = self;
    m_customCollView.backgroundColor = [UIColor clearColor];
    [customView addSubview:m_customCollView];
    
    m_button = [[UIButton alloc]initWithFrame:CGRectMake(260, 10, 55, 25)];
    [m_button setBackgroundImage:KUIImage(@"addmembers_ok") forState:UIControlStateNormal];
    [m_button setTitle:@"确定" forState:UIControlStateNormal];
    m_button.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [m_button addTarget:self action:@selector(addMembers:) forControlEvents:UIControlEventTouchUpInside];
    [customView addSubview:m_button];
}




-(void)didClickChooseAll:(UIButton *)sender
{
    if (m_myTableView.editing) {
        [m_myTableView setEditing:NO animated:YES];
        m_myTableView.frame = CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX);
        [sender setTitle:@"全选" forState:UIControlStateNormal];
        [customView removeFromSuperview];
        [addMemArray removeAllObjects];

    }else{
        [sender setTitle:@"取消" forState:UIControlStateNormal];
        m_myTableView.frame = CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-50);
        [self buildAddMembersScroll];
    [m_myTableView setEditing:YES animated:YES];
    for (int i =0; i<m_tableData.count; i++) {
        NSDictionary *dic = [m_tableData objectAtIndex:i];
        BOOL state = [KISDictionaryHaveKey(dic, @"state")boolValue];
        if (!state) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [m_myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
   NSArray *arr =[m_myTableView indexPathsForSelectedRows];
    for (NSIndexPath *path in arr) {
        [addMemArray addObject:m_tableData[path.row]];
    }
   [m_customCollView reloadData];
    }
>>>>>>> AffirmGame
}

-(void)viewDidAppear:(BOOL)animated
{
    [self getDataByStore];
}
- (void)getDataByStore
{
    [m_tableData removeAllObjects];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dRecommend = [DSRecommendList MR_findAllInContext:localContext];
        for (DSRecommendList* Recommend in dRecommend) {
            NSDictionary* tempDic = [NSDictionary dictionaryWithObjectsAndKeys:Recommend.headImgID, @"headImgID", Recommend.nickName, @"nickname", Recommend.userName, @"username", Recommend.state, @"state", Recommend.fromID, @"type", Recommend.fromStr,@"dis",Recommend.userid,@"userid",Recommend.recommendReason,@"recommendReason",nil];
            [m_tableData insertObject:tempDic atIndex:0];
        }
        m_pageIndex = [m_tableData count] > 20?20:[m_tableData count];
        [m_myTableView reloadData];
    }];
}

#pragma mark -添加好友
- (void)addButtonClick:(id)sender
{
    [m_myTableView setEditing:NO animated:YES];
    [customView removeFromSuperview];
    [addMemArray removeAllObjects];
    m_myTableView.frame = CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-50);
    AddContactViewController * addV = [[AddContactViewController alloc] init];
    [self.navigationController pushViewController:addV animated:YES];
}

#pragma mark 表格
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_tableData count] < 20 ? [m_tableData count] : m_pageIndex;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCharacter";
    RecommendCell *cell = (RecommendCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[RecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSDictionary* tempDic = [m_tableData objectAtIndex:indexPath.row];
    cell.headImageV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];

    cell.headImageV.imageURL=[ImageService getImageStr:KISDictionaryHaveKey(tempDic, @"headImgID") Width:80];
    
    cell.nameLabel.text = KISDictionaryHaveKey(tempDic, @"nickname");
    
    if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"1"]) {
        cell.fromImage.image = KUIImage(@"recommend_phone");
    }
    else if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"2"]) {
        cell.fromImage.image = KUIImage(@"recommend_star");
    }
    else  if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"3"]){
        cell.fromImage.image = KUIImage(@"recommend_wow");
    }
    else  if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"4"]){
        cell.fromImage.image = KUIImage(@"recommend_tongfumeizi");
    }
    else  if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"5"]){
        cell.fromImage.image = KUIImage(@"recommend_daren");
    }
    else  if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"6"]){
        cell.fromImage.image = KUIImage(@"recommend_suijimeizi");
    }
    
    cell.fromLabel.text = KISDictionaryHaveKey(tempDic, @"dis");
    
    if ([KISDictionaryHaveKey(tempDic, @"state") isEqualToString:@"0"]) {
        cell.statusButton.backgroundColor = kColorWithRGB(51, 164, 31, 1.0);
        [cell.statusButton setTitle:@"添加" forState:UIControlStateNormal];
        [cell.statusButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    else
    {
        cell.statusButton.backgroundColor = [UIColor clearColor];
        [cell.statusButton setTitle:@"已添加" forState:UIControlStateNormal];
        [cell.statusButton setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
    }
    cell.myDelegate = self;
    cell.myIndexPath = indexPath;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];


    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSArray *arr =[m_myTableView indexPathsForSelectedRows];
//    
//    for (NSIndexPath *path in arr) {
//        
//        [addMemArray addObject:m_tableData[path.row]];
//    }
//    
//    [m_customCollView reloadData];
    NSDictionary *dic = [m_tableData objectAtIndex:indexPath.row];
    [addMemArray addObject:dic];

 NSLog(@"+++%d",addMemArray.count);
    
    [m_customCollView reloadData];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [m_tableData objectAtIndex:indexPath.row];
    [addMemArray removeObject:dic];
    NSLog(@"---%d",addMemArray.count);
    [m_customCollView reloadData];

}

#pragma mark ---collectionview delegate  datasourse

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return addMemArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImgCollCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCell" forIndexPath:indexPath];
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    if (indexPath.row ==addMemArray.count-1) {
        cell.imageView.placeholderImage = KUIImage(imageids);
        cell.imageView.imageURL = nil;
    }else{
        cell.imageView.placeholderImage = [UIImage imageNamed:headplaceholderImage];
        cell.imageView.imageURL=[ImageService getImageStr:KISDictionaryHaveKey(tempDict, @"headImgID") Width:80];
    }
    return cell;
}
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





- (void)cellHeardImgClick:(RecommendCell*)myCell
{
    [m_myTableView setEditing:NO animated:YES];
    [customView removeFromSuperview];
    [addMemArray removeAllObjects];
    m_myTableView.frame = CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX-50);
    NSDictionary* tempDict = [m_tableData objectAtIndex:myCell.myIndexPath.row];
    TestViewController *detailV = [[TestViewController alloc] init];
    
    detailV.userId = KISDictionaryHaveKey(tempDict, @"userid");
    detailV.nickName = KISDictionaryHaveKey(tempDict, @"nickname");
    detailV.isChatPage = NO;
    [self.navigationController pushViewController:detailV animated:YES];
}

- (void)cellAddButtonClick:(RecommendCell*)myCell
{
    NSInteger row = myCell.myIndexPath.row;
    NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [tempDic addEntriesFromDictionary:[m_tableData objectAtIndex:row]];
    

    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:KISDictionaryHaveKey(tempDic, @"userid")forKey:@"frienduserid"];
    [paramDict setObject:KISDictionaryHaveKey(tempDic, @"recommendReason") forKey:@"recommendReason"];
    if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"1"]) {
        [paramDict setObject:@"5" forKey:@"type"];
    }
    else if ([KISDictionaryHaveKey(tempDic, @"type") isEqualToString:@"2"]) {
        [paramDict setObject:@"4" forKey:@"type"];
    }
    else if ([KISDictionaryHaveKey(tempDic, @"type")isEqualToString:@"4"]||[KISDictionaryHaveKey(tempDic, @"type")isEqualToString:@"5"])
    {
        [paramDict setObject:@"7" forKey:@"type"];
    }
    else  {
        [paramDict setObject:@"3" forKey:@"type"];
    }
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"109" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        NSString * userid=[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"userid")];
        [DataStoreManager deleteMemberFromListWithUserid:userid];
        
         if ([responseObject isKindOfClass:[NSDictionary class]])
        {
            [DataStoreManager changshiptypeWithUserId:userid type:KISDictionaryHaveKey(responseObject, @"shiptype")];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
        }
        for (int i =0 ;i<m_tableData.count; i++) {
            NSDictionary *dict = [m_tableData objectAtIndex:i];
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"userid")]isEqualToString:userid]) {
                [m_tableData removeObject:dict];
            }
        }
        [self showMessageWindowWithContent:@"关注成功" imageType:0];
        [m_myTableView reloadData];
        
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
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
        editingStyle =UITableViewCellEditingStyleDelete|UITableViewCellEditingStyleInsert;
    
}

-(void)requestPeopleInfoWithName:(NSString *)userName ForType:(int)type
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userName forKey:@"username"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"201" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];

    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"111--好友推荐重新请求之后的用户信息");
        [[UserManager singleton] saveUserInfo:responseObject];
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [hud hide:YES];
    }];
}

#pragma mark ---开始邀请成员
-(void)addMembers:(id)sender
{
    if (addMemArray.count>1) {
        
        NSMutableArray *customArr = [NSMutableArray arrayWithArray:addMemArray];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic  in customArr) {
            
            NSString *typeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"type")];
            NSString *recommendReason =[ GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"recommendReason")];
            NSString *userid =[ GameCommon getNewStringWithId: KISDictionaryHaveKey(dic, @"userid")];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:typeStr,@"type",recommendReason,@"recommendReason",userid,@"userid", nil];
            [arr addObject:dict];
        }
        [self updataInfoWithId:arr];
    }
}

-(void)updataInfoWithId:(NSArray *)arr
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * paramsDict = [NSMutableDictionary dictionary];
     [paramsDict setObject:arr forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"292" forKey:@"method"];
    [postDict setObject:paramsDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        [m_myTableView setEditing:NO animated:YES];
        
        NSMutableArray *sarr = [NSMutableArray arrayWithArray:m_tableData];
        for (NSDictionary *dic in addMemArray) {
            [DataStoreManager deleteMemberFromListWithUserid:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")]];
            [sarr removeObject:dic];
        }
        for (NSDictionary *dict in sarr) {
            [DataStoreManager updateRecommendStatus:@"1" ForPerson:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"userid")]];
        }
        [self getDataByStore];
        [addMemArray removeAllObjects];
        [customView removeFromSuperview];
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView * alertView_1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alertView_1 show];
            }
        }
        [hud hide:YES];
    }];
    
}
-(NSString*)getImageIdsStr:(NSArray*)imageIdArray
{
    NSString* headImgStr = @"";
    for (int i = 0;i<imageIdArray.count;i++) {
        NSString * temp1 = [imageIdArray objectAtIndex:i];
        headImgStr = [headImgStr stringByAppendingFormat:@"%@,",temp1];
    }
    return headImgStr;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
