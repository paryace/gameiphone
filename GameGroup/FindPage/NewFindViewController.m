//
//  NewFindViewController.m
//  GameGroup
//
//  Created by admin on 14-3-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewFindViewController.h"
#import "NewNearByViewController.h"
#import "NearByViewController.h"
#import "NormalTableCell.h"
#import "SameRealmViewController.h"
#import "CanRankTitleObjViewController.h"
#import "NewsViewController.h"
#import "EncoXHViewController.h"
#import "MagicGirlViewController.h"
#import "AddressListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ActivateViewController.h"
#import "EGOImageButton.h"

#import "HostInfo.h"
#import "FindSubView.h"
#import "FinderView.h"

#import "MessageAddressViewController.h"
#import "EveryDataNewsViewController.h"
#import "CircleHeadViewController.h"
@interface NewFindViewController ()
{
    EGOImageButton    *m_dynamicBtn;//动态
    UIButton    *m_nearByBtn;//附近
    UIButton    *m_samerealmBtn;//同F
    UIButton    *m_phoneBtn;//通讯录
    UIButton    *m_girlBtn;//魔女榜
    UIButton    *m_meetBtn;//邂逅
    UIButton    *m_activateBtn;
    HostInfo    *hostInfo;
    UIImageView *m_notibgInfoImageView; //与我相关红点
    UIImageView *m_notibgCircleNewsImageView; //朋友圈红点
    UILabel *lb;
    DSuser   * m_userInfo;
   // NSMutableDictionary *friendImgDic;
    NSInteger    friendDunamicmsgCount;
    NSInteger    myDunamicmsgCount;
    BOOL myActive;
}
@property(nonatomic,retain)NSString * friendImgStr;
@end

@implementation NewFindViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(ss:) name:@"frienddunamicmsgChange_WX"
                                                  object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self
                                                selector:@selector(receivedMyDynamicMsg:)
                                                    name:@"mydynamicmsg_wx"
                                                  object:nil];

    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    
    if (![[TempData sharedInstance] isHaveLogin]) {
        [[Custom_tabbar showTabBar] when_tabbar_is_selected:0];
        return;
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    DSuser *user = [DSuser MR_findFirstWithPredicate:predicate];

    if ([user.action boolValue]) {
        NSLog(@"已激活");
        m_activateBtn.hidden = YES;
    }else
    {
        NSLog(@"未激活");
        m_activateBtn.hidden = NO;
    }
    
    
    
    
}

#pragma mark -
#pragma mark 红点监听
//监听与我相关的消息来临
-(void)receivedMyDynamicMsg:(NSNotification*)sender
{
    myDunamicmsgCount ++;
    //添加Tab上的小红点
    [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:0 OrDot:YES WithButtonIndex:2];
    
    //显示头像
    NSString * fruits = KISDictionaryHaveKey(sender.userInfo, @"img");
    if ([fruits isEqualToString:@""]) {
        m_dynamicBtn.imageURL =nil;
    }else{
        NSArray  * array= [fruits componentsSeparatedByString:@","];
        self.friendImgStr =[array objectAtIndex:0];
        
        [[NSUserDefaults standardUserDefaults]setValue:self.friendImgStr forKey:@"preload_img_wx_dongtai"];
        if (_friendImgStr) {
            m_dynamicBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/80",_friendImgStr]];
        }else{
            m_dynamicBtn.imageURL = nil;
        }
    }
    
    //显示数字
    if (myDunamicmsgCount && myDunamicmsgCount !=0)
    {
        m_notibgInfoImageView.hidden = NO;  //数字
        if (myDunamicmsgCount > 99) {
            lb.text = @"99+";
        }
        else
            lb.text =[NSString stringWithFormat:@"%d",myDunamicmsgCount] ;
    }
    
    
}
//监听消息来临
-(void)ss:(NSNotification*)sender
{
    NSLog(@"监听");
    //控制红点
    friendDunamicmsgCount ++;
    
    [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:0 OrDot:YES WithButtonIndex:2];
    //显示头像
    NSString * fruits = KISDictionaryHaveKey(sender.userInfo, @"img");
    if ([fruits isEqualToString:@""]) {
        m_dynamicBtn.imageURL =nil;
    }else{
    NSArray  * array= [fruits componentsSeparatedByString:@","];
    self.friendImgStr =[array objectAtIndex:0];
    
    [[NSUserDefaults standardUserDefaults]setValue:self.friendImgStr forKey:@"preload_img_wx_dongtai"];
    if (_friendImgStr) {
         m_dynamicBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/80",_friendImgStr]];
    }else{
        m_dynamicBtn.imageURL = nil;
    }
    }
    
    if (friendDunamicmsgCount && friendDunamicmsgCount !=0)
    {
        NSLog(@"-------->>>%d",friendDunamicmsgCount);
        if(m_notibgInfoImageView.hidden)
        {
            m_notibgCircleNewsImageView.hidden = NO;
        }
        else{
            m_notibgCircleNewsImageView.hidden = YES;
        }
//        m_notibgInfoImageView.hidden = NO;
//        if (friendDunamicmsgCount > 99) {
//            lb.text = @"99";
//        }
//        else
//            lb.text =[NSString stringWithFormat:@"%d",friendDunamicmsgCount] ;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setTopViewWithTitle:@"发现" withBackButton:NO];
    self.view.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
    self.view.backgroundColor = [UIColor whiteColor];

    
    UIImageView *imageView =[[ UIImageView alloc]initWithFrame:CGRectMake(0, 0, 162, 191)];
    imageView.center =self.view.center;
    imageView.image = KUIImage(@"finder_line");
    [self.view addSubview:imageView];
    

    
    m_activateBtn = [FinderView setButtonWithFrame:CGRectMake(0, 0, 50, 38) center:CGPointMake(295, startX+19) backgroundNormalImage:@"new_activate_pressed" backgroundHighlightImage:@"new_activate_normal" setTitle:nil nextImage:nil nextImage:nil];
    m_activateBtn.backgroundColor = [UIColor clearColor];
    [m_activateBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_activateBtn];

#pragma mark ----- 具体未做判定  账号是否激活
    
    m_meetBtn = [FinderView setButtonWithFrame:CGRectMake(0, 0, 102, 102) center:self.view.center backgroundNormalImage:@"trevi_fountain_pressed" backgroundHighlightImage:@"trevi_fountain_normal" setTitle:nil nextImage:nil nextImage:nil];
    //109 189
    
   // NSLog(@"self.view.center%@",self.view.center);
    m_meetBtn.layer.masksToBounds = YES;
    m_meetBtn.layer.cornerRadius = 51;

    [m_meetBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_meetBtn];
    
    
    
    
    m_dynamicBtn = [[EGOImageButton alloc]initWithFrame:CGRectMake(0, 0, 59, 59)];
    m_dynamicBtn.center =CGPointMake(m_meetBtn.center.x-49, m_meetBtn.center.y-125);
    m_dynamicBtn.placeholderImage = KUIImage(@"people_man");
    
    if (_friendImgStr ==nil) {
        m_dynamicBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/120/120",[[NSUserDefaults standardUserDefaults]objectForKey:@"preload_img_wx_dongtai"]]];
    }else{
        m_dynamicBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/80",_friendImgStr]];
    }
//    m_dynamicBtn.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@",_friendImgStr]];
    
    m_dynamicBtn.layer.masksToBounds = YES;
    m_dynamicBtn.layer.cornerRadius = 59/2;
    m_dynamicBtn.layer.borderWidth = 2.0;
    m_dynamicBtn.layer.borderColor = [[UIColor whiteColor] CGColor];

    [m_dynamicBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:m_dynamicBtn];
   
    //红点 - 朋友圈
    m_notibgCircleNewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(123, 70+startX, 15, 15)];
    m_notibgCircleNewsImageView.center =CGPointMake(m_meetBtn.center.x-25, m_meetBtn.center.y-140);
    [self.view bringSubviewToFront:m_notibgCircleNewsImageView];
    [m_notibgCircleNewsImageView setImage:[UIImage imageNamed:@"redpot.png"]];
    [self.view addSubview:m_notibgCircleNewsImageView];
    m_notibgCircleNewsImageView.hidden = YES;
    //红点 - 与我相关
    m_notibgInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(123, 70+startX, 18, 18)];
     m_notibgInfoImageView.center =CGPointMake(m_meetBtn.center.x-25, m_meetBtn.center.y-140);
    [self.view bringSubviewToFront:m_notibgInfoImageView];
    [m_notibgInfoImageView setImage:[UIImage imageNamed:@"redCB.png"]];
    [self.view addSubview:m_notibgInfoImageView];
     m_notibgInfoImageView.hidden = YES;
    
    lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [lb setTextColor:[UIColor whiteColor]];
    lb.font = [UIFont systemFontOfSize:14.0];
    [m_notibgInfoImageView addSubview:lb];
    
    

    
    if (friendDunamicmsgCount && friendDunamicmsgCount !=0)
    {
        m_notibgInfoImageView.hidden = NO;
        if (friendDunamicmsgCount > 99) {
            lb.text = @"99";
        }
        else
            lb.text =[NSString stringWithFormat:@"%d",friendDunamicmsgCount] ;
    }


    
    //-----小红点-----
//    m_notibgInfoImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
//    m_notibgInfoImageView.center =CGPointMake(m_meetBtn.center.x-22, m_meetBtn.center.y-140);
//    m_notibgInfoImageView.image = KUIImage(@"new_num_bg");
//    [self.view addSubview:m_notibgInfoImageView];
//    
//    UILabel *lb = [[UILabel alloc]initWithFrame:m_notibgInfoImageView.frame];
//    lb.font = [UIFont systemFontOfSize:8];
//    lb.textColor = [UIColor whiteColor];
//    [m_notibgInfoImageView addSubview:lb];

    
    
    UILabel *friendLb = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 53, 16)];
    friendLb.center = CGPointMake(m_meetBtn.center.x-45, m_meetBtn.center.y-80);
    friendLb.text = @"朋友圈";
    [friendLb setBackgroundColor:[UIColor colorWithPatternImage:KUIImage(@"friendtext")]];
    friendLb.font = [UIFont systemFontOfSize:12];
    friendLb.textAlignment = NSTextAlignmentCenter;
    friendLb.layer.masksToBounds = YES;
    friendLb.layer.cornerRadius = 3;

    [self.view addSubview:friendLb];
    
    
    
    m_nearByBtn = [FinderView setButtonWithFrame:CGRectMake(0, 0, 41, 41) center:CGPointMake(m_meetBtn.center.x+78, m_meetBtn.center.y-52) backgroundNormalImage:@"new_nearby_pressed" backgroundHighlightImage:@"new_nearby_normal" setTitle:nil nextImage:nil nextImage:nil];
    m_nearByBtn.layer.masksToBounds = YES;
    m_nearByBtn.layer.cornerRadius = 41/2;

    [m_nearByBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:m_nearByBtn];
    
    
    m_samerealmBtn = [FinderView setButtonWithFrame:CGRectMake(0, 0, 41, 41) center:CGPointMake(m_meetBtn.center.x-101,m_meetBtn.center.y-26) backgroundNormalImage:@"new_tongfu_pressed" backgroundHighlightImage:@"new_tongfu_normal" setTitle:nil nextImage:@"nil" nextImage:@"nil"];
    m_samerealmBtn.layer.masksToBounds = YES;
    m_samerealmBtn.layer.cornerRadius = 41/2;

    [m_samerealmBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:m_samerealmBtn];
        
    m_girlBtn = [FinderView setButtonWithFrame:CGRectMake(0, 0, 56, 56) center:CGPointMake(m_meetBtn.center.x+98,m_meetBtn.center.y+71) backgroundNormalImage:@"new_monv_pressed" backgroundHighlightImage:@"new_monv_normal" setTitle:nil nextImage:nil nextImage:nil];
    m_girlBtn.layer.masksToBounds = YES;
    m_girlBtn.layer.cornerRadius = 56/2;

    [m_girlBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:m_girlBtn];
    
    
    m_phoneBtn = [FinderView setButtonWithFrame:CGRectMake(0, 0, 65, 65) center:CGPointMake(m_meetBtn.center.x-69,m_meetBtn.center.y+114) backgroundNormalImage:@"new_address_pressed" backgroundHighlightImage:@"new_address_normal" setTitle:nil nextImage:nil nextImage:nil];
    m_phoneBtn.layer.masksToBounds = YES;
    m_phoneBtn.layer.cornerRadius = 65/2;

    [m_phoneBtn addTarget:self action:@selector(didClickenterMeet:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:m_phoneBtn];

    
    
	// Do any additional setup after loading the view.
}


-(void)didClickenterMeet:(UIButton *)sender
{
    NSLog(@"点击");
    
    if (sender ==m_meetBtn) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        EncoXHViewController *enco = [[EncoXHViewController alloc]init];
        [self.navigationController pushViewController:enco animated:YES];

    }
    if (sender ==m_dynamicBtn) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        CircleHeadViewController *circleVC  = [[CircleHeadViewController alloc]init];
        circleVC.imageStr = nil;
        circleVC.userId =[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
        [self.navigationController pushViewController:circleVC animated:YES];
//        NewsViewController* VC = [[NewsViewController alloc] init];
//        VC.myViewType = FRIEND_NEWS_TYPE;
//        VC.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];//好友动态
//        [self.navigationController pushViewController:VC animated:YES];

//        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveFriendNews];
//        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //清除红点
        m_notibgInfoImageView.hidden = YES;
        m_notibgCircleNewsImageView.hidden = YES;
        friendDunamicmsgCount =0;
        myDunamicmsgCount =0;
      //  [[GameCommon shareGameCommon] displayTabbarNotification];
        
        //清除tabbar红点 以前是上面方法 综合发现和我的动态通知
        [[Custom_tabbar showTabBar]removeNotificatonOfIndex:2];

    }
    if (sender ==m_girlBtn) {
        NSLog(@"魔女榜");
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        MagicGirlViewController *maVC = [[MagicGirlViewController alloc]init];
        [self.navigationController pushViewController:maVC animated:YES];
    }
    if (sender ==m_nearByBtn) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        NewNearByViewController* VC = [[NewNearByViewController alloc] init];
        [self.navigationController pushViewController:VC animated:YES];

    }
    if (sender ==m_samerealmBtn) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        SameRealmViewController* realmsVC = [[SameRealmViewController alloc] init];
        [self.navigationController pushViewController:realmsVC animated:YES];

    }
    if (sender ==m_phoneBtn) {
        NSLog(@"手机通讯录");
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        MessageAddressViewController *addVC = [[MessageAddressViewController alloc]init];
        [self.navigationController pushViewController:addVC animated:YES];
    }

    if (sender ==m_activateBtn) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];

        ActivateViewController *activeVC = [[ActivateViewController alloc]init];
        [self.navigationController pushViewController:activeVC animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
