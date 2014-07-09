//
//  MePageViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "MePageViewController.h"
#import "MyProfileViewController.h"
#import "MyTitleObjViewController.h"
#import "TitleObjDetailViewController.h"
#import "CharacterEditViewController.h"
#import "CharacterDetailsViewController.h"//角色详情界面
#import "HostInfo.h"
#import "PersonTableCell.h"
#import "MyCharacterCell.h"
#import "MyNormalTableCell.h"
#import "SetViewController.h"
#import "TitleObjTableCell.h"
#import "MyStateTableCell.h"
#import "NewsViewController.h"
#import "UserManager.h"
#import "GroupInformationViewController.h"
#import "FunsOfOtherViewController.h"
#import "MyCircleViewController.h"

@interface MePageViewController ()
{
    UITableView*  m_myTableView;
    HostInfo*     m_hostInfo;
    NSInteger     m_refreshCharaIndex;
}
@end

@implementation MePageViewController

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"appBecomeActive" object:Nil];

    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    
    if (![[TempData sharedInstance] isHaveLogin]) {
        [[Custom_tabbar showTabBar] when_tabbar_is_selected:0];
        return;
    }
    [self getUserInfoByNet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"dynamicFromMe_wx_notification" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"我" withBackButton:NO];
    self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - 50 - 64)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    m_myTableView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    [self.view addSubview:m_myTableView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
    
 
    m_hostInfo = [[HostInfo alloc] initWithHostInfo:[self getLocalInfo]];
    [m_myTableView reloadData];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:isFirstIntoMePage]) {
        [self getUserInfoByNet];
    }
}

//加在本地数据
-(NSMutableDictionary*)getLocalInfo
{
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    NSMutableDictionary * userDic = [DataStoreManager getUserInfoFromDbByUserid:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    NSMutableArray * titlessss= [DataStoreManager queryTitle:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] Hide:@"0"];
    NSMutableArray * chasss= [DataStoreManager queryCharacters:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    NSMutableDictionary * latestDynamicMsg = [DataStoreManager queryLatestDynamic:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    [info setObject:latestDynamicMsg forKey:@"latestDynamicMsg"];
    [info setObject:userDic forKey:@"user"];
    [info setObject:chasss forKey:@"characters"];
    [info setObject:titlessss forKey:@"title"];
    [info setObject:KISDictionaryHaveKey(userDic, @"gameids") forKey:@"gameids"];
    [info setObject:KISDictionaryHaveKey(userDic, @"shiptype") forKey:@"shiptype"];
    [info setObject:@"0" forKey:@"zannum"];
    [info setObject:@"0" forKey:@"fansnum"];
    return info;
}

-(void)reloadTableView:(id)sender
{
    [m_myTableView reloadData];
}

- (void)getUserInfoByNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"201" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    if (!m_hostInfo) {
        [hud show:YES];
    }
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_hostInfo = [[HostInfo alloc] initWithHostInfo:responseObject];
            [m_myTableView reloadData];
            [[UserManager singleton] saveUserInfo:responseObject];
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

#pragma mark 表格
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 0;
            break;
        case 1:
        {
                return 30;
        }break;
        case 3:
        {
                return 30;
        }break;
        default:
            return 30;
            break;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (0 == section) {
        return nil;
    }
    UIView* heardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 31)];
    UIImageView* topBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 31)];
    topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [heardView addSubview:topBg];

    UIButton* setButton = [CommonControlOrView setButtonWithFrame:CGRectMake(250, 0, 70, 30) title:@"" fontSize:Nil textColor:nil bgImage:KUIImage(@"set_normal") HighImage:KUIImage(@"set_click") selectImage:Nil];
    setButton.backgroundColor = [UIColor clearColor];
    UILabel* titleLabel;
    
    switch (section) {
        case 1:
        {
            titleLabel =[self getHeadTitleLable:@"我的动态"];
        } break;
        case 2:
        {
            titleLabel =[self getHeadTitleLable:@"我的角色"];
            [heardView addSubview:setButton];
            [setButton addTarget:self action:@selector(characterSetClick:) forControlEvents:UIControlEventTouchUpInside];
  
        }break;
        case 3:
        {
            titleLabel =[self getHeadTitleLable:@"我的头衔"];
            [heardView addSubview:setButton];
            [setButton addTarget:self action:@selector(achievementSetClick:) forControlEvents:UIControlEventTouchUpInside];

        }break;
        case 4://有动态和头衔
            titleLabel =[self getHeadTitleLable:@"我的操作"];
            break;
        default:
            break;
    }
    [topBg addSubview:titleLabel];
    return heardView;
}

-(UILabel*)getHeadTitleLable:(NSString*)lableText
{
    UILabel *titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 30) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:lableText textAlignment:NSTextAlignmentLeft];
    return titleLabel;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 70;
            break;
        case 1:
        {
            return 80+50;
        } break;
        case 2:
        {
            return 60;//角色
        }break;
        case 3:
        {
            return 50;
        }break;
        case 4:
            return 55;
            break;
        default:
            break;
    }
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
        {
                return 1;
        } break;
        case 2:
        {
            if ([m_hostInfo.charactersArr count] != 0) {
                return [m_hostInfo.charactersArr count];//角色
            }
            return 1;
        }break;
        case 3:
        {
            if([m_hostInfo.achievementArray count] != 0)//头衔
                return [m_hostInfo.achievementArray count];
            else
                return 1;
        }break;
        case 4://操作
            return 1;
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (0 == indexPath.section) {
        static NSString *identifier = @"myCell";
        PersonTableCell *cell = (PersonTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[PersonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        cell.nameLabel.text = m_hostInfo.nickName;
        
        if ([m_hostInfo.gender isEqualToString:@"0"]) {//男♀♂
            cell.ageLabel.text = [@"♂ " stringByAppendingString:m_hostInfo.age?m_hostInfo.age:@""];
            cell.ageLabel.backgroundColor = kColorWithRGB(33, 193, 250, 1.0);
            cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_man.png"];
        }
        else
        {
            cell.ageLabel.text = [@"♀ " stringByAppendingString:m_hostInfo.age?m_hostInfo.age:@""];
            cell.ageLabel.backgroundColor = kColorWithRGB(238, 100, 196, 1.0);
            cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
        }
        if (m_hostInfo.achievementArray && [m_hostInfo.achievementArray count] != 0) {
            NSDictionary* titleDic = [m_hostInfo.achievementArray objectAtIndex:0];
            cell.distLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(titleDic, @"titleObj"), @"title");
            cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(KISDictionaryHaveKey(titleDic, @"titleObj"), @"rarenum") integerValue]];
        }
        else{
            cell.distLabel.text = @"暂无头衔";
        }
        if (m_hostInfo.headImgArray.count>0) {
            cell.headImageV.imageURL = [ImageService getImageUrl4:[m_hostInfo.headImgArray objectAtIndex:0]];
        }else
        {
            cell.headImageV.imageURL = nil;
        }
        
        [cell refreshCell];
        
        NSArray * gameidss=[GameCommon getGameids:m_hostInfo.gameids];
        [cell setGameIconUIView:gameidss];
        return cell;
    }
    else if(1 == indexPath.section)//我的动态
    {
        static NSString *identifier = @"mystate";
        MyStateTableCell *cell = (MyStateTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[MyStateTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([m_hostInfo.state isKindOfClass:[NSDictionary class]] && [[m_hostInfo.state allKeys] count] != 0)//动态
        {
            if ([KISDictionaryHaveKey(m_hostInfo.state, @"destUser") isKindOfClass:[NSDictionary class]]) {//目标 别人评论了我
                NSDictionary* destDic = KISDictionaryHaveKey(m_hostInfo.state, @"destUser");
                NSString * imageIds=KISDictionaryHaveKey(destDic, @"userimg");
                cell.headImageV.imageURL = [ImageService getImageStr2:imageIds];
                cell.titleLabel.text = [NSString stringWithFormat:@"%@%@",[[GameCommon getNewStringWithId:KISDictionaryHaveKey(destDic, @"alias")] isEqualToString:@""] ? KISDictionaryHaveKey(destDic, @"nickname") : KISDictionaryHaveKey(destDic, @"alias") , KISDictionaryHaveKey(m_hostInfo.state, @"showtitle")];
            }
            else
            {
                NSString * userImages=KISDictionaryHaveKey(m_hostInfo.state, @"userimg");
                cell.headImageV.imageURL = [ImageService getImageStr2:userImages];
                if([KISDictionaryHaveKey(m_hostInfo.state, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]])
                {
                    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_hostInfo.state, @"type")] isEqualToString:@"3"]) {
                        cell.titleLabel.text = @"我发表了该内容";
                    }
                    else
                        cell.titleLabel.text = [NSString stringWithFormat:@"我%@",KISDictionaryHaveKey(m_hostInfo.state, @"showtitle")];
                }
                else
                    cell.titleLabel.text = [NSString stringWithFormat:@"%@%@",[[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_hostInfo.state, @"alias")] isEqualToString:@""] ? KISDictionaryHaveKey(m_hostInfo.state, @"nickname") : KISDictionaryHaveKey(m_hostInfo.state, @"alias") , KISDictionaryHaveKey(m_hostInfo.state, @"showtitle")];
            }
            NSString* tit = [[GameCommon getNewStringWithId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_hostInfo.state, @"title")]] isEqualToString:@""] ? KISDictionaryHaveKey(m_hostInfo.state, @"msg") : KISDictionaryHaveKey(m_hostInfo.state, @"title");
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_hostInfo.state, @"title")] isEqualToString:@""]) {
                cell.nameLabel.text = tit;
                
            }
            else
            {
                cell.nameLabel.text = [NSString stringWithFormat:@"「%@」", tit];
            }
            cell.timeLabel.text = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(m_hostInfo.state, @"createDate")]];
        }
        else
        {
            cell.titleLabel.text = @"";
            cell.nameLabel.text = @"暂无新的动态";
            cell.timeLabel.text = @"";
        }
        cell.fansLabel.text = [GameCommon getNewStringWithId:m_hostInfo.fanNum];
        cell.zanLabel.text = [GameCommon getNewStringWithId:m_hostInfo.zanNum];
        [cell.cellButton addTarget:self action:@selector(myStateClick:) forControlEvents:UIControlEventTouchUpInside];
        return cell;
    }
    else if(2 == indexPath.section)//我的角色
    {
        static NSString *identifier = @"myCharacter";
        MyCharacterCell *cell = (MyCharacterCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[MyCharacterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if ([m_hostInfo.charactersArr count]<=0) {
            cell.heardImg.hidden = YES; 
            cell.authBg.hidden = YES;
            cell.nameLabel.hidden = YES;
            cell.realmLabel.hidden = YES;
            cell.gameImg.hidden = YES;
            cell.pveLabel.hidden = YES;
            cell.pveTitle.hidden=YES;
            cell.noCharacterLabel.hidden = NO;
            return cell;
        }
        else
        {
            cell.heardImg.hidden = NO;
            cell.authBg.hidden = NO;
            cell.nameLabel.hidden = NO;
            cell.realmLabel.hidden = NO;
            cell.gameImg.hidden = NO;
            cell.pveLabel.hidden = NO;
            cell.pveTitle.hidden=NO;
            cell.noCharacterLabel.hidden = YES;
            NSDictionary* tempDic = [m_hostInfo.charactersArr objectAtIndex:indexPath.row];

//            NSString* realm =  KISDictionaryHaveKey(tempDic, @"realm");//服务器
            NSString* realm =  KISDictionaryHaveKey(tempDic, @"simpleRealm");//服务器
            NSString* v1=KISDictionaryHaveKey(tempDic, @"value1");//部落
            NSString* v2=KISDictionaryHaveKey(tempDic, @"value2");//战斗力
            NSString* v3=KISDictionaryHaveKey(tempDic, @"value3");//战斗力数
            NSString* auth=KISDictionaryHaveKey(tempDic, @"auth");
            NSString* name=KISDictionaryHaveKey(tempDic, @"name");
            NSString* failedmsg=KISDictionaryHaveKey(tempDic, @"failedmsg");
            NSString* img=KISDictionaryHaveKey(tempDic, @"img");//角色图标
            NSString* gameid=KISDictionaryHaveKey(tempDic, @"gameid");
            cell.heardImg.placeholderImage = KUIImage(@"clazz_icon.png");
            cell.realmLabel.text = [[realm stringByAppendingString:@" "] stringByAppendingString:v1];
            cell.authBg.hidden = NO;
            if ([failedmsg intValue] ==404)//角色不存在
            {
                cell.heardImg.image = KUIImage(@"clazz_icon.png");
                cell.authBg.image= KUIImage(@"chara_auth_3");
            }
            else
            {
                if ([GameCommon isEmtity:img]) {
                     cell.heardImg.image = KUIImage(@"clazz_icon.png");
                }
                else{
                    cell.heardImg.imageURL = [ImageService getImageUrl3:img Width:80];
                }
                
                if ([[GameCommon getNewStringWithId:auth] isEqualToString:@"1"]) {//已认证
                    cell.authBg.image= KUIImage(@"chara_auth_1");
                }
                else
                {
                    
                    cell.authBg.image= KUIImage(@"chara_auth_2");
                }
            }
           
            cell.rowIndex = indexPath.row;
            cell.myDelegate = self;
            NSString * gameImageId=[GameCommon putoutgameIconWithGameId:[GameCommon getNewStringWithId:gameid]];
            
            if ([GameCommon isEmtity:gameImageId ]) {
                cell.gameImg.imageURL=nil;
            }else{
                cell.gameImg.imageURL=[ImageService getImageUrl4:gameImageId];
            }
            
            
            cell.nameLabel.text = name;
            cell.pveLabel.text = [GameCommon getNewStringWithId:v3];
            cell.pveTitle.text=v2;
            return cell;
        }
    }
    else if (3 == indexPath.section)//头衔
    {
        static NSString *identifier = @"myTitleObjTableCell";
        TitleObjTableCell *cell = (TitleObjTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[TitleObjTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if([m_hostInfo.achievementArray count] == 0)//头衔
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.headImageV.hidden = YES;
            cell.nameLabel.text = @"没有头衔展示";
            cell.nameLabel.textColor = [UIColor blackColor];
            return cell;
        }
        cell.accessoryType = UITableViewCellAccessoryNone;

        NSDictionary* infoDic = [m_hostInfo.achievementArray objectAtIndex:indexPath.row];
        NSString* rarenum = [NSString stringWithFormat:@"rarenum_small_%@", [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(infoDic, @"titleObj") , @"rarenum")]];
        cell.headImageV.hidden = NO;
        cell.headImageV.image = KUIImage(rarenum);
        cell.nameLabel.text = KISDictionaryHaveKey(KISDictionaryHaveKey(infoDic, @"titleObj"), @"title");
        cell.nameLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(KISDictionaryHaveKey(infoDic, @"titleObj"), @"rarenum") integerValue]];
        if (indexPath.row == 0) {
            cell.userdButton.hidden = NO;
        }
        else
            cell.userdButton.hidden = YES;
        return cell;
    }
    else if (4 == indexPath.section)
    {
        static NSString *identifier = @"my";
        MyNormalTableCell *cell = (MyNormalTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[MyNormalTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

            cell.heardImg.image = KUIImage(@"me_system");
            cell.upLabel.text = @"系统设置";
            cell.downLabel.text = @"进行我的系统设置";
        return cell;
    }
    return Nil;
}

- (void)myStateClick:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];

    MyCircleViewController* VC = [[MyCircleViewController alloc] init];
    NSString * myUserid = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    VC.userId = myUserid;
    NSDictionary* user=[[UserManager singleton] getUser:myUserid];
    NSString * myNickName = [user objectForKey:@"nickname"];
    NSString * myImg = [user objectForKey:@"img"];
    VC.nickNmaeStr = myNickName;
    VC.imageStr = myImg;
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        
        MyProfileViewController* VC = [[MyProfileViewController alloc] init];
        VC.userName = m_hostInfo.userName;
        VC.nickName = m_hostInfo.nickName;
        [self.navigationController pushViewController:VC animated:YES];
    }
    else if (indexPath.section == 1)
    {
    }
    else if(indexPath.section == 2)
    {
        
         NSArray* characterArray = m_hostInfo.charactersArr;//魔兽世界
        if ([characterArray count]>0){
            NSDictionary *dic = [characterArray objectAtIndex:indexPath.row];
            NSString* gameId=[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"gameid")];//游戏Id
            NSString* chatId=[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"id")];//角色Id
            if([gameId isEqualToString:@"1"]||[gameId isEqualToString:@"2"])
            {
                [[Custom_tabbar showTabBar] hideTabBar:YES];
                CharacterDetailsViewController* VC = [[CharacterDetailsViewController alloc] init];
                VC.characterId = chatId;
                VC.gameId = gameId;
                VC.myViewType = CHARA_INFO_MYSELF;
                [[NSNotificationCenter defaultCenter]postNotificationName:@"contentOfjuese" object:nil];
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                [self showMessageWithContent:@"该游戏暂不支持此功能" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
            }
            NSLog(@"角色详情");
        }
        else
        {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            CharacterEditViewController *characterVC = [[CharacterEditViewController alloc]init];
            characterVC.isFromMeet =NO;
            [self.navigationController pushViewController:characterVC animated:YES];
            NSLog(@"添加角色");
        }
    }
    else if(indexPath.section == 3)//头衔
    {
        if (m_hostInfo.achievementArray && [m_hostInfo.achievementArray count] != 0) {
            [[Custom_tabbar showTabBar] hideTabBar:YES];
            TitleObjDetailViewController* detailVC = [[TitleObjDetailViewController alloc] init];
            detailVC.titleObjArray = m_hostInfo.achievementArray;
            detailVC.showIndex = indexPath.row;
            detailVC.isFriendTitle = NO;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
    }
    else if(indexPath.section == 4)
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        SetViewController* VC = [[SetViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 设置
//角色设置
- (void)characterSetClick:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    CharacterEditViewController* VC = [[CharacterEditViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}

//头衔设置
- (void)achievementSetClick:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    MyTitleObjViewController* VC = [[MyTitleObjViewController alloc] init];
    [self.navigationController pushViewController:VC animated:YES];
}
- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
