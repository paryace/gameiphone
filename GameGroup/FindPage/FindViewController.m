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
#import "DSCircleCount.h"
#import "NewSearchGroupController.h"
#define mTime 0.5

@interface FindViewController ()
{
    UIButton *menuButotn;
    UIButton *sameRealmBtn;
    UIButton *nearByBtn;
    UIButton *moGirlBtn;
    UIButton *encoBtn;
    UIButton *groupBtn;
    
    UIView *bottomView;
    UIImageView *m_notibgInfoImageView; //与我相关红点
    UIImageView *m_notibgCircleNewsImageView; //朋友圈红点

    UILabel *commentLabel;
    EGOImageButton * headImgView;
    
    
    UILabel *lb;
    
    UILabel *groupMsgTitleLable;
    UILabel *gbMsgCountLable;//公告消息数
    UIImageView *gbMsgCountImageView; //公告红点
    UIImageView *m_notibgGbImageView;//群公告红点
    EGOImageButton *iconImageView ;//群头像
    NSInteger    billboardMsgCount;//群公告消息
    UIImageView * leaderImage;
   
   
    
    float button_center_x;
    float button_center_y;
    float curren_hieght;
    
    NSMutableArray *centerBtnArray;
    BOOL isDidClick;
    TvView *drawView;
    NSDictionary *manDic;
    EGOImageButton *m_menuButton;
    UIImageView *imgV;
    
    NSTimeInterval markTime;
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
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedFriendDynamicMsg:) name:@"frienddunamicmsgChange_WX"object:nil];
//    //与我相关
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedMyDynamicMsg:)name:@"mydynamicmsg_wx" object:nil];
    //清除离线消息
    
    //群公告消息广播接收
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receivedBillboardMsg:) name:Billboard_msg object:nil];

    [[GameListManager singleton] getGameListDicFromLocal:^(id responseObject) {
        if (responseObject) {
            [self initGameList:responseObject];
        }
    } reError:^(id error) {
        
    }];
    [self preferredStatusBarStyle];
    [[Custom_tabbar showTabBar] hideTabBar:NO];
    [self initMsgCount];
//    [self initDynamicMsgCount];

}

-(void)initGameList:(NSMutableDictionary*)gameListDic{
    drawView.tableDic=gameListDic;
    NSMutableDictionary * userDic = [DataStoreManager getUserInfoFromDbByUserid:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    NSMutableArray * gameidss=[NSMutableArray arrayWithArray:[GameCommon getGameids:[GameCommon getNewStringWithId:KISDictionaryHaveKey(userDic, @"gameids")]]];
    drawView.tableArray = [NSMutableArray arrayWithArray:[drawView.tableDic allKeys]];
    if (gameidss &&gameidss.count>0) {
        
        for (int i =0; i<drawView.tableArray.count; i++) {
            NSMutableArray *arr = [NSMutableArray arrayWithArray:[drawView.tableDic objectForKey:drawView.tableArray[i]]];
            for (int j = arr.count-1; j>=0; j--) {
                NSDictionary *dic = arr[j];
                if (![gameidss containsObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"id")]]) {
                    [arr removeObject:dic];
                }
            }
            [drawView.tableDic setObject:arr forKey:[drawView.tableArray objectAtIndex:i]];
        }
        
        NSMutableArray *asr = [NSMutableArray array];
        for (int i = drawView.tableArray.count-1; i>=0; i--) {
            NSString *str = [drawView.tableArray objectAtIndex:i];
            NSArray *array = [drawView.tableDic objectForKey:str];
            if (!array||array.count<1) {
                [drawView.tableDic removeObjectForKey:str];
                [asr addObject:str];
            }
        }
        for (NSString *str in asr) {
            if ([drawView.tableArray containsObject:str]) {
                [drawView.tableArray removeObject:str];
            }
        }
        [drawView.tv reloadData];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark 接收到公告消息通知
-(void)receivedBillboardMsg:(NSNotification*)sender
{
    billboardMsgCount++;
    [self setMsgBillBoardConunt:billboardMsgCount];
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
            gbMsgCountImageView.frame = CGRectMake(45, 5, 25, 18);
            gbMsgCountLable.frame = CGRectMake(0, 0, 25, 18);
        }else{
            gbMsgCountLable.text =[NSString stringWithFormat:@"%d",msgCount] ;
            gbMsgCountLable.frame = CGRectMake(0, 0, 18, 18);
            gbMsgCountImageView.frame = CGRectMake(45, 5, 18, 18);
        }
//        groupMsgTitleLable.text =[NSString stringWithFormat:@"%d条新的群公告",msgCount];
    }else
    {
        gbMsgCountImageView.hidden = YES;
        NSInteger groupCount = [DataStoreManager queryGroupCount];
        if (groupCount>0) {
             m_notibgGbImageView.hidden = YES;
//            groupMsgTitleLable.text =[NSString stringWithFormat:@"%@%d%@",@"您已加入了",groupCount,@"个群"];
        }else {
             m_notibgGbImageView.hidden = NO;
            [[Custom_tabbar showTabBar] notificationWithNumber:NO AndTheNumber:1 OrDot:YES WithButtonIndex:3];
//            groupMsgTitleLable.text =@"您还未加入组织";
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
             [iconImageView setBackgroundImage:KUIImage(@"find_billboard") forState:UIControlStateNormal];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor darkGrayColor];
    isDidClick = YES;
    curren_hieght =kScreenHeigth;
    manDic = [NSDictionary new];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshCircle:) name:@"refreshCircleCount" object:nil];
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
    groupTitleLabel.text  = @"我的世界";
    groupTitleLabel.textColor = [UIColor whiteColor];
    groupTitleLabel.textAlignment = NSTextAlignmentLeft;
    [groupView addSubview:groupTitleLabel];
    
    groupMsgTitleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 33, 100, 20)];
    groupMsgTitleLable.backgroundColor = [UIColor clearColor];
    groupMsgTitleLable.textAlignment = NSTextAlignmentLeft;
    groupMsgTitleLable.textColor = UIColorFromRGBA(0x9e9e9e, 1);
    groupMsgTitleLable.font = [UIFont systemFontOfSize:11];
    groupMsgTitleLable.text = @"今日n条动态";
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
//    [iconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterGroupList:)]];
    [iconImageView addTarget:self action:@selector(enterGroupList:) forControlEvents:UIControlEventTouchUpInside];
//    iconImageView.backgroundColor = [UIColor redColor];
    iconImageView.placeholderImage =KUIImage(@"find_billboard");
    iconImageView.layer.cornerRadius = 5.0;
    iconImageView.layer.masksToBounds = YES;
    [bottomView addSubview:iconImageView];

//    //红点 - 公告
//    gbMsgCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 5, 18, 18)];
//    [gbMsgCountImageView setImage:[UIImage imageNamed:@"redCB.png"]];
//     gbMsgCountImageView.hidden = YES;
//    [bottomView addSubview:gbMsgCountImageView];
//    
//    //未读公告消息
//    gbMsgCountLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
//    [gbMsgCountLable setBackgroundColor:[UIColor clearColor]];
//    [gbMsgCountLable setTextAlignment:NSTextAlignmentCenter];
//    [gbMsgCountLable setTextColor:[UIColor whiteColor]];
//    gbMsgCountLable.font = [UIFont systemFontOfSize:14.0];
//    gbMsgCountLable.text = @"20";
//    [gbMsgCountImageView addSubview:gbMsgCountLable];
    
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
    m_notibgCircleNewsImageView.hidden = YES;
    [bottomView addSubview:m_notibgCircleNewsImageView];

    m_notibgInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(300,2, 18, 18)];
    [bottomView bringSubviewToFront:m_notibgInfoImageView];
    m_notibgInfoImageView.hidden = YES;
    [m_notibgInfoImageView setImage:[UIImage imageNamed:@"redCB.png"]];
    [bottomView addSubview:m_notibgInfoImageView];

    lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setTextAlignment:NSTextAlignmentCenter];
    lb.adjustsFontSizeToFitWidth = YES;
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
    commentLabel.text = @"暂无新动态";
    commentLabel.textColor = UIColorFromRGBA(0x9e9e9e, 1);
    commentLabel.font = [UIFont systemFontOfSize:11];
    [circleView addSubview:commentLabel];

    leaderImage =[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, kScreenHeigth-50-(KISHighVersion_7?60:80))];
    leaderImage.image = KISHighVersion_7?KUIImage(@"find_leader5"):KUIImage(@"find_leader4");
    leaderImage.hidden = YES;
    UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(enterLeaderImage:)];
    [leaderImage addGestureRecognizer:longPress];
    [self.view addSubview:leaderImage];
    
    m_menuButton = [[EGOImageButton alloc]initWithFrame:CGRectMake(0,drawView.bounds.size.height, 42.24, 44)];
    m_menuButton.center = CGPointMake(160,drawView.bounds.size.height);
    [m_menuButton addTarget:self action:@selector(dropdown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_menuButton];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"]) {
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"];
        NSString * imageId= KISDictionaryHaveKey(dic, @"img");
        m_menuButton.imageURL= [ImageService getImageUrl4:imageId];
        drawView.textLabel.text = @"选择游戏,开始您的游戏社交";
        if(leaderImage.hidden == NO){
            leaderImage.hidden = YES;
        }
    }else{
        [m_menuButton setBackgroundImage:KUIImage(@"menu_find_normal") forState:UIControlStateNormal];
        drawView.textLabel.text = @"点击Go,开始您的游戏社交";
        if(leaderImage.hidden == YES){
            leaderImage.hidden = NO;
        }
    }
    [self refreshCircle:nil];
}
#pragma mark 动态消息通知
-(void)refreshCircle:(id)sender
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTime)*100<mTime*1000) {
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        self.cellTimer = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(stopATime) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.cellTimer forMode:NSRunLoopCommonModes];
        markTime = [[NSDate date] timeIntervalSince1970];
        return;
    }
    markTime = [[NSDate date] timeIntervalSince1970];
    [self setCircleMessage];
}
- (void)stopATime
{
    [self setCircleMessage];
    if ([self.cellTimer isValid]) {
        [self.cellTimer invalidate];
        self.cellTimer = nil;
    }
}

-(void)setCircleMessage{
    DSCircleCount *dsCount = [DataStoreManager querymessageWithUserid:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    int r = dsCount.friendsCount;
    int g = dsCount.mineCount;
    NSString *img = dsCount.img;
    [self setHeadImage:img];
    [self setFriendCricleDot:r];
    [self setAboutMeDot:g];
    [self setMsgText:g FriendCoutn:r];
}


//设置提示文字
-(void)setMsgText:(NSInteger)mineCount FriendCoutn:(NSInteger)friendCount{
    if (mineCount>0) {
        commentLabel.text = [NSString stringWithFormat:@"%d条与我相关",mineCount];
    }else {
        if (friendCount>0) {
            commentLabel.text = [NSString stringWithFormat:@"%d条好友动态",friendCount];
        }else{
            commentLabel.text = @"暂无新动态";
            [[Custom_tabbar showTabBar]removeNotificatonOfIndex:3];
        }
    }
}


//设置头像
-(void)setHeadImage:(NSString*)imageId{
    if ([GameCommon isEmtity:imageId]) {
        headImgView.imageURL = nil;
        [headImgView setBackgroundImage:KUIImage(@"placeholder.png") forState:UIControlStateNormal];
    }else{
       headImgView.imageURL = [ImageService getImageStr:imageId Width:80];
    }
}

//设置好友动态红点
-(void)setFriendCricleDot:(NSInteger)msgCount{
    if (msgCount>0) {
        m_notibgCircleNewsImageView.hidden =NO;
    }else{
        m_notibgCircleNewsImageView.hidden =YES;
    }
}
//设置与我相关数量
-(void)setAboutMeDot:(NSInteger)msgCount{
    if (msgCount>0) {
        m_notibgInfoImageView.hidden = NO;
        if (msgCount>99) {
            lb.text = @"99+";
        }else{
            lb.text = [NSString stringWithFormat:@"%d",msgCount];
        }
    }else{
        m_notibgInfoImageView.hidden = YES;
    }
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
    [sameRealmBtn addTarget:self action:@selector(enterOtherPage:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sameRealmBtn];
    
    nearByBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"nearby_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    nearByBtn.hidden = YES;
    //    添加退拽手势

        [nearByBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [nearByBtn addTarget:self action:@selector(enterOtherPage:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:nearByBtn];
    
    
    encoBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"enxo_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    encoBtn.hidden = YES;
    //    添加退拽手势

    [encoBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [encoBtn addTarget:self action:@selector(enterOtherPage:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:encoBtn];
    
    
    moGirlBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"mogirl_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    moGirlBtn.hidden = YES;
    //    添加退拽手势

    [moGirlBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [moGirlBtn addTarget:self action:@selector(enterOtherPage:withEvent:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:moGirlBtn];
    
    
    groupBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"group_highlight" center:CGPointMake(160, KISHighVersion_7?79:59)];
    groupBtn.hidden = YES;
    //    添加退拽手势
    
    [groupBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势
    [groupBtn addTarget:self action:@selector(enterOtherPage:withEvent:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:groupBtn];
    
    
    //红点 - 公告
    gbMsgCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(45, 5, 18, 18)];
    [gbMsgCountImageView setImage:[UIImage imageNamed:@"redCB.png"]];
    gbMsgCountImageView.hidden = YES;
    [groupBtn addSubview:gbMsgCountImageView];
    
    //未读公告消息
    gbMsgCountLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [gbMsgCountLable setBackgroundColor:[UIColor clearColor]];
    [gbMsgCountLable setTextAlignment:NSTextAlignmentCenter];
    [gbMsgCountLable setTextColor:[UIColor whiteColor]];
    gbMsgCountLable.font = [UIFont systemFontOfSize:12.0];
    gbMsgCountLable.text = @"20";
    [gbMsgCountImageView addSubview:gbMsgCountLable];


}
//手指移动过程
- (void) dragMoving: (UIButton *) c withEvent:(UIEvent *)ev
{
    isDidClick =NO;
    c.center = [[[ev allTouches] anyObject] locationInView:self.view];
}
//手指弹起
-(void)enterOtherPage:(UIButton *)sender withEvent:(UIEvent *)ev
{
    if (isDidClick ==NO) {
        [self saveBtnCenter:sender withEvent:ev];
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
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        SameRealmViewController* realmsVC = [[SameRealmViewController alloc] init];
        realmsVC.gameid = KISDictionaryHaveKey(manDic, @"id");
        [self.navigationController pushViewController:realmsVC animated:YES];
    }
    if (sender == groupBtn) {
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        NewSearchGroupController * gruupV = [[NewSearchGroupController alloc] init];
        gruupV.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(manDic, @"id")];
        [self.navigationController pushViewController:gruupV animated:YES];
    }
}
//保存坐标
-(void)saveBtnCenter:(UIButton *)sender withEvent:(UIEvent *)ev{
    NSArray *centerArray = [NSArray arrayWithObjects:@(sender.center.x),@(sender.center
                            .y),nil];
    NSLog(@"----%@-----",centerArray);
    if (sender ==nearByBtn) {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"nearByBtn_center_wx"];
    }
    else if (sender ==sameRealmBtn)
    {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"sameBtn_center_wx"];
    }
    else if(sender ==encoBtn)
    {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"encoBtn_center_wx"];
    }
    else if (sender == groupBtn)
    {
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"groBtn_center_wx"];
    }
    else{
        [[NSUserDefaults standardUserDefaults]setObject:centerArray forKey:@"moGirlBtn_center_wx"];
    }
}
//创建小球菜单按钮
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
        bottomView.hidden = NO;
        [self.view sendSubviewToBack:drawView];
        [self.view sendSubviewToBack:imgV];
        [self performSelector:@selector(showNearBy:) withObject:nil afterDelay:0];
        [self performSelector:@selector(showSamerealm:) withObject:nil afterDelay:0.15];
        [self performSelector:@selector(showEnco:) withObject:nil afterDelay:0.3];
        [self performSelector:@selector(showMoGirl:) withObject:nil afterDelay:0.45];
        [self performSelector:@selector(showGroup:) withObject:nil afterDelay:0.6];

    }else{
        sameRealmBtn.hidden = YES;
        nearByBtn.hidden = YES;
        moGirlBtn.hidden = YES;
        encoBtn.hidden = YES;
        groupBtn.hidden = YES;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:1];
        sameRealmBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        nearByBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        moGirlBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        encoBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        groupBtn.center = CGPointMake(160, KISHighVersion_7?79:59);
        [UIView commitAnimations];
    }
}
//显示附近的
-(void)showNearBy:(id)sender{
    nearByBtn.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"nearByBtn_center_wx"]) {
        NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"nearByBtn_center_wx"];
        float i =[centerArray[1]floatValue];
        if (i>curren_hieght-110||i<(KISHighVersion_7?79:59)) {
            if ([centerArray[1]floatValue]>curren_hieght-110) {
                nearByBtn.center = CGPointMake([centerArray[0]floatValue],curren_hieght-110);
            }else if (i<KISHighVersion_7?79:59){
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
}
//显示同服
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
        }else if (i<(KISHighVersion_7?79:59)){
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);
        }else{
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        sameRealmBtn.center = CGPointMake(80, 150);
    }
    [UIView commitAnimations];
}
//显示群组
-(void)showGroup:(id)sender
{
    groupBtn.hidden = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"groBtn_center_wx"]) {
        NSArray *centerArray =[[NSUserDefaults standardUserDefaults]objectForKey:@"groBtn_center_wx"];
        float i = [centerArray[1]floatValue];
        if (i>curren_hieght-110) {
            groupBtn.center = CGPointMake([centerArray[0]floatValue],curren_hieght-110);
        }else if (i<(KISHighVersion_7?79:59)){
            groupBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);
        }else{
            groupBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        groupBtn.center = CGPointMake(80, 150);
    }
    [UIView commitAnimations];
}
//显示魔女榜
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
        }else if (i<(KISHighVersion_7?79:59)){
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
//显示许愿池
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
        }else if (i<(KISHighVersion_7?79:59)){
            encoBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?79:59);

        }else{
            encoBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        encoBtn.center = CGPointMake(240, 300);
    }
    [UIView commitAnimations];
}

-(void)enterCirclePage:(id)sender
{
    [[Custom_tabbar showTabBar] hideTabBar:YES];
    CircleHeadViewController *circleVC  = [[CircleHeadViewController alloc]init];
    circleVC.imageStr = nil;
    circleVC.userId =[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    [self.navigationController pushViewController:circleVC animated:YES];
    [DataStoreManager clearFriendCircleCountWithUserid:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
}

-(void)enterGroupList:(id)sender
{
//    [[Custom_tabbar showTabBar] hideTabBar:YES];
//    MyGroupViewController * gruupV = [[MyGroupViewController alloc] init];
//    [self.navigationController pushViewController:gruupV animated:YES];
    
}

-(void)enterLeaderImage:(id)sender
{
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
    ;
    if (picker.sourceType ==UIImagePickerControllerSourceTypeCamera) {
        UIImageWriteToSavedPhotosAlbum(selectImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    }
    NSData *data = UIImageJPEGRepresentation(afterImage, 0.7);
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"bgImgForFinder_wx"];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)didClickGameIdWithView:(TvView *)myView
{
    bottomView.hidden =YES;
    if (drawView.showList) {
        if (![[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"]) {
            leaderImage.hidden=NO;
        }
        [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        m_menuButton.center = CGPointMake(160,KISHighVersion_7?79:59);
        [self.view bringSubviewToFront:m_menuButton];
        [UIView commitAnimations];

    }else{
        if (![[NSUserDefaults standardUserDefaults]objectForKey:@"find_initial_game"]) {
            leaderImage.hidden=YES;
        }
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
    if (leaderImage.hidden == NO) {
        leaderImage.hidden = YES;
    }
    m_menuButton.center = CGPointMake(160, KISHighVersion_7?79:59);
    [self.view bringSubviewToFront:m_menuButton];

    [UIView commitAnimations];

    
    
    NSLog(@"manDic--%@",manDic);
}

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
//    NSString *msg = nil ;
//    if(error != NULL){
//        msg = @"保存图片失败,请允许本应用访问您的相册";
//    }else{
//        msg = @"保存图片成功" ;
//    }
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];
//    [alert show];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
