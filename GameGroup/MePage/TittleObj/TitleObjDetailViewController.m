//
//  TitleObjDetailViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-26.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "TitleObjDetailViewController.h"
#import "TitleObjUpView.h"
//#import "TestViewController.h"
#import "SendNewsViewController.h"
#import "ShareToOther.h"
#define degreesToRadians(x) (M_PI*(x)/180.0)//弧度

#define kSegmentFriend (0)
#define kSegmentRealm (1)
#define kSegmentCountry (2)

@interface TitleObjDetailViewController ()
{
//    UIView*        topView;
    UIButton*      m_backButton;
    UIButton*      m_shareButton;
    
    UIScrollView*  upScroll;
    UIScrollView*  downScroll;
    
    UIPageControl*  pageControl;
    
    UIButton*       sortButton;

    UIButton*       m_friendButton;
    UIButton*       m_realmButton;
    UIButton*       m_countryButton;
    
    NSInteger       m_segmentClickIndex;
    
    UILabel*        m_sortTypeLabel;
    
    NSInteger       m_lastPageIndex;
    NSInteger       m_begainPageIndex;
    NSInteger       m_tableShowIndex;
    
    UITableView*    m_sortTableView;
    NSMutableArray* m_sortDataArray;
    
//    PullUpRefreshView      *refreshView;
//    PullDownRefreshView    *pullDownView;
    
    BOOL            isGetForData;//获取前面的数据
    
    BOOL            isShowSend;//是否提示发布成功
    
    UIView*         bgView;//action出来时另外半边
    
    UIView*         m_warnView;//发表成功提示语
}
@end

@implementation TitleObjDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
    if (isShowSend)
    {
//        [self showMessageWithContent:@"发表成功" point:CGPointMake(kScreenHeigth/2, kScreenWidth - 50)];
        [self showWarnView];
        isShowSend = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.transform = CGAffineTransformIdentity;
    self.view.transform = CGAffineTransformMakeRotation(degreesToRadians(-90));
//    self.view.bounds = CGRectMake(0.0, 0.0, kScreenWidth, kScreenHeigth);
//    self.view.frame = CGRectMake(0.0, 0.0, kScreenHeigth, kScreenWidth);
    NSLog(@"haizai %@=%@=%f,%f",NSStringFromCGRect(self.view.frame),
          NSStringFromCGRect(self.view.bounds),kScreenWidth,kScreenHeigth);
    
    upScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenHeigth, kScreenWidth)];
    upScroll.backgroundColor = [UIColor grayColor];
    upScroll.scrollEnabled = YES;
    upScroll.delegate = self;
    upScroll.bounces = NO;
    upScroll.pagingEnabled = YES;
    upScroll.showsHorizontalScrollIndicator = NO;
    upScroll.contentSize = CGSizeMake(kScreenHeigth * [self.titleObjArray count], kScreenWidth);
    upScroll.contentOffset = CGPointMake(kScreenHeigth * self.showIndex, 0);
    [self.view addSubview:upScroll];
//
//    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
//    tapGesture.delegate = self;
//    [upScroll addGestureRecognizer:tapGesture];
//    
    downScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, kScreenWidth, kScreenHeigth, kScreenWidth)];
    downScroll.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downScroll];
    
//    UITapGestureRecognizer * tapGesture_dowm = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
//    tapGesture_dowm.delegate = self;
//    [downScroll addGestureRecognizer:tapGesture_dowm];
    
    m_segmentClickIndex = kSegmentFriend;
    
    [self setTopView];
    [self setUpView];
   // [self setDownView];
   // [self setTableTopView];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    hud.labelText = @"查询中...";
}

- (void)showWarnView
{
    if (m_warnView != nil) {
        [m_warnView removeFromSuperview];
    }
    m_warnView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 120, 100)];
    m_warnView.center = CGPointMake(kScreenHeigth/2, kScreenWidth/2);
    m_warnView.backgroundColor = [UIColor blackColor];
    m_warnView.layer.cornerRadius = 5;
    m_warnView.layer.masksToBounds = YES;
    m_warnView.alpha = 0.7;
    [self.view addSubview:m_warnView];
    
    UIImageView* warnImage = [[UIImageView alloc] initWithFrame:CGRectMake(95.0/2, 25, 25, 25)];
    warnImage.backgroundColor = [UIColor clearColor];
    [m_warnView addSubview:warnImage];
    warnImage.image = KUIImage(@"show_success");

    UILabel* showLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 50, 120, 25)];
    showLabel.backgroundColor = [UIColor clearColor];
    showLabel.font = [UIFont boldSystemFontOfSize:15.0];
    showLabel.textColor = [UIColor whiteColor];
    showLabel.textAlignment = NSTextAlignmentCenter;
    showLabel.text = @"发表成功";
    [m_warnView addSubview:showLabel];
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideView) object:nil];//取消该方法的调用
    [self performSelector:@selector(hideView) withObject:nil afterDelay:2.0f];
}

- (void)hideView
{
    m_warnView.frame = CGRectZero;
}

- (void)setTopView
{
//    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenHeigth, 44)];
////    topView.backgroundColor = kColorWithRGB(23, 161, 240, 1.0);
//    topView.backgroundColor = [UIColor clearColor];
//    topView.alpha = 0.8;
//    [self.view addSubview:topView];
    
//    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, kScreenHeigth - 100, 44)];
//    titleLabel.textColor = [UIColor whiteColor];
//    titleLabel.backgroundColor = [UIColor clearColor];
//    titleLabel.text = @"头衔详情";
//    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.font = [UIFont boldSystemFontOfSize:20];
//    [topView addSubview:titleLabel];
    
    m_backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 44)];
    [m_backButton setBackgroundImage:KUIImage(@"back") forState:UIControlStateNormal];
   // [m_backButton setBackgroundImage:KUIImage(@"back_click") forState:UIControlStateHighlighted];
    m_backButton.backgroundColor = [UIColor clearColor];
    [m_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:m_backButton];
    
    m_shareButton =[UIButton buttonWithType:UIButtonTypeCustom];
    m_shareButton.frame=CGRectMake(kScreenHeigth - 50, 0, 50, 44);
    [m_shareButton setBackgroundImage:KUIImage(@"share_touxian_normal") forState:UIControlStateNormal];
    [m_shareButton setBackgroundImage:KUIImage(@"share_touxian_click") forState:UIControlStateHighlighted];
    [self.view addSubview:m_shareButton];
    [m_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backButtonClick:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark 分享
- (void)shareButtonClick:(id)sender
{
    if (bgView != nil) {
        [bgView removeFromSuperview];
    }
    bgView = [[UIView alloc] init];
    bgView.frame = CGRectMake(328, 0, kScreenHeigth-320, kScreenWidth);
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4;
    [self.view addSubview:bgView];
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"分享到"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:Nil
                                  otherButtonTitles:@"我的动态",@"新浪微博",@"微信好友",@"微信朋友圈", nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.backgroundColor = [UIColor clearColor];
    [actionSheet showInView:self.view];
    
//    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"分享到我的动态", nil];
//    [alert show];
    
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{

    UIGraphicsBeginImageContext(CGSizeMake(kScreenHeigth, kScreenWidth));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    sortButton.hidden = YES;

    if (buttonIndex ==0) {
        pageControl.hidden = YES;
        m_backButton.hidden = YES;
        m_shareButton.hidden = YES;

        [self performSelector:@selector(pushSendNews) withObject:nil afterDelay:1.0];
    }
    else if (buttonIndex ==1)
    {
        
        [[ShareToOther singleton]shareTosina:viewImage];
    }
    else if(buttonIndex ==2)
    {
        [[ShareToOther singleton]changeScene:WXSceneSession];
        
        [[ShareToOther singleton] sendImageContentWithImage:viewImage];
    }
    else if(buttonIndex ==3)
    {
        [[ShareToOther singleton] changeScene:WXSceneTimeline];
        
        [[ShareToOther singleton] sendImageContentWithImage:viewImage];
    }

    if (bgView != nil) {
        [bgView removeFromSuperview];
    }
}

- (void)pushSendNews
{
    UIGraphicsBeginImageContext(CGSizeMake(kScreenHeigth, kScreenWidth));
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSDictionary* tempDic = [self.titleObjArray objectAtIndex:self.showIndex];
    NSDictionary* tempDic_small = KISDictionaryHaveKey([self.titleObjArray objectAtIndex:self.showIndex], @"titleObj");
    sortButton.hidden = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic_small, @"rank")] isEqualToString:@"1"] ? NO : YES;

    pageControl.hidden = NO;
    m_backButton.hidden = NO;
    m_shareButton.hidden = NO;
    if (self.isFriendTitle) {
        pageControl.hidden = YES;
    }
    SendNewsViewController* VC = [[SendNewsViewController alloc] init];
    VC.titleImage = viewImage;
    VC.delegate = self;
    VC.isComeFromMe = NO;
    if(upScroll.center.y < 0)
    {
        VC.defaultContent = [NSString stringWithFormat:@"分享%@的%@排名", KISDictionaryHaveKey(tempDic, @"charactername"), KISDictionaryHaveKey(tempDic_small, @"titletype")];
    }
    else
    {
        VC.defaultContent = [NSString stringWithFormat:@"分享%@的头衔：%@", KISDictionaryHaveKey(tempDic, @"charactername"), KISDictionaryHaveKey(tempDic_small, @"title")];
    }
    [self.navigationController pushViewController:VC animated:NO];
}

- (void)setUpView
{
    for (int i = 0; i < [self.titleObjArray count]; i++) {
        NSDictionary* tempDic = [self.titleObjArray objectAtIndex:i];
        TitleObjUpView* oneView = [[TitleObjUpView alloc] initWithFrame:CGRectMake(kScreenHeigth * i, 0, kScreenHeigth, kScreenWidth)];
        NSDictionary* titleDic = KISDictionaryHaveKey(tempDic, @"titleObj");
        if (![titleDic isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        oneView.rightImageId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleDic, @"img")];
        oneView.gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleDic, @"gameid")];
        oneView.rarenum= [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleDic, @"rarenum")];//稀有度
        oneView.titleName= KISDictionaryHaveKey(titleDic, @"title");
        oneView.characterName= KISDictionaryHaveKey(tempDic, @"charactername");
        oneView.remark= KISDictionaryHaveKey(titleDic, @"remark");

        oneView.rarememo= KISDictionaryHaveKey(titleDic, @"rarememo");//%

        oneView.detailDis= KISDictionaryHaveKey(titleDic, @"remarkDetail");//查看详情内容

        [oneView setMainView];
        [upScroll addSubview:oneView];
    }
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];
    pageControl.center = CGPointMake(upScroll.contentOffset.x + kScreenHeigth/2, kScreenWidth - 30);
    pageControl.numberOfPages = [self.titleObjArray count];
    pageControl.currentPage = self.showIndex;
    [upScroll addSubview:pageControl];
    
    [upScroll addSubview:sortButton];
    
    
    if (self.isFriendTitle) {
        pageControl.hidden = YES;
    }
}

#pragma mark scrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == upScroll) {
        CGPoint offsetofScrollView = scrollView.contentOffset;

        NSInteger page = offsetofScrollView.x / upScroll.frame.size.width;
       
        self.showIndex = page;
       
        [pageControl setCurrentPage:page];
        
        CGRect rect = CGRectMake(page * upScroll.frame.size.width, 0,
                                 upScroll.frame.size.width, upScroll.frame.size.height);
        [upScroll scrollRectToVisible:rect animated:YES];
        
        NSDictionary* tempDic = KISDictionaryHaveKey([self.titleObjArray objectAtIndex:page], @"titleObj");
        sortButton.hidden = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"rank")] isEqualToString:@"1"] ? NO : YES;
        if (!sortButton.hidden) {
            sortButton.center = CGPointMake(upScroll.contentOffset.x + kScreenHeigth - 65/2, kScreenWidth - 40);
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(scrollView == upScroll)
    {
        pageControl.center = CGPointMake(upScroll.contentOffset.x + kScreenHeigth/2, kScreenWidth - 30);
    }
}
@end
