//
//  OnceDynamicViewController.m
//  GameGroup
//
//  Created by Shen Yanping on 14-1-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "OnceDynamicViewController.h"
#import "EGOImageButton.h"
#import "PhotoViewController.h"
#import "ReplyViewController.h"
#import "MyProfileViewController.h"
#import "TestViewController.h"
#import "EGOImageView.h"
#import "AppDelegate.h"
#import "JSON.h"
#import "ShareToOther.h"
@interface OnceDynamicViewController ()
{
    UIButton *m_shareButton;
    
//    UIView* inPutView;
//    UIButton* inputButton;
    UILabel* commentLabel;
    NSInteger  allPL;//总评论数
    
    double  webViewHeight;
    
    UIView* m_shareViewBg;
    UIView* m_shareView;
    
    NSInteger shareType;//0为好友 1为广播
    UILabel*  sharePeopleLabel;
    
    UIWebView* mWebView;
    
    UIImageView* bg1;
    EGOImageButton* headBtn1;
    UILabel* nickLabel1;
    UILabel* titleLabel1;
    UILabel* titleLabel_no1;
    UIButton* zanButton1;
    UILabel *commentLabel12;
    UILabel* line1;
    UIButton* inputButton1;
    UIButton* reportButton1;
    UIImageView *imageView1;
    NSString *m_msg;
    
   NSString * m_userid;
    AppDelegate *app;
    
    NSInteger m_zannum;
}
@property(nonatomic, strong)NSDictionary* dataDic;
@property(nonatomic, strong)NSArray*      headImgArray;
//@property (strong,nonatomic) HPGrowingTextView *textView;
@property (nonatomic, strong)NSDictionary* shareUserDic;
@end

@implementation OnceDynamicViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:Nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:Nil];

    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setTopViewWithTitle:@"详情" withBackButton:YES];
    
    m_shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_shareButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [m_shareButton setBackgroundImage:KUIImage(@"share_normal") forState:UIControlStateNormal];
    [m_shareButton setBackgroundImage:KUIImage(@"share_click") forState:UIControlStateHighlighted];
    [self.view addSubview:m_shareButton];
    [m_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
     m_shareButton.hidden = YES;

    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self getDataByNet];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAck:)name:kMessageAck object:nil];
}


//- (void)setUpViewBeforeLoading
//{
//    bg1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, + startX, kScreenWidth, 60)];
//    bg1.image = KUIImage(@"detail_top_bg");
//    [self.view addSubview:bg1];
//    
//    headBtn1 = [[EGOImageButton alloc] initWithFrame:CGRectMake(10, 10 + startX, 40, 40)];
//    headBtn1.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
//    headBtn1.imageURL = [NSURL URLWithString:self.imgStr];
//    headBtn1.layer.cornerRadius = 5;
//    headBtn1.layer.masksToBounds=YES;
//    [self.view addSubview:headBtn1];
//    
//    nickLabel1 = [CommonControlOrView setLabelWithFrame:CGRectMake(60, 8+ startX, 180, 20) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:15.0] text:self.nickNameStr textAlignment:NSTextAlignmentLeft];
//    [self.view addSubview:nickLabel1];
//    
//    NSDictionary* titleDic = KISDictionaryHaveKey(self.dataDic, @"titleObj");
//    if ([titleDic isKindOfClass:[NSDictionary class]]) {
//        titleLabel1 = [CommonControlOrView setLabelWithFrame:CGRectMake(60, 33+ startX, 180, 20) textColor:[UIColor whiteColor] font:[UIFont boldSystemFontOfSize:14.0] text:@"22222" textAlignment:NSTextAlignmentLeft];
//        [self.view addSubview:titleLabel1];
//    }
//    else
//    {
//        titleLabel_no1 = [CommonControlOrView setLabelWithFrame:CGRectMake(60, 33+ startX, 150, 20) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:13.0] text:@"暂无头衔" textAlignment:NSTextAlignmentLeft];
//        [self.view addSubview:titleLabel_no1];
//    }
//    
//    zanButton1 = [[UIButton alloc] initWithFrame:CGRectMake(230, 15+ startX, 76, 30)];
//    [zanButton1 setBackgroundImage:KUIImage(@"zan_normal") forState:UIControlStateNormal];
//    [zanButton1 setBackgroundImage:KUIImage(@"zan_click") forState:UIControlStateSelected];
//    [zanButton1 setTitle:self.zanStr forState:UIControlStateNormal];
//    if ([[GameCommon getNewStringWithId:self.zanStr] isEqualToString:@"1"]) {
//        [zanButton1 setTitleColor:kColorWithRGB(204, 204, 204, 1.0) forState:UIControlStateNormal];
//        zanButton1.selected = YES;
//        [zanButton1 setBackgroundImage:KUIImage(@"zan_hig_1") forState:UIControlStateHighlighted];
//    }
//    else
//    {
//        [zanButton1 setTitleColor:kColorWithRGB(153, 153, 153, 1.0) forState:UIControlStateNormal];
//        [zanButton1 setBackgroundImage:KUIImage(@"zan_hig_2") forState:UIControlStateHighlighted];
//        zanButton1.selected = NO;
//    }
//    zanButton1.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
//    zanButton1.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//    [self.view addSubview:zanButton1];
//    
//   imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, 320, 40)];
//    imageView1.image = KUIImage(@"inputbg.png");
//    imageView1.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:imageView1];
//    
//    reportButton1 = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, 159, 40)];
//    [reportButton1 setImage:KUIImage(@"news_report") forState:UIControlStateNormal];
//    reportButton1.imageEdgeInsets = UIEdgeInsetsMake(15.0/2, 34, 15.2/2, 100);
//    reportButton1.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 34);
//    [reportButton1 setTitle:@"举报投诉" forState:UIControlStateNormal];
//    reportButton1.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
//    [reportButton1 setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
//    [self.view addSubview:reportButton1];
//    
//    line1= [[UILabel alloc] initWithFrame:CGRectMake(160, self.view.frame.size.height-30, 1, 20)];
//    line1.backgroundColor = kColorWithRGB(200, 200, 200, 1.0);
//    [self.view addSubview:line1];
//    
//    inputButton1 = [[UIButton alloc] initWithFrame:CGRectMake(161, self.view.frame.size.height-40, 159, 40)];
//    [inputButton1 setImage:KUIImage(@"news_comment") forState:UIControlStateNormal];
//    inputButton1.imageEdgeInsets = UIEdgeInsetsMake(15.0/2, 34, 15.2/2, 100);
//    [self.view addSubview:inputButton1];
//    
//    commentLabel12 = [[UILabel alloc] initWithFrame:CGRectMake(225, self.view.frame.size.height-40, 85, 40)];
//    commentLabel12.textAlignment = NSTextAlignmentLeft;
//    commentLabel12.textColor = kColorWithRGB(102, 102, 102, 1.0);
//    commentLabel12.font = [UIFont boldSystemFontOfSize:12.0];
//    commentLabel12.text = [NSString stringWithFormat:@"评论 %d", allPL];
//    commentLabel12.backgroundColor = [UIColor clearColor];
//    [self.view addSubview:commentLabel12];
//}




- (void)getDataByNet
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:self.messageid forKey:@"messageid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"136" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    hud.labelText = @"加载中...";

    [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.dataDic = responseObject;
            
            m_userid = KISDictionaryHaveKey(responseObject, @"userid");
            
            m_msg = KISDictionaryHaveKey(responseObject, @"msg");
            m_shareButton.hidden = [KISDictionaryHaveKey(responseObject, @"type") integerValue] == 3 ? NO : YES;
            self.urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"urlLink")];
            
            allPL = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"commentnum")] integerValue];
            
            self.messageid = KISDictionaryHaveKey(responseObject, @"id");
            
            self.headImgArray = [ImageService getImageIds:KISDictionaryHaveKey(responseObject, @"img")];
            [self setUpView];
            [self setButtomView];
            
            [self.view bringSubviewToFront:hud];
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

- (void)setUpView
{

    
    UIImageView* bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, + startX, kScreenWidth, 60)];
    bg.image = KUIImage(@"detail_top_bg");
    [self.view addSubview:bg];
    
    EGOImageButton* headBtn = [[EGOImageButton alloc] initWithFrame:CGRectMake(10, 10 + startX, 40, 40)];
    headBtn.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
    
    NSString * imageIds=KISDictionaryHaveKey(self.dataDic, @"userimg");
    headBtn.imageURL = [ImageService getImageStr2:imageIds];
    
    headBtn.layer.cornerRadius = 5;
    headBtn.layer.masksToBounds=YES;
    [headBtn addTarget:self action:@selector(heardImgClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:headBtn];
    
    UILabel* nickLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(60, 8+ startX, 180, 20) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:15.0] text:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"alias")] isEqualToString:@""]?KISDictionaryHaveKey(self.dataDic, @"nickname"):KISDictionaryHaveKey(self.dataDic, @"alias") textAlignment:NSTextAlignmentLeft];
    [self.view addSubview:nickLabel];
    
    NSDictionary* titleDic = KISDictionaryHaveKey(self.dataDic, @"titleObj");
    if ([titleDic isKindOfClass:[NSDictionary class]]) {
        UILabel* titleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(60, 33+ startX, 180, 20) textColor:[GameCommon getAchievementColorWithLevel:[[KISDictionaryHaveKey(titleDic, @"titleObj") objectForKey:@"rarenum"] integerValue]] font:[UIFont boldSystemFontOfSize:14.0] text:[KISDictionaryHaveKey(titleDic, @"titleObj") objectForKey:@"title"] textAlignment:NSTextAlignmentLeft];
        [self.view addSubview:titleLabel];
    }
    else
    {
        UILabel* titleLabel_no = [CommonControlOrView setLabelWithFrame:CGRectMake(60, 33+ startX, 150, 20) textColor:[UIColor blackColor] font:[UIFont boldSystemFontOfSize:13.0] text:@"暂无头衔" textAlignment:NSTextAlignmentLeft];
        [self.view addSubview:titleLabel_no];
    }
    
    UIButton* zanButton = [[UIButton alloc] initWithFrame:CGRectMake(230, 15+ startX, 76, 30)];
    [zanButton setBackgroundImage:KUIImage(@"zan_normal") forState:UIControlStateNormal];
    [zanButton setBackgroundImage:KUIImage(@"zan_click") forState:UIControlStateSelected];
    [zanButton setTitle:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"zannum")] forState:UIControlStateNormal];
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"zan")] isEqualToString:@"1"]) {
        [zanButton setTitleColor:kColorWithRGB(204, 204, 204, 1.0) forState:UIControlStateNormal];
        zanButton.selected = YES;
        [zanButton setBackgroundImage:KUIImage(@"zan_hig_1") forState:UIControlStateHighlighted];
    }
    else
    {
        [zanButton setTitleColor:kColorWithRGB(153, 153, 153, 1.0) forState:UIControlStateNormal];
        [zanButton setBackgroundImage:KUIImage(@"zan_hig_2") forState:UIControlStateHighlighted];
        zanButton.selected = NO;
    }
    zanButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    zanButton.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
    [zanButton addTarget:self action:@selector(zanButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zanButton];
}

- (void)heardImgClick:(id)sender
{
//    if ([KISDictionaryHaveKey(self.dataDic, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
//        MyProfileViewController * myP = [[MyProfileViewController alloc] init];
//        [self.navigationController pushViewController:myP animated:YES];
//    }
//    else
//    {
        TestViewController* detailV = [[TestViewController alloc] init];
        detailV.userId = KISDictionaryHaveKey(self.dataDic, @"userid");
        detailV.nickName = KISDictionaryHaveKey(self.dataDic, @"nickname");
        detailV.isChatPage = NO;
        [self.navigationController pushViewController:detailV animated:YES];
//    }
}

#pragma mark button
- (void)zanButtonClick:(id)sender
{
    NSLog(@"我要赞啦～～～～");
    if ([KISDictionaryHaveKey(self.dataDic, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
        [self showAlertViewWithTitle:@"提示" message:@"您不能对自己进行赞" buttonTitle:@"确定"];
        return;
    }
    UIButton* zanBtn = (UIButton*)sender;
    
    zanBtn.userInteractionEnabled = NO;
    
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    hud.labelText = nil;
    [hud show:YES];
//    [paramDict setObject:@"4" forKey:@"type"];
    [paramDict setObject:self.messageid forKey:@"messageId"];
 //   [paramDict setObject:@"mydynamicmsg" forKey:@"msgtype"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"185" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        zanBtn.userInteractionEnabled = YES;

        zanBtn.selected = !zanBtn.selected;
        m_zannum =  [[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"zannum")]intValue];

        if(zanBtn.selected)
        {
            [hud hide:YES];
            m_zannum-=1;
            [zanBtn setTitle:[NSString stringWithFormat:@"%d",m_zannum] forState:UIControlStateNormal];

            [zanBtn setBackgroundImage:KUIImage(@"zan_hig_1") forState:UIControlStateHighlighted];
            [self showMessageWindowWithContent:@"已赞" imageType:5];
        }
        else
        {
            [hud hide:YES];
            m_zannum-=1;
            [zanBtn setBackgroundImage:KUIImage(@"zan_hig_2") forState:UIControlStateHighlighted];
            [zanBtn setTitle:[NSString stringWithFormat:@"%d",m_zannum] forState:UIControlStateNormal];
            [self showMessageWindowWithContent:@"取消赞" imageType:6];
        }
    
//        double allZan = [KISDictionaryHaveKey(responseObject, @"zannum") doubleValue];
//        [zanBtn setTitle:[NSString stringWithFormat:@"%.f", allZan] forState:UIControlStateNormal];
       // if (self.delegate&&[self.delegate respondsToSelector:@selector(dynamicListJustReload)])
          //  [self.delegate dynamicListJustReload];//上个页面刷新
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [hud hide:YES];

        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        zanBtn.userInteractionEnabled = YES;
    }];

}

#pragma mark ---点击webview 获取图片
- (NSString *)createJavaScript{
    NSString *js = @"var imgArray = document.getElementsByTagName('img');for(var i = 0; i < imgArray.length; i++){var img = imgArray[i];img.onclick=function(){var url='lfyprotocol:'+this.src;document.location = url;}}";
    return js;
}





#pragma mark html

- (NSString*)htmlContentWithTitle:(NSString*)title time:(NSString*)time content:(NSString*)content
{//;width:100%%;height:100%%<div style=\"background-color:#f7f7f7\">
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    NSString* str = [NSString stringWithFormat:@"<body bgcolor=\"#f7f7f7\"><font size=\"3\" color=\"#444444\"><center><b>%@</b></center></font><p align=\"right\"><font size=\"3\" color=\"#444444\">%@</font></p><p><font size=\"3\" color=\"#444444\" style=\"line-height:25px\">%@</font></p></body>", title, time, content];
    return str;
}

- (NSString*)imageHtmlWithId:(NSString*)imageid
{
//    if ([GameCommon isPureInt:imageid]) {
//        [NSString stringWithFormat:@"<a href=\"myimage:%@\"><img src=\"%@%@\" width=\"305\"></img></a>", imageid,[ImageService getImageUrl4:imageid],@"/305"];
//    }
    return [NSString stringWithFormat:@"<a href=\"myimage:%@\"><img src=\"%@%@\" width=\"305\"></img></a>", imageid,[ImageService getImageUrl4:imageid],@"?imageView2/2/w/305"];
}

- (void)setButtomView
{
    if ([self.urlLink isEqualToString:@""]) {   //如果是动态
        NSString* loadStr = [self htmlContentWithTitle:KISDictionaryHaveKey(self.dataDic, @"title") time:[NSString stringWithFormat:@"%@", [self getDataWithTime]] content:KISDictionaryHaveKey(self.dataDic, @"msg")];
        

        
        
        for(int i = 0; i < [self.headImgArray count]; i++)
        {
            loadStr = [loadStr stringByAppendingString:[self imageHtmlWithId:[self.headImgArray objectAtIndex:i]]];
        }
        
        UIWebView* contentView = [[UIWebView alloc] initWithFrame:CGRectMake(0, startX + 60, kScreenWidth, kScreenHeigth - 40 - startX - 60-(KISHighVersion_7?0:20))];
        contentView.scalesPageToFit = NO;
        contentView.dataDetectorTypes = UIDataDetectorTypePhoneNumber | UIDataDetectorTypeLink;
//        contentView.dataDetectorTypes = UIDataDetectorTypeAll;
//        contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        contentView.delegate = self;
        loadStr = [UILabel getStr:loadStr];
        [contentView loadHTMLString:loadStr baseURL:nil];
        UIScrollView *scroller = [contentView.subviews objectAtIndex:0];//去掉阴影
        if (scroller) {
            for (UIView *v in [scroller subviews]) {
                if ([v isKindOfClass:[UIImageView class]]) {
                    [v removeFromSuperview];
                }
            }
        }
        [self.view addSubview:contentView];

    }
    else    //如果是网页
    {
        mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, startX + 60, kScreenWidth, kScreenHeigth - 40 - startX - 60-(KISHighVersion_7?0:20))];
//        mWebView.scalesPageToFit = YES;
        mWebView.delegate = self;
        NSURL *requestUrl = [NSURL URLWithString:self.urlLink];
        NSURLRequest *request = [NSURLRequest requestWithURL:requestUrl];
        [mWebView loadRequest:request];
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
        tapGesture.delegate = self;
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        [mWebView addGestureRecognizer:tapGesture];
        
        [self.view addSubview:mWebView];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, 320, 40)];
    imageView.image = KUIImage(@"inputbg.png");
    imageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:imageView];
    
    UIButton* reportButton = [[UIButton alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-40, 159, 40)];
    [reportButton setImage:KUIImage(@"news_report") forState:UIControlStateNormal];
    reportButton.imageEdgeInsets = UIEdgeInsetsMake(15.0/2, 34, 15.2/2, 100);
    reportButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 34);
    if ([m_userid intValue]==[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]intValue ]) {
        [reportButton setTitle:@"删除动态" forState:UIControlStateNormal];
    }else{
        [reportButton setTitle:@"举报投诉" forState:UIControlStateNormal];
    }
    reportButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
    [reportButton setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
    [reportButton addTarget:self action:@selector(reportButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:reportButton];
    
    UILabel* line = [[UILabel alloc] initWithFrame:CGRectMake(160, self.view.frame.size.height-30, 1, 20)];
    line.backgroundColor = kColorWithRGB(200, 200, 200, 1.0);
    [self.view addSubview:line];

    UIButton* inputButton = [[UIButton alloc] initWithFrame:CGRectMake(161, self.view.frame.size.height-40, 159, 40)];
    [inputButton setImage:KUIImage(@"news_comment") forState:UIControlStateNormal];
    inputButton.imageEdgeInsets = UIEdgeInsetsMake(15.0/2, 34, 15.2/2, 100);
//    inputButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 34);
//    inputButton.titleLabel.textAlignment = NSTextAlignmentLeft;
//    [inputButton setTitle:[NSString stringWithFormat:@"评论 %d", allPL] forState:UIControlStateNormal];
//    inputButton.titleLabel.font = [UIFont boldSystemFontOfSize:12.0];
//    [inputButton setTitleColor:kColorWithRGB(102, 102, 102, 1.0) forState:UIControlStateNormal];
    [inputButton addTarget:self action:@selector(okButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:inputButton];
    
    commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(225, self.view.frame.size.height-40, 85, 40)];
    commentLabel.textAlignment = NSTextAlignmentLeft;
    commentLabel.textColor = kColorWithRGB(102, 102, 102, 1.0);
    commentLabel.font = [UIFont boldSystemFontOfSize:12.0];
    commentLabel.text = [NSString stringWithFormat:@"评论 %d", allPL];
    commentLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:commentLabel];
}

- (void)imageClick:(UIButton*)imageButton
{
    PhotoViewController * photoV = [[PhotoViewController alloc]
                                    initWithSmallImages:nil
                                    images:self.headImgArray
                                    indext:imageButton.tag];
    [self presentViewController:photoV animated:NO completion:^{
        
    }];
}

#pragma mark 手势
- (void)tapClick:(id)sender
{
    //[self.textView resignFirstResponder];
    NSLog(@"点击啊 点击");
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}

#pragma mark 详情
- (NSString*)getDataWithTime
{
    NSString* messageTime = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"createDate")];
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    NSString * finalTime;
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString *currentStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    NSDateFormatter *dateFormatter2 = [[NSDateFormatter alloc] init];
    [dateFormatter2 setDateFormat:@"HH:mm"];
    NSString * msgT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    NSString * nowT = [dateFormatter2 stringFromDate:[NSDate dateWithTimeIntervalSince1970:theCurrentT]];
    
    int hours = [[nowT substringToIndex:2] intValue];
    int minutes = [[nowT substringFromIndex:3] intValue];
    
    int currentDayBegin = theCurrentT-hours*3600-minutes*60;
    int yesterdayBegin = currentDayBegin-3600*24;
    
    //今天
    if ([currentStr isEqualToString:messageDateStr]) {
        finalTime = [NSString stringWithFormat:@"%@",msgT];
    }
    //昨天
    else if(theMessageT>=yesterdayBegin&&theMessageT<currentDayBegin){
        finalTime = [NSString stringWithFormat:@"昨天 %@",msgT];
    }
    //今年
    else if([[messageDateStr substringToIndex:4] isEqualToString:[currentStr substringToIndex:4]]){
        finalTime = [NSString stringWithFormat:@"%@月%@日 %@",[[messageDateStr substringFromIndex:5] substringToIndex:2],[messageDateStr substringFromIndex:8], msgT];
    }
    else
        finalTime = [NSString stringWithFormat:@"%@年%@月%@日 %@",[[messageDateStr substringFromIndex:0] substringToIndex:4] ,[[messageDateStr substringFromIndex:5] substringToIndex:2],[messageDateStr substringFromIndex:8], msgT];
    return finalTime;
}

#pragma mark 分享
- (void)shareButtonClick:(id)sender
{
    
    UIActionSheet* actionSheet = [[UIActionSheet alloc]initWithTitle:@"分享到" delegate:self cancelButtonTitle:@"取消"destructiveButtonTitle:Nil
                                  otherButtonTitles:@"好友",@"新浪微博",@"QQ",@"微信朋友圈",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 90) {
        switch (buttonIndex) {
            case 0:
            {
                shareType = 0;
                selectContactPage *VC = [[selectContactPage alloc] init];
                VC.contactDelegate = self;
                VC.contentDic = self.dataDic;
                [self.navigationController pushViewController:VC animated:YES];
            }  break;
            case 1:
            {
                shareType = 1;
                [self setShareView];
            }break;
            default:
                break;
        }
    }else{
        
       
         NSString * shareUrl = [self getShareUrl:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"id")]];
        
        if (buttonIndex ==0) {
            if ([KISDictionaryHaveKey([DataStoreManager queryMyInfo], @"superstar") doubleValue]) {
                UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"分享类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发送给好友",@"广播给粉丝及好友", nil];
                sheet.tag = 90;
                [sheet showInView:self.view];
            }
            else
            {
                shareType = 0;
                selectContactPage *VC = [[selectContactPage alloc] init];
                VC.contactDelegate = self;
                [self.navigationController pushViewController:VC animated:YES];
            }
        }
        else if (buttonIndex ==1)
        {//分享到微博
            NSString * title = KISDictionaryHaveKey(self.dataDic, @"title");
            if ([GameCommon isEmtity:title]) {
                title = KISDictionaryHaveKey(self.dataDic, @"msg");
            }else{
                title = [NSString stringWithFormat:@"《%@》",title];
            }
            
            if (title.length>100) {
//                [self showAlertViewWithTitle:@"提示" message:@"消息文本内容长度必须小于140个汉字" buttonTitle:@"确定"];
                title = [title substringToIndex:100];
                NSLog(@"%d",title.length);
//                return;
            }
            
            
            [[ShareToOther singleton]shareTosinass:[self getShareImageToSima] Title:title Description:_dataDic[@"msg"] Url:[self getShareUrl:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"id")]]];
        }
        else if(buttonIndex ==2)
        {//分享到QQ
            [[ShareToOther singleton]changeScene:WXSceneSession];
            NSString * title = KISDictionaryHaveKey(self.dataDic, @"title");
            if ([GameCommon isEmtity:title]) {
               title = [NSString stringWithFormat:@"分享自%@的动态",_dataDic[@"nickname"]];
            }
            if (title.length>100) {
                title = [title substringToIndex:100];
            }
            if ([GameCommon isEmtity:KISDictionaryHaveKey(self.dataDic, @"img")]) {
                NSData * data = [self getNSDataFromURL:@"icon"];
                [[ShareToOther singleton] onShareToQQ:title Description:_dataDic[@"msg"] Url:shareUrl previewImageData:data IsZone:NO];
            }else{
                [[ShareToOther singleton] onShareToQQ:title Description:_dataDic[@"msg"] Url:shareUrl previewImageURL:[ImageService getImageString:KISDictionaryHaveKey(self.dataDic, @"img")] IsZone:NO];
            }
//          [[ShareToOther singleton] sendAppExtendContent_friend:[self getShareImage] Title:title Description:_dataDic[@"msg"] Url:[self getShareUrl:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"id")]]];
        }
        else if(buttonIndex ==3)
        {//分享到微信
            NSString * title = KISDictionaryHaveKey(self.dataDic, @"title");
            if ([GameCommon isEmtity:title]) {
                title = _dataDic[@"msg"];
            }
            if (title.length>100) {
                title = [title substringToIndex:100];
            }
            [[ShareToOther singleton] changeScene:WXSceneTimeline];
            [[ShareToOther singleton] sendAppExtendContent_friend:[self getShareImage] Title:title Description:_dataDic[@"msg"] Url:[self getShareUrl:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"id")]]];
        }
    }
}

-(NSString*)getShareUrl:(NSString*)msgid
{
    return [NSString stringWithFormat:@"%@%@%@",BaseDynamicShareUrl,@"id=",msgid];
}

//请求网络图片
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

//请求网络图片
-(NSData *) getNSDataFromURL:(NSString *)imageName {
    return UIImageJPEGRepresentation(KUIImage(imageName),0.8);
}

-(UIImage*)getShareImageToSima
{
    NSString * imageUrl = [ImageService getImageString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"img")]];
    if (![GameCommon isEmtity:imageUrl]) {
        return [self getImageFromURL:imageUrl];
    }
    return nil;
}
-(UIImage*)getShareImage
{
    NSString * imageUrl = [ImageService getImageString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"img")]];
    if (![GameCommon isEmtity:imageUrl]) {
        return [self getImageFromURL:imageUrl];
    }
    return KUIImage(@"icon");
}

-(void)getContact:(NSDictionary *)userDict
{
    self.shareUserDic = userDict;//KISDictionaryHaveKey(userDict, @"userid");
    [self setShareView];
}

- (void)setShareView
{
    if (m_shareView == nil) {
        m_shareViewBg = [[UIView alloc] initWithFrame:self.view.frame];
        m_shareViewBg.backgroundColor = [UIColor blackColor];
        m_shareViewBg.alpha = 0.5;
        [self.view addSubview:m_shareViewBg];
        
        m_shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 170)];
        m_shareView.center = self.view.center;
        m_shareView.backgroundColor = [UIColor whiteColor];
        m_shareView.layer.cornerRadius = 3;
        m_shareView.layer.masksToBounds = YES;
        [self.view addSubview:m_shareView];
        
        CGSize titleSize = CGSizeZero;
        if ([GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"title")].length > 0) {
            titleSize = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"title")] sizeWithFont:[UIFont boldSystemFontOfSize:15.0] constrainedToSize:CGSizeMake(260, 40)];
        }
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 260, titleSize.height)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 2;
        titleLabel.text = KISDictionaryHaveKey(self.dataDic, @"title");
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [m_shareView addSubview:titleLabel];
        
        if ([GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"thumb")].length > 0 && ![[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"thumb")] isEqualToString:@"null"]) {
            EGOImageView* thumb = [[EGOImageView alloc] initWithFrame:CGRectMake(10, (titleSize.height > 0 ? titleSize.height : 10) + 15, 50, 50)];
            thumb.layer.cornerRadius = 5;
            thumb.layer.masksToBounds = YES;
            thumb.placeholderImage = KUIImage(@"have_picture");
            
            NSString * imageId=KISDictionaryHaveKey(self.dataDic, @"thumb");
            thumb.imageURL = [ImageService getImageUrl3:imageId Width:50];
            
            [m_shareView addSubview:thumb];
            
            CGSize contentSize = [KISDictionaryHaveKey(self.dataDic, @"msg") sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(200, 50)];
            UILabel* contentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(70, (titleSize.height > 0 ? titleSize.height : 10) + 15, 170, contentSize.height) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:KISDictionaryHaveKey(self.dataDic, @"msg") textAlignment:NSTextAlignmentLeft];
            contentLabel.numberOfLines = 0;
            [m_shareView addSubview:contentLabel];
        }
        else
        {
            CGSize contentSize = [KISDictionaryHaveKey(self.dataDic, @"msg") sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(260, 50)];

            UILabel* contentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(10, (titleSize.height > 0 ? titleSize.height : 10) + 15, 260, contentSize.height) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:KISDictionaryHaveKey(self.dataDic, @"msg") textAlignment:NSTextAlignmentLeft];
            contentLabel.numberOfLines = 0;
            [m_shareView addSubview:contentLabel];
        }
        if (shareType == 0) {
            sharePeopleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(15, 95, 250, 30) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont systemFontOfSize:13.0] text:[NSString stringWithFormat:@"分享给：%@", KISDictionaryHaveKey(self.shareUserDic, @"nickname")] textAlignment:NSTextAlignmentLeft];
        }
        else
        {
            sharePeopleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(15, 95, 250, 30) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont systemFontOfSize:13.0] text:@"分享给：好友及粉丝" textAlignment:NSTextAlignmentLeft];
        }
        [m_shareView addSubview:sharePeopleLabel];
        
        UIButton* cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 125, 120, 35)];
        [cancelBtn setBackgroundColor:kColorWithRGB(186, 186, 186, 1.0)];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [cancelBtn addTarget:self action:@selector(cancelShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_shareView addSubview:cancelBtn];
        
        UIButton* sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(145, 125, 120, 35)];
        [sendBtn setBackgroundColor:kColorWithRGB(35, 167, 211, 1.0)];
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(okShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [m_shareView addSubview:sendBtn];
    }
    else
    {
        m_shareViewBg.hidden = NO;
        m_shareView.hidden = NO;
        if (shareType == 0) {
            sharePeopleLabel.text = [NSString stringWithFormat:@"分享给：%@", KISDictionaryHaveKey(self.shareUserDic, @"nickname")];
        }
        else
        {
            sharePeopleLabel.text = @"分享给：好友及粉丝";
        }
    }
    
}

- (void)cancelShareClick:(id)sender
{
    m_shareViewBg.hidden = YES;
    m_shareView.hidden = YES;
}
- (void)okShareClick:(id)sender
{
    if (shareType == 0) {//好友
        [self sendToFriend];
    }else{//粉丝
        [self broadcastToFans];
    }
    m_shareViewBg.hidden = YES;
    m_shareView.hidden = YES;
}
//分享给好友
-(void)sendToFriend
{
    NSString *title = [NSString stringWithFormat:@"分享了%@的动态",_dataDic[@"nickname"]];
    NSXMLElement * payload = [NSXMLElement elementWithName:@"payload"];
    NSString *payloadStr = [MessageService createPayLoadStr:_dataDic[@"thumb"] title:title shiptype:@"1" messageid:_dataDic[@"id"] msg:_dataDic[@"msg"] type:@"3"];
    [payload setStringValue:payloadStr];
    
    NSString * nowTime = [GameCommon getCurrentTime];
    NSString * message = [NSString stringWithFormat:@"分享:%@的动态",_dataDic[@"nickname"]];
    NSString * fromUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * domain = [[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN];
    NSString * from = [fromUserId stringByAppendingString:domain];
    NSString * toUserid = KISDictionaryHaveKey(self.shareUserDic, @"userid");
    NSString * to = [toUserid stringByAppendingString:domain];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    
    NSXMLElement *mes =[MessageService createMes:nowTime Message:message UUid:uuid From:from To:to FileType:@"text" MsgType:@"normalchat" Type:@"chat"];
    [mes addChild:payload];
    
    //发送消息
    if ([((AppDelegate*)[[UIApplication sharedApplication] delegate]).xmppHelper sendMessage:mes]) {
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:title forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        [dictionary setObject:nowTime forKey:@"time"];
        [dictionary setObject:toUserid forKey:@"receiver"];
        [dictionary setObject:KISDictionaryHaveKey(self.shareUserDic, @"nickname") forKey:@"nickname"];
        [dictionary setObject:KISDictionaryHaveKey(self.shareUserDic, @"img") forKey:@"img"];
        [dictionary setObject:payloadStr forKey:@"payload"];
        [dictionary setObject:@"normalchat" forKey:@"msgType"];
        [dictionary setObject:uuid forKey:@"messageuuid"];
        [dictionary setObject:@"2" forKey:@"status"];
        [DataStoreManager storeMyPayloadmsg:dictionary];
        [DataStoreManager storeMyNormalMessage:dictionary];
    }else{
        [self showMessageWindowWithContent:@"发送失败" imageType:0];
    }
}


//消息发送成功
- (void)messageAck:(NSNotification *)notification
{
    NSDictionary* tempDic = notification.userInfo;
    [DataStoreManager refreshMessageStatusWithId:KISDictionaryHaveKey(tempDic, @"src_id") status:KISDictionaryHaveKey(tempDic, @"msgState")];
}

//广播给粉丝
-(void)broadcastToFans
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:self.messageid forKey:@"messageid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"145" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [self.view bringSubviewToFront:hud];
    hud.labelText = @"发送中...";
    [hud show:YES];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        m_shareViewBg.hidden = YES;
        m_shareView.hidden = YES;
        [self showMessageWindowWithContent:@"成功" imageType:0];
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



#pragma mark 举报 或评论
- (void)reportButtonClick:(id)sender
{
    NSString *str1;
    if ([m_userid intValue] ==[[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] intValue]) {
        str1 = @"您确定要删除这篇文章吗?";
    }else{
        str1 =@"您确定举报该篇文章吗？";
    }
    UIAlertView* alter = [[UIAlertView alloc] initWithTitle:@"提示" message:str1 delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alter.tag = 23;
    [alter show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 23) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            
            if (app.reach.currentReachabilityStatus ==NotReachable) {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"无法连接网络" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
                return;
            }
            
            //如果ID相同 则删除动态 否则举报用户
            if ([m_userid intValue] ==[[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] intValue]) {
                
                hud.labelText = @"删除中...";
                [hud show:YES];
                
                NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
                NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                [paramDic setObject:self.messageid forKey:@"messageId"];
                [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
                [dict setObject:paramDic forKey:@"params"];
                [dict setObject:@"193" forKey:@"method"];
                [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
                
                [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [hud hide:YES];
                    
                    NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"dynamicFromMe_wx"];
                    if ([KISDictionaryHaveKey(dic, @"id")intValue]==[self.messageid intValue]) {
                        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dynamicFromMe_wx"];
                    }
                    if (self.delegate&&[self.delegate respondsToSelector:@selector(dynamicListAddOneDynamic:)])
                        [self.delegate dynamicListAddOneDynamic:responseObject];

                    [self showMessageWindowWithContent:@"删除成功" imageType:0];
                    [self.navigationController popViewControllerAnimated:YES];
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
            }else{
                hud.labelText = @"举报中...";
                [hud show:YES];
                NSString* str = [NSString stringWithFormat:@"本人举报动态messageid为%@ 标题为%@的文章含不良内容，请尽快处理！", self.messageid,m_msg];
                NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:str ,@"msg",@"Platform=iphone", @"detail",self.messageid,@"id",@"dynamic",@"type",nil];
                NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
                [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
                [postDict setObject:@"155" forKey:@"method"];
                [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
                [postDict setObject:dic forKey:@"params"];
                
                [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    [hud hide:YES];
                    [self showAlertViewWithTitle:@"提示" message:@"感谢您的举报，我们会尽快处理！" buttonTitle:@"确定"];
                } failure:^(AFHTTPRequestOperation *operation, id error) {
                    if ([error isKindOfClass:[NSDictionary class]]) {
                        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                        {
                            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
                        }}}];

            }
        }
    }

}

- (void)okButtonClick:(id)sender
{
            ReplyViewController * VC = [[ReplyViewController alloc] init];
            VC.messageid = self.messageid;
            VC.delegate = self;
            VC.isHaveArticle = NO;
            [self.navigationController pushViewController:VC animated:YES];
}

- (void)dynamicListJustReload//新评论
{
    allPL ++;
    commentLabel.text = [NSString stringWithFormat:@"评论 %d", allPL];
    [self.delegate dynamicListJustReload];
}


#pragma mark web
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    //修改WebView的样式
    [self changeWebViewStyle:webView];

    //为图片添加点击响应
    NSString *str = [mWebView stringByEvaluatingJavaScriptFromString:[self createJavaScript]];
//    NSLog(@"------finish=%@",str);
}

- (void)changeWebViewStyle:(UIWebView *)webView{
    
    //添加javascript 控制图片的宽度
    [webView stringByEvaluatingJavaScriptFromString:@
     "var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function ResizeImages(){"
     "var myimg,oldwidth,oldheight;"
     "var maxwidth=305;"    //这是默认宽度
     "for(i=0;i <document.images.length;i++){"
     "myimg = document.images[i];"
     "if(myimg.width > maxwidth){"
     "oldwidth = myimg.width;"
     "oldheight = myimg.height;"
     "myimg.style.width = '';"     //必须先设置为空， 才能改变。不然会出现形如  <style width = "1500px" width = "305">这种坑爹的情况
     "myimg.style.height = '';"
     "myimg.width = maxwidth;"
     "myimg.height = oldheight * (maxwidth/oldwidth);"
     "}"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
    
//    NSString *lJs = @"document.documentElement.innerHTML";
//    NSString *lHtml1 = [webView stringByEvaluatingJavaScriptFromString:lJs];
//    NSLog(@"%@", lHtml1);
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [hud show:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
//    [hud hide:YES];
    [webView stopLoading];
}


- (BOOL)webView:(UIWebView *)webViewLocal shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSString *myURL = [[request URL] absoluteString];
    NSLog(@"%@",self.imgStr);
    if([myURL hasPrefix:@"http:"] && [self.urlLink isEqualToString:@""]) //动态
	{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:myURL]];
        return NO;
    }
    else if([myURL hasPrefix:@"myimage:"])
    {
        NSRange range = [myURL rangeOfString:@":"];
        if (range.location == NSNotFound) {
            return NO;
        }
        NSString * imageId = [myURL substringFromIndex:range.location+1];
        PhotoViewController * photoV = [[PhotoViewController alloc] initWithSmallImages:nil images:[NSArray arrayWithObject:imageId] indext:0];
        photoV.isComeFrmeUrl = NO;

        [self presentViewController:photoV animated:NO completion:^{
            
        }];
        return NO;
    }
    else{ //文章
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    NSLog(@"-----%@",components);
         NSLog(@"requsetstring%@",requestString);
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0] isEqualToString:@"lfyprotocol"]) {  //图片点击放大
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"http"] || [(NSString *)[components objectAtIndex:1] isEqualToString:@"https"]){
            //这个就是图片的路径
            NSLog(@"+++++++%@",components);
            NSString *path = [NSString stringWithFormat:@"%@:%@",[components objectAtIndex:1],[components objectAtIndex:2]];
            PhotoViewController * photoV = [[PhotoViewController alloc] initWithSmallImages:nil images:[NSArray arrayWithObject:path] indext:0];
            photoV.isComeFrmeUrl = YES;
            [self presentViewController:photoV animated:NO completion:^{
                
            }];
            
        }
        return NO;
    }
    }
	return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
