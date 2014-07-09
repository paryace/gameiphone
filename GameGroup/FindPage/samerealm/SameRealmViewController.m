//
//  SameRealmViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-19.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "SameRealmViewController.h"
#import "PersonTableCell.h"
#import "TestViewController.h"
#import "MJRefresh.h"
#import "CharacterEditViewController.h"
@interface SameRealmViewController ()
{
    UIButton*           m_selectRealmButton;
    UIButton*           m_selectImage;
    SelectView*         m_selectView;
    
    NSMutableArray*     m_realmsArray;
    
    UITableView*        m_myTableView;
    NSMutableArray*     m_tabelData;
    
    NSInteger           m_searchType;//3全部 0男 1女
    
    NSInteger           m_totalPage;
    NSInteger           m_currentPage;//0开始
    UIAlertView* alert;
    NSMutableArray *m_imgArray;
    NSInteger       sealmPage;
    
    UIImageView *m_loadImageView;
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    BOOL isGetNetSuccess;
    UIAlertView *alertView1;
}

@end

@implementation SameRealmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"" withBackButton:YES];
    isGetNetSuccess = YES;
    m_loadImageView = [[UIImageView alloc]initWithFrame:CGRectMake(70, KISHighVersion_7 ? 32 : 12, 20, 20)];
    NSMutableArray *imageArray = [NSMutableArray array];
    for (int i = 0; i<12; i++) {
        NSString *str =[NSString stringWithFormat:@"%d_03",i+1];
        [imageArray addObject:[UIImage imageNamed:str]];
    }
    
    m_loadImageView.animationImages = imageArray;
    m_loadImageView.animationDuration = 1;
    [m_loadImageView startAnimating];
    [self.view addSubview:m_loadImageView];

    m_tabelData = [[NSMutableArray alloc] init];
    m_realmsArray = [[NSMutableArray alloc] init];
    m_imgArray = [NSMutableArray array];
    m_myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX - (KISHighVersion_7?0:20))];
    m_myTableView.dataSource = self;
    m_myTableView.delegate = self;
    [self.view addSubview:m_myTableView];
    
    m_selectView = [[SelectView alloc] initWithFrame:CGRectZero];
    m_selectView.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    m_selectView.selectDelegate = self;
    [self.view addSubview:m_selectView];
    

    
    m_selectRealmButton = [[UIButton alloc] initWithFrame:CGRectMake(60, KISHighVersion_7 ? 20 : 0, 200, 20)];
//    [m_selectRealmButton setImage:KUIImage(@"toparrow_down") forState:UIControlStateNormal];
//    [m_selectRealmButton setImage:KUIImage(@"toparrow_up") forState:UIControlStateSelected];
//    m_selectRealmButton.imageEdgeInsets = UIEdgeInsetsMake(26, 160, 26, 26);
//    m_selectRealmButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 18);
    [m_selectRealmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_selectRealmButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    m_selectRealmButton.backgroundColor = [UIColor clearColor];
    m_selectRealmButton.hidden = YES;
    [m_selectRealmButton addTarget:self action:@selector(selectRealmClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_selectRealmButton];
    
    
    m_selectImage = [[UIButton alloc] initWithFrame:CGRectMake(265, KISHighVersion_7 ? 20 : 0, 20, 15)];
    [m_selectImage setImage:KUIImage(@"toparrow_down") forState:UIControlStateNormal];
    [m_selectImage setImage:KUIImage(@"toparrow_up") forState:UIControlStateSelected];
    [m_selectImage setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    m_selectImage.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    m_selectImage.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_selectImage];

    
    UIButton *menuButton=[UIButton buttonWithType:UIButtonTypeCustom];
    menuButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [menuButton setBackgroundImage:KUIImage(@"menu_button_normal") forState:UIControlStateNormal];
    [menuButton setBackgroundImage:KUIImage(@"menu_button_click") forState:UIControlStateHighlighted];
    [self.view addSubview:menuButton];
    if (isGetNetSuccess) {
        menuButton.userInteractionEnabled = YES;
    }
    else{
        menuButton.userInteractionEnabled =NO;
    }
    [menuButton addTarget:self action:@selector(menuButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    m_searchType = 3;
    m_totalPage = 0;
    m_currentPage = 0;
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
    [self addHeader];
    [self addFooter];

    [self getRealmsDataByNet];//所有服务器名
    
}

- (void)getRealmsDataByNet
{
    isGetNetSuccess = NO;
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.gameid forKey:@"gameid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"218" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         isGetNetSuccess =YES;
             [hud hide: YES];
        if ([responseObject isKindOfClass:[NSArray class]])
        {
            NSArray *array = responseObject;
            if (array.count==0) {
                alertView1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定角色" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去绑定", nil];
                alertView1.tag = 10001;
                [alertView1 show];
                [m_loadImageView stopAnimating];

                return ;
            }
            
            NSMutableArray* selectArray = [[NSMutableArray alloc] init];
            for (NSString *str in responseObject)
            {
                NSString* realmStr = str;
                    [m_realmsArray addObject:realmStr];
                   
                    NSMutableDictionary* selectViewDic = [NSMutableDictionary dictionaryWithCapacity:1];
                    [selectViewDic setObject:self.gameid forKey:kSelectGameIdKey];
                    [selectViewDic setObject:realmStr forKey:kSelectRealmKey];
                    [selectViewDic setObject:str forKey:kSelectCharacterKey];
                    [selectArray addObject:selectViewDic];
            }
            if ([m_realmsArray count] > 0) {
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_buttonTitleOfPage"]!=nil&&[[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_buttonTitleOfPage"]intValue]<m_realmsArray.count) {
                    [m_selectRealmButton setTitle:[m_realmsArray objectAtIndex:[[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_buttonTitleOfPage"]intValue]] forState:UIControlStateNormal];
                    [self setTitleOrgin];
                }else{
                    [m_selectRealmButton setTitle:[m_realmsArray objectAtIndex:0] forState:UIControlStateNormal];
                    [self setTitleOrgin];
                }
                float viewHeight = 21 + [m_realmsArray count] * 40;
                m_selectView.frame = CGRectMake(0, 0, kScreenWidth, viewHeight);
                m_selectView.center = CGPointMake(kScreenWidth/2, -(startX + viewHeight/2));
                m_selectView.buttonTitleArray = selectArray;
                [m_selectView setMainView];
                m_selectRealmButton.hidden = NO;

                [self getSameRealmDataByNet];
            }
        }else{
            [m_loadImageView stopAnimating];

            alertView1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有绑定角色" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去绑定", nil];
            alertView1.tag = 10001;
            [alertView1 show];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_loadImageView stopAnimating];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert2 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert2 show];
            }
        }
        else
        {
            alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求数据失败，请检查网络！" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
            alert.tag = 56;
            [alert show];
        }
        [hud hide:YES];
    }];
}

-(void)setTitleOrgin
{
    CGSize nameSize = [m_selectRealmButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:20.0] constrainedToSize:CGSizeMake(182, 20) lineBreakMode:NSLineBreakByWordWrapping];
    m_selectRealmButton.frame = CGRectMake((200-(nameSize.width>185?185:nameSize.width)+20-3)/2+50,(startX)/2, nameSize.width, 20);
    m_selectImage.frame = CGRectMake(m_selectRealmButton.frame.origin.x+m_selectRealmButton.frame.size.width+3,(startX)/2, 20, 15);
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 56) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (alertView.tag == 10001) {
        if (buttonIndex ==1) {
            CharacterEditViewController *CVC = [[CharacterEditViewController alloc]init];
            CVC.isFromMeet = YES;
            [self.navigationController pushViewController:CVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }

    
}

- (void)getSameRealmDataByNet
{
    isGetNetSuccess = NO;

    [m_loadImageView startAnimating];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    if (m_searchType != 3) {
        [paramDict setObject:[NSString stringWithFormat:@"%d", m_searchType] forKey:@"gender"];
    }
    [paramDict setObject:self.gameid forKey:@"gameid"];
    NSArray* realmArr = [m_selectRealmButton.titleLabel.text componentsSeparatedByString:@"("];
    
    //记忆服务器
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sameRealmOfsb"] !=nil) {
//        [paramDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:@"sameRealmOfsb"] forKey:@"realm"];
//    }else{
    
    NSLog(@"------》%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"sameRealmOfsb"]);
    if (realmArr && [realmArr count] != 0) {
        [paramDict setObject:[realmArr objectAtIndex:0] forKey:@"realm"];
    }
   // }
    
    [paramDict setObject:[NSString stringWithFormat:@"%d", m_currentPage] forKey:@"pageIndex"];
    [paramDict setObject:@"10" forKey:@"maxSize"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"121" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        isGetNetSuccess =YES;
        [m_loadImageView stopAnimating];
        if ((m_currentPage ==0 && ![responseObject isKindOfClass:[NSDictionary class]]) || (m_currentPage != 0 && ![responseObject isKindOfClass:[NSArray class]])) {
            [m_header endRefreshing];
            [m_footer endRefreshing];
            return;
        }
        if (m_currentPage == 0) {
            [m_tabelData removeAllObjects];
            
            
            [m_tabelData addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"users")];
            if (m_tabelData.count<1) {
                [self showMessageWithContent:@"暂无玩家信息" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
            }
            
            m_totalPage = [[responseObject objectForKey:@"totalResults"] intValue];
        }
        else
        {
            [m_tabelData addObjectsFromArray:responseObject];
        }
        
        [m_myTableView reloadData];


        m_currentPage ++;//从0开始
        
        [m_header endRefreshing];
        [m_footer endRefreshing];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_loadImageView stopAnimating];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert1 = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert1 show];
            }
        }
        [m_header endRefreshing];
        [m_footer endRefreshing];

        [hud hide:YES];
    }];
}

#pragma mark 服务器筛选
- (void)selectRealmClick:(id)sender
{
    m_selectRealmButton.selected = !m_selectRealmButton.selected;
    
    float viewHeight = 21 + [m_realmsArray count] * 40;
//    [UIView animateWithDuration:0.4 animations:^{
        if (m_selectRealmButton.selected) {
            m_selectView.center = CGPointMake(kScreenWidth/2, startX + viewHeight/2);
        }
        else
            m_selectView.center = CGPointMake(kScreenWidth/2, -(startX + viewHeight/2));
//    } completion:^(BOOL finished) {
//        
//    }];
}

- (void)selectButtonWithIndex:(NSInteger)buttonIndex
{
    [self selectRealmClick:Nil];
    m_searchType = 3;
    [m_selectRealmButton setTitle:[m_realmsArray objectAtIndex:buttonIndex] forState:UIControlStateNormal];
    [self setTitleOrgin];
    [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",buttonIndex] forKey:@"wx_buttonTitleOfPage"];
    if (m_selectRealmButton.titleLabel.text.length>6) {
        m_selectRealmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }else{
        m_selectRealmButton.titleLabel.font = [UIFont systemFontOfSize:20];
        
    }

    m_currentPage = 0;
    [self getSameRealmDataByNet];
}

#pragma mark 筛选
- (void)menuButtonClick:(id)sender
{
    if (isGetNetSuccess ==NO) {
        [self showMessageWithContent:@"正在处理上次请求" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];

    }else{
    
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"筛选条件"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"只看男", @"只看女", @"看全部", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
    }
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
  //  [m_tabelData removeAllObjects];
    [m_myTableView reloadData];
    
    m_currentPage = 0;
    
    NSString* currentTitle = @"";
    NSArray* realmArr = [m_selectRealmButton.titleLabel.text componentsSeparatedByString:@"("];
    if (realmArr && [realmArr count] != 0) {
        currentTitle = [realmArr objectAtIndex:0];
    }

    if (buttonIndex == 0) {//男
        [m_selectRealmButton setTitle:[currentTitle stringByAppendingString:@"(男)"] forState:UIControlStateNormal];
        [self setTitleOrgin];
        m_searchType = 0;
    }
    else if (buttonIndex == 1) {//女
        [m_selectRealmButton setTitle:[currentTitle stringByAppendingString:@"(女)"] forState:UIControlStateNormal];
        [self setTitleOrgin];
        m_searchType = 1;
    }
    else//全部
    {
        [m_selectRealmButton setTitle:currentTitle forState:UIControlStateNormal];
        [self setTitleOrgin];
        m_searchType = 3;
    }
    
    if (m_selectRealmButton.titleLabel.text.length>6) {
        m_selectRealmButton.titleLabel.font = [UIFont systemFontOfSize:16];
    }else{
        m_selectRealmButton.titleLabel.font = [UIFont systemFontOfSize:20];
    
    }

    [self getSameRealmDataByNet];
}

#pragma mark - table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_tabelData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"myCell";
    PersonTableCell *cell = (PersonTableCell*)[tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[PersonTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    NSDictionary* tempDict = [m_tabelData objectAtIndex:indexPath.row];
    
    
    
    cell.nameLabel.text = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"alias")] isEqualToString:@""] ? [tempDict objectForKey:@"nickname"] : KISDictionaryHaveKey(tempDict, @"alias");
    
//    cell.sexImg.image = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"gender")] isEqualToString:@"0"] ? KUIImage(@"man") : KUIImage(@"woman");
    
//    cell.sexBg.backgroundColor = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"gender")] isEqualToString:@"0"] ? kColorWithRGB(33, 193, 250, 1.0) : kColorWithRGB(238, 100, 196, 1.0);
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"gender")] isEqualToString:@"0"]) {//男♀♂
        cell.ageLabel.text = [@"♂ " stringByAppendingString:[GameCommon getNewStringWithId:[tempDict objectForKey:@"age"]]];
        cell.ageLabel.backgroundColor = kColorWithRGB(33, 193, 250, 1.0);
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_man.png"];
    }
    else
    {
        cell.ageLabel.text = [@"♀ " stringByAppendingString:[GameCommon getNewStringWithId:[tempDict objectForKey:@"age"]]];
        cell.ageLabel.backgroundColor = kColorWithRGB(238, 100, 196, 1.0);
        cell.headImageV.placeholderImage = [UIImage imageNamed:@"people_woman.png"];
    }
    NSString * imageIdss=KISDictionaryHaveKey(tempDict, @"img");
    cell.headImageV.imageURL = [ImageService getImageStr:imageIdss Width:80];
    NSDictionary* titleDic = KISDictionaryHaveKey(tempDict, @"title");
    if ([titleDic isKindOfClass:[NSDictionary class]]) {
        cell.distLabel.text = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"title")] isEqualToString:@""] ? @"暂无头衔" : KISDictionaryHaveKey(KISDictionaryHaveKey(titleDic, @"titleObj"), @"title");
        cell.distLabel.textColor = [GameCommon getAchievementColorWithLevel:[KISDictionaryHaveKey(KISDictionaryHaveKey(titleDic, @"titleObj"), @"rarenum") integerValue]];
    }
    else
    {
        cell.distLabel.text = @"暂无头衔";
        cell.distLabel.textColor = [UIColor blackColor];
    }
    
    cell.timeLabel.text = [GameCommon getTimeAndDistWithTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"updateUserLocationDate")] Dis:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDict, @"distance")]];
    
    [cell refreshCell];
    
    //-----
//    NSArray * gameidss=[GameCommon getGameids:[tempDict objectForKey:@"gameids"]];
    NSArray * gameidss=[GameCommon getGameids:[NSString stringWithFormat:@"%@",self.gameid]];
    [cell setGameIconUIView:gameidss];
    //-----
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (m_tabelData.count ==0) {
        return;
    }
    
    NSDictionary* recDict = [m_tabelData objectAtIndex:indexPath.row];
    
     TestViewController* VC = [[TestViewController alloc] init];
    
    VC.userId = KISDictionaryHaveKey(recDict, @"id");
    VC.nickName = KISDictionaryHaveKey(recDict, @"nickname");
    VC.ageStr = [NSString stringWithFormat:@"%d",[KISDictionaryHaveKey(recDict, @"age")intValue]];
    VC.sexStr = [NSString stringWithFormat:@"%d",[KISDictionaryHaveKey(recDict, @"gender")intValue]];
    VC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"updateUserLocationDate")];
    VC.jlStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"distance")];
    if([KISDictionaryHaveKey(recDict, @"active")intValue]==2){
        VC.isActiveAc =YES;
    }
    else{
        VC.isActiveAc =NO;
    }

    VC.achievementColor =[[GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"title")] isEqualToString:@""] ? @"暂无头衔" :KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(recDict, @"title"), @"titleObj"), @"rarenum");
    
    VC.achievementStr = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"title")] isEqualToString:@""] ? @"暂无头衔" : KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(recDict, @"title"), @"titleObj"), @"title");

    VC.constellationStr =KISDictionaryHaveKey(recDict, @"constellation");

    VC.createTimeStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"createTime")];

    VC.constellationStr =KISDictionaryHaveKey(recDict, @"constellation");
    VC.titleImage = [GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"img")];
    VC.isChatPage = NO;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark --加载刷新
- (void)addFooter
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;

    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getSameRealmDataByNet];
        
    };
    m_footer = footer;
    
}
- (void)addHeader
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;

    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currentPage = 0;
        [self getSameRealmDataByNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
    //[header beginRefreshing];
    m_header = header;
}

-(void)dealloc
{
    alertView1.delegate = nil;
    alert.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
