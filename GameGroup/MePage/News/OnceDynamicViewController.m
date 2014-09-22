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
    
    ShareDynamicView * showShareView;
    
    NSString * m_userid;
    AppDelegate *app;
    
    NSInteger m_zannum;
}
@property(nonatomic, strong)NSDictionary* dataDic;
@property(nonatomic, strong)NSArray*      headImgArray;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setTopViewWithTitle:@"详情" withBackButton:YES];
    
    m_shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    m_shareButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [m_shareButton setBackgroundImage:KUIImage(@"shareButton") forState:UIControlStateNormal];
    [m_shareButton setBackgroundImage:KUIImage(@"shareButton2") forState:UIControlStateHighlighted];
    [self.view addSubview:m_shareButton];
    [m_shareButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
     m_shareButton.hidden = YES;
    

    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:hud];
    app = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [self getDataByNet];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAck:)name:kMessageAck object:nil];
}

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
        [hud hide:YES];
        [self showErrorMsgDialog:error];
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
    m_zannum =  [[GameCommon getNewStringWithId:KISDictionaryHaveKey(self.dataDic, @"zannum")]intValue];

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
    TestViewController* detailV = [[TestViewController alloc] init];
    detailV.userId = KISDictionaryHaveKey(self.dataDic, @"userid");
    detailV.nickName = KISDictionaryHaveKey(self.dataDic, @"nickname");
    detailV.isChatPage = NO;
    [self.navigationController pushViewController:detailV animated:YES];
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
    [paramDict setObject:self.messageid forKey:@"messageId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"185" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        zanBtn.userInteractionEnabled = YES;
        zanBtn.selected = !zanBtn.selected;
        if(zanBtn.selected){
            [hud hide:YES];
            m_zannum++;
            [zanBtn setTitle:[NSString stringWithFormat:@"%d",m_zannum] forState:UIControlStateNormal];

            [zanBtn setBackgroundImage:KUIImage(@"zan_hig_1") forState:UIControlStateHighlighted];
            [self showMessageWindowWithContent:@"已赞" imageType:5];
        }else{
            [hud hide:YES];
            m_zannum--;
            [zanBtn setBackgroundImage:KUIImage(@"zan_hig_2") forState:UIControlStateHighlighted];
            [zanBtn setTitle:[NSString stringWithFormat:@"%d",m_zannum] forState:UIControlStateNormal];
            [self showMessageWindowWithContent:@"取消赞" imageType:6];
        }
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
{
    content = [content stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
    NSString* str = [NSString stringWithFormat:@"<body bgcolor=\"#f7f7f7\"><font size=\"3\" color=\"#444444\"><center><b>%@</b></center></font><p align=\"right\"><font size=\"3\" color=\"#444444\">%@</font></p><p><font size=\"3\" color=\"#444444\" style=\"line-height:25px\">%@</font></p></body>", title, time, content];
    return str;
}

- (NSString*)imageHtmlWithId:(NSString*)imageid
{
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
    else//如果是网页
    {
        mWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, startX + 60, kScreenWidth, kScreenHeigth - 40 - startX - 60-(KISHighVersion_7?0:20))];
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
                [self.navigationController pushViewController:VC animated:YES];
            }  break;
            case 1:
            {
                shareType = 1;
                [self setShareView:1];
            }break;
            default:
                break;
        }
    }else{
        if (buttonIndex ==0) {
            if ([KISDictionaryHaveKey([DataStoreManager queryMyInfo], @"superstar") doubleValue]) {
                UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"分享类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"发送给好友",@"广播给粉丝及好友", nil];
                sheet.tag = 90;
                [sheet showInView:self.view];
            }
            else
            {
                [self intentToSelectFriendPage];
            }
        }else {
            [[ShareDynamicMsgService singleton] shareToOther:KISDictionaryHaveKey(self.dataDic, @"id") MsgTitle:KISDictionaryHaveKey(self.dataDic, @"title") Description:KISDictionaryHaveKey(self.dataDic, @"msg") Image:KISDictionaryHaveKey(self.dataDic, @"img") UserNickName:KISDictionaryHaveKey(self.dataDic,@"nickname") index:buttonIndex];
        }

    }
}
//跳转选择好友页面
-(void)intentToSelectFriendPage{
    selectContactPage *VC = [[selectContactPage alloc] init];
    VC.contactDelegate = self;
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark --选择好友回来
-(void)getContact:(NSDictionary *)userDict
{
    self.shareUserDic = userDict;
    [self setShareView:0];
}

- (void)setShareView:(NSInteger)type
{
    if (showShareView == nil) {
        showShareView = [[ShareDynamicView alloc] initWithFrame:self.view.frame];
        showShareView.shareDelegate = self;
        [self.view addSubview:showShareView];
    }else{
        [showShareView showSelf];
    }
    [showShareView setTextToView:KISDictionaryHaveKey(self.dataDic, @"title") MsgContext:KISDictionaryHaveKey(self.dataDic, @"msg") ShareToUserNickName:KISDictionaryHaveKey(self.shareUserDic, @"nickname") ShareImage:KISDictionaryHaveKey(self.dataDic, @"thumb") type:type];
}
#pragma mark --分享给好友
-(void)shareToFriend{
    [self sendDynamicToFriend];
}
#pragma mark -- 广播给粉丝
-(void)broadcastToFans{
    [self broadcastDynamicToFans];
}
//分享给好友
-(void)sendDynamicToFriend
{
    [[ShareDynamicMsgService singleton] sendToFriend:KISDictionaryHaveKey(self.dataDic,@"nickname") DynamicId:self.dataDic[@"id"] MsgBody:self.dataDic[@"msg"] DynamicImage:KISDictionaryHaveKey(self.dataDic, @"thumb") ToUserId:KISDictionaryHaveKey(self.shareUserDic, @"userid") ToNickName:KISDictionaryHaveKey(self.shareUserDic, @"nickname") ToImage:KISDictionaryHaveKey(self.shareUserDic, @"img") success:^{
        [self showMessageWindowWithContent:@"发送成功" imageType:0];
    } failure:^(NSString *error) {
        [self showMessageWindowWithContent:@"发送失败" imageType:0];
    }];
}

//广播给粉丝
-(void)broadcastDynamicToFans
{
    [self.view bringSubviewToFront:hud];
    hud.labelText = @"发送中...";
    [hud show:YES];
    [[ShareDynamicMsgService singleton] broadcastToFans:KISDictionaryHaveKey(self.dataDic, @"id") resuccess:^(id responseObject) {
        [hud hide:YES];
        showShareView.hidden = YES;
        [self showMessageWindowWithContent:@"成功" imageType:0];
    } refailure:^(id error) {
        [hud hide:YES];
        [self showErrorMsgDialog:error];
    }];
}

-(void)showErrorMsgDialog:(id)error{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }

}

//消息发送成功
- (void)messageAck:(NSNotification *)notification
{
    NSDictionary* tempDic = notification.userInfo;
    [DataStoreManager refreshMessageStatusWithId:KISDictionaryHaveKey(tempDic, @"src_id") status:KISDictionaryHaveKey(tempDic, @"msgState")];
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
                    [hud hide:YES];
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
     "myimg.style.width = '';"//必须先设置为空， 才能改变。不然会出现形如  <style width = "1500px" width = "305">这种坑爹的情况
     "myimg.style.height = '';"
     "myimg.width = maxwidth;"
     "myimg.height = oldheight * (maxwidth/oldwidth);"
     "}"
     "}"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    [webView stringByEvaluatingJavaScriptFromString:@"ResizeImages();"];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
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
