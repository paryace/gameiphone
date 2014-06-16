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
}
@end

@implementation MyGroupViewController

NSString *const RAMCollectionViewFlemishBondHeaderKind = @"RAMCollectionViewFlemishBondHeaderKind";
static NSString * const HeaderIdentifier = @"HeaderIdentifier";

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableArray * bills = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    if (bills&&bills.count>0) {
        dict = [bills objectAtIndex:0];
    }else{
        dict=nil;
    }
    [groupCollectionView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"我的群组" withBackButton:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshNet:) name:@"RefreshMyGroupList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:@"billboard_msg" object:nil];
    

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
    
//    [groupCollectionView registerClass:[ReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headView"];
    NSArray *arr1 = @[@"智能推荐",@"附近的组织",@"同服的组织"];
    NSArray *arr2 = @[@"根据你支持的队伍选择群组",@"加入附近的组织,和他们一起玩",@"看看同服有哪些组织"];
    NSArray *arr3 =@[@"find_role",@"find_role",@"find_group"];
    
    cellView = [[UIView alloc]initWithFrame:CGRectMake(0, startX+(70+10+imageHight+10), 320, 200)];
    UILabel *lajiLabel= [[ UILabel alloc]initWithFrame:CGRectMake(0, 10, 320, 20)];
    lajiLabel.backgroundColor = [UIColor clearColor];
    lajiLabel.textColor = [UIColor grayColor];
    lajiLabel.text = @"立即添加游戏组织,开始更好的游戏体验!";
    lajiLabel.textAlignment = NSTextAlignmentCenter;
    lajiLabel.font = [UIFont systemFontOfSize:12];
    [cellView addSubview:lajiLabel];
    [self.view addSubview:cellView];
    
    for (int i =0; i<3; i++) {
        UIButton *view = [self bulidCellWithFrame:CGRectMake(0, 60+60*i, 320, 59) title1:arr1[i] title2:arr2[i] img:arr3[i]];
        view.tag = 100+i;
        [view addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didClickNormal:)]];
        [cellView addSubview:view];
    }
    [self getGroupListFromNet];
}

#pragma mark 收到公告消息
-(void)receivedBillboardMsg:(NSNotification*)sender
{
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

//-(void)backButtonClick:(id)sender
//{
//    [self.navigationController popToRootViewControllerAnimated:YES];
//}

#pragma mark ---创建群
-(void)didClickCreateGroup:(id)sender
{
    AddGroupViewController *addGroupView =[[ AddGroupViewController alloc]init];
    [self.navigationController pushViewController:addGroupView animated:YES];
}


-(UIButton *)bulidCellWithFrame:(CGRect)frame title1:(NSString*)title1 title2:(NSString *)title2 img:(NSString *)img
{
    UIButton *view = [[UIButton alloc]initWithFrame:frame];
    view.backgroundColor = [UIColor whiteColor];
    [view setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
    [view setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(15,15, 30, 30)];
    imageView.image = KUIImage(img);
    [view addSubview:imageView];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(60,10, 200, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentLeft;
    label.text = title1;
    [view addSubview:label];
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(60, 35, 200, 20)];
    label1.backgroundColor = [UIColor clearColor];
    label1.textColor = [UIColor grayColor];
    label1.font = [UIFont systemFontOfSize:13];
    label1.textAlignment = NSTextAlignmentLeft;
    label1.text = title2;
    [view addSubview:label1];

    UIImageView *rightImg = [[UIImageView alloc]initWithFrame:CGRectMake(300, 25, 10, 10)];
    rightImg.image = KUIImage(@"right");
    [view addSubview:rightImg];
    
    UIView *lineView =[[ UIView alloc]initWithFrame:CGRectMake(0, frame.origin.y+59, 320, 1)];
    lineView.backgroundColor = kColorWithRGB(200,200,200, 0.5);
    [cellView addSubview:lineView];
    return view;
    
}

-(void)didClickNormal:(UIGestureRecognizer *)sender
{
    SearchGroupViewController *groupView = [[SearchGroupViewController alloc]init];

    switch (sender.view.tag) {
        case 100:
            [self showAlertViewWithTitle:@"嘟嘟嘟嘟" message:@"我都不知道这个标签是干什么的！没事不要乱点!" buttonTitle:@"跪求原谅"];
            break;
        case 101:
            groupView.ComeType = SETUP_NEARBY;
            [self.navigationController pushViewController:groupView animated:YES];
            break;
        case 102:
            break;
        default:
            [self showAlertViewWithTitle:@"嘟嘟嘟嘟" message:@"难道你不知道同服现在不能点呢嘛！！没事不要乱点!" buttonTitle:@"跪求原谅"];
 
//            groupView.ComeType = SETUP_SAMEREALM;
//            [self.navigationController pushViewController:groupView animated:YES];
            break;
    }
}

-(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"230" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            [myGroupArray removeAllObjects];
            [myGroupArray addObjectsFromArray:responseObject];
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"addphoto",@"backgroundImg", nil];
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
            
            for (NSMutableDictionary * groupInfo in responseObject) {
                [DataStoreManager saveDSGroupList:groupInfo];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
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
    cell.headImgView.placeholderImage = KUIImage(@"mess_news");
    cell.headImgView.imageURL = [ImageService getImageUrl4:KISDictionaryHaveKey(cellDic, @"backgroundImg")];
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
        [self.navigationController pushViewController:gr animated:YES];
    }
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *titleView;
    
    if (kind == UICollectionElementKindSectionHeader) {
        titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:HeaderIdentifier forIndexPath:indexPath];
        if (dict) {
            ((ReusableView *)titleView).label.hidden=NO;
            ((ReusableView *)titleView).contentLabel.hidden=NO;
            ((ReusableView *)titleView).timeLabel.hidden=NO;
            ((ReusableView *)titleView).headImageView.hidden=NO;
            ((ReusableView *)titleView).topLabel.hidden=YES;
            [((ReusableView *)titleView).topBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
//            [((ReusableView *)titleView).topBtn  setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
            ((ReusableView *)titleView).topBtn.tag=123;
            [((ReusableView *)titleView).topBtn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            NSString * groupName = KISDictionaryHaveKey(dict, @"groupName");
            NSString * billboard = KISDictionaryHaveKey(dict, @"billboard");
            NSString * createDate = KISDictionaryHaveKey(dict, @"createDate");
            NSString * backgroundImg = KISDictionaryHaveKey(dict, @"backgroundImg");
            ((ReusableView *)titleView).label.text = billboard;
            ((ReusableView *)titleView).contentLabel.text = groupName;
            ((ReusableView *)titleView).timeLabel.text = [NSString stringWithFormat:@"%@", [self getMsgTime:createDate]];
            CGSize textSize = [((ReusableView *)titleView).timeLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
            ((ReusableView *)titleView).timeLabel.frame=CGRectMake(320 - textSize.width-10, 45, textSize.width, 15);
            if ([GameCommon isEmtity:backgroundImg]) {
                ((ReusableView *)titleView).headImageView.imageURL = nil;
            }else{
                ((ReusableView *)titleView).headImageView.imageURL = [ImageService getImageStr2:backgroundImg];
            }
            
        }else{
            ((ReusableView *)titleView).label.hidden=YES;
            ((ReusableView *)titleView).contentLabel.hidden=YES;
            ((ReusableView *)titleView).timeLabel.hidden=YES;
            ((ReusableView *)titleView).headImageView.hidden=YES;
            ((ReusableView *)titleView).topBtn.hidden=NO;
            ((ReusableView *)titleView).topLabel.hidden=NO;
            [((ReusableView *)titleView).topBtn setBackgroundImage:KUIImage(@"blue_bg") forState:UIControlStateNormal];
        }
    }
    return titleView;
}

-(void)topBtnClick:(UIButton*)sender
{
    BillboardViewController *joinIn = [[BillboardViewController alloc]init];
    [self.navigationController pushViewController:joinIn animated:YES];
}
//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
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
