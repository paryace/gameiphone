//
//  FindViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FindViewController.h"
#import "EGOImageView.h"
#import "EGOImageButton.h"
#import "NewNearByViewController.h"
#import "CircleHeadViewController.h"
#import "SameRealmViewController.h"
#import "EncoXHViewController.h"
#import "MagicGirlViewController.h"
#import "MyGroupViewController.h"
#import "JoinGroupViewController.h"
@interface FindViewController ()
{
    UIButton *menuButotn;
    UIButton *sameRealmBtn;
    UIButton *nearByBtn;
    UIButton *moGirlBtn;
    UIButton *encoBtn;
    
    UIView *bottomView;
    UIImageView *m_notibgInfoImageView; //与我相关红点
    UIImageView *m_notibgCircleNewsImageView; //朋友圈红点

    UILabel *commentLabel;
    EGOImageButton * headImgView;
    
    NSInteger    myDunamicmsgCount;
    NSInteger    friendDunamicmsgCount;
    
    UILabel *lb;
    
    UILabel *groupMsgTitleLable;
    UILabel *gbMsgCountLable;//公告消息数
    UIImageView *gbMsgCountImageView; //公告红点
    UIImageView *m_notibgGbImageView;//群公告红点
    EGOImageButton *iconImageView ;//群头像
    NSInteger    billboardMsgCount;//群公告消息
   
   
    
    float button_center_x;
    float button_center_y;
    float curren_hieght;
    
    NSMutableArray *centerBtnArray;
    BOOL isDidClick;
    TvView *drawView;
    NSDictionary *manDic;
    EGOImageButton *m_menuButton;
    UIImageView *imgV;
}
@property(nonatomic,retain)NSString * friendImgStr;

@end

@implementation FindViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
           }
    return self;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super  viewWillDisappear:animated];
    
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //好友动态
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedFriendDynamicMsg:) name:@"frienddunamicmsgChange_WX"object:nil];
    //与我相关
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedMyDynamicMsg:)name:@"mydynamicmsg_wx" object:nil];
    //清除离线消息
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(cleanNews) name:@"cleanInfoOffinderPage_wx" object:nil];
    //群公告消息广播接收
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:Billboard_msg object:nil];

    
    
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        drawView.tableDic= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    }else{
        [[GameCommon shareGameCommon]firtOpen];
        drawView.tableDic= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    }
    
    NSMutableDictionary * userDic = [DataStoreManager getUserInfoFromDbByUserid:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    
    NSMutableArray * gameidss=[NSMutableArray arrayWithArray:[GameCommon getGameids:[GameCommon getNewStringWithId:KISDictionaryHaveKey(userDic, @"gameids")]]];
    
    
    drawView.tableArray = [NSMutableArray arrayWithArray:[drawView.tableDic allKeys]];
    
    if (gameidss &&gameidss.count>0) {
        
    
    for (int i =0; i<drawView.tableArray.count; i++) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:[drawView.tableDic objectForKey:drawView.tableArray[i]]];
        for (int j =0; j<arr.count; j++) {
            NSDictionary *dic = arr[j];
            if (![gameidss containsObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"id")]]) {
                [arr removeObject:dic];
                [drawView.tableDic setObject:arr forKey:[drawView.tableArray objectAtIndex:i]];
            }
        }
    }
    
    for (int i = 0; i<drawView.tableArray.count; i++) {
        NSArray *array = [drawView.tableDic objectForKey:drawView.tableArray[i]];
        if (!array||array.count<1) {
            [drawView.tableDic removeObjectForKey:drawView.tableArray[i]];
            [drawView.tableArray removeObjectAtIndex:i];
        }
    }
    [drawView.tv reloadData];

    }
  
    [self preferredStatusBarStyle];
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    [self initMsgCount];
    [self initDynamicMsgCount];

}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark 接收到于我相关消息通知
-(void)receivedMyDynamicMsg:(NSNotification*)sender
{
    //添加Tab上的小红点
    myDunamicmsgCount = [self getMyDynamicMsgCount];
    [self setDynamicMsgCount:friendDunamicmsgCount MydynamicmsgCount:myDunamicmsgCount];


}
#pragma mark 接收到好友动态消息通知
-(void)receivedFriendDynamicMsg:(NSNotification*)sender
{
    friendDunamicmsgCount = [self getFriendDynamicMsgCount];
    [self setDynamicMsgCount:friendDunamicmsgCount MydynamicmsgCount:myDunamicmsgCount];
    [self setDynamicImage];
}

#pragma mark 接收到公告消息通知
-(void)receivedBillboardMsg:(NSNotification*)sender
{
    billboardMsgCount++;
    [self setMsgBillBoardConunt:billboardMsgCount];
}

//取出我的动态消息数
-(NSInteger)getMyDynamicMsgCount
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"]) {
        return [[[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"] intValue];
    }
    return 0;
}
//取出好友动态的消息数量
-(NSInteger)getFriendDynamicMsgCount
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]) {
        return [[[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"] intValue];
    }
    return 0;
}

//初始化动态红点
-(void)initDynamicMsgCount
{
    myDunamicmsgCount = [self getMyDynamicMsgCount];
    friendDunamicmsgCount = [self getFriendDynamicMsgCount];
    [self setDynamicMsgCount:friendDunamicmsgCount MydynamicmsgCount:myDunamicmsgCount];
}

//设置动态红点以及数量
-(void)setDynamicMsgCount:(NSInteger)dongtaicount MydynamicmsgCount:(NSInteger)mydynamicmsgcount
{
    NSString *commStr1 = @"";
    NSString *commStr2 = @"";
    if (dongtaicount>0||mydynamicmsgcount>0) {
        
        
        if (mydynamicmsgcount>0) {
            commStr2 = [NSString stringWithFormat:@"%d条与我相关",mydynamicmsgcount];
            m_notibgInfoImageView.hidden = NO;
            [bottomView bringSubviewToFront:m_notibgInfoImageView];
            lb.text =[NSString stringWithFormat:@"%d",mydynamicmsgcount];
            commentLabel.text = commStr2;
        }else{
            commStr2 = @"";
            m_notibgInfoImageView.hidden = YES;

            if (dongtaicount>0) {
                commStr1 = [NSString stringWithFormat:@"共有%d条新动态.",dongtaicount];
                m_notibgCircleNewsImageView.hidden =NO;
                [bottomView bringSubviewToFront:m_notibgCircleNewsImageView];
            }else{
                m_notibgCircleNewsImageView.hidden = YES;
            }
            commentLabel.text = commStr1;
        }
//        commentLabel.text = [commStr1 stringByAppendingString:commStr2];
    }else{
        commentLabel.text  = @"暂无新动态";
        lb.text = @"";
        m_notibgInfoImageView.hidden = YES;
        m_notibgCircleNewsImageView.hidden = YES;
    }
}
//设置动态消息的头像
-(void)setDynamicImage
{
    NSDictionary * dicInfo = [self getFriendDynamicInfo];
    if (!dicInfo) {
        headImgView.imageURL = nil;
        [headImgView setBackgroundImage:KUIImage(@"placeholder.png") forState:UIControlStateNormal];
    }else{
        NSString * headImage = KISDictionaryHaveKey(dicInfo, @"img");
        if([GameCommon isEmtity:headImage])
        {
            headImgView.imageURL = nil;
            [headImgView setBackgroundImage:KUIImage(@"placeholder.png") forState:UIControlStateNormal];
        }else{
            headImgView.imageURL = [ImageService getImageStr:headImage Width:80];
            [iconImageView setBackgroundImage:nil forState:UIControlStateNormal];
        }
    }
}

//获取缓存的动态消息内容
-(NSDictionary*)getFriendDynamicInfo
{
    NSMutableData *data= [NSMutableData data];
    NSDictionary *dic = [NSDictionary dictionary];
    data =[[NSUserDefaults standardUserDefaults]objectForKey:@"frienddynamicmsg_huancun_wx"];
    NSKeyedUnarchiver *unarchiver= [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    dic = [unarchiver decodeObjectForKey: @"getDatat"];
    [unarchiver finishDecoding];
    return dic;
}

//初始化公告未读消息数量
-(void)initMsgCount
{
    NSNumber *bullboardMsgCount = [[NSUserDefaults standardUserDefaults]objectForKey:Billboard_msg_count];
    billboardMsgCount = [bullboardMsgCount intValue];
    [self setMsgBillBoardConunt:billboardMsgCount];
}

//设置公告未读消息数量
-(void)setMsgBillBoardConunt:(NSInteger)msgCount
{
    [self setBillboardImage];
    if (msgCount>0) {
        gbMsgCountImageView.hidden = NO;
        if (msgCount > 99) {
            gbMsgCountLable.text = @"99+";
        }
        else{
            gbMsgCountLable.text =[NSString stringWithFormat:@"%d",msgCount] ;
        }
        groupMsgTitleLable.text =[NSString stringWithFormat:@"%d条新的群公告",msgCount];
    }else
    {
        gbMsgCountImageView.hidden = YES;
        NSInteger groupCount = [DataStoreManager queryGroupCount];
        if (groupCount>0) {
             m_notibgGbImageView.hidden = YES;
            groupMsgTitleLable.text =[NSString stringWithFormat:@"%@%d%@",@"您已加入了",groupCount,@"个群"];
        }else {
             m_notibgGbImageView.hidden = NO;
            [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:1 OrDot:YES WithButtonIndex:2];
            groupMsgTitleLable.text =@"您还未加入组织";
        }
    }
}
-(void)setBillboardImage
{
    NSMutableDictionary * billBoard = [self getBillboardGroupInfo];
    if (billBoard) {
        NSString * groupId = KISDictionaryHaveKey(billBoard, @"groupId");
        NSMutableDictionary * simpleGroupInfo = [[GroupManager singleton] getGroupInfo:groupId];
        NSString * groupImage = KISDictionaryHaveKey(simpleGroupInfo, @"backgroundImg");
        if ([GameCommon isEmtity:groupImage]) {
            iconImageView.imageURL = nil;
             [iconImageView setBackgroundImage:KUIImage(@"placeholder.png") forState:UIControlStateNormal];
        }else{
            [iconImageView setBackgroundImage:nil forState:UIControlStateNormal];
            iconImageView.imageURL = [ImageService getImageUrl3:groupImage Width:120];
        }
        
    }else
    {
        iconImageView.imageURL = nil;
        [iconImageView setBackgroundImage:KUIImage(@"find_billboard") forState:UIControlStateNormal];
    }
}
-(NSMutableDictionary*)getBillboardGroupInfo
{
    NSMutableArray * bills = [DataStoreManager queryDSGroupApplyMsgByMsgType:@"groupBillboard"];
    if (bills&&bills.count>0) {
        return [bills objectAtIndex:0];
    }
    return nil;
}

-(void)cleanNews
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dongtaicount_wx"];
    [[Custom_tabbar showTabBar]removeNotificatonOfIndex:2];
    m_notibgCircleNewsImageView.hidden = YES;
    commentLabel.text = @"暂无新动态";

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    isDidClick = YES;
    curren_hieght =kScreenHeigth;
    manDic = [NSDictionary new];
    
    //初始化背景图片 并且添加点击换图方法
    imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth)];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"bgImgForFinder_wx"]) {
        NSData *data =[[NSUserDefaults standardUserDefaults]objectForKey:@"bgImgForFinder_wx"];
        
        UIImage *image =[UIImage imageWithData:data];
        imgV.image = image;

    }else{
        UIImage * defaultImage=iPhone5?KUIImage(@"bg"):KUIImage(@"bg_4");
        UIImage * afterImage= [self dealDefaultImage:defaultImage centerInSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height*2)];
        
        imgV.image = afterImage;
    }
    imgV.center = self.view.center;
    imgV.userInteractionEnabled = YES;
    [imgV addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImage:)]];
    [self.view addSubview:imgV];

    centerBtnArray = [NSMutableArray array];
    
    // 建立标头和下拉菜单
    drawView =[[ TvView alloc]initWithFrame:CGRectMake(0,0, 320, KISHighVersion_7?79:59 )];
    drawView.myViewDelegate = self;
    [self.view addSubview:drawView];

    
    
    
    
    //建立朋友圈view
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-110, 320, 60)];
    bottomView.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.6];
    [self.view addSubview:bottomView];
    

    
    UIView *groupView = [[UIView alloc]initWithFrame:CGRectMake(61, 0 , 99, 60)];
    groupView.backgroundColor =[UIColor clearColor];
    [groupView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterGroupList:)]];
    [bottomView addSubview:groupView];
    
    UILabel *groupTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 100, 18)];
    groupTitleLabel.backgroundColor = [UIColor clearColor];
    groupTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    groupTitleLabel.text  = @"我的组织";
    groupTitleLabel.textColor = [UIColor whiteColor];
    groupTitleLabel.textAlignment = NSTextAlignmentLeft;
    [groupView addSubview:groupTitleLabel];
    
    groupMsgTitleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, 100, 20)];
    groupMsgTitleLable.backgroundColor = [UIColor clearColor];
    groupMsgTitleLable.textAlignment = NSTextAlignmentLeft;
    groupMsgTitleLable.textColor = UIColorFromRGBA(0x9e9e9e, 1);
    groupMsgTitleLable.font = [UIFont systemFontOfSize:11];
    groupMsgTitleLable.text = @"没有群公告";
    [groupView addSubview:groupMsgTitleLable];
    
    UIImageView * lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(165, 10, 1, 40)];
    lineImage.image = KUIImage(@"find_line");
    [bottomView addSubview:lineImage];
    
    UIView *circleView = [[UIView alloc]initWithFrame:CGRectMake(161, 0 , 100, 60)];
    circleView.backgroundColor =[UIColor clearColor];
    [circleView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCirclePage:)]];
    [bottomView addSubview:circleView];
    
    UILabel *bottomTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 100, 20)];
    bottomTitleLabel.backgroundColor = [UIColor clearColor];
    bottomTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    bottomTitleLabel.text  = @"朋友圈";
    bottomTitleLabel.textColor = [UIColor whiteColor];
    bottomTitleLabel.textAlignment = NSTextAlignmentRight;
    [circleView addSubview:bottomTitleLabel];

    
    iconImageView = [[EGOImageButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    [iconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterGroupList:)]];
    iconImageView.layer.cornerRadius = 5.0;
    iconImageView.layer.masksToBounds = YES;
    [bottomView addSubview:iconImageView];
    
    //红点 - 公告
    gbMsgCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, 18, 18)];
    [gbMsgCountImageView setImage:[UIImage imageNamed:@"redCB.png"]];
     gbMsgCountImageView.hidden = YES;
    [bottomView addSubview:gbMsgCountImageView];
    //未读公告消息
    gbMsgCountLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [gbMsgCountLable setBackgroundColor:[UIColor clearColor]];
    [gbMsgCountLable setTextAlignment:NSTextAlignmentCenter];
    [gbMsgCountLable setTextColor:[UIColor whiteColor]];
    gbMsgCountLable.font = [UIFont systemFontOfSize:14.0];
    gbMsgCountLable.text = @"20";
    [gbMsgCountImageView addSubview:gbMsgCountLable];
    
    //红点 - 朋友圈
    m_notibgGbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, 15, 15)];
    [m_notibgGbImageView setImage:[UIImage imageNamed:@"redpot.png"]];
    m_notibgGbImageView.hidden = YES;
    [bottomView addSubview:m_notibgGbImageView];
    
    headImgView = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder.png")];
    [headImgView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCirclePage:)]];
    headImgView.frame = CGRectMake(320-50, 10, 40, 40);
    headImgView.layer.cornerRadius = 5.0;
    headImgView.layer.masksToBounds = YES;
    if (_friendImgStr ==nil) {
        NSString * imageId=[[NSUserDefaults standardUserDefaults]objectForKey:@"preload_img_wx_dongtai"];
        
        headImgView.imageURL = [ImageService getImageUrl3:imageId Width:120];
    }else{
        headImgView.imageURL = [ImageService getImageUrl3:_friendImgStr Width:80];
    }
    [bottomView addSubview:headImgView];
    //红点 - 朋友圈
    m_notibgCircleNewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(265, 2, 15, 15)];
    [self.view bringSubviewToFront:m_notibgCircleNewsImageView];
    [m_notibgCircleNewsImageView setImage:[UIImage imageNamed:@"redpot.png"]];
    [bottomView addSubview:m_notibgCircleNewsImageView];
    
    
    m_notibgInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(300,2, 18, 18)];
    [bottomView bringSubviewToFront:m_notibgInfoImageView];
    [m_notibgInfoImageView setImage:[UIImage imageNamed:@"redCB.png"]];
    [bottomView addSubview:m_notibgInfoImageView];

    lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [lb setTextColor:[UIColor whiteColor]];
    lb.font = [UIFont systemFontOfSize:14.0];
    [m_notibgInfoImageView addSubview:lb];
    [self buildMenuButton];
    
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"]) {
        manDic = [[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"];
        drawView.showList = YES;
        [self didClickMenu:nil];
        drawView.showList =NO;
    }

    
    commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, 100, 20)];
    commentLabel.backgroundColor = [UIColor clearColor];
    commentLabel.textAlignment = NSTextAlignmentRight;
    commentLabel.adjustsFontSizeToFitWidth = YES;
    commentLabel.textColor = UIColorFromRGBA(0x9e9e9e, 1);
    commentLabel.font = [UIFont systemFontOfSize:11];
    [circleView addSubview:commentLabel];
    
    [self setDynamicImage];//设置动态消息图片
    
    m_menuButton = [[EGOImageButton alloc]initWithFrame:CGRectMake(0,drawView.bounds.size.height, 42.24, 44)];
    m_menuButton.center = CGPointMake(160,drawView.bounds.size.height);
    [m_menuButton addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventTouchUpInside];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"]) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"];
        NSString * imageId= KISDictionaryHaveKey(dic, @"img");
        m_menuButton.imageURL= [ImageService getImageUrl4:imageId];
        drawView.textLabel.text = @"选择游戏,开始您的游戏社交";
    }else{
        [m_menuButton setBackgroundImage:KUIImage(@"menu_find_normal") forState:UIControlStateNormal];
        drawView.textLabel.text = @"点击Go,开始您的游戏社交";
    }
    [self.view addSubview:m_menuButton];
}
- (UIImage *) dealDefaultImage: (UIImage *) image centerInSize: (CGSize) viewsize
{
	CGSize size = image.size;
    float dwidth = 0.0f;
    float dheight = 0.0f;
    float rate = 0.0f;
    
    float rate1 = viewsize.height / size.height;
    float rate2  = viewsize.width / size.width;
    if(rate1>rate2){
        rate=rate1;
        float w = rate * size.width;
        dwidth = (viewsize.width - w) / 2.0f;
        dheight = 0;
    }else{
        rate=rate2;
        float w = rate * size.height;
        dheight = (viewsize.height - w) / 2.0f;
        dwidth = 0;
    }
    CGRect rect = CGRectMake(dwidth, dheight-70, size.width*rate, size.height*rate);
	UIGraphicsBeginImageContext(viewsize);
	[image drawInRect:rect];
	UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    return newimg;
}
-(void)dropdown
{
    [drawView dropdown];
    [self.view bringSubviewToFront:m_menuButton];
}
-(void)buildMenuButton
{
    sameRealmBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"samerealm_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    sameRealmBtn.hidden = YES;
    
//    添加退拽手势
    [sameRealmBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
//    添加点击手势
    [sameRealmBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sameRealmBtn];
    
    nearByBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"nearby_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    nearByBtn.hidden = YES;
    //    添加退拽手势

        [nearByBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [nearByBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:nearByBtn];
    
    
    encoBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"enxo_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    encoBtn.hidden = YES;
    //    添加退拽手势

    [encoBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [encoBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:encoBtn];
    
    
    moGirlBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"mogirl_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    moGirlBtn.hidden = YES;
    //    添加退拽手势

    [moGirlBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [moGirlBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:moGirlBtn];

}

- (void) dragMoving: (UIButton *) c withEvent:(UIEvent *)ev
{
    isDidClick =NO;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];

    
    NSArray *centerArray = [NSArray arrayWithObjects:@(c.center.x),@(c.center
                            .y),nil];
    if (c ==nearByBtn) {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"nearByBtn_center_wx"];
    }
    else if (c ==sameRealmBtn)
    {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"sameBtn_center_wx"];
    }
    else if(c ==encoBtn)
    {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"encoBtn_center_wx"];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"moGirlBtn_center_wx"];
    }
    
}

-(UIButton *)buildBttonWithFrame:(CGRect)frame backGroundColor:(UIColor *)bgColor bgImg:(NSString *)bgImg center:(CGPoint)center
{
    UIButton *button  = [[UIButton alloc]initWithFrame:frame];
    button.backgroundColor = bgColor;
    button.center = center;
    [button setBackgroundImage:KUIImage(bgImg) forState:UIControlStateNormal];
    return button;
}

-(void)didClickMenu:(UIButton *)sender
{
    
    if (drawView.showList) {
        nearByBtn.hidden = NO;
        bottomView.hidden = NO;
        [self.view sendSubviewToBack:drawView];
        [self.view sendSubviewToBack:imgV];

        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];

        if ([[NSUserDefaults standardUserDefaults]objectForKey:@"nearByBtn_center_wx"]) {
            NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"nearByBtn_center_wx"];
            float i =[centerArray[1]floatValue];
            
            NSLog(@"%d",KISHighVersion_7?79:59);
            if (i>curren_hieght-110||i<(KISHighVersion_7?79:59)) {
                if ([centerArray[1]floatValue]>curren_hieght-110) {
                    nearByBtn.center = CGPointMake([centerArray[0]floatValue],curren_hieght-110);
                }else if (i<KISHighVersion_7?79:59)
                {
                    nearByBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);
                }
            }
            else{
                nearByBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
            }
        }else{
            nearByBtn.center = CGPointMake(80, 300);
        }
        [UIView commitAnimations];
        [self performSelector:@selector(showSamerealm:) withObject:nil afterDelay:0.15];
        [self performSelector:@selector(showEnco:) withObject:nil afterDelay:0.3];
        [self performSelector:@selector(showMoGirl:) withObject:nil afterDelay:0.45];

    }else{
        sameRealmBtn.hidden = YES;
        nearByBtn.hidden = YES;
        moGirlBtn.hidden = YES;
        encoBtn.hidden = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        sameRealmBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        nearByBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        moGirlBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        encoBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        [UIView commitAnimations];
    }
}

-(void)showSamerealm:(id)sender
{
    sameRealmBtn.hidden = NO;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];

    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sameBtn_center_wx"]) {
        NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"sameBtn_center_wx"];
        float i = [centerArray[1]floatValue];
        
        if (i>curren_hieght-110) {
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue],curren_hieght-110);
        }else if (i<(KISHighVersion_7?79:59))
        {
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);
            

        }else{
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        sameRealmBtn.center = CGPointMake(80, 150);
    }
    [UIView commitAnimations];

}

-(void)showMoGirl:(id)sender
{
    moGirlBtn.hidden = NO;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];

    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"moGirlBtn_center_wx"]) {
        NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"moGirlBtn_center_wx"];
        float i = [centerArray[1]floatValue];

        if (i>curren_hieght-110) {
            moGirlBtn.center = CGPointMake([centerArray[0]floatValue],curren_hieght-110);
        }else if (i<(KISHighVersion_7?79:59))
        {
            moGirlBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);
        }else{
        moGirlBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        moGirlBtn.center = CGPointMake(240, 150);
    }
    [UIView commitAnimations];
;

}

-(void)showEnco:(id)sender
{
    encoBtn.hidden = NO;

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];

    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"encoBtn_center_wx"]) {
        NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"encoBtn_center_wx"];
        float i = [centerArray[1]floatValue];

        if (i>curren_hieght-110) {
            encoBtn.center = CGPointMake([centerArray[0]floatValue], curren_hieght-110);
            
        }else if (i<(KISHighVersion_7?79:59))
        {
            encoBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);

        }else{
        encoBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        encoBtn.center = CGPointMake(240, 300);
    }
    [UIView commitAnimations];

 
}


-(void)changebuttonImgWithButton:(UIButton *)button framekey:(NSString *)framekey initialcenter:(CGPoint)initiAlcenter img:(NSString *)img durTime:(float)dTime delay:(float)delay img2:(NSString *)img2 durtime2:(float)dTime2 delay:(float)delay2
{
    [UIView animateWithDuration:0.5 animations:^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        
        if ([[NSUserDefaults standardUserDefaults]objectForKey:framekey]) {
            NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:framekey];
            if ([centerArray[1]floatValue]>curren_hieght-110) {
                button.center = CGPointMake([centerArray[0]floatValue], curren_hieght-110);
            }else{
                button.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
            }
        }else{
            button.center = initiAlcenter;
        }
        [UIView commitAnimations];
        
    } completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:3 animations:^{
                
                [button setBackgroundImage:KUIImage(img) forState:UIControlStateNormal];
                
            } completion:^(BOOL finished){
                if (finished) {
                    
                    [UIView beginAnimations:nil context:nil];
                    [UIView setAnimationDelay:delay2];
                    [UIView setAnimationDuration:dTime2];
                    [button setBackgroundImage:KUIImage(img2) forState:UIControlStateNormal];
                    [UIView commitAnimations];
                }
            }];
        }
    }];
}


-(void)enterOtherPage:(UIButton *)sender
{
    if (isDidClick ==NO) {
        isDidClick =YES;
        return;
    }
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(manDic, @"id")]isEqualToString:@""]||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(manDic, @"id")]isEqualToString:@" "]||!manDic) {
        [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏" buttonTitle:@"确定"];
        return;
    }
    if (sender ==encoBtn) {  //许愿
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        EncoXHViewController *enco = [[EncoXHViewController alloc]init];
        enco.gameId = KISDictionaryHaveKey(manDic, @"id");
        [self.navigationController pushViewController:enco animated:YES];
        
    }
    if (sender ==moGirlBtn) {
        NSLog(@"魔女榜");
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        MagicGirlViewController *maVC = [[MagicGirlViewController alloc]init];
        maVC.gameid = KISDictionaryHaveKey(manDic, @"id");
        [self.navigationController pushViewController:maVC animated:YES];
    }
    if (sender ==nearByBtn ) {//附近
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        NewNearByViewController* VC = [[NewNearByViewController alloc] init];
        VC.gameid = KISDictionaryHaveKey(manDic, @"id");
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    if (sender ==sameRealmBtn) {
        
        NSLog(@"123123123312313");
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        SameRealmViewController* realmsVC = [[SameRealmViewController alloc] init];
        realmsVC.gameid = KISDictionaryHaveKey(manDic, @"id");
        [self.navigationController pushViewController:realmsVC animated:YES];
    }
}


-(void)enterCirclePage:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    CircleHeadViewController *circleVC  = [[CircleHeadViewController alloc]init];
    circleVC.imageStr = nil;
//    circleVC.msgCount = [[[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]intValue];
    circleVC.userId =[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    [self.navigationController pushViewController:circleVC animated:YES];
    friendDunamicmsgCount = 0;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dongtaicount_wx"];
    //清除tabbar红点 以前是上面方法 综合发现和我的动态通知
    [[Custom_tabbar showTabBar]removeNotificatonOfIndex:2];
}

-(void)enterGroupList:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    MyGroupViewController * gruupV = [[MyGroupViewController alloc] init];
    [self.navigationController pushViewController:gruupV animated:YES];
    [[Custom_tabbar showTabBar] removeNotificatonOfIndex:2];
}

#pragma mark --改变顶部图片
-(void)changeTopImage:(UILongPressGestureRecognizer*)sender
{
    if (sender.state ==UIGestureRecognizerStateBegan) {
        UIActionSheet *acs = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"相机", nil];
        acs.tag =9999999;
        [acs showInView:self.view];
    }
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==9999999) {
        UIImagePickerController * imagePicker;
        
        if (buttonIndex==1)
        {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate=self;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypeCamera;
                [self presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }
            else {
                UIAlertView *cameraAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相机" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
                [cameraAlert show];
            }
        }
        else if (buttonIndex==0) {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate=self;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:^{
                    
                }];
            }
            else {
                UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
                [libraryAlert show];
            }
        }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage*selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage * afterImage= [NetManager image2:selectImage centerInSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height*2)];
    imgV.image = afterImage;
    NSData *data = UIImageJPEGRepresentation(afterImage, 0.7);
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"bgImgForFinder_wx"];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)didClickGameIdWithView:(TvView *)myView
{
    bottomView.hidden =YES;
    if (drawView.showList) {
        [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];

        m_menuButton.center = CGPointMake(160,KISHighVersion_7?79:59);
        [self.view bringSubviewToFront:m_menuButton];
        [UIView commitAnimations];

    }else{
        [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];

        m_menuButton.center = CGPointMake(160,kScreenHeigth-90);

        [UIView commitAnimations];

    }
    [self didClickMenu:nil];
    [self.view bringSubviewToFront:m_menuButton];

}
-(void)didClickGameIdSuccessWithView:(TvView *)myView section:(NSInteger)section row:(NSInteger)row
{
    [self didClickMenu:nil];
    bottomView.hidden = NO;
    [self.view sendSubviewToBack :drawView];
    [self.view sendSubviewToBack:imgV];
//    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    
//    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
//
//    NSArray *allkeys = [dict allKeys];
    manDic = [[drawView.tableDic objectForKey:drawView.tableArray[section]]objectAtIndex:row];
    [[NSUserDefaults standardUserDefaults]setObject:manDic forKey:@"find_initial_game"];

    [m_menuButton setBackgroundImage:KUIImage(@"") forState:UIControlStateNormal];
    
    NSString * imageId2=KISDictionaryHaveKey(manDic, @"img");
    m_menuButton.imageURL=[ImageService getImageUrl4:imageId2];
    [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
drawView.textLabel.text = @"选择游戏,开始您的游戏社交";
    m_menuButton.center = CGPointMake(160, KISHighVersion_7?79:59);
    [self.view bringSubviewToFront:m_menuButton];

    [UIView commitAnimations];

    
    
    NSLog(@"manDic--%@",manDic);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
