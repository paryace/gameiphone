//
//  NewFriendPageController.m
//  GameGroup
//
//  Created by Apple on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewFriendPageController.h"
#import "MJRefreshHeaderView.h"
#import "NewPersonalTableViewCell.h"
#import "MessageAddressViewController.h"
#import "AddContactViewController.h"
#import "FunsOfOtherViewController.h"
#import "NearFriendsViewController.h"
#import "TestViewController.h"

@interface NewFriendPageController (){
    UITableView*  m_myTableView;
    MJRefreshHeaderView *m_Friendheader;
    NSMutableDictionary * m_friendDict;
    NSMutableArray * m_sectionArray_friend;
    NSMutableArray * m_sectionIndexArray_friend;
    NSString *fansNum;
    
}
@property (nonatomic, strong) UIView *topView;
@end

@implementation NewFriendPageController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"通讯录" withBackButton:NO];

    
    
    m_friendDict = [NSMutableDictionary dictionary];
    m_sectionArray_friend = [NSMutableArray array];
    m_sectionIndexArray_friend = [NSMutableArray array];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    if(KISHighVersion_7){
        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    m_myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    m_myTableView.tableHeaderView=self.topView;
    [self.view addSubview:m_myTableView];
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
    [self getFriendDateFromDataSore];
    [m_myTableView reloadData];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:isFirstOpen]) {
        [m_Friendheader beginRefreshing];
    }else{
        [self getFriendListFromNet];
    }
    self.view.backgroundColor=[UIColor blackColor];
}


- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0,0,320,60);
        _topView.backgroundColor = [UIColor blackColor];
        NSArray *topTitle = @[@"粉丝数量",@"附近的朋友",@"手机联系人",@"添加好友"];
        for (int i = 0; i < 4; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = CGRectMake(i*80, 0, 80, 60);
            [button addTarget:self action:@selector(topBtnAction:)
             forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_normal_%d",i+1]]
                    forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_click_%d",i+1]]
                    forState:UIControlStateHighlighted];
            [button setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
            [_topView addSubview:button];
            UILabel *titleLable = [[UILabel alloc] init];
            CGSize textSize =[[topTitle objectAtIndex:i] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
            CGFloat textWidth = textSize.width;
            titleLable.frame=CGRectMake(i*80+((80-textWidth)/2),40, 80 ,20);
            titleLable.font = [UIFont systemFontOfSize:11];
            titleLable.textColor=UIColorFromRGBA(0xf7f7f7, 1);
            titleLable.backgroundColor=[UIColor clearColor];
            titleLable.text=[topTitle objectAtIndex:i];
            [_topView addSubview:titleLable];
           
        }
    }
    return _topView;
}

- (void)topBtnAction:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
        {
            NSString *userid=[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
            FunsOfOtherViewController *fans = [[FunsOfOtherViewController alloc]init];
            fans.userId = userid;
            [self.navigationController pushViewController:fans animated:YES];
        }
            break;
        case 1:
        {
            NearFriendsViewController *addVC = [[NearFriendsViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 2:
        {
            MessageAddressViewController *addVC = [[MessageAddressViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 3:
        {
            AddContactViewController * addV = [[AddContactViewController alloc] init];
            [self.navigationController pushViewController:addV animated:YES];

        }
            break;
        default:
            break;
    }
}
//返回组的数量
#pragma mark 表格
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return m_sectionIndexArray_friend.count;
}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (m_sectionArray_friend==nil||[m_sectionArray_friend count]==0||section>[m_sectionArray_friend count]) {
        return 0;
    }
    return [[[m_sectionArray_friend objectAtIndex:section] objectAtIndex:1] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * stringCell3 = @"cell";
    NewPersonalTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:stringCell3];
    if (!cell) {
        cell = [[NewPersonalTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:stringCell3];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSDictionary * tempDict;
   tempDict= [m_friendDict objectForKey:[[[m_sectionArray_friend objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row]];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"sex")] isEqualToString:@"0"]) {//男♀♂
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_man.png"];//
    }
    else
    {
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_woman.png"];//
    }
    
    if ([KISDictionaryHaveKey(tempDict, @"sex")intValue]==0)
    {
        cell.sexImg.image = KUIImage(@"gender_boy");
    }else
    {
        cell.sexImg.image = KUIImage(@"gender_girl");
    }
    
    if ([KISDictionaryHaveKey(tempDict, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(tempDict, @"img")isEqualToString:@" "]) {
        cell.headImageV.imageURL = nil;
    }else{
        if ([GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"img")]) {
            cell.headImageV.imageURL = [NSURL URLWithString:[[BaseImageUrl stringByAppendingString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"img")]] stringByAppendingString:@"/80"]];
        }else{
            cell.headImageV.imageURL = nil;
        }
    }
    cell.nameLabel.text = [tempDict objectForKey:@"nickname"];
    cell.gameImg_one.image = KUIImage(@"wow");
    NSString *titleName=KISDictionaryHaveKey(tempDict, @"achievement");
    cell.distLabel.text = (titleName==nil||[titleName isEqualToString:@""]) ? @"暂无头衔" : titleName;
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(tempDict, @"achievementLevel") integerValue]];
    
    CGSize nameSize = [cell.nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.nameLabel.frame = CGRectMake(80, 5, nameSize.width + 5, 20);
    cell.sexImg.frame = CGRectMake(80 + nameSize.width, 5, 20, 20);
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary * tempDict;
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    TestViewController *detailVC = [[TestViewController alloc]init];
    
    
    tempDict = [m_friendDict objectForKey:[[[m_sectionArray_friend objectAtIndex:indexPath.section] objectAtIndex:1] objectAtIndex:indexPath.row]];
    detailVC.viewType = VIEW_TYPE_FriendPage1;

    detailVC.achievementStr = [KISDictionaryHaveKey(tempDict, @"achievement") isEqualToString:@""] ? @"暂无头衔" : KISDictionaryHaveKey(tempDict, @"achievement");
    detailVC.achievementColor =KISDictionaryHaveKey(tempDict, @"achievementLevel") ;
    detailVC.sexStr =  KISDictionaryHaveKey(tempDict, @"sex");
    
    detailVC.titleImage =[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"img")] ;
    
    detailVC.ageStr = [GameCommon getNewStringWithId:[tempDict objectForKey:@"age"]];
    detailVC.constellationStr =KISDictionaryHaveKey(tempDict, @"constellation");
    detailVC.userId = KISDictionaryHaveKey(tempDict, @"userid");
    detailVC.nickName = KISDictionaryHaveKey(tempDict, @"displayName");
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"updateUserLocationDate")];
    detailVC.jlStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"distance")];
    detailVC.createTimeStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"createTime")];
    if([KISDictionaryHaveKey(tempDict, @"active")intValue]==2){
        detailVC.isActiveAc =YES;
    }
    else{
        detailVC.isActiveAc =NO;
    }
    
    detailVC.isChatPage = NO;
    [self.navigationController pushViewController:detailVC animated:YES];
}



//返回索引的字母
#pragma mark 索引
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
  NSString * keyName= [m_sectionIndexArray_friend objectAtIndex:section];
    return keyName;
}
// 返回索引列表的集合
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
   return m_sectionIndexArray_friend;
}



#pragma mark 请求数据
- (void)getFriendListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"212" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken ] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [hud hide:YES];
                    [self parseFriendsList:responseObject];
                }
                failure:^(AFHTTPRequestOperation *operation, id error) {
                        [hud hide:YES];
                        [m_Friendheader endRefreshing];
                }];
}
//解析
-(void)parseFriendsList:(id)responseObject
{
    dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
    dispatch_async(queue, ^{
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            fansNum=[[responseObject objectForKey:@"fansnum"] stringValue];
            [[NSUserDefaults standardUserDefaults] setObject:fansNum forKey:FansCount];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSDictionary* resultArray = [responseObject objectForKey:@"contacts"];
            NSArray* keyArr = [resultArray allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [resultArray objectForKey:key]) {
                    NSString *shiptype=[dict objectForKey:@"shiptype"];
                    [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:shiptype];
                }
            }
        }
        [self getFriendDateFromDataSore];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setFansNum];
            [hud hide:YES];
            [m_myTableView reloadData];
            [m_Friendheader endRefreshing];
        });
    });
}

//查库
-(void) getFriendDateFromDataSore
{
    dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
    dispatch_async(queue, ^{
        m_friendDict = [DataStoreManager newQueryAllUserManagerWithshipType:@"1" ShipType2:@"2"];//所有朋友
        m_sectionArray_friend = [DataStoreManager querySections];
        [m_sectionIndexArray_friend removeAllObjects];
        for (int i = 0; i < m_sectionArray_friend.count; i++) {
            NSString * str=[[m_sectionArray_friend objectAtIndex:i] objectAtIndex:0];
            [m_sectionIndexArray_friend addObject:str];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_myTableView reloadData];
        });
    });
}
//设置粉丝数量
-(void)setFansNum
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:FansCount]) {
        fansNum=[[NSUserDefaults standardUserDefaults] objectForKey:FansCount];
    }
    NSString *fanstr;
    int intfans = [fansNum intValue];
    if (intfans>9999) {
        fanstr=[fansNum stringByAppendingString:@"粉"];
    }else{
        fanstr=[fansNum stringByAppendingString:@"位粉丝"];
    }
    NSArray *viewArray=[[self topView] subviews];
    UILabel *fansLable=(UILabel *)[viewArray objectAtIndex:1];
    fansLable.text=fanstr;
    CGSize textSize =[fanstr sizeWithFont:[UIFont systemFontOfSize:11] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
    fansLable.frame=CGRectMake(((80-textSize.width)/2),40, 80 ,20);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
