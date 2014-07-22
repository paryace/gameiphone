//
//  InvitationMembersViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InvitationMembersViewController.h"
#import "MJRefresh.h"
#import "ImgCollCell.h"
#import "LocationManager.h"
#import "TestViewController.h"
@interface InvitationMembersViewController ()
{
    UIScrollView                       *  m_mainScroll;
    UITableView                        *  m_rTableView;//好友界面
    NSMutableArray                     *  m_rArray;//好友数据
    NSMutableArray                     *  addMemArray;//邀请人数数据
    
    UIButton                           *  m_button;
    UICollectionView                   *  m_customCollView;//邀请人员列表
    UICollectionViewFlowLayout         *  m_layout;
    UIView                             *  m_listView;
    
    
    AddGroupMemberCell                 *  cell1; //
    
    
    NSInteger                             m_tabTag;
    UIButton                           * chooseAllBtn;
    
    NSString                           * m_realmStr;
    
}
@end

@implementation InvitationMembersViewController

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
    // Do any additional setup after loading the view.
    [self setTopViewWithTitle:@"添加成员" withBackButton:YES];
    
    chooseAllBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    chooseAllBtn.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [chooseAllBtn setImage:KUIImage(@"choose_all") forState:UIControlStateNormal];
    [chooseAllBtn setImage:KUIImage(@"choose_no") forState:UIControlStateSelected];
    [self.view addSubview:chooseAllBtn];
    [chooseAllBtn addTarget:self action:@selector(didClickChooseAll:) forControlEvents:UIControlEventTouchUpInside];
    
    
    m_rArray = [NSMutableArray array];
    m_tabTag = 1;
    addMemArray = [NSMutableArray array];
    
    [addMemArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil]];
    
    [self buildMainView];
    [self buildlistView];
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"获取中...";
    
    
    [self getInfo];

}

-(UIButton *)buildButtonWithFrame:(CGRect)frame img1:(NSString *)img1 img2:(NSString*)img2
{
    UIButton *button = [[UIButton alloc]initWithFrame:frame];
    [button setImage:KUIImage(img1) forState:UIControlStateNormal];
    [button setImage:KUIImage(img2) forState:UIControlStateSelected];
    return button;
}

-(void)buildlistView
{
    m_listView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeigth-50-(KISHighVersion_7?0:20), 320, 40)];
    m_listView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    [self.view addSubview:m_listView];
    
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
    [m_listView addSubview:m_customCollView];
    
    m_button = [[UIButton alloc]initWithFrame:CGRectMake(260, 10, 55, 25)];
    [m_button setBackgroundImage:KUIImage(@"addmembers_ok") forState:UIControlStateNormal];
    [m_button setTitle:@"确定" forState:UIControlStateNormal];
    m_button.titleLabel.font = [UIFont boldSystemFontOfSize:11];
    [m_button addTarget:self action:@selector(addMembers:) forControlEvents:UIControlEventTouchUpInside];
    [m_listView addSubview:m_button];
}

-(void)DetectNetwork
{
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        [hud hide:YES];
        [self showMessageWithContent:@"请求数据失败，请检查网络" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
}

-(void)didClickChooseAll:(UIButton *)sender
{
    NSDictionary *customDic = [NSDictionary dictionaryWithObjectsAndKeys:@"find_billboard",@"img", nil];
    switch (m_tabTag) {
        case 1:
            if (sender.selected) {
                sender.selected = NO;
                for (NSMutableDictionary *dic in m_rArray) {
                    [dic setObject:@"1" forKey:@"choose"];
                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];
                }
                
                
            }else{
                sender.selected = YES;
                for (NSMutableDictionary *dic in m_rArray) {
                    [dic setObject:@"2" forKey:@"choose"];
                    
                    if ([addMemArray containsObject:dic]) {
                        [addMemArray removeObject:dic];
                    }
                }
                if ([addMemArray containsObject:customDic]) {
                    [addMemArray removeObject:customDic];
                }
                [addMemArray addObjectsFromArray:m_rArray];
                [addMemArray addObject:customDic];
                if (addMemArray.count==0) {
                    [m_button setTitle:[NSString stringWithFormat:@"确定"] forState:UIControlStateNormal];
                }else{
                    [m_button setTitle:[NSString stringWithFormat:@"确定(%d)",addMemArray.count-1] forState:UIControlStateNormal];            }
                
                
            }
            
            [m_rTableView reloadData];
            
            
            
            break;
            
        default:
            break;
    }
    [m_customCollView reloadData];
    
}



-(void)buildMainView
{
    
    m_rTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth-startX-50)];
    m_rTableView.delegate = self;
    m_rTableView.dataSource =self;
    [self.view addSubview:m_rTableView];
    
}


-(void)getInfo
{
    hud.labelText = @"获取中...";
    //    [hud showAnimated:YES whileExecutingBlock:^{
    NSMutableDictionary *userinfo=[DataStoreManager  newQuerySections:@"1" ShipType2:@"2"];
    
    
    NSMutableDictionary* result = [userinfo objectForKey:@"userList"];
    NSMutableArray* keys = [userinfo objectForKey:@"nameKey"];
    
    for (int i =0; i<keys.count; i++) {
        NSArray *array = [result objectForKey:keys[i]];
        for (NSMutableDictionary *dic in array) {
            [dic setValue:@"1" forKey:@"choose"];
            [dic setValue:@"friends" forKeyPath:@"tabType"];
            [dic setObject:[NSString stringWithFormat:@"%d",i] forKey:@"row"];
        }
        [m_rArray addObjectsFromArray:array];
    }
    [m_rTableView reloadData];
}




-(void)addMembers:(id)sender
{
    if (addMemArray.count>1) {
        
        NSMutableArray *customArr = [NSMutableArray arrayWithArray:addMemArray];
        [customArr removeLastObject];
        NSMutableArray *arr = [NSMutableArray array];
        for (NSDictionary *dic  in customArr) {
            
            NSString *userid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
            
            if (![arr containsObject:userid]) {
                [arr addObject:userid];
            }
        }
        
        [self updataInfoWithId:[self getImageIdsStr:arr]];
    }
    
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
-(void)updataInfoWithId:(NSString *)str
{
    [hud show:YES];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.roomId forKey:@"roomId"];
    [paramDict setObject:str forKey:@"userids"];
    [paramDict setObject:self.gameId forKey:@"gameid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"287" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        [self.navigationController popViewControllerAnimated:YES];
        
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

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return m_rArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *indefine = @"cell";
    AddGroupMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:indefine];
    if (!cell) {
        cell = [[AddGroupMemberCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indefine];
    }
    
    cell.tag = 100+indexPath.row;
    cell.myDelegate = self;
    
    NSDictionary * tempDict ;
        tempDict = m_rArray[indexPath.row];
        cell.disLabel.hidden = YES;
    
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    
    cell.headImg.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImg.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"choose")]intValue]==1) {
        cell.chooseImg.image = KUIImage(@"unchoose");
    }else{
        cell.chooseImg.image = KUIImage(@"choose");
    }
    cell.nameLabel.text = nickName;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddGroupMemberCell*cell;
    NSMutableDictionary * tempDict;
        cell =(AddGroupMemberCell*)[m_rTableView cellForRowAtIndexPath:indexPath];
        tempDict = m_rArray[indexPath.row];

    
    if (cell.chooseImg.image ==KUIImage(@"unchoose")) {
        cell.chooseImg.image = KUIImage(@"choose");
        NSDictionary *dic = tempDict;
        [tempDict setObject:@"2" forKey:@"choose"];
        //        [dic setValue:@(indexPath.row) forKey:@"row"];
        [addMemArray insertObject:dic atIndex:addMemArray.count-1];
        
    }else{
        cell.chooseImg.image =KUIImage(@"unchoose");
        NSDictionary *dic = tempDict;
        [tempDict setObject:@"1" forKey:@"choose"];
        
        //        [dic setValue:@(indexPath.row) forKey:@"row"];
        
        [addMemArray removeObject:dic];
    }
    [m_customCollView reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];
    int count = addMemArray.count;
    NSString *title = [NSString stringWithFormat:@"确定(%d)",count-1];
    [m_button setTitle:title forState:UIControlStateNormal];
    
    
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
        cell.imageView.imageURL=[ImageService getImageStr:imageids Width:80];
    }
    return cell;
}

-(void)enterMembersInfoPageWithCell:(AddGroupMemberCell*)cell
{
    NSDictionary * tempDict =[NSDictionary dictionary];
 
            tempDict = m_rArray[cell.tag-100];
    TestViewController *test =[[ TestViewController alloc]init];
    test.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"userid")];
    test.nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"nickname")];
    [self.navigationController pushViewController:test animated:YES];
}




-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row ==addMemArray.count-1) {
        return;
    }
    
    NSDictionary * tempDict =[addMemArray objectAtIndex:indexPath.row];
    
    
    int row = [KISDictionaryHaveKey(tempDict, @"row")intValue];
    
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"row")]intValue] inSection:0];
    
    
    NSMutableDictionary *dic;
    
        dic = [m_rArray objectAtIndex:row];
        cell1 = (AddGroupMemberCell*)[m_rTableView cellForRowAtIndexPath:path];
    
    [dic setObject:@"1" forKey:@"choose"];
    cell1.chooseImg.image = KUIImage(@"unchoose");
    
    [addMemArray removeObject:tempDict];
    [m_customCollView reloadData];
    int count = addMemArray.count-1;
    NSString *title;
    if (count==0) {
        title = [NSString stringWithFormat:@"确定"];
    }else{
        title = [NSString stringWithFormat:@"确定(%d)",addMemArray.count-1];
    }
    [m_button setTitle:title forState:UIControlStateNormal];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    m_customCollView.contentOffset = CGPointMake(addMemArray.count*44, 0);
    [UIView commitAnimations];
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
