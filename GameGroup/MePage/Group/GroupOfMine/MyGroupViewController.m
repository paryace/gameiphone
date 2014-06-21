//
//  MyGroupViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyGroupViewController.h"
#import "JoinInGroupViewController.h"
#import "GroupOfMineCell.h"
#import "GroupInformationViewController.h"
#import "ReusableView.h"
#import "SearchGroupViewController.h"
#import "AddGroupViewController.h"
#import "BillboardViewController.h"

@interface MyGroupViewController ()
{
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *groupCollectionView;
    NSMutableArray *myGroupArray;
    UIView *cellView;
    NSDictionary *dict;
    CGFloat imageHight;
    NSInteger msgCount;
}
@end
@implementation MyGroupViewController

NSString *const RAMCollectionViewFlemishBondHeaderKind = @"RAMCollectionViewFlemishBondHeaderKind";
static NSString * const HeaderIdentifier = @"HeaderIdentifier";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSInteger localMsgCount =  [self loadMsgCount:self.msgUnReadCount];
    msgCount = self.msgUnReadCount +localMsgCount;
    NSMutableArray * bills = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    if (bills&&bills.count>0) {
        dict = [bills objectAtIndex:0];
    }else{
        dict=nil;
    }
    [groupCollectionView reloadData];
}

-(NSInteger)loadMsgCount:(NSInteger)tempCount
{
    if (![[NSUserDefaults standardUserDefaults]objectForKey: Billboard_msg_count2]) {
        [[NSUserDefaults standardUserDefaults]setObject:@(tempCount) forKey:Billboard_msg_count2];
         [[NSUserDefaults standardUserDefaults] synchronize];
        return 0;
    }
    int i =[[[NSUserDefaults standardUserDefaults]objectForKey: Billboard_msg_count2]intValue];
    [[NSUserDefaults standardUserDefaults]setObject:@(i+tempCount) forKey:Billboard_msg_count2];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return i;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"我的组织" withBackButton:NO];
    
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, KISHighVersion_7 ? 20 : 0, 65, 44)];
    [backButton setBackgroundImage:KUIImage(@"btn_back") forState:UIControlStateNormal];
    [backButton setBackgroundImage:KUIImage(@"btn_back_onclick") forState:UIControlStateHighlighted];
    backButton.backgroundColor = [UIColor clearColor];
    [backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNet:) name:@"RefreshMyGroupList" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:Billboard_msg object:nil];

    myGroupArray = [NSMutableArray array];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(didClickCreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    NSMutableArray * bills = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    if (bills&&bills.count>0) {
        dict = [bills objectAtIndex:0];
    }
    imageHight = (320-15)/4;
    m_layout = [[UICollectionViewFlowLayout alloc]init];
    m_layout.minimumInteritemSpacing = 1;
    m_layout.minimumLineSpacing =5;
    m_layout.itemSize = CGSizeMake(imageHight, imageHight);
    m_layout.headerReferenceSize = CGSizeMake(320, 70);
    m_layout.sectionInset = UIEdgeInsetsMake(10,3,3,3);
    
    groupCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, startX, 320, 70+10+imageHight+10) collectionViewLayout:m_layout];
    groupCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
    groupCollectionView.scrollEnabled = YES;
    groupCollectionView.delegate = self;
    groupCollectionView.dataSource = self;
    [groupCollectionView registerClass:[GroupOfMineCell class] forCellWithReuseIdentifier:@"titleCell"];
    [groupCollectionView registerClass:[ReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderIdentifier];
    groupCollectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:groupCollectionView];
    
    
    cellView = [[UIView alloc]initWithFrame:CGRectMake(0, startX+(70+10+imageHight+10), 320, 200)];
    UILabel *lajiLabel= [[ UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 20)];
    lajiLabel.backgroundColor = [UIColor clearColor];
    lajiLabel.textColor = [UIColor grayColor];
    lajiLabel.text = @"立即添加游戏组织,开始更好的游戏体验!";
    lajiLabel.textAlignment = NSTextAlignmentCenter;
    lajiLabel.font = [UIFont systemFontOfSize:12];
    [cellView addSubview:lajiLabel];
    [self.view addSubview:cellView];
    [self loadCacheGroupList];
    [self getGroupListFromNet];
}
-(void)backButtonClick:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:0 forKey:Billboard_msg_count];
    [[NSUserDefaults standardUserDefaults] synchronize];
   [self.navigationController popViewControllerAnimated:YES];

}
#pragma mark 收到公告消息
-(void)receivedBillboardMsg:(NSNotification*)sender
{
    msgCount++;
    [self loadMsgCount:1];
    
    [[NSUserDefaults standardUserDefaults]setObject:0 forKey:Billboard_msg_count];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDictionary * msg = sender.userInfo;
    NSString * payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    NSString * groupName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupName")];
    NSString * backgroundImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"backgroundImg")];
    NSString * billboard = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"billboard")];
    NSString * billboardId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"billboardId")];
    NSString * createDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"createDate")];

    [msg setValue:groupId forKey:@"groupId"];
    [msg setValue:groupName forKey:@"groupName"];
    [msg setValue:backgroundImg forKey:@"backgroundImg"];
    [msg setValue:billboard forKey:@"billboard"];
    [msg setValue:billboardId forKey:@"billboardId"];
    [msg setValue:createDate forKey:@"createDate"];
    dict = msg;
    [groupCollectionView reloadData];
}
-(void)refreshNet:(id)sender
{
    [self getGroupListFromNet];
}

#pragma mark ---创建群
-(void)didClickCreateGroup:(id)sender
{
    AddGroupViewController *addGroupView =[[ AddGroupViewController alloc]init];
    [self.navigationController pushViewController:addGroupView animated:YES];
}

//加载本地缓存数据
-(void)loadCacheGroupList
{
    NSMutableArray * groupList = [DataStoreManager queryGroupInfoList];
    [self setGroupList:groupList];
}

//加载服务器数据
-(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"230" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {

        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            [self setGroupList:responseObject];
            
            for (NSMutableDictionary * groupInfo in responseObject) {
                [DataStoreManager saveDSGroupList:groupInfo];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}

-(void)setGroupList:(NSMutableArray*)responseObject
{
    [myGroupArray removeAllObjects];
    [myGroupArray addObjectsFromArray:responseObject];
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"tianjiazhaopian",@"backgroundImg", nil];
    [myGroupArray addObject:dic];
    if (myGroupArray.count<4) {
        groupCollectionView.frame = CGRectMake(0, startX, 320, 70+10+imageHight+10);
        cellView.frame = CGRectMake(0, startX+(70+10+imageHight+10), 320, 200);
    }
    if (myGroupArray.count>4) {
        groupCollectionView.frame = CGRectMake(0, startX, 320, 70+(imageHight+10)*2+10);
        cellView.frame = CGRectMake(0, startX+(70+(imageHight+10)*2+10), 320, 180);
    }
    [groupCollectionView reloadData];

}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSLog(@"-------%d",myGroupArray.count);
    return myGroupArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GroupOfMineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
    NSMutableDictionary * cellDic = [myGroupArray objectAtIndex:indexPath.row];
    if (indexPath.row ==myGroupArray.count-1) {
        cell.headImgView.placeholderImage =nil;
        cell.headImgView.imageURL = nil;
        NSString *imgStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(cellDic, @"backgroundImg")];
        cell.headImgView.placeholderImage = KUIImage(imgStr);
        cell.headImgView.imageURL = nil;
        cell.titleLabel.backgroundColor = [UIColor clearColor];
        cell.titleLabel.text = @"";
    }else{
        cell.headImgView.placeholderImage = KUIImage(@"group_icon");
        cell.headImgView.imageURL = [ImageService getImageUrl3:KISDictionaryHaveKey(cellDic, @"backgroundImg") Width:120];
        cell.titleLabel.backgroundColor  =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
        cell.titleLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
        
    }
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath

{
    NSDictionary *dic = [myGroupArray objectAtIndex:indexPath.row];
    if (indexPath.row ==myGroupArray.count-1) {
        JoinInGroupViewController *joinIn = [[JoinInGroupViewController alloc]init];
        [self.navigationController pushViewController:joinIn animated:YES];
  
    }else{
        GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
        gr.groupId =KISDictionaryHaveKey(dic, @"groupId");
        gr.isAudit = NO;
        [self.navigationController pushViewController:gr animated:YES];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *titleView;
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HeaderIdentifier forIndexPath:indexPath];
        ReusableView * reu = ((ReusableView *)titleView);
        reu.delegate = self;
        [reu setInfo:dict setMsgCount:msgCount];
    }
    return titleView;
}

//点击
-(void)onClick:(UIButton*)sender
{
    msgCount=0;
    [[NSUserDefaults standardUserDefaults]setObject:@(0) forKey:Billboard_msg_count2];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    BillboardViewController *joinIn = [[BillboardViewController alloc]init];
    [self.navigationController pushViewController:joinIn animated:YES];
}

-(void)enterSearchGroupPage:(id)sender
{
    JoinInGroupViewController *joinIn = [[JoinInGroupViewController alloc]init];
    [self.navigationController pushViewController:joinIn animated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
