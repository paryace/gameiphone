//
//  FindViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-5-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FindViewController.h"
#import "EGOImageView.h"
#import "NewNearByViewController.h"
#import "CircleHeadViewController.h"
#import "SameRealmViewController.h"
#import "EncoXHViewController.h"
#import "MagicGirlViewController.h"
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
    EGOImageView * headImgView;
    
    NSInteger    friendDunamicmsgCount;
    NSInteger    myDunamicmsgCount;
    UILabel *lb;
    float button_center_x;
    float button_center_y;
    float curren_hieght;
    
    NSMutableArray *centerBtnArray;
    BOOL isDidClick;
    TvView *drawView;
    NSDictionary *manDic;
    
    UIImageView *imgV;
}
@property(nonatomic,retain)NSString * friendImgStr;

@end

@implementation FindViewController

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
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[Custom_tabbar showTabBar] hideTabBar:NO];

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
        headImgView.imageURL =nil;
    }else{
        NSArray  * array= [fruits componentsSeparatedByString:@","];
        self.friendImgStr =[array objectAtIndex:0];
        
        [[NSUserDefaults standardUserDefaults]setValue:self.friendImgStr forKey:@"preload_img_wx_dongtai"];
        if (_friendImgStr) {
            headImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/80/80",_friendImgStr]];
        }else{
            headImgView.imageURL = nil;
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
        commentLabel.text =[NSString stringWithFormat:@"有%d条新动态",myDunamicmsgCount];
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
        headImgView.imageURL =nil;
    }else{
        NSArray  * array= [fruits componentsSeparatedByString:@","];
        self.friendImgStr =[array objectAtIndex:0];
        
        [[NSUserDefaults standardUserDefaults]setValue:self.friendImgStr forKey:@"preload_img_wx_dongtai"];
        if (_friendImgStr) {
            headImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/80",_friendImgStr]];
        }else{
            headImgView.imageURL = nil;
        }
    }
    
//    if (friendDunamicmsgCount && friendDunamicmsgCount !=0)
//    {
//        NSLog(@"-------->>>%d",friendDunamicmsgCount);
//        if(m_notibgInfoImageView.hidden)
//        {
//            m_notibgCircleNewsImageView.hidden = NO;
//        }
//        else{
//            m_notibgCircleNewsImageView.hidden = YES;
//        }
//        //        m_notibgInfoImageView.hidden = NO;
//        //        if (friendDunamicmsgCount > 99) {
//        //            lb.text = @"99";
//        //        }
//        //        else
//      commentLabel.text =[NSString stringWithFormat:@"有%d条新动态",friendDunamicmsgCount] ;
//    }
    NSString *commStr1 = @"";
    NSString *commStr2 = @"";
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]) {
        commStr1 = [NSString stringWithFormat:@"共有%d条新动态.",[[[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]intValue]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"]) {
        commStr2 = [NSString stringWithFormat:@"%d条与我相关",[[[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"]intValue]];
    }
    commentLabel.text = [commStr1 stringByAppendingString:commStr2];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isDidClick = YES;
    curren_hieght =kScreenHeigth;
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    manDic = [NSDictionary new];
    
    //初始化背景图片 并且添加点击换图方法
    imgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, (KISHighVersion_7?20:0), 320, kScreenHeigth-(KISHighVersion_7?20:0))];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"bgImgForFinder_wx"]) {
        NSData *data =[[NSUserDefaults standardUserDefaults]objectForKey:@"bgImgForFinder_wx"];
        imgV.image = [UIImage imageWithData:data];
    }else{
    imgV.image = KUIImage(@"bg.jpg");
    }
    imgV.userInteractionEnabled = YES;
    [imgV addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImage:)]];
    [self.view addSubview:imgV];
    
    
    
    centerBtnArray = [NSMutableArray array];
    
    drawView =[[ TvView alloc]initWithFrame:CGRectMake(0,0, 320, KISHighVersion_7?110:90 )];
    drawView.myViewDelegate = self;
    
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    
    drawView.tableDic= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    
    drawView.tableArray = [drawView.tableDic allKeys];
    [self.view addSubview:drawView];

    
    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height-110, 320, 60)];
    bottomView.backgroundColor =[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.6];
    [bottomView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterCirclePage:)]];

    [self.view addSubview:bottomView];
    
    UILabel *bottomTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 4, 80, 24)];
    bottomTitleLabel.backgroundColor = [UIColor clearColor];
    bottomTitleLabel.font = [UIFont boldSystemFontOfSize:18];
    bottomTitleLabel.text  = @"朋友圈";
    bottomTitleLabel.textColor = [UIColor whiteColor];
    bottomTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    [bottomView addSubview:bottomTitleLabel];
    
    UIImageView *iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 60)];
    iconImageView.image = KUIImage(@"circleIcon");
   // iconImageView.backgroundColor =[ UIColor clearColor];
    [bottomView addSubview:iconImageView];
    
    
    
    commentLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 28, 120, 20)];
    commentLabel.backgroundColor = [UIColor clearColor];
    commentLabel.textAlignment = NSTextAlignmentLeft;
    commentLabel.textColor = UIColorFromRGBA(0x9e9e9e, 1);
    commentLabel.font = [UIFont systemFontOfSize:11];
    NSString *commStr1 = @"";
    NSString *commStr2 = @"";
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]) {
        commStr1 = [NSString stringWithFormat:@"共有%d条新动态.",[[[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]intValue]];
    }
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"]) {
        commStr2 = [NSString stringWithFormat:@"%d条与我相关",[[[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"]intValue]];
    }
    commentLabel.text = [commStr1 stringByAppendingString:commStr2];
    [bottomView addSubview:commentLabel];
    
    headImgView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage(@"12312")];
    headImgView.frame = CGRectMake(260, 10, 40, 40);
       if (_friendImgStr ==nil) {
        headImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/120/120",[[NSUserDefaults standardUserDefaults]objectForKey:@"preload_img_wx_dongtai"]]];
    }else{
        headImgView.imageURL = [NSURL URLWithString:[NSString stringWithFormat:BaseImageUrl@"%@/80",_friendImgStr]];
    }
    [bottomView addSubview:headImgView];

    
    //红点 - 朋友圈
    m_notibgCircleNewsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(253, 2, 15, 15)];
    [self.view bringSubviewToFront:m_notibgCircleNewsImageView];
    [m_notibgCircleNewsImageView setImage:[UIImage imageNamed:@"redpot.png"]];
    [bottomView addSubview:m_notibgCircleNewsImageView];
    m_notibgCircleNewsImageView.hidden = YES;
    //红点 - 与我相关
    m_notibgInfoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(297,2, 18, 18)];
    [bottomView bringSubviewToFront:m_notibgInfoImageView];
    [m_notibgInfoImageView setImage:[UIImage imageNamed:@"redCB.png"]];
    [bottomView addSubview:m_notibgInfoImageView];
    m_notibgInfoImageView.hidden = YES;
    
    lb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setTextAlignment:NSTextAlignmentCenter];
    [lb setTextColor:[UIColor whiteColor]];
    lb.font = [UIFont systemFontOfSize:14.0];
    [m_notibgInfoImageView addSubview:lb];
    [self buildMenuButton];
   // [self didClickMenu:nil];
}

-(void)buildMenuButton
{
    sameRealmBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"samerealm_highlight" center:CGPointMake(160, KISHighVersion_7?110:90)];
    sameRealmBtn.hidden = YES;
    
//    添加退拽手势
    [sameRealmBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
//    添加点击手势
    [sameRealmBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sameRealmBtn];
    
    nearByBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"nearby_highlight" center:CGPointMake(160, KISHighVersion_7?110:90)];
    nearByBtn.hidden = YES;
    //    添加退拽手势

        [nearByBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [nearByBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:nearByBtn];
    
    
    encoBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"enxo_highlight" center:CGPointMake(160, KISHighVersion_7?110:90)];
    encoBtn.hidden = YES;
    //    添加退拽手势

    [encoBtn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
    //    添加点击手势

    [encoBtn addTarget:self action:@selector(enterOtherPage:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:encoBtn];
    
    
    moGirlBtn = [self buildBttonWithFrame:CGRectMake(0, 0, 60, 60) backGroundColor:[UIColor clearColor] bgImg:@"mogirl_highlight" center:CGPointMake(160, KISHighVersion_7?110:90)];
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
            
            NSLog(@"%d",KISHighVersion_7?130:110);
            if (i>curren_hieght-110||i<(KISHighVersion_7?130:110)) {
                if ([centerArray[1]floatValue]>curren_hieght-110) {
                    nearByBtn.center = CGPointMake([centerArray[0]floatValue],curren_hieght-110);
                }else if (i<KISHighVersion_7?130:110)
                {
                    nearByBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?130:110);
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
        sameRealmBtn.center = CGPointMake(160, KISHighVersion_7?110:90);
        nearByBtn.center = CGPointMake(160, KISHighVersion_7?110:90);
        moGirlBtn.center = CGPointMake(160, KISHighVersion_7?110:90);
        encoBtn.center = CGPointMake(160, KISHighVersion_7?110:90);
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
        }else if (i<(KISHighVersion_7?130:110))
        {
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?130:110);
            

        }else{
            sameRealmBtn.center = CGPointMake([centerArray[0]floatValue], [centerArray[1]floatValue]);
        }
    }else{
        sameRealmBtn.center = CGPointMake(80, 150);
    }
    [UIView commitAnimations];

  //  [self changebuttonImgWithButton:sameRealmBtn img:@"realm" durTime:0.2 delay:1.4];
;

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
        }else if (i<(KISHighVersion_7?130:110))
        {
            moGirlBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?130:110);
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
            
        }else if (i<(KISHighVersion_7?130:110))
        {
            encoBtn.center = CGPointMake([centerArray[0]floatValue],KISHighVersion_7?130:110);

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
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(manDic, @"id")]isEqualToString:@""]||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(manDic, @"id")]isEqualToString:@" "]) {
        [self showAlertViewWithTitle:@"提示" message:@"请先选择游戏" buttonTitle:@"确定"];
        return;
    }

    NSLog(@"------%@------",manDic);
    
    NSLog(@"点击");
    if (sender ==encoBtn) {  //许愿
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        EncoXHViewController *enco = [[EncoXHViewController alloc]init];
        [self.navigationController pushViewController:enco animated:YES];
        
    }
    if (sender ==moGirlBtn) {
        NSLog(@"魔女榜");
        [[Custom_tabbar showTabBar] hideTabBar:YES];
        MagicGirlViewController *maVC = [[MagicGirlViewController alloc]init];
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
    circleVC.userId =[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    [self.navigationController pushViewController:circleVC animated:YES];
    //清除红点
    m_notibgInfoImageView.hidden = YES;
    m_notibgCircleNewsImageView.hidden = YES;
    friendDunamicmsgCount =0;
    myDunamicmsgCount =0;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dongtaicount_wx"];
    commentLabel.text = @"暂无新的动态";
    //清除tabbar红点 以前是上面方法 综合发现和我的动态通知
    [[Custom_tabbar showTabBar]removeNotificatonOfIndex:2];
    

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
                //imagePicker.allowsEditing = YES;
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
                //imagePicker.allowsEditing = YES;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                //                [self presentModalViewController:imagePicker animated:YES];
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
//    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    UIImage*selectImage = [info objectForKey:UIImagePickerControllerOriginalImage];

    imgV.image = selectImage;
    NSData *data = UIImageJPEGRepresentation(selectImage, 0.7);
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"bgImgForFinder_wx"];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(void)didClickGameIdWithView:(TvView *)myView
{
    bottomView.hidden =YES;
    
    [self didClickMenu:nil];

}
-(void)didClickGameIdSuccessWithView:(TvView *)myView section:(NSInteger)section row:(NSInteger)row
{
    [self didClickMenu:nil];
    bottomView.hidden = NO;
    [self.view sendSubviewToBack:drawView];
    [self.view sendSubviewToBack:imgV];
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    
    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];

    NSArray *allkeys = [dict allKeys];
    manDic = [[dict objectForKey:allkeys[section]]objectAtIndex:row];
    NSLog(@"manDic--%@",manDic);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
