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
#import "FeedBackViewController.h"
#import "CharacterEditViewController.h"
#import "CharacterDetailsViewController.h"//角色详情界面
#import "CircleWithMeViewController.h"
#import "HostInfo.h"
//#import "ContactsCell.h"
#import "PersonTableCell.h"
#import "MyCharacterCell.h"
#import "MyNormalTableCell.h"
#import "SetViewController.h"
#import "TitleObjTableCell.h"
#import "MyStateTableCell.h"
#import "NewsViewController.h"
#import "UserManager.h"

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
    if (![[NSUserDefaults standardUserDefaults]objectForKey:isFirstIntoMePage]) {
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isFirstIntoMePage];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self getUserInfoByNet];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadTableView:) name:@"dynamicFromMe_wx_notification" object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"我" withBackButton:NO];
    
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - 50 - 64)];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    m_myTableView.showsVerticalScrollIndicator = NO;
    m_myTableView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:m_myTableView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:isFirstIntoMePage]) {
        [self getUserInfoByNet];
    }
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
//    [postDict setObject:@"106" forKey:@"method"];
    [postDict setObject:@"201" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    if (!m_hostInfo) {
        [hud show:YES];
    }
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        NSLog(@"responseObject%@", responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            m_hostInfo = [[HostInfo alloc] initWithHostInfo:responseObject];

            [m_myTableView reloadData];
            
            [DataStoreManager newSaveAllUserWithUserManagerList:KISDictionaryHaveKey(responseObject, @"user") withshiptype:KISDictionaryHaveKey(responseObject, @"shiptype")];
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
                return 35;
        }break;
        case 3:
        {
                return 35;
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
    UIView* heardView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 35)];
    UIImageView* topBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 35)];
    topBg.image = KUIImage(@"table_heard_bg");
    [heardView addSubview:topBg];

    UIButton* setButton = [CommonControlOrView setButtonWithFrame:CGRectMake(250, 0, 70, 30) title:@"" fontSize:Nil textColor:nil bgImage:KUIImage(@"set_normal") HighImage:KUIImage(@"set_click") selectImage:Nil];
    setButton.backgroundColor = [UIColor clearColor];
    
    UILabel* titleLabel;
    
    switch (section) {
        case 1:
        {
//            if(![m_hostInfo.state isEqualToString:@""])//动态
//            {
                titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 30) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"我的动态" textAlignment:NSTextAlignmentLeft];
//            }
//            else
//            {
//                topBg.frame = CGRectZero;
//            }
        } break;
        case 2:
        {
            titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 30) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"我的角色" textAlignment:NSTextAlignmentLeft];
            [heardView addSubview:setButton];
            [setButton addTarget:self action:@selector(characterSetClick:) forControlEvents:UIControlEventTouchUpInside];
  
        }break;
        case 3:
        {
//           if([m_hostInfo.achievementArray count] != 0)//头衔
//           {
                titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 30) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"我的头衔" textAlignment:NSTextAlignmentLeft];
               [heardView addSubview:setButton];
               [setButton addTarget:self action:@selector(achievementSetClick:) forControlEvents:UIControlEventTouchUpInside];
//           }
//            else
//                topBg.frame = CGRectZero;
        }break;
        case 4://有动态和头衔
            titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 30) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"我的操作" textAlignment:NSTextAlignmentLeft];
            break;
        default:
            break;
    }
    [topBg addSubview:titleLabel];
    return heardView;
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
            //动态
//            if(![m_hostInfo.state isEqualToString:@""])//动态
                return 1;
//            else
//               return 0;
        } break;
        case 2:
        {
//            if ([KISDictionaryHaveKey(m_hostInfo.characters, @"1") isKindOfClass:[NSArray class]]) {
//                return [KISDictionaryHaveKey(m_hostInfo.characters, @"1") count];//角色
//            }
            
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
        cell.gameImg_one.image = KUIImage(@"wow");
        
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
            cell.headImageV.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BaseImageUrl,[m_hostInfo.headImgArray objectAtIndex:0]]];
        }else
        {
            cell.headImageV.imageURL = nil;
        }
        
        [cell refreshCell];
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

//        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"dynamicFromMe_wx"]) {
//            NSDictionary *dic=[[NSUserDefaults standardUserDefaults]objectForKey:@"dynamicFromMe_wx"];
//            cell.headImageV.hidden =NO;
//            cell.titleLabel.text = @"我发表了";
//            cell.nameLabel.text = KISDictionaryHaveKey(dic, @"msg");
//            cell.timeLabel.text = [GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")]];
//            NSString *imgStr = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"img")];
//            if ([imgStr isEqualToString:@" "]||[imgStr isEqualToString:@""]) {
//                cell.headImageV.imageURL =nil;
//            }else{
//            cell.headImageV.imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@/80/80",BaseImageUrl,[GameCommon getHeardImgId:imgStr]]];
//            }
//        }else{
//            cell.titleLabel.text = @"";
//            cell.nameLabel.text = @"暂无新的动态";
//            cell.timeLabel.text = @"";
//            cell.headImageV.hidden = YES;
//        }
//        
//        cell.fansLabel.text = [GameCommon getNewStringWithId:m_hostInfo.fanNum];
//        cell.zanLabel.text = [GameCommon getNewStringWithId:m_hostInfo.zanNum];
//        [cell.cellButton addTarget:self action:@selector(myStateClick:) forControlEvents:UIControlEventTouchUpInside];
//
//           return cell;

        
        
        
        if([m_hostInfo.state isKindOfClass:[NSDictionary class]] && [[m_hostInfo.state allKeys] count] != 0)//动态
        {
            if ([KISDictionaryHaveKey(m_hostInfo.state, @"destUser") isKindOfClass:[NSDictionary class]]) {//目标 别人评论了我
                NSDictionary* destDic = KISDictionaryHaveKey(m_hostInfo.state, @"destUser");
                NSString * imgid = [GameCommon getHeardImgId: KISDictionaryHaveKey(destDic, @"userimg")];
                if (imgid) {
                    cell.headImageV.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:imgid]];
                }else
                {
                    cell.headImageV.imageURL = nil;
                }
                
                cell.titleLabel.text = [NSString stringWithFormat:@"%@%@",[[GameCommon getNewStringWithId:KISDictionaryHaveKey(destDic, @"alias")] isEqualToString:@""] ? KISDictionaryHaveKey(destDic, @"nickname") : KISDictionaryHaveKey(destDic, @"alias") , KISDictionaryHaveKey(m_hostInfo.state, @"showtitle")];
            }
            else
            {
                NSString * imgid = [GameCommon getHeardImgId: KISDictionaryHaveKey(m_hostInfo.state, @"userimg")];
                if ([imgid isEqualToString:@""]||[imgid isEqualToString:@" "]) {
                     cell.headImageV.imageURL = nil;
                }else{
                if (imgid) {
                    cell.headImageV.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:imgid]];
                }else
                {
                    cell.headImageV.imageURL = nil;
                }
                
                }
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
//            if ([[NSUserDefaults standardUserDefaults] objectForKey:haveMyNews] && [[[NSUserDefaults standardUserDefaults] objectForKey:haveMyNews] isEqualToString:@"1"]){
//                cell.notiBgV.hidden = NO;
//            }
//            else
//                cell.notiBgV.hidden = YES;
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

//        NSArray* characterArray = KISDictionaryHaveKey(m_hostInfo.characters, @"1");//魔兽世界 旧的
        
        NSMutableArray* characterArray = m_hostInfo.charactersArr;//魔兽世界 新的
        
        
        [[NSUserDefaults standardUserDefaults]setObject:characterArray forKey:@"CharacterArrayOfAllForYou"];
        
        
//        if (![characterArray isKindOfClass:[NSArray class]]) {
            if ([characterArray count]<=0) {
//          cell.heardImg.image = [UIImage imageNamed:@"clazz_0.png"];
//          cell.nameLabel.text = @"暂无角色";
            cell.heardImg.hidden = YES;
            cell.authBg.hidden = YES;
            cell.nameLabel.hidden = YES;
            cell.realmLabel.hidden = YES;
            cell.gameImg.hidden = YES;
            cell.pveLabel.hidden = YES;
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
            cell.noCharacterLabel.hidden = YES;
            NSDictionary* tempDic = [characterArray objectAtIndex:indexPath.row];
            
//            if ([KISDictionaryHaveKey(tempDic, @"failedmsg")intValue] ==404)//角色不存在
//            {
//                cell.heardImg.image = [UIImage imageNamed:@"clazz_0.png"];
//                cell.realmLabel.text = @"角色不存在";
//            }
//            else
//            {
//                int imageId = [KISDictionaryHaveKey(tempDic, @"clazz") intValue];
//                if (imageId > 0 && imageId < 12) {//1~11
//                    cell.heardImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_%d", imageId]];
//                }
//                else
//                    cell.heardImg.image = [UIImage imageNamed:@"clazz_0.png"];
//                NSString* realm = [KISDictionaryHaveKey(tempDic, @"raceObj") isKindOfClass:[NSDictionary class]] ? KISDictionaryHaveKey(KISDictionaryHaveKey(tempDic, @"raceObj"), @"sidename") : @"";
//                cell.realmLabel.text = [KISDictionaryHaveKey(tempDic, @"realm") stringByAppendingString:realm];
//            }
//            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"auth")] isEqualToString:@"1"]) {//已认证
//                cell.authBg.hidden = NO;
//                cell.authBg.image= KUIImage(@"chara_auth_1");
//            }
//            else
//            {
//                cell.authBg.hidden = NO;
//                 cell.authBg.image= KUIImage(@"chara_auth_2");
//            }
//            cell.rowIndex = indexPath.row;
//            cell.myDelegate = self;
//            cell.gameImg.image = KUIImage(@"wow");
//            cell.nameLabel.text = KISDictionaryHaveKey(tempDic, @"name");
//            cell.pveLabel.text = [GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"pveScore")];
//            cell.noCharacterLabel.hidden = YES;
            NSString* realm =  KISDictionaryHaveKey(tempDic, @"realm");//服务器
            NSString* v1=KISDictionaryHaveKey(tempDic, @"value1");//部落
            NSString* v2=KISDictionaryHaveKey(tempDic, @"value2");//战斗力
            NSString* v3=KISDictionaryHaveKey(tempDic, @"value3");//战斗力数
            NSString* auth=KISDictionaryHaveKey(tempDic, @"auth");
            NSString* name=KISDictionaryHaveKey(tempDic, @"name");
            NSString* failedmsg=KISDictionaryHaveKey(tempDic, @"failedmsg");
            NSString* img=KISDictionaryHaveKey(tempDic, @"img");//角色图标
            
            if ([failedmsg intValue] ==404)//角色不存在
            {
                cell.heardImg.image = [UIImage imageNamed:@"clazz_0.png"];
                cell.realmLabel.text = @"角色不存在";
            }
            else
            {
                if (!img ||[img isEqualToString:@""]) {//1~11
                    cell.heardImg.imageURL=nil;
//                    cell.heardImg.image = [UIImage imageNamed:[NSString stringWithFormat:@"clazz_0.png"]];
                }
                else
                    cell.heardImg.imageURL=[NSURL URLWithString:[[BaseImageUrl stringByAppendingString:[GameCommon getNewStringWithId:img]] stringByAppendingString:@"/81"]];
                
                
                cell.realmLabel.text = [[realm stringByAppendingString:@" "] stringByAppendingString:v1];
            }
            if ([[GameCommon getNewStringWithId:auth] isEqualToString:@"1"]) {//已认证
                cell.authBg.hidden = NO;
                cell.authBg.image= KUIImage(@"chara_auth_1");
            }
            else
            {
                cell.authBg.hidden = NO;
                cell.authBg.image= KUIImage(@"chara_auth_2");
            }
            cell.rowIndex = indexPath.row;
            cell.myDelegate = self;
            cell.gameImg.image = KUIImage(@"wow");
            cell.nameLabel.text = name;
            cell.pveLabel.text = [GameCommon getNewStringWithId:v3];
            cell.noCharacterLabel.text=v2;
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

- (void)CellOneButtonClick:(NSInteger)rowIndex
{
//    NSMutableArray* characterArray = KISDictionaryHaveKey(m_hostInfo.characters, @"1");//魔兽世界
//    if (![characterArray isKindOfClass:[NSArray class]]) {
//        return;
//    }
    
    if ([m_hostInfo.charactersArr count]>0) {
        return;
    }
    m_refreshCharaIndex = rowIndex;
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"是否刷新该角色信息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 112;
    [alert show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 112) {
        if (buttonIndex != alertView.cancelButtonIndex) {
//            NSMutableArray* characterArray = KISDictionaryHaveKey(m_hostInfo.characters, @"1");//魔兽世界
            NSMutableArray* characterArray =m_hostInfo.charactersArr;//魔兽世界
            
            
            NSDictionary* tempDic = [characterArray objectAtIndex:m_refreshCharaIndex];
            if ([KISDictionaryHaveKey(tempDic, @"failedmsg") isEqualToString:@"404"])//角色不存在
            {
                [self showAlertViewWithTitle:@"提示" message:@"角色不存在" buttonTitle:@"确定"];
                return;
            }
            else
            {
                NSDictionary* tempDic = [characterArray objectAtIndex:m_refreshCharaIndex];
                NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
                NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
                
                [paramDict setObject:@"1" forKey:@"gameid"];
                [paramDict setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"id")] forKey:@"characterid"];
                
                [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
                [postDict setObject:paramDict forKey:@"params"];
                [postDict setObject:@"123" forKey:@"method"];
                [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
                
                [hud show:YES];
                
                [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [hud hide:YES];
                    NSLog(@"新角色信息：：：%@", responseObject);
                    if ([responseObject isKindOfClass:[NSDictionary class]]) {
                        [characterArray replaceObjectAtIndex:m_refreshCharaIndex withObject:responseObject];
                        m_hostInfo.characters = [NSDictionary dictionaryWithObject:characterArray forKey:@"1"];
                        
                        NSIndexSet* section = [[NSIndexSet alloc] initWithIndex:2];
                        [m_myTableView reloadSections:section withRowAnimation:UITableViewRowAnimationNone];
                    }
                    //            [self getUserInfoByNet];
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
        }
    }
}

//- (NSString*)getCellTitleWithType:(NSString*)type withNick:(NSString*)nickName withUserId:(NSString*)userid
//{
//    NSInteger typeInt = [type intValue];
//    if (type == 0) {
//        return nickName;
//    }
//    NSString* titleStr = @"";
//
//    switch (typeInt) {
//        case 3://发表
//            if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
//                titleStr = [titleStr stringByAppendingString:@"我发表了该内容"];
//            }
//            break;
//        case 4://赞
//            if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
//                titleStr = [titleStr stringByAppendingString:@"我赞了该内容"];
//            }
//            else
//            {
//                titleStr = [titleStr stringByAppendingFormat:@"%@赞了该内容", nickName];
//            }
//            break;
//        case 5://评论
//            if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
//                titleStr = [titleStr stringByAppendingString:@"我评论了该内容"];
//            }
//            else
//            {
//                titleStr = [titleStr stringByAppendingFormat:@"%@评论了该内容", nickName];
//            }
//            break;
//        default:
//            break;
//    }
//    return titleStr;
//}

- (void)myStateClick:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
//    //进入与我相关
//    CircleWithMeViewController *cirMe = [[CircleWithMeViewController alloc]init];
//    cirMe.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
//
//    [self.navigationController pushViewController:cirMe animated:YES];
    
    //消除红点
    //[[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveMyNews];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    //[[GameCommon shareGameCommon] displayTabbarNotification];

    MyCircleViewController* VC = [[MyCircleViewController alloc] init];
    NSString * myUserid = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    VC.userId = myUserid;
    NSDictionary* user=[[UserManager singleton] getUser:myUserid];
    NSString * myNickName = [user objectForKey:@"nickname"];
    NSString * myImg = [user objectForKey:@"img"];
    VC.nickNmaeStr = myNickName;
    VC.imageStr = myImg;
    // VC.myViewType = ME_NEWS_TYPE;  暂时不能识别是自己的还是别人的
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
//        [[Custom_tabbar showTabBar] hideTabBar:YES];
//        NewsViewController* VC = [[NewsViewController alloc] init];
//        VC.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
//        VC.myViewType = ME_NEWS_TYPE;
//        [self.navigationController pushViewController:VC animated:YES];
//        
//        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveMyNews];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        [[GameCommon shareGameCommon] displayTabbarNotification];
        

        
        
        
    }
    else if(indexPath.section == 2)
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        CharacterDetailsViewController* VC = [[CharacterDetailsViewController alloc] init];
//        NSArray* characterArray = KISDictionaryHaveKey(m_hostInfo.characters, @"1");//魔兽世界
//        if (![characterArray isKindOfClass:[NSArray class]]){
//            CharacterEditViewController *characterVC = [[CharacterEditViewController alloc]init];
//            characterVC.isFromMeet =NO;
//            
//            [self.navigationController pushViewController:characterVC animated:YES];
//            NSLog(@"添加角色");
//        }
         NSArray* characterArray = m_hostInfo.charactersArr;//魔兽世界
        if ([characterArray count]>0){
            NSDictionary *dic = [characterArray objectAtIndex:indexPath.row];
            NSString* gameId=[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"gameid")];//游戏Id
            NSString* chatId=[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"id")];//角色Id
            VC.characterId = chatId;
            VC.gameId = gameId;
            VC.myViewType = CHARA_INFO_MYSELF;
            [[NSNotificationCenter defaultCenter]postNotificationName:@"contentOfjuese" object:nil];
            [self.navigationController pushViewController:VC animated:YES];
            NSLog(@"角色详情");
        }
        else
        {
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
    
    if (m_hostInfo.achievementArray && [m_hostInfo.achievementArray count] != 0) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        MyTitleObjViewController* VC = [[MyTitleObjViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];
    }else{
        [self showMessageWithContent:@"暂无头衔" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
    }
}



- (BOOL)prefersStatusBarHidden
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
