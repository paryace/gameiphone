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
#import "NewSearchGroupController.h"
#import "MyGroupsTableViewCell.h"
@interface MyGroupViewController ()
{
    UICollectionViewFlowLayout *m_layout;
    UICollectionView *groupCollectionView;
    NSMutableArray *myGroupArray;
    UIView *cellView;
    NSDictionary *dict;
    CGFloat imageHight;
    NSInteger msgCount;
    UITableView * m_myTableView;
}
@end
@implementation MyGroupViewController

NSString *const RAMCollectionViewFlemishBondHeaderKind = @"RAMCollectionViewFlemishBondHeaderKind";
static NSString * const HeaderIdentifier = @"HeaderIdentifier";

- (void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    [self initMsgCount];
    NSMutableArray * bills = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    if (bills&&bills.count>0) {
        dict = [bills objectAtIndex:0];
    }else{
        dict=nil;
    }
    [groupCollectionView reloadData];
}
- (void)dealloc
{
    //删除通知
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"refelsh_myGroupTableView" object:nil];
}
//初始化公告未读消息数量
-(void)initMsgCount
{
    NSNumber *bullboardMsgCount = [[NSUserDefaults standardUserDefaults]objectForKey:Billboard_msg_count];
    msgCount = [bullboardMsgCount intValue];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"我的组织" withBackButton:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshNet:) name:@"refelsh_groupInfo_wx" object:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNet:) name:@"RefreshMyGroupList" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:Billboard_msg object:nil];
    // 我的组织
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshTableView:) name:@"refelsh_myGroupTableView" object:nil];
    
    myGroupArray = [NSMutableArray array];
    
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"createGroup_click") forState:UIControlStateHighlighted];
//    [shareButton setTitle:@"创建" forState:UIControlStateNormal];
    shareButton.titleLabel.font = [UIFont systemFontOfSize: 18.0];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(didClickCreateGroup:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    NSMutableArray * bills = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    if (bills&&bills.count>0) {
        dict = [bills objectAtIndex:0];
    }
    
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    m_myTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
//    if(KISHighVersion_7){
//        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
//    }
//    m_myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
//    m_myTableView.sectionIndexColor = UIColorFromRGBA(0xbcbcbc, 1);
    
    [self.view addSubview:m_myTableView];

    [GameCommon setExtraCellLineHidden:m_myTableView];
    
    
//    imageHight = (320-15)/4;
//    m_layout = [[UICollectionViewFlowLayout alloc]init];
//    m_layout.minimumInteritemSpacing = 1;
//    m_layout.minimumLineSpacing =5;
//    m_layout.itemSize = CGSizeMake(imageHight, imageHight);
//    m_layout.headerReferenceSize = CGSizeMake(320, 70);
//    m_layout.sectionInset = UIEdgeInsetsMake(10,5,3,3);
//    
//    groupCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, startX, 320, 70+10+imageHight+5) collectionViewLayout:m_layout];
//    groupCollectionView.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
//    groupCollectionView.scrollEnabled = YES;
//    groupCollectionView.delegate = self;
//    groupCollectionView.dataSource = self;
//    [groupCollectionView registerClass:[GroupOfMineCell class] forCellWithReuseIdentifier:@"titleCell"];
//    [groupCollectionView registerClass:[ReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:HeaderIdentifier];
//    groupCollectionView.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:groupCollectionView];
    
    
//    cellView = [[UIView alloc]initWithFrame:CGRectMake(0, startX+(70+10+imageHight+5), 320, 200)];
//    UILabel *lajiLabel= [[ UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 20)];
//    lajiLabel.backgroundColor = [UIColor clearColor];
//    lajiLabel.textColor = [UIColor grayColor];
//    lajiLabel.text = @"立即添加游戏组织,开始更好的游戏体验!";
//    lajiLabel.textAlignment = NSTextAlignmentCenter;
//    lajiLabel.font = [UIFont systemFontOfSize:12];
//    [cellView addSubview:lajiLabel];
//    [self.view addSubview:cellView];
    [self loadCacheGroupList];
    [self getGroupListFromNet];
}
- (void)refreshTableView:(id)sender
{
    [self getGroupListFromNet];

}
#pragma mark 收到公告消息
-(void)receivedBillboardMsg:(NSNotification*)sender
{
    msgCount++;
    
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
-(void)refreshGroupInfo
{
    [self getGroupListFromNet];
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
            [DataStoreManager deleteAllDSGroupList];
            [self setGroupList:responseObject];
            for (NSMutableDictionary * groupInfo in responseObject) {
                
                [[GroupManager singleton] clearGroupCache:KISDictionaryHaveKey(groupInfo, @"groupId")];
                [DataStoreManager saveDSGroupList:groupInfo];
            }
        }
        [m_myTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}

-(void)setGroupList:(NSMutableArray*)responseObject
{
    [myGroupArray removeAllObjects];
//    myGroupArray = [responseObject mutableCopy];
   NSArray *arr = [responseObject sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
         return (NSComparisonResult)NSOrderedAscending;
    }];
    myGroupArray = [NSMutableArray arrayWithArray:arr];
//    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"addphoto",@"backgroundImg", nil];
//    [myGroupArray addObject:dic];
    if (myGroupArray.count<4) {
        groupCollectionView.frame = CGRectMake(0, startX, 320, 70+10+imageHight+5);
        cellView.frame = CGRectMake(0, startX+(70+10+imageHight+5), 320, 200);
    }
    if (myGroupArray.count>4) {
        groupCollectionView.frame = CGRectMake(0, startX, 320, 70+(imageHight+10)*2+5);
        cellView.frame = CGRectMake(0, startX+(70+(imageHight+10)*2+5), 320, 180);
    }
    [groupCollectionView reloadData];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return myGroupArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"cell";
    MyGroupsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[MyGroupsTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSMutableDictionary * cellDic = [myGroupArray objectAtIndex:indexPath.row];
    cell.headImageView.placeholderImage = KUIImage(@"group_icon");
    cell.headImageView.imageURL = [ImageService getImageUrl3:KISDictionaryHaveKey(cellDic, @"backgroundImg") Width:120];
    cell.titleLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
    NSString * gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(cellDic, @"gameid")];
    NSString * imageId = [GameCommon putoutgameIconWithGameId:gameId];
    cell.gameImageView.imageURL = [ImageService getImageUrl4:imageId];
//    NSURL *url = [ImageService getImageStr2: imageId];
//    EGOImageView * EGOimage = [[EGOImageView alloc]init];
//    EGOimage.imageURL = url;
//    cell.gameImageView.imageURL = [ImageService getImageStr:imageId Width:100];
//    cell.gameImageView.image = EGOimage.image;
    cell.memberCountLable.text = [NSString stringWithFormat:@"%@/%@",KISDictionaryHaveKey(cellDic, @"currentMemberNum"),KISDictionaryHaveKey(cellDic, @"maxMemberNum")];
    cell.describeLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(cellDic, @"info")];
    cell.leveLable.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(cellDic, @"level")];
    //取消cell d的点中效果
    [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
    return cell;

}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dic = [myGroupArray objectAtIndex:indexPath.row];
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId =KISDictionaryHaveKey(dic, @"groupId");
    gr.isAudit = NO;
    [self.navigationController pushViewController:gr animated:YES];

}


//-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//{
//    NSLog(@"-------%d",myGroupArray.count);
//    return myGroupArray.count;
//}
//
//-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    GroupOfMineCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"titleCell" forIndexPath:indexPath];
//    NSMutableDictionary * cellDic = [myGroupArray objectAtIndex:indexPath.row];
//    if (indexPath.row ==myGroupArray.count-1) {
//        NSString *imgStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(cellDic, @"backgroundImg")];
//        cell.headImgView.placeholderImage = KUIImage(imgStr);
//        cell.headImgView.imageURL = nil;
//        cell.titleLabel.backgroundColor = [UIColor clearColor];
//        cell.titleLabel.text = @"";
//    }else{
//        cell.headImgView.placeholderImage = KUIImage(@"group_icon");
//        cell.headImgView.imageURL = [ImageService getImageUrl3:KISDictionaryHaveKey(cellDic, @"backgroundImg") Width:120];
//        cell.titleLabel.backgroundColor  =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
//        cell.titleLabel.text = KISDictionaryHaveKey(cellDic, @"groupName");
//    }
//    return cell;
//}
//-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSDictionary *dic = [myGroupArray objectAtIndex:indexPath.row];
////    if (indexPath.row ==myGroupArray.count-1) {
////        NewSearchGroupController *joinIn = [[NewSearchGroupController alloc]init];
////        joinIn.gameid = self.gameid;
////        [self.navigationController pushViewController:joinIn animated:YES];
////    }else{
//        GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
//        gr.groupId =KISDictionaryHaveKey(dic, @"groupId");
//        gr.isAudit = NO;
//        [self.navigationController pushViewController:gr animated:YES];
////    }
//}
//
//-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
//{
//    UICollectionReusableView *titleView;
//    if (kind == UICollectionElementKindSectionHeader) {
//        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HeaderIdentifier forIndexPath:indexPath];
//        ReusableView * reu = ((ReusableView *)titleView);
//        reu.delegate = self;
//        [reu setInfo:dict setMsgCount:msgCount];
//    }
//    return titleView;
//}

//点击
-(void)onClick:(UIButton*)sender
{
    msgCount=0;
    [[NSUserDefaults standardUserDefaults]setObject:0 forKey:Billboard_msg_count];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [groupCollectionView reloadData];
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
