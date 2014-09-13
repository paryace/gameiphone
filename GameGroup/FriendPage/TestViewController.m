//
//  TestViewController.m
//  GameGroup 
//
//  Created by admin on 14-3-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TestViewController.h"
#import "PhotoViewController.h"
#import "AppDelegate.h"
#import "SetRemarkNameViewController.h"
#import "KKChatController.h"
#import "TitleObjDetailViewController.h"//头衔界面
#import "NewsViewController.h"//动态界面
#import "AppDelegate.h"
#import "CharacterDetailsViewController.h"
#import "UserManager.h"
#import "HelpViewController.h"
#import "MyCircleViewController.h"
#import "ImageService.h"
#import "GroupInformationViewController.h"
#import "GroupListViewController.h"
#import "H5CharacterDetailsViewController.h"

@interface TestViewController ()
{
    UILabel*        m_titleLabel;
    HGPhotoWall*    m_photoWall;
    
    UIScrollView*    m_myScrollView;
    
    float           m_currentStartY;
    
    UILabel*        m_relationLabel;//关系
    
    AppDelegate*    m_delegate;
    NSMutableArray *littleImgArray;

    UIView*         m_buttonBgView;
    NSMutableArray *wxSDArray;
    UIButton *        delFriendBtn;
    UIButton *        addFriendBtn;
    UIButton *        attentionBtn;
    UIButton *        attentionOffBtn;
}

@end

@implementation TestViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    m_titleLabel.text = [DataStoreManager queryRemarkNameForUser:self.userId];//别名或昵称
    if ([m_titleLabel.text isEqualToString:@""]) {//不是好友或关注
        m_titleLabel.text = self.nickName?self.nickName:self.hostInfo.nickName;
        NSLog(@"self.userid%@",self.nickName);
    }
    NSLog(@"m_titlelabel%@",m_titleLabel.text);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTopViewWithTitle:@"" withBackButton:YES];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getInfoFromUserManager:) name:userInfoUpload object:nil];
    wxSDArray = [NSMutableArray array];
    littleImgArray = [NSMutableArray array];
    self.isOnClick = NO;
    NSDictionary *dic = [self getUserInfo:self.userId];//获取缓存
    if (dic) {//本地有
        self.hostInfo = [[HostInfo alloc] initWithHostInfo:dic];
        [self setInfoViewType:self.hostInfo];
        [self setBottomView];
        [self buildMainView];
        [[UserManager singleton]requestUserFromNet:self.userId];
    }else{
        [self buildInitialize];
        [[UserManager singleton]requestUserFromNet:self.userId];
    }
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hud];
}
//从缓存获取用户信息
-(NSDictionary*)getUserInfo:(NSString*)userId
{
    NSMutableData *data= [NSMutableData data];//将nsuserdefaults中获取到的数据 抓换成data 并且转化成NSDictionary
    NSDictionary *dic = [NSDictionary dictionary];
    data =[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"swxInPersonInfo%@",self.userId]];
    if (!data) {
        return nil;
    }
    NSKeyedUnarchiver *unarchiver= [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    dic = [unarchiver decodeObjectForKey: @"getDatat"];
    [unarchiver finishDecoding];
    return  dic;
}

//保存用户信息到缓存
-(void)saveUserInfo:(NSString*)userId UserInfo:(NSDictionary*) userInfodictionary
{
    NSMutableData *data= [[NSMutableData alloc]init]; //将获取到的数据转换成NSData类型保存到nsuserdefaults中
    NSKeyedArchiver *archiver= [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:userInfodictionary forKey: @"getDatat"];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:[NSString stringWithFormat:@"swxInPersonInfo%@",self.userId]];
}
//用户信息获取成功接收到的广播
-(void)getInfoFromUserManager:(NSNotification *)notification
{
    if (![[[notification.userInfo objectForKey:@"user"] objectForKey:@"userid"]isEqualToString:self.userId])
    {
        return;
    }
    
    NSDictionary *dictionary = notification.userInfo;
    NSLog(@"111--个人详情的用户信息");
    [self saveUserInfo:self.userId UserInfo:dictionary];//保存
    NSArray *views = [self.view subviews];
    for(UIView* view in views)
    {
        [view removeFromSuperview];
    }
    [self setTopViewWithTitle:@"" withBackButton:YES];
    self.hostInfo = [[HostInfo alloc] initWithHostInfo:dictionary];
    [self setInfoViewType:self.hostInfo];
    [self setBottomView];//设置底部按钮
    //重新设置标题
    m_titleLabel.text = [[GameCommon getNewStringWithId:self.hostInfo.alias] isEqualToString:@""] ? self.nickName : self.hostInfo.alias;
    [self buildMainView];
}

-(void)setInfoViewType:(HostInfo*)hostInfo
{
    if ([self.hostInfo.relation isEqualToString:@"1"]) {
        
        self.viewType = VIEW_TYPE_FriendPage1;
    }
    else if([self.hostInfo.relation isEqualToString:@"2"]) {
        
        self.viewType = VIEW_TYPE_AttentionPage1;
    }
    else if([self.hostInfo.relation isEqualToString:@"3"]) {
        
        self.viewType = VIEW_TYPE_FansPage1;
    }
    else if([self.hostInfo.userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]])
    {
        self.viewType = VIEW_TYPE_Self1;
    }
    else  {
        self.viewType = VIEW_TYPE_STRANGER1;
    }
}
-(void)buildInitialize
{
    UIButton *editButton=[UIButton buttonWithType:UIButtonTypeCustom];
    editButton.frame=CGRectMake(270, startX - 44, 50, 44);
    [editButton setBackgroundImage:KUIImage(@"edit_normal") forState:UIControlStateNormal];
    [editButton setBackgroundImage:KUIImage(@"edit_click") forState:UIControlStateHighlighted];
    [self.view addSubview:editButton];
    
    
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
    m_titleLabel.text = self.nickName;
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    
    m_currentStartY = 0;
    
    m_myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX - (KISHighVersion_7?0:20))];
    [self.view addSubview:m_myScrollView];
    m_myScrollView.backgroundColor = [UIColor clearColor];
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 80)];
    view.backgroundColor =[UIColor grayColor];
    [m_myScrollView addSubview:view];
    
    self.headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 5, 70, 70)];
    self.headImageView.layer.cornerRadius = 5;
    self.headImageView.layer.masksToBounds=YES;
    self.headImageView.placeholderImage = [UIImage imageNamed:@"people_man.png"];

   self.headImageView.imageURL =[ImageService getImageStr:self.titleImage Width:80];
    
    m_currentStartY +=80;
    
    NSString *sexStr = [NSString stringWithFormat:@"%@",self.sexStr];
    NSString *ageStr = [NSString stringWithFormat:@"%@",self.ageStr];
    NSArray * gameidss=[GameCommon getGameids:self.hostInfo.gameids];
    UIView* genderView = [CommonControlOrView setGenderAndAgeViewWithFrame:CGRectMake(10, m_currentStartY, kScreenWidth, 30) gender:sexStr age:ageStr star:self.constellationStr gameIds:gameidss];
    [m_myScrollView addSubview:genderView];
    
    UILabel* timeLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(150, m_currentStartY, 160, 30) textColor:kColorWithRGB(151, 151, 151, 1.0) font:[UIFont systemFontOfSize:12.0] text:[GameCommon getTimeAndDistWithTime:self.timeStr Dis:self.jlStr] textAlignment:NSTextAlignmentRight];
    [m_myScrollView addSubview:timeLabel];
    
    m_currentStartY += 30;
    [self setOneLineWithY:m_currentStartY];
    
    //////个人动态
    
    m_myScrollView.contentSize = CGSizeMake(kScreenWidth, m_currentStartY);
    
    float currentHeigth = 0;
    
    UIView* topBg7 = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg7.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg7];
    
    UILabel* titleLabel7 = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人动态" textAlignment:NSTextAlignmentLeft];
    [topBg7 addSubview:titleLabel7];
    
    m_currentStartY += 30;
    
    [self setOneLineWithY:m_currentStartY];
    
    /////////////////
    UIButton* zanBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, m_currentStartY + 10, 75, 30)];
    [zanBtn setImage:KUIImage(@"detail_zan") forState:UIControlStateNormal];
    zanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 45);
    [zanBtn addTarget:self action:@selector(ZanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_myScrollView addSubview:zanBtn];
    
    UILabel* zanLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(42, m_currentStartY + 10, 45, 30) textColor:kColorWithRGB(151, 151, 151, 1.0) font:[UIFont systemFontOfSize:12.0] text:self.hostInfo.zanNum textAlignment:NSTextAlignmentLeft];
    [m_myScrollView addSubview:zanLabel];
    
    UIButton* fansBtn = [[UIButton alloc] initWithFrame:CGRectMake(85, m_currentStartY + 10, 75, 30)];
    [fansBtn setImage:KUIImage(@"detail_fans") forState:UIControlStateNormal];
    fansBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 45);
    [fansBtn addTarget:self action:@selector(FansButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_myScrollView addSubview:fansBtn];
    
    UILabel* fansLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(117, m_currentStartY + 10, 45, 30) textColor:kColorWithRGB(151, 151, 151, 1.0) font:[UIFont systemFontOfSize:12.0] text:self.hostInfo.fanNum textAlignment:NSTextAlignmentLeft];
    [m_myScrollView addSubview:fansLabel];
    
    m_buttonBgView = [[UIView alloc] initWithFrame:CGRectMake(165, m_currentStartY, kScreenWidth-165, 50)];
    m_buttonBgView.backgroundColor = [UIColor clearColor];
    [m_myScrollView addSubview:m_buttonBgView];
    
    m_currentStartY += 50;
    ////////////////////////
    UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg];
    
    UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人资料" textAlignment:NSTextAlignmentLeft];
    [topBg addSubview:titleLabel];
    
    m_currentStartY += 30;
    UIView* person_id = [CommonControlOrView setTwoLabelViewNameText:@"陌游ID" text:self.userId nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
    
    UIImageView * activeIV = [[UIImageView alloc]initWithFrame:CGRectMake(200, m_currentStartY + 13, 29, 12)];
    
    [m_myScrollView addSubview:activeIV];
    currentHeigth = person_id.frame.size.height;
    person_id.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
    [m_myScrollView addSubview:person_id];
    
    m_currentStartY += currentHeigth;
    [self setOneLineWithY:m_currentStartY];
    
    UIView* person_dis = [CommonControlOrView setTwoLabelViewNameText:@"个人标签" text: @"获取中..."  nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
    currentHeigth = person_dis.frame.size.height;
    person_dis.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
    [m_myScrollView addSubview:person_dis];
    
    m_currentStartY += currentHeigth;
    [self setOneLineWithY:m_currentStartY];
    
    UIView* person_signature = [CommonControlOrView setTwoLabelViewNameText:@"个性签名" text: @"获取中..."  nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
    currentHeigth = person_signature.frame.size.height;
    person_signature.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
    [m_myScrollView addSubview:person_signature];
    
    m_currentStartY += currentHeigth;
    [self setOneLineWithY:m_currentStartY];
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, m_currentStartY, 100, 37)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
    nameLabel.font = [UIFont boldSystemFontOfSize:13.0];
    nameLabel.text = @"关系";
    [m_myScrollView addSubview:nameLabel];
    
    m_relationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, m_currentStartY, 100, 37)];
    m_relationLabel.backgroundColor = [UIColor clearColor];
    m_relationLabel.textColor = kColorWithRGB(51, 51, 51, 1.0);
    m_relationLabel.font = [UIFont boldSystemFontOfSize:14.0];
    m_relationLabel.text = @"陌生人";
    [m_myScrollView addSubview:m_relationLabel];

    m_currentStartY += 37;
    [self setOneLineWithY:m_currentStartY];
    
    ////
    UIView* topBggroup = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBggroup.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBggroup];
    
    UILabel* titleLabelgroup = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"他的群组" textAlignment:NSTextAlignmentLeft];
    [topBggroup addSubview:titleLabelgroup];
    
    m_currentStartY += 30;
    ////
    
    UIView* topBg3 = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg3.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg3];
    
    UILabel* titleLabel3 = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人角色" textAlignment:NSTextAlignmentLeft];
    [topBg3 addSubview:titleLabel3];
    
    m_currentStartY += 30;
    
    UIView* topBg6 = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg6.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg6];
    
    UILabel* titleLabel1 = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人头衔" textAlignment:NSTextAlignmentLeft];
    [topBg6 addSubview:titleLabel1];
    
    m_currentStartY +=topBg.frame.size.height;
    UIView *bview= [[UIView alloc]initWithFrame:CGRectMake(0, m_currentStartY, 320, 40)];
    [m_myScrollView addSubview:bview];
    
    NSString* rarenum = [NSString stringWithFormat:@"rarenum_small_%@", [GameCommon getNewStringWithId:self.achievementColor]];
    
    UIView* titleObjView = [CommonControlOrView setMyTitleObjWithImage:rarenum titleName:self.achievementStr rarenum:self.achievementColor showCurrent:NO];
    [bview addSubview: titleObjView ];
    m_currentStartY +=bview.frame.size.height;
    [self setOneLineWithY:m_currentStartY];
    
    
    UIView* topBg4 = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg4.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg4];
    
    UILabel* titleLabel4 = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 0, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"其他" textAlignment:NSTextAlignmentLeft];
    [topBg4 addSubview:titleLabel4];
    
    m_currentStartY += 30;
    
    UIImageView *timeImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, m_currentStartY + 5, 35, 35)];
    timeImg.image = KUIImage(@"time");
    [m_myScrollView addSubview:timeImg];
    
    UILabel* timeTitleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(55, m_currentStartY + 5, 100, 35) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont boldSystemFontOfSize:15.0] text:@"注册时间" textAlignment:NSTextAlignmentLeft];
    [m_myScrollView addSubview:timeTitleLabel];
    
    NSString* timeStr = [[GameCommon shareGameCommon] getDataWithTimeInterval:self.createTimeStr];
    
    UILabel* timeLabel4 = [CommonControlOrView setLabelWithFrame:CGRectMake(160, m_currentStartY + 5, 150, 35) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:15.0] text:timeStr textAlignment:NSTextAlignmentRight];
    [m_myScrollView addSubview:timeLabel4];
    
    m_currentStartY += 45;
    m_myScrollView.contentSize = CGSizeMake(320, m_currentStartY);
}


#pragma mark -创建界面
-(NSArray *)imageToURL:(NSArray *)imageArray;
{
    NSMutableArray * temp = [NSMutableArray array];
    for (id headID in imageArray) {
        if (![GameCommon isEmtity:headID]) {
            [temp addObject:[ImageService getImageUrlString:headID Width:160 Height:160]];
        }
    }
    return temp;
}

-(void)ltttt:(id)sender
{
    NSLog(@"1111");
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    KKChatController * kkchat = [[KKChatController alloc] init];
    kkchat.chatWithUser = self.hostInfo.userId;
    kkchat.type = @"normal";
    [self.navigationController pushViewController:kkchat animated:YES];
}
- (void)buildMainView
{
    m_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, startX - 44, 220, 44)];
    m_titleLabel.textColor = [UIColor whiteColor];
    m_titleLabel.backgroundColor = [UIColor clearColor];
   
    m_titleLabel.text = [DataStoreManager queryRemarkNameForUser:self.userId];//别名或昵称
    if ([m_titleLabel.text isEqualToString:@""]) {//不是好友或关注
         m_titleLabel.text = self.hostInfo.nickName;
    }
    m_titleLabel.textAlignment = NSTextAlignmentCenter;
    m_titleLabel.font = [UIFont boldSystemFontOfSize:20];
    [self.view addSubview:m_titleLabel];
    
    
    
    m_delegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    
    m_currentStartY = 0;
    
    m_myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX - (KISHighVersion_7?0:20)-44)];
    m_myScrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:m_myScrollView];

    [littleImgArray removeAllObjects];
    for (int i = 0; i <self.hostInfo.headImgArray.count; i++) {
        NSString *str = [self.hostInfo.headImgArray objectAtIndex:i];
        [littleImgArray addObject:str];
    }

    m_photoWall = [[HGPhotoWall alloc] initWithFrame:CGRectZero];
    m_photoWall.descriptionType = DescriptionTypeImage;
    [m_photoWall setPhotos:[self imageToURL:littleImgArray]];
    m_photoWall.delegate = self; 
    [m_myScrollView addSubview:m_photoWall];
    m_photoWall.backgroundColor = kColorWithRGB(105, 105, 105, 1.0);
    
    
    m_currentStartY += m_photoWall.frame.size.height;
    
    
    NSArray * gameidss=[GameCommon getGameids:self.hostInfo.gameids];
    
    UIView* genderView = [CommonControlOrView setGenderAndAgeViewWithFrame:CGRectMake(10, m_currentStartY, kScreenWidth, 30) gender:self.hostInfo.gender age:self.hostInfo.age star:self.hostInfo.starSign gameIds:gameidss];
    [m_myScrollView addSubview:genderView];
    
    UILabel* timeLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(150, m_currentStartY, 160, 30) textColor:kColorWithRGB(151, 151, 151, 1.0) font:[UIFont systemFontOfSize:12.0] text:[GameCommon getTimeAndDistWithTime:self.hostInfo.updateTime Dis:self.hostInfo.distrance] textAlignment:NSTextAlignmentRight];
    [m_myScrollView addSubview:timeLabel];
    
    m_currentStartY += 30;
    [self setOneLineWithY:m_currentStartY];
    
    //////个人动态
    [self setUserInfoView];
    [self setGroupList];
    [self setRoleView];
    [self setAchievementView];
    [self setOtherView];
    
    m_myScrollView.contentSize = CGSizeMake(kScreenWidth, m_currentStartY);
}

- (void)setUserInfoView
{
    float currentHeigth = 0;
    if ([self.hostInfo.state isKindOfClass:[NSDictionary class]] && [[self.hostInfo.state allKeys] count] != 0) {
        
        UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
        topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
        [m_myScrollView addSubview:topBg];
        
        UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 2.5, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人动态" textAlignment:NSTextAlignmentLeft];
        [topBg addSubview:titleLabel];
        
        m_currentStartY += 30;
        
        NSString* showTitle = @"";
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.hostInfo.state, @"type")] isEqualToString:@"3"]) {
            showTitle =  [[DataStoreManager queryRemarkNameForUser:self.userId]stringByAppendingString:@"发表了该内容"];
            NSLog(@"showtitle%@",showTitle);
            if ([showTitle  isEqualToString:@""]) {
                showTitle = [KISDictionaryHaveKey(self.hostInfo.state, @"nickname") stringByAppendingString:@"发表了该内容"];
                
            }
            NSLog(@"showTitle%@",showTitle);
        }
        else
            showTitle = [[DataStoreManager queryRemarkNameForUser:KISDictionaryHaveKey(self.hostInfo.state, @"userid")]stringByAppendingString:KISDictionaryHaveKey(self.hostInfo.state, @"showtitle")];
        if (showTitle ==nil) {
            showTitle = [KISDictionaryHaveKey(self.hostInfo.state, @"nickname") stringByAppendingString:KISDictionaryHaveKey(self.hostInfo.state, @"showtitle")];
            
        }
        NSString* tit = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.hostInfo.state, @"title")] isEqualToString:@""] ? KISDictionaryHaveKey(self.hostInfo.state, @"msg") : KISDictionaryHaveKey(self.hostInfo.state, @"title");
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.hostInfo.state, @"title")] isEqualToString:@""]) {
            tit = [NSString stringWithFormat:@"「%@」", tit];
        }
        UIView* person_state ;
        
        person_state =[CommonControlOrView setPersonStateViewTime:[GameCommon getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.hostInfo.state, @"createDate")]] nameText:showTitle achievement:tit achievementLevel:@"1" titleImage:KISDictionaryHaveKey(self.hostInfo.state, @"userimg")];
        currentHeigth = person_state.frame.size.height;
        person_state.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
        [m_myScrollView addSubview:person_state];
        
        UIButton* titleSelect = [[UIButton alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth)];
        titleSelect.backgroundColor = [UIColor clearColor];
        [titleSelect addTarget:self action:@selector(stateSelectClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_myScrollView addSubview:titleSelect];
        
        m_currentStartY += currentHeigth;
        [self setOneLineWithY:m_currentStartY];
    }
    /////////////////
    UIButton* zanBtn = [[UIButton alloc] initWithFrame:CGRectMake(10, m_currentStartY + 10, 75, 30)];
    [zanBtn setImage:KUIImage(@"detail_zan") forState:UIControlStateNormal];
    zanBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 45);
    [zanBtn addTarget:self action:@selector(ZanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_myScrollView addSubview:zanBtn];
    
    UILabel* zanLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(42, m_currentStartY + 10, 45, 30) textColor:kColorWithRGB(151, 151, 151, 1.0) font:[UIFont systemFontOfSize:12.0] text:self.hostInfo.zanNum textAlignment:NSTextAlignmentLeft];
    [m_myScrollView addSubview:zanLabel];
    
    UIButton* fansBtn = [[UIButton alloc] initWithFrame:CGRectMake(85, m_currentStartY + 10, 75, 30)];
    [fansBtn setImage:KUIImage(@"detail_fans") forState:UIControlStateNormal];
    fansBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 45);
    
    [fansBtn addTarget:self action:@selector(FansButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [m_myScrollView addSubview:fansBtn];
    
    UILabel* fansLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(117, m_currentStartY + 10, 45, 30) textColor:kColorWithRGB(151, 151, 151, 1.0) font:[UIFont systemFontOfSize:12.0] text:self.hostInfo.fanNum textAlignment:NSTextAlignmentLeft];
    [m_myScrollView addSubview:fansLabel];
    
    m_buttonBgView = [[UIView alloc] initWithFrame:CGRectMake(165, m_currentStartY, kScreenWidth-165, 50)];
    m_buttonBgView.backgroundColor = [UIColor clearColor];
    [m_myScrollView addSubview:m_buttonBgView];
    
    m_currentStartY += 50;
    
    ////////////////////////
    UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg];
    
    UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 2.5, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人资料" textAlignment:NSTextAlignmentLeft];
    [topBg addSubview:titleLabel];
    
    m_currentStartY += 30;
    
    if ([self.hostInfo.superstar isEqualToString:@"1"]) {//明星用户
        UIView* person_auth = [CommonControlOrView setTwoLabelViewNameText:@"       认证" text:self.hostInfo.superremark nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
        currentHeigth = person_auth.frame.size.height;
        person_auth.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
        [m_myScrollView addSubview:person_auth];
        
        UIImageView* vAuthImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, m_currentStartY+10, 20, 20)];
        vAuthImg.image = KUIImage(@"v_auth");
        [m_myScrollView addSubview:vAuthImg];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(280, m_currentStartY+10, 20, 20)];
        [button setBackgroundImage:KUIImage(@"me_set_info") forState:UIControlStateNormal];
        [button addTarget:self action:@selector(testEnterToHelpPage:) forControlEvents:UIControlEventTouchUpInside];
        [m_myScrollView addSubview:button];
        
        
        m_currentStartY += currentHeigth;
        [self setOneLineWithY:m_currentStartY];
    }
    
    UIView* person_id = [CommonControlOrView setTwoLabelViewNameText:@"陌游ID" text:self.hostInfo.userId nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
    UIImageView * activeIV = [[UIImageView alloc]initWithFrame:CGRectMake(200, m_currentStartY + 13, 29, 12)];
    [m_myScrollView addSubview:activeIV];
    if (self.hostInfo.active)
    {
        activeIV.image = [UIImage imageNamed:@"active"];
    }else
    {
        activeIV.image = [UIImage imageNamed:@"unactive"];
    }
    currentHeigth = person_id.frame.size.height;
    person_id.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
    [m_myScrollView addSubview:person_id];
    
    m_currentStartY += currentHeigth;
    [self setOneLineWithY:m_currentStartY];
    
    UIView* person_dis = [CommonControlOrView setTwoLabelViewNameText:@"个人标签" text:([self.hostInfo.hobby isEqualToString:@""] ? @"暂无标签" : self.hostInfo.hobby) nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
    currentHeigth = person_dis.frame.size.height;
    person_dis.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
    [m_myScrollView addSubview:person_dis];
    
    m_currentStartY += currentHeigth;
    [self setOneLineWithY:m_currentStartY];
    
    UIView* person_signature = [CommonControlOrView setTwoLabelViewNameText:@"个性签名" text:([self.hostInfo.signature isEqualToString:@""] ? @"暂无签名" : self.hostInfo.signature) nameTextColor:kColorWithRGB(102, 102, 102, 1.0) textColor:kColorWithRGB(51, 51, 51, 1.0)];
    currentHeigth = person_signature.frame.size.height;
    person_signature.frame = CGRectMake(0, m_currentStartY, kScreenWidth, currentHeigth);
    [m_myScrollView addSubview:person_signature];
    
    m_currentStartY += currentHeigth;
    [self setOneLineWithY:m_currentStartY];
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, m_currentStartY, 100, 37)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
    nameLabel.font = [UIFont boldSystemFontOfSize:13.0];
    nameLabel.text = @"关系";
    [m_myScrollView addSubview:nameLabel];
    
    m_relationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, m_currentStartY, 100, 37)];
    m_relationLabel.backgroundColor = [UIColor clearColor];
    m_relationLabel.textColor = kColorWithRGB(51, 51, 51, 1.0);
    m_relationLabel.font = [UIFont boldSystemFontOfSize:14.0];
    switch (self.viewType) {
        case VIEW_TYPE_FriendPage1:
            m_relationLabel.text = @"好友";
            break;
        case VIEW_TYPE_AttentionPage1:
            m_relationLabel.text = @"关注";
            break;
        case VIEW_TYPE_FansPage1:
            m_relationLabel.text = @"粉丝";
            break;
        case VIEW_TYPE_STRANGER1:
            m_relationLabel.text = @"陌生人";
            break;
        case VIEW_TYPE_Self1:
            m_relationLabel.text = @"自己";
            
            break;
        default:
            break;
    }
    [m_myScrollView addSubview:m_relationLabel];
    
    m_currentStartY += 37;
    [self setOneLineWithY:m_currentStartY];
}

- (void)ZanButtonClick:(id)sender
{
    [self showAlertViewWithTitle:@"" message:[NSString stringWithFormat:@"获得赞的数量：%@", self.hostInfo.zanNum] buttonTitle:@"确定"];
}

- (void)FansButtonClick:(id)sender
{
    [self showAlertViewWithTitle:[NSString stringWithFormat:@"拥有粉丝数量：%@", self.hostInfo.fanNum] message:@"拥有粉丝数量包含好友数量" buttonTitle:@"确定"];
}

- (void)stateSelectClick:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    MyCircleViewController *VC = [[MyCircleViewController alloc]init];
    VC.userId = self.hostInfo.userId;
    VC.nickNmaeStr = self.hostInfo.nickName?self.hostInfo.nickName:@"";
    [self.navigationController pushViewController:VC animated:YES];
}

- (void)setGroupList
{
    if (![self.hostInfo.groupList isKindOfClass:[NSArray class]]) {
        return;
    }
    if (self.hostInfo.groupList.count==0) {
        return;
    }
    UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg];//259
    
    UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 2.5, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:[NSString stringWithFormat:@"%@",@"他的群组"] textAlignment:NSTextAlignmentLeft];
    [topBg addSubview:titleLabel];
    
    UIButton* setButton = [CommonControlOrView setButtonWithFrame:CGRectMake(250, 0, 70, 30) title:@"" fontSize:Nil textColor:nil bgImage:KUIImage(@"home_normal") HighImage:KUIImage(@"home_click") selectImage:Nil];
    setButton.backgroundColor = [UIColor clearColor];
    [setButton addTarget:self action:@selector(groupListClick:) forControlEvents:UIControlEventTouchUpInside];
    [topBg addSubview:setButton];
    
    
    UILabel* groupNumLable = [CommonControlOrView setLabelWithFrame:CGRectMake(25, 5, 30, 20) textColor:[UIColor grayColor] font:[UIFont boldSystemFontOfSize:14.0] text:[NSString stringWithFormat:@"%@%@",@"x",self.hostInfo.groupNum] textAlignment:NSTextAlignmentLeft];
    [setButton addSubview:groupNumLable];
    
    m_currentStartY += 30;
    for (int i = 0; i < self.hostInfo.groupList.count; i++) {
        UIButton * groupView = [[UIButton alloc] initWithFrame:CGRectMake(0, m_currentStartY, 320, 50)];
        [groupView addTarget:self action:@selector(groupInfoClick:) forControlEvents:UIControlEventTouchUpInside];
        groupView.tag = i;
        EGOImageView * headImage = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 5, 40, 40)];
        
        if ([GameCommon isEmtity:KISDictionaryHaveKey([self.hostInfo.groupList objectAtIndex:i], @"backgroundImg")]) {
            headImage.image = KUIImage(@"group_icon");
        }else{
            headImage.imageURL = [ImageService getImageStr:KISDictionaryHaveKey([self.hostInfo.groupList objectAtIndex:i], @"backgroundImg") Width:80];
        }
        headImage.layer.cornerRadius = 5.0;
        headImage.layer.masksToBounds = YES;
        [groupView addSubview:headImage];
        UILabel * groupName = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 270, 20)];
        groupName.textColor = [UIColor blackColor];
        groupName.backgroundColor = [UIColor clearColor];
        groupName.font=[UIFont boldSystemFontOfSize:14.0];
        groupName.text = KISDictionaryHaveKey([self.hostInfo.groupList objectAtIndex:i], @"groupName");
        [groupView addSubview:groupName];
        
        
        UILabel * shipTypeName = [[UILabel alloc] initWithFrame:CGRectMake(320-50-10, 15, 50, 20)];
        shipTypeName.textColor = [UIColor grayColor];
        shipTypeName.backgroundColor = [UIColor clearColor];
        shipTypeName.textAlignment = NSTextAlignmentRight;
        shipTypeName.font=[UIFont boldSystemFontOfSize:12.0];
        shipTypeName.text = [self getShipTypeName:KISDictionaryHaveKey([self.hostInfo.groupList objectAtIndex:i], @"groupUsershipType")];
        [groupView addSubview:shipTypeName];
        [m_myScrollView addSubview:groupView];
        
        m_currentStartY += 50;
        [self setOneLineWithY:m_currentStartY];
    }
}
//
-(NSString*)getShipTypeName:(NSString*)groupUsershipType
{
    if ([GameCommon isEmtity:[GameCommon getNewStringWithId:groupUsershipType]]) {
        return @"";
    }
    if ([groupUsershipType intValue]==0) {
        return @"群主";
    }else if ([groupUsershipType intValue]==1){
        return @"管理员";
    }
    return @"";
}

-(void)groupListClick:(UIButton*)sender
{
    GroupListViewController *gr = [[GroupListViewController alloc]init];
    gr.userId = self.userId;
    [self.navigationController pushViewController:gr animated:YES];
}

-(void)groupInfoClick:(UIButton*)sender
{
    NSInteger index = sender.tag;
    GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
    gr.groupId =KISDictionaryHaveKey([self.hostInfo.groupList objectAtIndex:index], @"groupId");
    gr.isAudit = NO;
    [self.navigationController pushViewController:gr animated:YES];

}

- (void)setRoleView
{
    UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg];
    
    UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 2.5, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人角色" textAlignment:NSTextAlignmentLeft];
    [topBg addSubview:titleLabel];
    
    m_currentStartY += 30;
    NSArray * charactersArr = self.hostInfo.charactersArr;
    if (![charactersArr isKindOfClass:[NSArray class]]) {
        return;
    }
    for (int i = 0; i < [charactersArr count]; i++) {
        NSDictionary* characterDic = [charactersArr objectAtIndex:i];
        NSString* realm =  KISDictionaryHaveKey(characterDic, @"simpleRealm");//服务器realm
        NSString* gameId=[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(characterDic, @"gameid")];//游戏Id
        NSString* v1=KISDictionaryHaveKey(characterDic, @"value1");//部落
        NSString* v2=KISDictionaryHaveKey(characterDic, @"value2");//战斗力
        NSString* v3=KISDictionaryHaveKey(characterDic, @"value3");//战斗力数
        NSString* auth=KISDictionaryHaveKey(characterDic, @"auth");
        NSString* name=KISDictionaryHaveKey(characterDic, @"name");
        NSString* failedmsg=KISDictionaryHaveKey(characterDic, @"failedmsg");
        NSString* img=KISDictionaryHaveKey(characterDic, @"img");//角色图标
        
        if ([failedmsg intValue ]==404)//角色不存在
        {
            UIView* myCharacter = [CommonControlOrView setCharactersViewWithName:name gameId:gameId realm:[[realm stringByAppendingString:@" "] stringByAppendingString:v1] pveScore:[NSString stringWithFormat:@"%@",v3] img:@"" auth:@"00" Pro:v2];
            myCharacter.frame = CGRectMake(0, m_currentStartY, kScreenWidth, 60);
            [m_myScrollView addSubview:myCharacter];
        }
        else
        {
            UIView* myCharacter = [CommonControlOrView setCharactersViewWithName:name gameId:gameId realm:[[realm stringByAppendingString:@" "] stringByAppendingString:v1] pveScore:[NSString stringWithFormat:@"%@",v3] img:img auth:[GameCommon getNewStringWithId:auth] Pro:v2];
            
            myCharacter.frame = CGRectMake(0, m_currentStartY, kScreenWidth, 60);
            [m_myScrollView addSubview:myCharacter];
            
            UIButton* titleSelect = [[UIButton alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 60)];
            titleSelect.backgroundColor = [UIColor clearColor];
            [titleSelect addTarget:self action:@selector(tapMyCharacter:) forControlEvents:UIControlEventTouchUpInside];
            titleSelect.tag = i+1000;
            [m_myScrollView addSubview:titleSelect];
            
        }
        m_currentStartY += 60;
        [self setOneLineWithY:m_currentStartY];
    }
}

//点击角色
-(void)tapMyCharacter:(UIButton *)sender
{
    NSArray* characterArray = self.hostInfo.charactersArr;
    NSDictionary *dic = [characterArray objectAtIndex:sender.tag-1000];
    NSString *gameId = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"gameid")];
    
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"404"]
        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"notSupport"]) {
        [self showMessageWithContent:@"无法获取角色详情数据,由于角色不存在或暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
    VC.characterId = KISDictionaryHaveKey(dic, @"id");
    VC.gameId = gameId;
    VC.characterName = KISDictionaryHaveKey(dic, @"name");
    [self.navigationController pushViewController:VC animated:YES];
}
- (void)setAchievementView
{
    if ([self.hostInfo.achievementArray isKindOfClass:[NSArray class]] && [self.hostInfo.achievementArray count] != 0) {
        UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
        topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
        [m_myScrollView addSubview:topBg];
        
        UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 2.5, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"个人头衔" textAlignment:NSTextAlignmentLeft];
        [topBg addSubview:titleLabel];
        
        m_currentStartY += 30;
        
        for (int i = 0; i < [self.hostInfo.achievementArray count]; i++) {
            NSDictionary* smallTitleDic = KISDictionaryHaveKey([self.hostInfo.achievementArray objectAtIndex:i], @"titleObj");
            NSString* rarenum;
            if ([smallTitleDic isKindOfClass:[NSDictionary class]]) {
                rarenum = [NSString stringWithFormat:@"rarenum_small_%@", [GameCommon getNewStringWithId:KISDictionaryHaveKey(smallTitleDic , @"rarenum")]];

            }
            UIView* titleObjView = [CommonControlOrView setMyTitleObjWithImage:rarenum titleName:KISDictionaryHaveKey(smallTitleDic, @"title") rarenum:KISDictionaryHaveKey(smallTitleDic, @"rarenum") showCurrent:i == 0 ? NO : YES];
            titleObjView.frame = CGRectMake(0, m_currentStartY, kScreenWidth, 40);
            [m_myScrollView addSubview:titleObjView];
            
            UIButton* titleSelect = [[UIButton alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 40)];
            titleSelect.backgroundColor = [UIColor clearColor];
            [titleSelect addTarget:self action:@selector(titleObjSelectClick:) forControlEvents:UIControlEventTouchUpInside];
            titleSelect.tag = i;
            [m_myScrollView addSubview:titleSelect];
            m_currentStartY += 40;
            [self setOneLineWithY:m_currentStartY];
        }
    }
}



//点击头衔
- (void)titleObjSelectClick:(UIButton*)selectBut
{
    TitleObjDetailViewController* detailVC = [[TitleObjDetailViewController alloc] init];
    detailVC.titleObjArray = [NSArray arrayWithObject:[self.hostInfo.achievementArray objectAtIndex:selectBut.tag]];
    detailVC.showIndex = 0;
    detailVC.isFriendTitle = YES;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (void)setOtherView
{
    UIView* topBg = [[UIView alloc] initWithFrame:CGRectMake(0, m_currentStartY, kScreenWidth, 30)];
    topBg.backgroundColor = UIColorFromRGBA(0xe8e8e8, 1);
    [m_myScrollView addSubview:topBg];
    
    UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, 2.5, 100, 25) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:12.0] text:@"其他" textAlignment:NSTextAlignmentLeft];
    [topBg addSubview:titleLabel];
    
    m_currentStartY += 30;
    
    UIImageView *timeImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, m_currentStartY + 5, 35, 35)];
    timeImg.image = KUIImage(@"time");
    [m_myScrollView addSubview:timeImg];
    
    UILabel* timeTitleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(55, m_currentStartY + 5, 100, 35) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont boldSystemFontOfSize:15.0] text:@"注册时间" textAlignment:NSTextAlignmentLeft];
    [m_myScrollView addSubview:timeTitleLabel];
    
    NSString* timeStr = [[GameCommon shareGameCommon] getDataWithTimeInterval:self.hostInfo.createTime];
    
    UILabel* timeLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(160, m_currentStartY + 5, 150, 35) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:15.0] text:timeStr textAlignment:NSTextAlignmentRight];
    [m_myScrollView addSubview:timeLabel];
    
    m_currentStartY += 45;
    
    //    [self setOneLineWithY:m_currentStartY];
    
    UIButton* reportButton = [CommonControlOrView setButtonWithFrame:CGRectMake(213, self.view.bounds.size.height-44, 107, 44) title:nil fontSize:[UIFont boldSystemFontOfSize:15.0] textColor:kColorWithRGB(51, 51, 51, 1.0) bgImage:KUIImage(@"report_normal") HighImage:KUIImage(@"report_click") selectImage:nil];
    reportButton.backgroundColor = kColorWithRGB(225, 225, 225, 1.0);
    [reportButton addTarget:self action:@selector(reportButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reportButton];
    
    if (self.viewType ==VIEW_TYPE_Self1) {
        reportButton.hidden =YES;
        m_myScrollView.frame =CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX - (KISHighVersion_7?0:20));
    }else{
        reportButton.hidden =NO;
        m_myScrollView.frame =CGRectMake(0, startX, kScreenWidth, kScreenHeigth - startX - (KISHighVersion_7?0:20)-44);
    }
    m_currentStartY += 45;
}

- (void)setOneLineWithY:(float)frameY
{
    UIImageView* lineImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, frameY, kScreenWidth, 2)];
    lineImg.image = KUIImage(@"line");
    lineImg.backgroundColor = [UIColor clearColor];
    [m_myScrollView addSubview:lineImg];
}

#pragma mark -举报
- (void)reportButtonClick:(id)sender
{
    
    UIActionSheet *acs =[[ UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"举报" otherButtonTitles:@"拉黑", nil];
    [acs showInView:self.view];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0) {
        UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定举报该用户吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alter.tag = 23;
        [alter show];
    }else if (buttonIndex ==1){
        
        
        NSArray *array = [DataStoreManager queryAllBlackListUserid];
        if ([array containsObject:self.hostInfo.userId]) {
            [self showAlertViewWithTitle:@"提示" message:@"该用户已在您黑名单中" buttonTitle:@"确定"];
        }else{
        
        NSLog(@"拉黑么");
        UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"您确定要拉黑该用户吗？" message:@"拉黑之后该用户将无法与您进行聊天,并且无法对您发表的动态进行评论" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alter.tag = 28;
        [alter show];
        }
    }
}


#pragma mark -按钮布局
- (void)setBottomView
{
    switch (self.viewType) {
        case VIEW_TYPE_FriendPage1://好友
        {
            UIButton *editButton=[UIButton buttonWithType:UIButtonTypeCustom];
            editButton.frame=CGRectMake(255, KISHighVersion_7 ? 20 : 0 , 65, 43);
            [editButton setBackgroundImage:KUIImage(@"beizhu") forState:UIControlStateNormal];
            [editButton setBackgroundImage:KUIImage(@"beizhu_click") forState:UIControlStateHighlighted];
            editButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            [editButton  setExclusiveTouch :YES];
            [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:editButton];

            delFriendBtn = [self setCenterBtn:@"del_friend_normal" ClickImage:@"del_friend_click"];
            [delFriendBtn addTarget:self action:@selector(deleteFriend:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:delFriendBtn];
        }break;
        case VIEW_TYPE_AttentionPage1://关注
        {
            UIButton *editButton=[UIButton buttonWithType:UIButtonTypeCustom];
            editButton.frame=CGRectMake(255, KISHighVersion_7 ? 20 : 0 , 65, 43);
            [editButton setBackgroundImage:KUIImage(@"beizhu") forState:UIControlStateNormal];
            [editButton setBackgroundImage:KUIImage(@"beizhu_click") forState:UIControlStateHighlighted];
            [self.view addSubview:editButton];
            [editButton  setExclusiveTouch :YES];
            [editButton addTarget:self action:@selector(editButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            
            attentionOffBtn = [self setCenterBtn:@"Focus_off_normal" ClickImage:@"Focus_off_click"];
            [attentionOffBtn addTarget:self action:@selector(cancelAttentionClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:attentionOffBtn];
        }  break;
        case VIEW_TYPE_FansPage1://粉丝
        {
            addFriendBtn = [self setCenterBtn:@"add_friend_normal" ClickImage:@"add_friend_click"];
            [addFriendBtn addTarget:self action:@selector(addFriendClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:addFriendBtn];
        }break;
        case VIEW_TYPE_STRANGER1://陌生人
        {
            attentionBtn=[self setCenterBtn:@"Focus_on_normal" ClickImage:@"Focus_on_3_click"];
            [attentionBtn addTarget:self action:@selector(attentionClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:attentionBtn];
        }break;
        default:
        {
            
        }break;
    }
    
    if (self.viewType!=VIEW_TYPE_Self1) {
        UIButton* button_right = [CommonControlOrView
                                  setButtonWithFrame:CGRectMake(0, self.view.bounds.size.height -44, 106, 44)//120
                                  title:@""
                                  fontSize:[UIFont boldSystemFontOfSize:15.0] textColor:[UIColor whiteColor]
                                  bgImage:KUIImage(@"chat_normal")
                                  HighImage:KUIImage(@"chat_click")
                                  selectImage:Nil];
        [button_right  setExclusiveTouch :YES];
        [button_right addTarget:self action:@selector(startChat:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button_right];
    }
}

-(UIButton*)setCenterBtn:(NSString*)normalImage ClickImage:(NSString*)clickImage
{
    UIButton *centenBtn = [CommonControlOrView
                    setButtonWithFrame:CGRectMake(106, self.view.bounds.size.height-44, 107, 44)//120
                    title:nil
                    fontSize:[UIFont boldSystemFontOfSize:15.0] textColor:[UIColor whiteColor]
                    bgImage:KUIImage(normalImage)
                    HighImage:KUIImage(clickImage)
                    selectImage:Nil];
    return centenBtn;

}
//添加第一次打招呼
-(void)getSayHello
{
    
    [self DetectNetwork];
    NSMutableDictionary * postDict1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.hostInfo.userId forKey:@"touserid"];
    [postDict1 addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict1 setObject:@"153" forKey:@"method"];
    [postDict1 setObject:paramDict forKey:@"params"];
    
    [postDict1 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict1 success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [wxSDArray addObject:self.hostInfo.userId];
        [DataStoreManager storeThumbMsgUser:self.hostInfo.userId type:@"1"];
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"sayHello_wx_info_id"];
        [[NSUserDefaults standardUserDefaults]setObject:wxSDArray forKey:@"sayHello_wx_info_id"];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
    
}



- (void)deleteFriend:(id)sender
{
    UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要删除该好友吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alter.tag = 234;
    [alter show];
}
//刷新粉丝数
-(void)refreFansNum:(NSString*)type
{
    NSString *fansNumFileName=[FansCount stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    NSString *fansStr=[[NSUserDefaults standardUserDefaults] objectForKey:fansNumFileName];
    NSInteger fansInteger = 0;
   
    if ([type isEqualToString:@"0"]) {//删除好友
        
        if(!fansStr||[fansStr isEqualToString:@""]){
            fansInteger=0;
        }else{
            fansInteger= [fansStr intValue];
            fansInteger++;
        }
    }else{//添加好友
        if(!fansStr||[fansStr isEqualToString:@""]){
            fansInteger=0;
        }else{
            fansInteger= [fansStr intValue];
            if (fansInteger>0) {
                fansInteger--;
            }
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat: @"%d",fansInteger] forKey:fansNumFileName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//删除好友或者取消关注Action
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self DetectNetwork];

    if (alertView.tag == 234) {//删除好友
        if (buttonIndex != alertView.cancelButtonIndex) {
            [self cancelFriend:@"2"];
        }
    }
    else if(alertView.tag == 345)//取消关注
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            [self cancelFriend:@"1"];
        }
    }
    else if (alertView.tag == 23) { //举报
        if (buttonIndex != alertView.cancelButtonIndex) {
            [hud show:YES];
            NSString* str = [NSString stringWithFormat:@"本人举报用户id为%@的用户信息含不良内容，请尽快处理！", self.hostInfo.userId];
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:str ,@"msg",@"Platform=iphone", @"detail",self.hostInfo.userId,@"id",@"user",@"type",nil];
            NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
            [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
            [postDict setObject:@"155" forKey:@"method"];
            [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
            [postDict setObject:dic forKey:@"params"];
            
            [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
                [hud hide:YES];
                [self showAlertViewWithTitle:@"提示" message:@"感谢您的举报，我们会尽快处理！" buttonTitle:@"确定"];
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
    else if (alertView.tag == 28)//拉黑
    {
        if (buttonIndex ==1) {
            
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:self.hostInfo.userId,@"userid",self.hostInfo.nickName,@"nickname",self.hostInfo.headImgStr,@"img",[GameCommon getCurrentTime],@"createDate", nil];
            [DataStoreManager SaveBlackListWithDic:dic WithType:@"1"];
            
            NSMutableDictionary *tempDict = [NSMutableDictionary dictionary];
            NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
            
            [tempDict setObject:self.hostInfo.userId forKey:@"userid"];
            
            [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
            [postDict setObject:@"226" forKey:@"method"];
            [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
            [postDict setObject:tempDict forKey:@"params"];
            
            [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
//                dispatch_queue_t queue = dispatch_queue_create("com.living.game.", NULL);
//                dispatch_async(queue, ^{
//                    [DataStoreManager changeBlackListTypeWithUserid:self.hostInfo.userId];
                    [self updateDb:@"unknow"];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [self refreFansNum:@"0"];
                [self showMessageWindowWithContent:@"拉黑成功" imageType:0];
                [self.navigationController popViewControllerAnimated:YES];
//                    });
//                });
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

-(void)begin
{
    addFriendBtn.userInteractionEnabled = NO;
    delFriendBtn.userInteractionEnabled = NO;
    attentionBtn.userInteractionEnabled = NO;
    attentionOffBtn.userInteractionEnabled = NO;
}
-(void)end
{
    addFriendBtn.userInteractionEnabled = YES;
    delFriendBtn.userInteractionEnabled = YES;
    attentionBtn.userInteractionEnabled = YES;
    attentionOffBtn.userInteractionEnabled = YES;
}

//取消关注或者删除好友1，取消关注 2,删除好友
-(void)cancelFriend:(NSString*)type
{
    [self begin];
    [hud show:YES];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.hostInfo.userId forKey:@"frienduserid"];
    [paramDict setObject:type forKey:@"type"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"110" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self end];
        [hud hide:YES];
        NSString * shipT=KISDictionaryHaveKey(responseObject, @"shiptype");
        [DataStoreManager changshiptypeWithUserId:self.hostInfo.userId type:shipT Successcompletion:^(BOOL success, NSError *error) {
            DSuser *dUser = [DataStoreManager getInfoWithUserId:self.hostInfo.userId];
            [DataStoreManager cleanIndexWithNameIndex:dUser.nameIndex withType:@"2"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
            if ([type isEqualToString:@"1"]) {
                if (self.myDelegate&&[self.myDelegate respondsToSelector:@selector(isAttention:attentionSuccess:backValue:)]) {
                    [self.myDelegate isAttention:self attentionSuccess:self.testRow backValue:@"off"];
                }
            }
            if ([type isEqualToString:@"2"]) {
                [self refreFansNum:@"0"];
                [self showMessageWindowWithContent:@"删除成功" imageType:0];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self end];
        [hud hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}

-(void)updateDb:(NSString*)shiptype
{
    [DataStoreManager changshiptypeWithUserId:self.hostInfo.userId type:shiptype Successcompletion:^(BOOL success, NSError *error) {
        if (success) {
            DSuser *dUser = [DataStoreManager getInfoWithUserId:self.hostInfo.userId];
            [DataStoreManager cleanIndexWithNameIndex:dUser.nameIndex withType:@"2"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
        }else{
            
        }
    }];
}
- (void)todoSomething:(id)sender
{
    self.isOnClick = NO;
    if (self.isChatPage) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else//直接进入聊天页面
    {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        KKChatController * kkchat = [[KKChatController alloc] init];
        kkchat.chatWithUser = self.hostInfo.userId;
        kkchat.type = @"normal";
        [self.navigationController pushViewController:kkchat animated:YES];
    }
}
- (void)startChat:(id)sender
{
    self.isOnClick = YES;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(todoSomething:) object:sender];
    [self performSelector:@selector(todoSomething:) withObject:sender afterDelay:0.2f];
    

}
//添加好友
- (void)addFriendClick:(id)sender
{
    [self addFriend:@"2"];
}
//添加关注
- (void)attentionClick:(id)sender
{
    [self addFriend:@"1"];
}

//添加关注或者加好友1，添加好友 2.添加关注
-(void)addFriend:(NSString*)type
{
    [self DetectNetwork];
    MBProgressHUD *hudadd = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:hudadd];
    [self.view bringSubviewToFront:hudadd];
    [hudadd show:YES];
    [self begin];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.hostInfo.userId forKey:@"frienduserid"];
    [paramDict setObject:type forKey:@"type"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"109" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self end];
        NSString * shipType=KISDictionaryHaveKey(responseObject, @"shiptype");
        [DataStoreManager changshiptypeWithUserId:self.hostInfo.userId type:shipType Successcompletion:^(BOOL success, NSError *error) {
            [DataStoreManager deleteMemberFromListWithUserid:self.hostInfo.userId];
            if ([type isEqualToString:@"2"]) {
                [self refreFansNum:@"1"];
            }
            [wxSDArray removeAllObjects];
            [wxSDArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
            if (![wxSDArray containsObject:self.hostInfo.userId]) {
                [self getSayHello];
            }
            if ([type isEqualToString:@"1"]) {
                if (self.myDelegate&&[self.myDelegate respondsToSelector:@selector(isAttention:attentionSuccess:backValue:)]) {
                    [self.myDelegate isAttention:self attentionSuccess:self.testRow backValue:@"on"];
                }
                NSArray *array = [DataStoreManager queryAllBlackListUserid];
                
                if ([array containsObject:self.hostInfo.userId]) {
                    [DataStoreManager deletePersonFromBlackListWithUserid:self.hostInfo.userId];
                }
                [self showMessageWindowWithContent:@"关注成功" imageType:0];
            }
            [hudadd hide:YES];
            if ([type isEqualToString:@"2"]) {
                if (self.isFansPage) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadFansKey object:[NSString stringWithFormat: @"%d",self.fansTestRow]];
                }else{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
                }
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self end];
        [hudadd hide:YES];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}

- (void)cancelAttentionClick:(id)sender
{
    UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确实取消对该用户的关注吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alter.tag = 345;
    [alter show];
}

#pragma mark 修改备注名字
- (void)editButtonClick:(id)sender
{
    if (self.isOnClick) {
        return;
    }
    SetRemarkNameViewController* VC = [[SetRemarkNameViewController alloc] init];
    VC.userName = self.hostInfo.userName;
    VC.nickName = self.hostInfo.nickName;
    VC.userId = self.hostInfo.userId;
    VC.isFriend = self.viewType == VIEW_TYPE_FriendPage1 ? YES : NO;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 头像
-(void)photoWallDelPhotoAtIndex:(NSInteger)index
{
    
}

- (void)photoWallPhotoTaped:(NSUInteger)index WithPhotoWall:(UIView *)photoWall
{
    //放大
     PhotoViewController * pV = [[PhotoViewController alloc] initWithSmallImages:nil images:self.hostInfo.headImgArray indext:index];
    [self presentViewController:pV animated:NO completion:^{
        
    }];
}

-(void)testEnterToHelpPage:(id)sender
{
    HelpViewController *helpVC = [[HelpViewController alloc]init];
    helpVC.myUrl = @"content.html?2";
    [self.navigationController pushViewController:helpVC animated:YES];

}


- (void)photoWallMovePhotoFromIndex:(NSInteger)index toIndex:(NSInteger)newIndex
{
    NSLog(@"1");
}

- (void)photoWallAddAction
{
    NSLog(@"2");
}

- (void)photoWallAddFinish
{
    NSLog(@"3");
}

- (void)photoWallDeleteFinish
{
    NSLog(@"4");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
