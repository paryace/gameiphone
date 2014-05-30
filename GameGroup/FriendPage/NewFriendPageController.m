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
#import "AddFriendsViewController.h"
#import "MyFansPageViewController.h"
#import "ImageService.h"
#import "InterestingPerpleViewController.h"
@interface NewFriendPageController (){
    
    UILabel*        m_titleLabel;
    
    NSMutableDictionary *resultArray;//数据集合
    NSMutableArray * keyArr;//字母集合
    
    UITableView*  m_myTableView;
    NSString *fansNum;
}
@property (nonatomic, strong) UIView *topView;
@end

@implementation NewFriendPageController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    if (![[TempData sharedInstance] isHaveLogin]) {
        [[Custom_tabbar showTabBar] when_tabbar_is_selected:0];
        return;
    }
    [self getFriendDateFromDataSore];
    if (![[NSUserDefaults standardUserDefaults]objectForKey:isFirstOpen]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isFirstOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContentList:) name:kReloadContentKey object:nil];
        [self getFriendListFromNet];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"" withBackButton:NO];
    
    resultArray =[NSMutableDictionary dictionary];
    keyArr=[NSMutableArray array];
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = @"联系人";
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startX, 320, self.view.bounds.size.height-startX-50)];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    if(KISHighVersion_7){
        m_myTableView.sectionIndexBackgroundColor = [UIColor clearColor];
    }
    
    m_myTableView.sectionIndexTrackingBackgroundColor = [UIColor clearColor];
    m_myTableView.tableHeaderView=self.topView;
    [self.view addSubview:m_myTableView];
    self.view.backgroundColor=[UIColor blackColor];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:isFirstOpen]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadContentList:) name:kReloadContentKey object:nil];
        [self getFriendListFromNet];
    }
}
#pragma mark 刷新表格
- (void)reloadContentList:(NSNotification*)notification
{
    [self getFriendDateFromDataSore];
}
- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] init];
        _topView.frame = CGRectMake(0,0,320,60);
        _topView.backgroundColor = [UIColor blackColor];
        NSArray *topTitle = @[@"粉丝数量",@"附近的朋友",@"有趣的人",@"添加好友"];
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
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            NSString *userid=[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
            MyFansPageViewController *fans = [[MyFansPageViewController alloc]init];
            fans.userId = userid;
            [self.navigationController pushViewController:fans animated:YES];
        }
            break;
        case 1:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            NearFriendsViewController *addVC = [[NearFriendsViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 2:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
//            MessageAddressViewController *addVC = [[MessageAddressViewController alloc]init];
            InterestingPerpleViewController *addVC = [[InterestingPerpleViewController alloc]init];
            [self.navigationController pushViewController:addVC animated:YES];
        }
            break;
        case 3:
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            AddFriendsViewController * addV = [[AddFriendsViewController alloc] init];
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
    return  keyArr.count;
}
//返回每个组里面的数据条数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[resultArray objectForKey:[keyArr objectAtIndex:section]] count];
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
    
    if (resultArray.count==0||keyArr.count==0) {
        return nil;
    }
    
    NSDictionary * tempDict =[[resultArray objectForKey:[keyArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    
    NSString * headplaceholderImage= [self headPlaceholderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.headImageV.placeholderImage = [UIImage imageNamed:headplaceholderImage];
    NSString * imageids=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageV.imageURL=[ImageService getImageStr:imageids Width:80];
    NSString *genderimage=[self genderImage:KISDictionaryHaveKey(tempDict, @"gender")];
    cell.sexImg.image =KUIImage(genderimage);
    
    NSString * nickName=[tempDict objectForKey:@"alias"];
    if ([GameCommon isEmtity:nickName]) {
        nickName=[tempDict objectForKey:@"nickname"];
    }
    cell.nameLabel.text = nickName;
    
    NSString *titleName=KISDictionaryHaveKey(tempDict, @"titleName");
    cell.distLabel.text = (titleName==nil||[titleName isEqualToString:@""]) ? @"暂无头衔" : titleName;
    cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(tempDict, @"rarenum") integerValue]];
    CGSize nameSize = [cell.nameLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    cell.nameLabel.frame = CGRectMake(80, 5, nameSize.width + 5, 20);
    cell.sexImg.frame = CGRectMake(80 + nameSize.width, 5, 20, 20);
    NSArray * gameids=[GameCommon getGameids:KISDictionaryHaveKey(tempDict, @"gameids")];
    [cell setGameIconUIView:gameids];
    return cell;
}
//头像默认图片
-(NSString*)headPlaceholderImage:(NSString*)gender
{
    if ([[GameCommon getNewStringWithId:gender] isEqualToString:@"0"]) {//男♀♂
        return @"people_man.png";
    }
    else
    {
        return @"people_woman.png";//
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
//点击Table进入个人详情
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    NSDictionary * tempDict =[[resultArray objectForKey:[keyArr objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row];
    TestViewController *detailVC = [[TestViewController alloc]init];
    detailVC.userId = KISDictionaryHaveKey(tempDict, @"userid");
    [self.navigationController pushViewController:detailVC animated:YES];
}
//返回索引的字母
#pragma mark 索引
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    NSString * keyName =[keyArr objectAtIndex:section];
    return keyName;
}
// 返回索引列表的集合
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return keyArr;
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
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        fansNum=[[responseObject objectForKey:@"fansnum"] stringValue];
                        [[NSUserDefaults standardUserDefaults] setObject:fansNum forKey:[FansCount stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        NSMutableDictionary* result = [responseObject objectForKey:@"contacts"];
                        NSMutableArray* keys = [NSMutableArray arrayWithArray:[result allKeys]];
                        [keys sortUsingSelector:@selector(compare:)];
                        [keyArr removeAllObjects];
                        [resultArray removeAllObjects];
                        keyArr = keys;
                        resultArray = result;
                        [m_myTableView reloadData];
                        [self setFansNum];
                        //保存
                        [self saveFriendsList:result Keys:keys];
                    }
                }
                failure:^(AFHTTPRequestOperation *operation, id error) {
                    if ([error isKindOfClass:[NSDictionary class]]) {
                        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                        {
                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                        }
                    }
                }];
}
//保存用户列表信息
-(void)saveFriendsList:(NSDictionary*)result Keys:(NSArray*)keys
{
    dispatch_queue_t queue = dispatch_queue_create("com.living.game.NewFriendController", NULL);
    dispatch_async(queue, ^{
        if (result.count>0) {
            [DataStoreManager deleteAllNameIndex];
            for (int i=0; i<[keys count]; i++) {
                NSString *key=[keys objectAtIndex:i];
                for (NSMutableDictionary * dict in [result objectForKey:key]) {
                    [dict setObject:key forKey:@"nameIndex"];
                    NSString *shiptype=[dict objectForKey:@"shiptype"];
                    [DataStoreManager newSaveAllUserWithUserManagerList:dict withshiptype:shiptype];
                }
            }
        }
    });
}

//查询用户列表
-(void) getFriendDateFromDataSore
{
    dispatch_queue_t queue = dispatch_queue_create("com.living.game.NewFriendController", NULL);
    dispatch_async(queue, ^{
        NSMutableDictionary *userinfo=[DataStoreManager  newQuerySections:@"1" ShipType2:@"2"];
        NSMutableDictionary* result = [userinfo objectForKey:@"userList"];
        NSMutableArray* keys = [userinfo objectForKey:@"nameKey"];
        [keyArr removeAllObjects];
        [resultArray removeAllObjects];
        keyArr = keys;
        resultArray = result;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setFansNum];
            [m_myTableView reloadData];
        });
    });
}

//刷新title
-(void)refreTitle
{
    int count=0;
    for (int i=0; i<keyArr.count; i++) {
        count+=[[resultArray objectForKey:[keyArr objectAtIndex:i]] count];
    }
    m_titleLabel.text = [[@"联系人(" stringByAppendingString:[NSString stringWithFormat: @"%d",count]] stringByAppendingString:@")"];
}

//设置粉丝数量
-(void)setFansNum
{
    [self refreTitle];
    
    fansNum=[[NSUserDefaults standardUserDefaults] objectForKey:[FansCount stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]];
    NSString *fanstr;
    if ([GameCommon isEmtity:fansNum]) {
        fanstr=@"粉丝";
    }else {
        int intfans = [fansNum intValue];
        if (intfans>9999) {
            fanstr=[fansNum stringByAppendingString:@"粉"];
        }else{
            fanstr=[fansNum stringByAppendingString:@"位粉丝"];
        }
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
