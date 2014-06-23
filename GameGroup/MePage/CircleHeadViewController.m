//
//  CircleHeadViewController.m
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleHeadViewController.h"
#import "OnceDynamicViewController.h"
#import "CircleWithMeViewController.h"
#import "MyCircleViewController.h"
#import "TestViewController.h"
#import "ReplyViewController.h"
#import "PhotoViewController.h"
#import "CircleHeadCell.h"
#import "MJRefresh.h"
#import "UserManager.h"
#import "DSOfflineZan.h"
#import "InterestingPerpleViewController.h"
#import "FunEntranceCell.h"
typedef enum : NSUInteger {
    CommentInputTypeKeyboard,
    CommentInputTypeEmoji,
} CommentInputType;
@interface CircleHeadViewController ()
{
    UITableView *m_myTableView;
    NSMutableArray *m_dataArray;//数据集合
    NSInteger  m_currPageCount;//分页加载
    MJRefreshHeaderView *m_header;
    MJRefreshFooterView *m_footer;
    UILabel *nickNameLabel;
    UIImageView *topImgaeView;
    EGOImageButton *headImageView;
    EGOImageView *imageViewC;
    
    CircleHeadCell *openMenuBtn;
    
    UIButton *friendZanBtn;
    AppDelegate *app;
    
    UIImageView *abobtMeImageView;
    EGOImageView *aboutMeHeadImgView;
    UILabel *aboutMeLabel;
    
    NSIndexPath *indexPaths;
    NSMutableArray * commentArray;
    UIView *toolView;
    UIView* tool;
    UIView *inPutView;
    NSString *commentMsgId;
    NSString *destuserId;
    NSString *destMsgId;
    BOOL isComeBackComment;
    UITapGestureRecognizer *hidenMenuTap;
    NSString *methodStr;
    BOOL isfriendCircle;
    UIButton *senderBnt;
    int m_commentAboutMeCount;
    
    UIAlertView *delCellAlertView;
    int  delCellCount;//删除动态的cell行数（位置）
    
    NSMutableDictionary *delcommentDic;
    NSMutableDictionary *cellhightarray;//存放每个Cell的高度
    float offer;
    int height;
    
    UIView *bottomView;//逗你玩界面
    UIView *topVIew;
    NSMutableDictionary *commentOffLineDict;
    UIActivityIndicatorView * m_loginActivity;
    BOOL ishaveAboutMe;
    BOOL ishavehuancun;
    
//    BOOL isHaveFuns;
}
@property (nonatomic, strong) EmojiView *theEmojiView;
@property (nonatomic, assign) CommentInputType commentInputType;
@end

@implementation CircleHeadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"mydynamicmsg_wx" object:nil];
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showAboutMePage:) name:@"mydynamicmsg_wx" object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    ishaveAboutMe =NO;
    ishavehuancun = NO;
//    isHaveFuns = NO;
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    tapGr.delegate = self;
    [self.view addGestureRecognizer:tapGr];
    app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    height=216;
    
    
    
    NSDictionary* user=[[UserManager singleton] getUser:self.userId];
    NSString * nickName=KISDictionaryHaveKey(user, @"nickname");
    NSString * imageIds=KISDictionaryHaveKey(user, @"img");
    nickNameLabel.text = nickName;
    headImageView.imageURL = [ImageService getImageStr2:imageIds];
    
    
    m_dataArray = [NSMutableArray new];
    
    commentArray = [NSMutableArray array];
    delcommentDic = [NSMutableDictionary dictionary];
    commentOffLineDict = [NSMutableDictionary dictionary];
    cellhightarray = [NSMutableDictionary dictionary];

    m_currPageCount = 0;
    methodStr = @"1";
    //判断是否是回复某人的评论
    isComeBackComment = NO;
    isfriendCircle = YES;
    
    m_myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height) style:UITableViewStylePlain];
    m_myTableView.delegate = self;
    m_myTableView.dataSource = self;
    [self.view addSubview:m_myTableView];
    
    //顶部图片
    
    topVIew =[[ UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 370)];
    topVIew.backgroundColor  =[UIColor whiteColor];
    m_myTableView.tableHeaderView = topVIew;
    
    topImgaeView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 320)];
    topImgaeView.backgroundColor = [UIColor blackColor];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"topImageData_wx_%@",kMYUSERID]]) {
        topImgaeView.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"topImageData_wx_%@",kMYUSERID]]];
    }else{
        topImgaeView.backgroundColor = UIColorFromRGBA(0x262930, 1);
        topImgaeView.image = KUIImage(@"");
    }
    topImgaeView.userInteractionEnabled =YES;
    
    [topImgaeView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeTopImage:)]];
    [topVIew addSubview:topImgaeView];
    
    //黑白渐变Label以突出文字
    UIImageView *topunderBgImageView =[[UIImageView alloc]initWithFrame:CGRectMake(0, 280, 320, 40)];
    topunderBgImageView.image = KUIImage(@"underbg");
    [topVIew addSubview:topunderBgImageView];
    
//    昵称
//    NSString * strNickName = KISDictionaryHaveKey(user, @"nickname");
    CGSize nickLabelsize =[nickName sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
    
    UILabel *underNickLabel = [[UILabel alloc]initWithFrame:CGRectMake(221-nickLabelsize.width, 291, nickLabelsize.width, 30)];
    underNickLabel.text =self.nickNmaeStr;
    underNickLabel.text = nickName;
    underNickLabel.textColor = [UIColor blackColor];
    underNickLabel.backgroundColor =[UIColor clearColor];
    underNickLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:underNickLabel];
    
   
    nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(220-nickLabelsize.width, 290, nickLabelsize.width, 30)];
    nickNameLabel.text =self.nickNmaeStr;
    nickNameLabel.text = nickName;
    nickNameLabel.textColor = [UIColor whiteColor];
    nickNameLabel.backgroundColor =[UIColor clearColor];
    nickNameLabel.textAlignment = NSTextAlignmentRight;
    [topVIew addSubview:nickNameLabel];
    
    
    //头像
    headImageView = [[EGOImageButton alloc]initWithFrame:CGRectMake(230, 280, 80, 80)];
    headImageView.placeholderImage = KUIImage(@"placeholder");
    headImageView.imageURL = [ImageService getImageUrl4:self.imageStr];
    
    headImageView.layer.cornerRadius = 5;
    headImageView.layer.masksToBounds=YES;
    [headImageView addTarget:self action:@selector(enterPersonViewController:) forControlEvents:UIControlEventTouchDown];
    NSString * headImageIds=KISDictionaryHaveKey(user, @"img");
    headImageView.imageURL = [ImageService getImageStr2:headImageIds];
    
    [topVIew addSubview:headImageView];

    //朋友在赞
    friendZanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    friendZanBtn.frame = CGRectMake(10, 306, 74, 28);
    [friendZanBtn setBackgroundImage:KUIImage(@"friend_is_zan_on") forState:UIControlStateNormal];
    [friendZanBtn setBackgroundImage:KUIImage(@"friend_is_zan_off") forState:UIControlStateSelected];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"aboutFriendSwitch_friendCircle_netTitle_wx"]) {
        NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"aboutFriendSwitch_friendCircle_netTitle_wx"];
        if ([str intValue]==1) {
            friendZanBtn.selected =YES;
        }else{
            friendZanBtn.selected = NO;
        }
    }
    [friendZanBtn addTarget:self action:@selector(friendZan:) forControlEvents:UIControlEventTouchUpInside];
    [topVIew addSubview:friendZanBtn];
    
    //与我相关
    abobtMeImageView = [[UIImageView alloc]init];
    abobtMeImageView.frame = CGRectMake(68, 370, 184, 37);
    abobtMeImageView.image = [UIImage imageNamed:@"newinfoaboutme"];
    abobtMeImageView.userInteractionEnabled = YES;
    [abobtMeImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enterAboutMePage:)]];
    [topVIew addSubview:abobtMeImageView];
    
    aboutMeHeadImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(8, 3, 30, 30)];
    aboutMeHeadImgView.placeholderImage = KUIImage(@"moren_people.png");
    [abobtMeImageView addSubview:aboutMeHeadImgView];
    
    aboutMeLabel = [[UILabel alloc]initWithFrame:CGRectMake(50, 3, 140, 30)];
    aboutMeLabel.textColor = [UIColor whiteColor];
    aboutMeLabel.backgroundColor =[UIColor clearColor];
    aboutMeLabel.font = [UIFont boldSystemFontOfSize:13];
    [abobtMeImageView addSubview:aboutMeLabel];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancun_wx"]) {
        ishaveAboutMe =YES;
        //改变HeadView的高度 以容纳aboutMeImageView
        CGRect frame = m_myTableView.tableHeaderView.frame;
        frame.size.height =430;
        UIView *view = m_myTableView. tableHeaderView;
        view.frame = frame;
        m_myTableView.tableHeaderView = view;
        
        NSMutableData *data= [NSMutableData data];
        NSDictionary *dic = [NSDictionary dictionary];
        data =[[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancun_wx"];
        NSKeyedUnarchiver *unarchiver= [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        dic = [unarchiver decodeObjectForKey: @"getDatat"];
        [unarchiver finishDecoding];

        NSString *customObject;
        NSString *customUser;
        
        if ([KISDictionaryHaveKey(dic, @"type")intValue]==4) {
            customObject = @"zanObject";
            customUser = @"zanUser";
        }
        else if ([KISDictionaryHaveKey(dic, @"type")intValue]==5||[KISDictionaryHaveKey(dic, @"type")intValue]==7)
        {
            customObject =@"commentObject";
            customUser = @"commentUser";
        }
        
        abobtMeImageView.hidden =NO;
        NSString * cusUserImageIds=KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(dic, customObject),customUser), @"img");
        
        if ([GameCommon isEmtity:cusUserImageIds]) {
            aboutMeHeadImgView.imageURL =nil;
        }else
        {
            aboutMeHeadImgView.imageURL = [ImageService getImageStr:cusUserImageIds Width:60];
            
        }
        
        
        m_commentAboutMeCount =[[[NSUserDefaults standardUserDefaults]objectForKey:@"mydynamicmsg_huancunCount_wx"]intValue];
        aboutMeLabel.text = [NSString stringWithFormat:@"%d条新消息",m_commentAboutMeCount];

    }else
    {
        abobtMeImageView.hidden = YES;
    }
    
    [self setTopViewWithTitle:@"朋友圈" withBackButton:YES];
    UIButton *shareButton = [[UIButton alloc]initWithFrame:CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44)];

    [shareButton setBackgroundImage:KUIImage(@"published_circle_normal") forState:UIControlStateNormal];
    [shareButton setBackgroundImage:KUIImage(@"published_circle_click") forState:UIControlStateHighlighted];
    shareButton.backgroundColor = [UIColor clearColor];
    [shareButton addTarget:self action:@selector(publishInfo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];

    
    m_loginActivity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view addSubview:m_loginActivity];
    m_loginActivity.frame = CGRectMake(110, KISHighVersion_7?27:7, 20, 20);
    m_loginActivity.center = CGPointMake(110, KISHighVersion_7?42:22);
    m_loginActivity.color = [UIColor whiteColor];
    m_loginActivity.activityIndicatorViewStyle =UIActivityIndicatorViewStyleWhite;
    
    
    
    hud = [[MBProgressHUD alloc]initWithView:self.view];
    hud.labelText = @"加载中...";
    [self.view addSubview:hud];
    
    [self addheadView];
    [self addFootView];
    
    [self.view addSubview:self.theEmojiView];
    self.theEmojiView.hidden = YES;
    
    //创建评论框
    [self buildcommentView];
    NSString * path = [[RootDocPath stringByAppendingString:@"/circleFriend_huancun_01_wx_"]stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    if ([NSMutableArray arrayWithContentsOfFile:path]) {
        m_dataArray= [NSMutableArray arrayWithContentsOfFile:path];
        if (m_dataArray.count<1) {
            [self buildBottomView];
        }
        [self getInfoFromNet];
    }else{
        ishavehuancun = YES;
        m_myTableView.contentOffset = CGPointMake(0, 150);
        [self buildBottomView];
        [self getInfoFromNet];
    }
}

-(void)buildBottomView
{
    
    CGRect frame = m_myTableView.tableHeaderView.frame;
    frame.size.height =kScreenHeigth+370;
    UIView *view = m_myTableView. tableHeaderView;
    view.frame = frame;
    m_myTableView.tableHeaderView = view;

    bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 370, 320, kScreenHeigth)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [topVIew addSubview:bottomView];

    
    UILabel *lb1 = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 300, 20)];
    lb1.font = [UIFont boldSystemFontOfSize:14];
    lb1.text = @"在陌游中分享你在游戏与现实中发生的事情";
    lb1.textColor = [UIColor grayColor];
    lb1.textAlignment = NSTextAlignmentCenter;
    lb1.backgroundColor =[ UIColor clearColor];
    [bottomView addSubview:lb1];
    
    
    UILabel *lb2 =[[ UILabel alloc]initWithFrame:CGRectMake(10, 35, 300, 20)];
    lb2.font = [UIFont boldSystemFontOfSize:14];
    lb2.text = @"你的组织成员,附近的玩家与好友会及时的";
    lb2.textColor = [UIColor grayColor];
    lb2.textAlignment = NSTextAlignmentCenter;
    lb2.backgroundColor =[ UIColor clearColor];
    [bottomView addSubview:lb2];
    
    UILabel *lb3 =[[ UILabel alloc]initWithFrame:CGRectMake(10, 65, 300, 20)];
    lb3.font = [UIFont boldSystemFontOfSize:14];
    lb3.text = @"看到你的动态";
    lb3.textColor = [UIColor grayColor];
    lb3.textAlignment = NSTextAlignmentCenter;
    lb3.backgroundColor =[ UIColor clearColor];
    [bottomView addSubview:lb3];
    
    UIImageView *imageView =[[ UIImageView alloc]initWithFrame:CGRectMake(80, 90, 160, 100)];
    imageView.image = KUIImage(@"eggs");
    [bottomView addSubview:imageView];
    
    UIButton *button  =[[ UIButton alloc]initWithFrame:CGRectMake(110,200, 100, 20)];
    [button setImage:KUIImage(@"nizhendou") forState:UIControlStateNormal];
    [button addTarget:self action:@selector(bierenyedou:) forControlEvents:UIControlEventTouchUpInside];
    [bottomView addSubview:button];
    
    UILabel *lb4 =[[ UILabel alloc]initWithFrame:CGRectMake(10, 230, 300, 20)];
    lb4.font = [UIFont boldSystemFontOfSize:14];
    lb4.text = @"学着做一个有趣的人,就可以认识更多的游戏";
    lb4.textColor = [UIColor grayColor];
    lb4.textAlignment = NSTextAlignmentCenter;
    lb4.backgroundColor =[ UIColor clearColor];
    [bottomView addSubview:lb4];

    UILabel *lb5 =[[ UILabel alloc]initWithFrame:CGRectMake(10, 255, 300, 20)];
    lb5.font = [UIFont boldSystemFontOfSize:14];
    lb5.text = @"的伙伴,充分享受陌游带给你的乐趣";
    lb5.textColor = [UIColor grayColor];
    lb5.textAlignment = NSTextAlignmentCenter;
    lb5.backgroundColor =[ UIColor clearColor];
    [bottomView addSubview:lb5];

    
}



-(void)dynamicListAddOneDynamic:(NSDictionary*)dynamic
{
    m_currPageCount = 0;
    [self getInfoFromNet];
}
#pragma mark - Views
//表情按钮
- (EmojiView *)theEmojiView{
    if (!_theEmojiView) {
        _theEmojiView = [[EmojiView alloc]
                         initWithFrame:CGRectMake(0,
                                                  self.view.frame.size.height-253,
                                                  320,
                                                  253)
                         WithSendBtn:YES];
        _theEmojiView.delegate = self;
    }
    return _theEmojiView;
}
//点击添加表情按钮
-(void)emojiBtnClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (self.commentInputType != CommentInputTypeEmoji) {//点击切到表情
        [self showEmojiScrollView];
    }else{//点击切回键盘
        [self showKeyboardView];
        
    }
}
//显示键盘
-(void)showKeyboardView
{
    [self.textView becomeFirstResponder];
    self.commentInputType = CommentInputTypeKeyboard;
    self.theEmojiView.hidden = YES;
}
//显示表情布局
-(void)showEmojiScrollView
{
    self.commentInputType = CommentInputTypeEmoji;
    [self.textView resignFirstResponder];
    self.theEmojiView.hidden = NO;
    self.theEmojiView.frame = CGRectMake(0,self.view.frame.size.height-253,320,253);
    [self autoMovekeyBoard:253];
}

//删除表情
-(void)deleteEmojiStr
{
    if (self.textView.text.length>=1) {
        if ([self.textView.text hasSuffix:@"] "] && [self.textView.text length] >= 5) {
            self.textView.text = [self.textView.text substringToIndex:(self.textView.text.length-5)];
        }
        else
        {
            self.textView.text = [self.textView.text substringToIndex:(self.textView.text.length-1)];
        }
    }
}
//发送表情
-(void)emojiSendBtnDo
{
    
    [self updateComment];
}
//选择表情
-(NSString *)selectedEmoji:(NSString *)ssss
{
	if (self.textView.text == nil) {
		self.textView.text = ssss;
	}
	else {
		self.textView.text = [self.textView.text stringByAppendingString:ssss];
	}
    return 0;
}

#pragma mark ---发表新动态
-(void)publishInfo:(UIButton *)sender
{
    SendNewsViewController* sendNews = [[SendNewsViewController alloc] init];
    sendNews.delegate = self;
    sendNews.isComeFromMe = YES;
    sendNews.delegate = self;
    [self.navigationController pushViewController:sendNews animated:YES];
    
}

-(void)enterPersonViewController:(UIButton *)sender
{
    TestViewController *testVC = [[TestViewController alloc]init];
    testVC.userId =[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
    testVC.nickName = self.nickNmaeStr;
    testVC.viewType = VIEW_TYPE_Self1;
    [self.navigationController pushViewController:testVC animated:YES];
}


-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
    if (openMenuBtn.menuImageView.hidden==NO) {
        openMenuBtn.menuImageView.hidden =YES;
    }
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
    if(self.theEmojiView.hidden == NO){
        self.theEmojiView.hidden = YES;
        [self autoMovekeyBoard:-inPutView.bounds.size.height];
        self.commentInputType = CommentInputTypeKeyboard;
        senderBnt.selected = NO;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}
-(void)buildcommentView
{
    inPutView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height, 320, 50)];
    [self.view addSubview:inPutView];
    
    self.textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 7, 240, 35)];
    self.textView.isScrollable = NO;
    self.textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
	self.textView.minNumberOfLines = 1;
	self.textView.maxNumberOfLines = 6;
	self.textView.returnKeyType = UIReturnKeyDone; //just as an example
	self.textView.font = [UIFont systemFontOfSize:15.0f];
	self.textView.delegate = self;
    self.textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    self.textView.backgroundColor = [UIColor clearColor];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"chat_input.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(10, 7, 240, 35);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, inPutView.frame.size.width, inPutView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [inPutView addSubview:imageView];
    [inPutView addSubview:entryImageView];
    [inPutView addSubview:self.textView];
    
    senderBnt = [UIButton buttonWithType:UIButtonTypeCustom];
    [senderBnt setBackgroundImage:KUIImage(@"emoji") forState:UIControlStateNormal];
    [senderBnt setBackgroundImage:KUIImage(@"keyboard.png") forState:UIControlStateSelected];
    [senderBnt addTarget:self action:@selector(emojiBtnClicked:) forControlEvents:UIControlEventTouchDown];
    senderBnt.frame = CGRectMake(260, 0, 50, 50);
    [inPutView bringSubviewToFront:senderBnt];
    
    [inPutView addSubview:senderBnt];
}


//显示与我相关
-(void)showAboutMePage:(NSNotification *)info
{
    NSString *customObject;
    NSString *customUser;
    
    if ([KISDictionaryHaveKey(info.userInfo, @"type")intValue]==4) {
        customObject = @"zanObject";
        customUser = @"zanUser";
    }
    else if ([KISDictionaryHaveKey(info.userInfo, @"type")intValue]==5||[KISDictionaryHaveKey(info.userInfo, @"type")intValue]==7)
    {
        customObject =@"commentObject";
        customUser = @"commentUser";
    }
    
    m_commentAboutMeCount++;
    
    //改变HeadView的高度 以容纳aboutMeImageView
    if(abobtMeImageView.hidden)
    {
        CGRect frame = m_myTableView.tableHeaderView.frame;
        frame.size.height =430;
        UIView *view = m_myTableView. tableHeaderView;
        view.frame = frame;
        m_myTableView.tableHeaderView = view;
        abobtMeImageView.hidden =NO;
    }
    
    NSString * userImageids=KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info.userInfo, customObject),customUser), @"img");
    
    
    if ([GameCommon isEmtity:userImageids]) {
        aboutMeHeadImgView.imageURL =nil;
    }else
    {
       aboutMeHeadImgView.imageURL = [ImageService getImageStr:userImageids Width:60];
    }
    
    
    aboutMeLabel.text = [NSString stringWithFormat:@"%d条新消息",m_commentAboutMeCount];
    
}

#pragma mark --进入与我相关界面
-(void)enterAboutMePage:(id)sender
{
    offer-=20;
    ishaveAboutMe = NO;
    abobtMeImageView.hidden =YES;
    //改变Headview高度 以适配隐藏aboutMeImageView后的样式
    CGRect frame = m_myTableView.tableHeaderView.frame;
    frame.size.height = 350;
    UIView *view = m_myTableView. tableHeaderView;
    view.frame = frame;
    m_myTableView.tableHeaderView = view;
    
    m_commentAboutMeCount=0;
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"mydynamicmsg_huancunCount_wx"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"mydynamicmsg_huancun_wx"];
    CircleWithMeViewController *cir = [[CircleWithMeViewController alloc]init];
    cir.userId = [[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:haveMyNews];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.navigationController pushViewController:cir animated:YES];
}

#pragma mark --网络请求 获取信息
-(void)getInfoFromNet
{
    [m_loginActivity startAnimating];
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:self.userId forKey:@"userid"];
    [paramDic setObject:@"20" forKey:@"maxSize"];
    [paramDic setObject:methodStr forKey:@"aboutFriendSwitch"];
    [paramDic setObject:@(m_currPageCount) forKey:@"pageIndex"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"189" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_loginActivity stopAnimating];
        
        self.view.backgroundColor = UIColorFromRGBA(0x262930, 1);
        if (KISHighVersion_7) {
            m_myTableView.backgroundColor = UIColorFromRGBA(0x262930, 1);
        }
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSArray *arraaay =KISDictionaryHaveKey(responseObject, @"dynamicMsgList");
            if (([arraaay isKindOfClass:[NSArray class]]&&arraaay.count>0)&&ishavehuancun) {
                
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.4];
                m_myTableView.contentOffset = CGPointMake(0, 0);
                topVIew.frame =CGRectMake(0, 0, 320, 370);
                [UIView commitAnimations];
                [bottomView removeFromSuperview];
                
                CGRect frame = m_myTableView.tableHeaderView.frame;
                if (ishaveAboutMe) {
                    frame.size.height =430;
                }else{
                    frame.size.height =370;
                }
                UIView *view = m_myTableView. tableHeaderView;
                view.frame = frame;
                m_myTableView.tableHeaderView = view;
                ishavehuancun =NO;
            }

            
            
            if ([KISDictionaryHaveKey(responseObject, @"aboutFriendSwitch")intValue]==1) {
                friendZanBtn.selected = YES;
            }else{
                friendZanBtn.selected =NO;
            }
            [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(responseObject, @"aboutFriendSwitch") forKey:@"aboutFriendSwitch_friendCircle_netTitle_wx"];
            
            if (m_currPageCount==0) {
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dongtaicount_wx"];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"cleanInfoOffinderPage_wx" object:nil];
                [m_dataArray removeAllObjects];
                
                [m_dataArray addObjectsFromArray:KISDictionaryHaveKey(responseObject, @"dynamicMsgList")];
//                //拉数据回来以后直接格式化， 再保存
//                isHaveFuns = NO;
                for (int i=0; i<m_dataArray.count; i++) {
                    m_dataArray[i] = [self contentAnalyzer:m_dataArray[i] withReAnalyzer:NO];
                }
                
                [self saveinfoToUserDefaults:m_dataArray];
                
//                if (self.msgCount<m_dataArray.count&&!isHaveFuns) {
//                    isHaveFuns = YES;
//                   NSMutableDictionary * dicccc = [NSMutableDictionary dictionary];
//                    [dicccc setValue:@"isYes" forKey:@"isFund"];
//                    [m_dataArray insertObject:dicccc atIndex:self.msgCount];
//                }
                
            }else{
                NSMutableArray *arr  = [NSMutableArray array];
                NSMutableArray *customArr = KISDictionaryHaveKey( responseObject, @"dynamicMsgList");
                NSMutableArray *idArray = [NSMutableArray array];
                for (int i = 0; i<m_dataArray.count; i++) {
                    NSString *idStr = KISDictionaryHaveKey(m_dataArray[i], @"id");
                    [idArray addObject:idStr];
                }
                for (int i = 0; i<customArr.count;i++) {
                    if ([idArray containsObject:KISDictionaryHaveKey(customArr[i], @"id")]) {
                        [customArr removeObjectAtIndex:i];
                    }
                }
                
                
                for (int i =0; i<customArr.count; i++) {
                    [arr addObject:[self contentAnalyzer:customArr[i] withReAnalyzer:NO]];
                }
                [m_dataArray addObjectsFromArray:arr];
                
//                if (self.msgCount<m_dataArray.count&&!isHaveFuns) {
//                    isHaveFuns = YES;
//                    NSMutableDictionary * dicccc = [NSMutableDictionary dictionary];
//                    [dicccc setValue:@"isYes" forKey:@"isFund"];
//                    [m_dataArray insertObject:dicccc atIndex:self.msgCount];
//                }
            }
            m_currPageCount++;
            [m_header endRefreshing];
            [m_footer endRefreshing];
            [m_myTableView reloadData];
            [hud  hide:YES];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_header endRefreshing];
        [m_footer endRefreshing];
        [m_loginActivity stopAnimating];

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
#pragma mark --朋友在赞触发方法与网络请求
-(void)friendZan:(UIButton *)sender
{
  //  sender.selected  =!sender.selected;
    m_currPageCount =0;
    hud.labelText =@"加载中...";
    [hud show:YES];
    NSString *str = [[NSUserDefaults standardUserDefaults]objectForKey:@"aboutFriendSwitch_friendCircle_netTitle_wx"];
    if ([str intValue]==1) {
        methodStr = @"2";
    }else{
        methodStr = @"1";
    }
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:methodStr forKey:@"aboutFriendSwitch"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"199" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        m_currPageCount =0;
        [self getInfoFromNet];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        else
        {
            UIAlertView* alertView1 = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请求数据失败，请检查网络！" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView1 show];
        }
        [hud hide:YES];
    }];
}
- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if(scrollView==m_myTableView){
        if (openMenuBtn.menuImageView.hidden==NO) {
            openMenuBtn.menuImageView.hidden =YES;
        }
    }
    
}
#pragma mark Content分析器
- (NSMutableDictionary *)contentAnalyzer:(NSMutableDictionary *)contentDict withReAnalyzer:(BOOL)reAnalyzer;
{
//    if (![GameCommon isEmtity:KISDictionaryHaveKey(contentDict, @"isFund")]) {
//        return contentDict;
//    }
    if ([[contentDict allKeys]containsObject:@"Analyzed"] && [KISDictionaryHaveKey(contentDict, @"Analyzed") boolValue] && !reAnalyzer ) {  //如果已经分析过
        return contentDict;
    }
    
    float cellHeight = 0.0f; //行高
    
    //昵称
    cellHeight += 30;
    
    //正文高度
    if([[contentDict allKeys]containsObject:@"titleLabelHieght"] &&!reAnalyzer)
    {
        cellHeight += [KISDictionaryHaveKey(contentDict, @"titleLabelHieght") floatValue];
    }
    else{
        
        NSString *urlLink = KISDictionaryHaveKey(contentDict, @"urlLink");
        if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil){
            //普通正文
            NSString *str = KISDictionaryHaveKey(contentDict, @"msg");
            str = [UILabel getStr:str];
            CGSize size = [str sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            [contentDict setObject:@(size.height) forKey:@"titleLabelHieght"];
            cellHeight += size.height +5 ;  //+5为了不和下面太紧
            
            //图片
            if([[contentDict allKeys]containsObject:@"imgHieght"] &&!reAnalyzer)
            {
                cellHeight +=[KISDictionaryHaveKey(contentDict, @"imgHieght") floatValue];
            }
            else{
                if([KISDictionaryHaveKey(contentDict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(contentDict, @"img") isEqualToString:@" "])
                {
                    //无图
                    cellHeight += 0;
                    
                    [contentDict setObject:@(0) forKey:@"imgHieght"];
                }
                else
                {
                    //有图， 先解析出图片数组
                    NSMutableString *imgStr = KISDictionaryHaveKey(contentDict, @"img");
                    NSString *str = [imgStr substringFromIndex:imgStr.length];
                    NSString *str2;
                    if ([str isEqualToString:@","]) {
                        str2= [imgStr substringToIndex:imgStr.length-1];
                    }
                    else {
                        str2 = imgStr;
                    }
                    NSArray *collArray = [imgStr componentsSeparatedByString:@","];
                    
                    if ([[collArray lastObject]isEqualToString:@""]||[[collArray lastObject]isEqualToString:@" "]) {
                        [(NSMutableArray*)collArray removeLastObject];
                    }
                    [contentDict setObject:collArray forKey:@"imgArray"];
                    
                    //根据图片数组接卸图片所占高度
                    int i = (collArray.count-1)/3;
                    float imgViewHeight = i*80+80; //图片的高度
                    imgViewHeight += (i+1)*2; //图片的padding, 为2
                    [contentDict setObject:@(imgViewHeight) forKey:@"imgHieght"];
                    
                    cellHeight +=imgViewHeight;
                }
            }
        }
        else {
            //分享的链接 URL
            //NSString *strTitle = KISDictionaryHaveKey(contentDict, @"title");
            NSString *strTitle = KISDictionaryHaveKey(contentDict, @"title");
            NSLog(@"strTitle:%@",strTitle);
            CGSize size1 = [strTitle sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            NSLog(@"heightfloot:%f",size1.height);
            NSNumber* titleLabelHieght = [NSNumber numberWithFloat:size1.height];
            [contentDict setObject:titleLabelHieght forKey:@"titleLabelHieght"];
            
            cellHeight += size1.height  +50 +5 ;  //+5为了不和下面太紧
        }
    }
    
   
    
    //时间label, 删除按钮与btn_more  50
    cellHeight += 50;
    
    //赞label
    if ([KISDictionaryHaveKey(contentDict, @"zanNum")intValue]!=0)
    {
        NSArray *array = KISDictionaryHaveKey(contentDict, @"zanList");
        if (array.count>0){ //以前的数据有些没有zanlist
            cellHeight +=30;
        }
    }
    
    //评论table
    if ([[contentDict allKeys]containsObject:@"commentListHieght"] &&!reAnalyzer) {
        cellHeight +=[KISDictionaryHaveKey(contentDict, @"commentListHieght") floatValue];
    }
    else{
        float commHieght = 0.0f;
        NSArray *commentsArray =KISDictionaryHaveKey(contentDict, @"commentList");
        for (int i =0; i<commentsArray.count; i++) {
            NSMutableDictionary *dic = [commentsArray objectAtIndex:i];
            //判断是否是回复某人的评论
            if([[dic allKeys]containsObject:@"commentCellHieght"] &&!reAnalyzer){
                float commentCellHeight = [KISDictionaryHaveKey(dic, @"commentCellHieght") floatValue];
                commHieght +=commentCellHeight;
            }
            else{   //如果没算高度， 算出高度，存起来
                NSString *str ;
                if ([[dic allKeys]containsObject:@"commentStr"] &&!reAnalyzer) {
                    str =KISDictionaryHaveKey(dic, @"commentStr");
                }
                else{
                    NSString * nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"alias");
                    if ([GameCommon isEmtity:nickName]) {
                        nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"commentUser"), @"nickname");
                    }
                    if ([[dic allKeys]containsObject:@"destUser"]) {
                        NSString * nickName2=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"destUser"), @"alias");
                        if ([GameCommon isEmtity:nickName2]) {
                            nickName2=KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"destUser"), @"nickname");
                        }
                        str =[NSString stringWithFormat:@"%@ 回复 %@: %@",nickName,nickName2,KISDictionaryHaveKey(dic, @"comment")];
                    }else{
                        str =[NSString stringWithFormat:@"%@: %@",nickName,KISDictionaryHaveKey(dic, @"comment")];
                    }
                    str = [UILabel getStr:str];
                    [dic setObject:str forKey:@"commentStr"];
                }
                
                //计算ceommentCell 的高度
                CGSize size = [str sizeWithFont:[UIFont boldSystemFontOfSize:12.0] constrainedToSize:CGSizeMake(245, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
                float height1= size.height+5;
                [dic setObject:@(height1) forKey:@"commentCellHieght"];
                commHieght += height1;
            }
        }
        [contentDict setObject:@(commHieght) forKey:@"commentListHieght"];
        cellHeight += commHieght;
    }
    
    //查看更多评论label
    if ([KISDictionaryHaveKey(contentDict, @"commentNum")intValue]>7) {
        cellHeight += 20;
    }
    [contentDict setObject:@(cellHeight) forKey:@"cellHieght"];
    
    bool Analyzed = YES;
    [contentDict setObject:@(Analyzed) forKey:@"Analyzed"];
    
    return contentDict;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [m_myTableView deselectRowAtIndexPath:indexPath animated:YES];
//    NSMutableDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];
//    if (![GameCommon isEmtity:KISDictionaryHaveKey(dict, @"isFund")]) {
//        InterestingPerpleViewController *addVC = [[InterestingPerpleViewController alloc]init];
//        [self.navigationController pushViewController:addVC animated:YES];
//    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return m_dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableDictionary *dict = [m_dataArray objectAtIndex:indexPath.row];

//    if (![GameCommon isEmtity:KISDictionaryHaveKey(dict, @"isFund")]) {
//        static NSString *identifier =@"cell111";
//        FunEntranceCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//        if (cell ==nil) {
//            cell = [[FunEntranceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//        }
//        return cell;
//    }
    
    static NSString *identifier =@"cell";
    CircleHeadCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell ==nil) {
        cell = [[CircleHeadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.myCellDelegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    
    
    int m_currmagY =0;
    
    cell.tag = indexPath.row+100;
    
    indexPaths = [NSIndexPath indexPathForRow:cell.tag-100 inSection:0];
    
    NSString * headImages=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img");
    
    if ([GameCommon isEmtity:headImages]) {
        cell.headImgBtn.imageURL = nil;
    }else{
        cell.headImgBtn.imageURL = [ImageService getImageStr:headImages Width:80];
        
    }
    cell.headImgBtn.tag= indexPath.row;
    
    [cell.headImgBtn addTarget:self action:@selector(enterPersonCirclePage:) forControlEvents:UIControlEventTouchUpInside];
    
    //判断赞按钮状态显示相应的图标
    UIButton *button  = cell.zanBtn;
    NSString *isZan=KISDictionaryHaveKey(dict, @"isZan");
    if (isZan !=nil ){
        if([isZan intValue]==0){
            [button setBackgroundImage:[UIImage imageNamed:@"zan_circle_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"zan_circle_click"] forState:UIControlStateHighlighted];
        }else{
            [button setBackgroundImage:[UIImage imageNamed:@"cancle_zan_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"cancle_zan_click"] forState:UIControlStateHighlighted];
        }
    }
    
    NSMutableDictionary *userD=KISDictionaryHaveKey(dict, @"user");
    NSString * nickName=KISDictionaryHaveKey(userD, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(userD, @"nickname");
    }
    
    cell.nickNameLabel.text =nickName;
    m_currmagY += cell.nickNameLabel.frame.size.height+cell.nickNameLabel.frame.origin.y;//加上nickName的高度
    cell.commentCount = [KISDictionaryHaveKey(dict, @"commentNum")intValue];
    
    //计算时间
    NSString *time;
    if(![[dict allKeys]containsObject:@"MessageTime"]){
        time = [self getTimeWithMessageTime:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")]];
    }
    else
    {
        time =KISDictionaryHaveKey(dict, @"MessageTime");
    }
    cell.timeLabel.text = time;
    
    //开始正文布局
    NSString *urlLink = KISDictionaryHaveKey(dict, @"urlLink");
        //动态
        if ([urlLink isEqualToString:@" "]||[urlLink isEqualToString:@""]||urlLink ==nil) {
            cell.shareView.hidden = YES;
            cell.contentLabel.hidden = YES;
            cell.shareImgView.hidden = YES;
            [cell.titleLabel setEmojiText:KISDictionaryHaveKey(dict, @"msg")];
            
            //动态的高度
            float height1 = [KISDictionaryHaveKey(dict, @"titleLabelHieght") floatValue];
            cell.titleLabel.frame = CGRectMake(60, 30, 250, height1);
            m_currmagY += height1 + 5;
            
        
            //无图动态
            if ([KISDictionaryHaveKey(dict, @"img") isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img") isEqualToString:@" "]) {
            cell.customPhotoCollectionView.hidden =YES;

                cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
                cell.openBtn.frame = CGRectMake(270,m_currmagY+5, 50, 40);
            if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
                cell.delBtn.hidden =NO;
                cell.delBtn.frame = CGRectMake(190,m_currmagY+11,50, 30);
                
            }else{
                cell.delBtn.hidden =YES;
            }
            
        }
            //有图动态
            else{
            NSArray *imgArray = KISDictionaryHaveKey(dict, @"imgArray");
                [cell getImgWithArray:imgArray];
            cell.customPhotoCollectionView.hidden = NO;
            
            float imgHeight = [KISDictionaryHaveKey(dict, @"imgHieght") floatValue];
            cell.customPhotoCollectionView.frame = CGRectMake(60, m_currmagY, 250,imgHeight);
            m_currmagY += imgHeight;
    

            cell.timeLabel.frame = CGRectMake(60,m_currmagY, 120, 30);
            cell.openBtn.frame = CGRectMake(270,m_currmagY-5, 50, 40);
            
            //删除按钮 - 自己的文章
            if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
                cell.delBtn.hidden =NO;
                cell.delBtn.frame = CGRectMake(150,m_currmagY+1,50, 30);
                
            }else{
                cell.delBtn.hidden =YES;
            }
        }
            
            m_currmagY=cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
        //后台文章 - URLlink有内容的
        else
        {
        cell.shareView.hidden = NO;
        cell.contentLabel.hidden = NO;
        cell.shareImgView.hidden = NO;
        cell.customPhotoCollectionView.hidden =YES;
        cell.titleLabel.text = KISDictionaryHaveKey(dict, @"title");
        
        float titleLabelHeight;
        //文章高度
        titleLabelHeight = [KISDictionaryHaveKey(dict, @"titleLabelHieght") floatValue];
        cell.titleLabel.frame = CGRectMake(60, 30, 250, titleLabelHeight);
        cell.shareView.frame = CGRectMake(60, titleLabelHeight+35, 250, 50);
            //titleLabelHeight +=5;
        m_currmagY += titleLabelHeight+50 ;
            
        //去除掉首尾的空白字符和换行字符
        NSString *str = KISDictionaryHaveKey(dict, @"msg");
        str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
        str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        cell.contentLabel.text =str;
            
    
        [cell.shareView addTarget:self action:@selector(enterInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareView.tag = indexPath.row;
        
            //无图文章
        if ([KISDictionaryHaveKey(dict, @"img")isEqualToString:@""]||[KISDictionaryHaveKey(dict, @"img")isEqualToString:@" "]) {
            cell.shareImgView.imageURL =nil;
            cell.shareImgView.hidden =YES;
            cell.contentLabel.frame = CGRectMake(5, 5, 245, 40);
            cell.contentLabel.numberOfLines =2;
        }else{  //有图文章
            cell.shareImgView.hidden =NO;
            NSString * imageId=KISDictionaryHaveKey(dict, @"img");
            cell.shareImgView.imageURL = [ImageService getImageUrl4:imageId];
            
//            cell.shareImgView.imageURL = [NSURL URLWithString:[BaseImageUrl stringByAppendingString:KISDictionaryHaveKey(dict, @"img")]];
            
            
            cell.contentLabel.frame = CGRectMake(60, 5, 190, 40);
            cell.contentLabel.numberOfLines = 2;
        }
        
        cell.timeLabel.frame = CGRectMake(60,m_currmagY+10, 120, 30);
        cell.openBtn.frame = CGRectMake(270,m_currmagY+5, 50, 40);
            
            //删除按钮 - 如果是自己发表的文章
        if ([KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
            cell.delBtn.hidden =NO;
            cell.delBtn.frame = CGRectMake(190,m_currmagY+11,50, 30);
            
        }else{
            cell.delBtn.hidden =YES;
        }
         m_currmagY  = cell.timeLabel.frame.origin.y + cell.timeLabel.frame.size.height;
    }
    
    // 赞，取最后一个用户的昵称显示
    if ([KISDictionaryHaveKey(dict, @"zanNum")intValue]!=0) {
        NSArray *array = KISDictionaryHaveKey(dict, @"zanList");
        if (array.count>0){ //以前的数据有些没有zanlist
        cell.zanView.frame = CGRectMake(59, m_currmagY, 251, 25);
        
        NSMutableDictionary *userDic=[array objectAtIndex:0];
        NSString * zanNickName=KISDictionaryHaveKey(userDic, @"alias");
        if ([GameCommon isEmtity:zanNickName]) {
            zanNickName=KISDictionaryHaveKey(userDic, @"nickname");
        }
//        NSString *zanNickName=KISDictionaryHaveKey([array objectAtIndex:0], @"nickname");
        
        cell.zanView.hidden = NO;
        cell.zanNameLabel.text = zanNickName;
        CGSize size =[zanNickName sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        cell.zanNameLabel.frame = CGRectMake(15, 0, size.width+5, 30);
        cell.zanLabel.text = [NSString stringWithFormat:@"等%@人都觉得赞",KISDictionaryHaveKey(dict,@"zanNum")];
        cell.zanLabel.frame  = CGRectMake(20+size.width, 0, 225-15-size.width, 30);
        m_currmagY +=cell.zanView.frame.size.height;
        }
        else
        {
            cell.zanView.hidden = YES;
        }
        
    }else{
        cell.zanView.hidden = YES;
    }
    
    // 评论
    commentArray =KISDictionaryHaveKey(dict, @"commentList");
//    cell.commentArray = commentArray;
    [cell getCommentArray:commentArray];
    cell.commentTabelView.backgroundColor = UIColorFromRGBA(0xf0f1f3, 1);
    
    float commHieght = [KISDictionaryHaveKey(dict, @"commentListHieght") floatValue];
    cell.commentTabelView.frame = CGRectMake(60, m_currmagY, 250,commHieght);
    m_currmagY+= commHieght;
    if ([KISDictionaryHaveKey(dict, @"commentNum")intValue]>7) {
        cell.commentMoreBtn.hidden = NO;
        cell.commentMoreBtn.frame = CGRectMake(60, m_currmagY, 250, 20);
        [cell.commentMoreBtn setTitle:[NSString stringWithFormat:@"查看全部%@条评论",KISDictionaryHaveKey(dict, @"commentNum")] forState:UIControlStateNormal];
    }else{
        cell.commentMoreBtn.hidden = YES;
        cell.commentMoreBtn.frame = CGRectZero;
    }
    
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //用分析器初始化m_dataArray
    NSMutableDictionary *dict =[m_dataArray objectAtIndex:indexPath.row];
    
//    if (![GameCommon isEmtity:KISDictionaryHaveKey(dict, @"isFund")]) {
//        return 50;
//    }
    
    dict = [self contentAnalyzer:dict withReAnalyzer:NO];
    float currnetY = [KISDictionaryHaveKey(dict, @"cellHieght") floatValue];
        
    //以动态id为键存放每个cell的高度到集合里
    NSNumber *number = [NSNumber numberWithFloat:currnetY];
    [cellhightarray setObject:number forKey:KISDictionaryHaveKey(dict, @"id")];
    return currnetY;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --enter MyCircleViewController page 进入个人朋友圈界面

-(void)enterPersonCirclePage:(UIButton *)sender
{
    NSDictionary *dict = [m_dataArray objectAtIndex:sender.tag];
    TestViewController *VC = [[TestViewController alloc]init];
    VC.userId = [GameCommon getHeardImgId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"userid")];
    NSMutableDictionary *userDic=KISDictionaryHaveKey(dict, @"user");
    NSString * nickName=KISDictionaryHaveKey(userDic, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(userDic, @"nickname");
    }
    VC.nickName =nickName;
   // VC.imageStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img")];
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark --enter OnceDynamicViewController Page  进入动态详情界面
-(void)enterInfoPage:(UIButton *)sender
{
    NSDictionary *dict = [m_dataArray objectAtIndex:sender.tag];
    
    OnceDynamicViewController *detailVC = [[OnceDynamicViewController alloc]init];
    detailVC.messageid = KISDictionaryHaveKey(dict, @"id");
    
    NSString * imageIds=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"user"), @"img");
    detailVC.imgStr = [ImageService getImgUrl:imageIds];
    
    NSMutableDictionary *userDic=KISDictionaryHaveKey(dict, @"user");
    NSString * nickName=KISDictionaryHaveKey(userDic, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(userDic, @"nickname");
    }
    
    
    detailVC.nickNameStr = [KISDictionaryHaveKey(dict, @"userid") isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]] ? @"我" :nickName;
    
    
    detailVC.timeStr =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"createDate")];

    [self.navigationController pushViewController:detailVC animated:YES];

}

#pragma mark --改变顶部图片
-(void)changeTopImage:(UITapGestureRecognizer*)sender
{
    UIActionSheet *acs = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"相机", nil];
    acs.tag =9999999;
    [acs showInView:self.view];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag ==9999999) {
        UIImagePickerController * imagePicker;
        if (buttonIndex==1)
            //这里捕捉“毁灭键”,其实该键的index是0，从上到下从0开始，称之为毁灭是因为是红的
        {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate=self;
                imagePicker.allowsEditing = YES;
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
                imagePicker.allowsEditing = YES;
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

    }else if(actionSheet.tag ==888888){
        if (buttonIndex==0) {
            
            [self delcomment];
        }else{
            return;
        }
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerEditedImage"];
    NSString * imagePath=[self writeImageToFile:upImage ImageName:@"topImage.jpg"];
    [self uploadbgImg:imagePath];
//    [self uploadbgImg:upImage];
    topImgaeView.image = upImage;
   
}
//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg ImageName:(NSString*)imageName
{
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@",path,imageName];
    
    NSData *data = UIImageJPEGRepresentation(thumbimg, 0.7);
    
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:[NSString stringWithFormat:@"topImageData_wx_%@",kMYUSERID]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
    if ([data writeToFile:openImgPath atomically:NO]) {
        return openImgPath;
    }
    return nil;
}
#pragma mark --getTime //时间戳方法
- (NSString*)getTimeWithMessageTime:(NSString*)messageTime
{
    NSString* currentString = [GameCommon getCurrentTime];
    if (messageTime.length < 10 || currentString.length < 10) {
        return @"未知";
    }
    // NSString * finalTime;
    NSString* curStr = [currentString substringToIndex:messageTime.length-3];
    NSString* mesStr = [messageTime substringToIndex:messageTime.length-3];
    
    double theCurrentT = [curStr doubleValue];
    double theMessageT = [mesStr doubleValue];
    
    if (((int)(theCurrentT-theMessageT))<60) {
        return @"1分钟以前";
    }
    if (((int)(theCurrentT-theMessageT))<60*59) {
        return [NSString stringWithFormat:@"%.f分钟以前",((theCurrentT-theMessageT)/60+1)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*24) {
        return [NSString stringWithFormat:@"%.f小时以前",((theCurrentT-theMessageT)/3600)==0?1:((theCurrentT-theMessageT)/3600)];
    }
    if (((int)(theCurrentT-theMessageT))<60*60*48) {
        return @"昨天";
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *messageDateStr = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:theMessageT]];
    return [messageDateStr substringFromIndex:5];
}
#pragma mark ---cell delegate  openMenuCell
- (void)openMenuCell:(CircleHeadCell*)myCell
{
    if(openMenuBtn) //如果有打开的cell
    {
        //关闭它
        CircleHeadCell* cell = openMenuBtn;
        cell.menuImageView.hidden = YES;
        if (openMenuBtn.tag == myCell.tag) {    //如果打开的是自己
            openMenuBtn=nil;
            return;
        }
    }
        [myCell.contentView bringSubviewToFront:myCell.menuImageView];
        [myCell.contentView  becomeFirstResponder];
        myCell.menuImageView.hidden = NO;
        openMenuBtn=myCell;}
#pragma mark ---cell delegate  commentAndZan
//评论button方法
-(void)pinglunWithCircle:(CircleHeadCell *)myCell
{
    destuserId=@"";
    self.textView.text = nil;
    self.textView.placeholder= nil;
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag-100];
    isComeBackComment = NO;
    commentMsgId =KISDictionaryHaveKey(dic, @"id");
    myCell.menuImageView.hidden = YES;
    [self.textView becomeFirstResponder];
    [self keyboardLocation:myCell];
}
#pragma mark--删除动态方法
-(void)delCellWithCell:(CircleHeadCell *)myCell
{
    delCellAlertView = [[UIAlertView alloc ]initWithTitle:@"提示" message:@"您确认删除这条动态吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    delCellCount = myCell.tag;
    [delCellAlertView show];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        return;
    }
    NSDictionary *dic =[m_dataArray objectAtIndex:(delCellCount-100)];
    NSLog(@"dic---%@",dic);
    [self delCellWithMsgId:KISDictionaryHaveKey(dic, @"id")];
}


//删除动态230746
-(void)delCellWithMsgId:(NSString *)msgId
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgId forKey:@"messageId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"193" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *dic = [[NSUserDefaults standardUserDefaults]objectForKey:@"dynamicFromMe_wx"];
        if ([KISDictionaryHaveKey(dic, @"id")intValue]==[KISDictionaryHaveKey([m_dataArray objectAtIndex:delCellCount-100], @"id")intValue]) {
            [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"dynamicFromMe_wx"];
        }
        
        
        
        [m_dataArray removeObjectAtIndex:delCellCount-100];
        [m_myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:delCellCount-100 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
        [m_myTableView reloadData];
        if (delCellCount-100<20) {
//            NSString * path = [RootDocPath stringByAppendingString:@"/circleFriend_huancun_01_wx"];
//            NSMutableArray *array = [NSMutableArray arrayWithContentsOfFile:path];
//            [array removeObjectAtIndex:delCellCount-100];
            [self saveinfoToUserDefaults:m_dataArray];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
        
    }];

}

#pragma mark ---评论赞 点击方法
-(void)zanWithCircle:(CircleHeadCell *)myCell
{
    NSLog(@"赞");
    NSDictionary *zanDic= [m_dataArray objectAtIndex:myCell.tag-100];
    myCell.menuImageView.hidden = YES;
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    [commentUser setObject:@"" forKey:@"img"];
    [commentUser setObject:[DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]] forKey:@"nickname"];
    [commentUser setObject:@"0" forKey:@"superstar"];
    [commentUser setObject:@"" forKey:@"userid"];
    [commentUser setObject:@"" forKey:@"username"];
    
    
    for (NSMutableDictionary *dic in m_dataArray) {
        if ([KISDictionaryHaveKey(dic, @"id") intValue]==[KISDictionaryHaveKey(zanDic, @"id") intValue]) {

            NSMutableArray *arr = KISDictionaryHaveKey(dic, @"zanList");
            int commentNum  = [KISDictionaryHaveKey(dic, @"zanNum")intValue];
             NSString *isZan=KISDictionaryHaveKey(dic, @"isZan");
            NSString *userid = KISDictionaryHaveKey(KISDictionaryHaveKey(dic, @"user"),@"userid");
            if ([userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
                [self showAlertViewWithTitle:@"提示" message:@"您不能对自己进行赞" buttonTitle:@"确定"];
                return;
            }
            if ([isZan intValue]==0) {//假如是未赞状态
                if (commentNum<=0) {
                    float temphight=[[cellhightarray objectForKey:KISDictionaryHaveKey(zanDic, @"id")]floatValue];
                    temphight+=30;
                    NSNumber *number = [NSNumber numberWithFloat:temphight];
                    [cellhightarray removeObjectForKey:KISDictionaryHaveKey(zanDic, @"id")];
                    [cellhightarray setObject:number forKey:KISDictionaryHaveKey(zanDic, @"id")];
                }
                [arr insertObject:commentUser atIndex:0];
                [dic setValue:[NSString stringWithFormat:@"%d",commentNum+1] forKey:@"zanNum"];
                [dic setValue:[NSString stringWithFormat:@"%d",1] forKey:@"isZan"];
                [self showMessageWindowWithContent:@"赞已成功" imageType:0];
                if (commentNum<1) {
                    [dic setObject:@([KISDictionaryHaveKey(dic, @"cellHieght")floatValue]+30) forKey:@"cellHieght"];
                }
                [m_myTableView reloadData];

                //请求网络点赞
                [self postZanWithMsgId:KISDictionaryHaveKey(zanDic, @"id") IsZan:YES];
            }else{//假如是已经赞的状态
                if (commentNum==1) {
                    float temphight=[[cellhightarray objectForKey:KISDictionaryHaveKey(zanDic, @"id")]floatValue];
                    temphight-=30;
                    NSNumber *number = [NSNumber numberWithFloat:temphight];
                    [cellhightarray removeObjectForKey:KISDictionaryHaveKey(zanDic, @"id")];
                    [cellhightarray setObject:number forKey:KISDictionaryHaveKey(zanDic, @"id")];
                }
                [arr removeObject:commentUser];
                [dic setValue:[NSString stringWithFormat:@"%d",commentNum-1] forKey:@"zanNum"];
                [dic setValue:[NSString stringWithFormat:@"%d",0] forKey:@"isZan"];
                [self showMessageWindowWithContent:@"已取消" imageType:0];
                if (commentNum==1) {
                    [dic setObject:@([KISDictionaryHaveKey(dic, @"cellHieght")floatValue]-30) forKey:@"cellHieght"];
                }
                [m_myTableView reloadData];
                //请求网络取消
                [self postZanWithMsgId:KISDictionaryHaveKey(zanDic, @"id") IsZan:NO];
            }
            if (myCell.tag-100<20) {
                [self saveinfoToUserDefaults:m_dataArray];
            }
            
        }
    }
}

- (void)handleNickNameButton_HeadCell:(CircleHeadCell*)cell withIndexPathRow:(NSInteger)row
{
    TestViewController *testVC = [[TestViewController alloc]init];
    NSDictionary *dic = [m_dataArray objectAtIndex:cell.tag-100];
    NSDictionary *dict = [KISDictionaryHaveKey(dic, @"commentList") objectAtIndex:row];
    if ( [KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"userid")isEqualToString:@""]) {
        return;
    }
    NSString *userid = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"userid");
    NSString *nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
    testVC.userId =userid;
    testVC.nickName = nickName;
    testVC.viewType = VIEW_TYPE_STRANGER1;
    [self.navigationController pushViewController:testVC animated:YES];
}

-(void)tapZanNickNameWithCell:(CircleHeadCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag-100];
    NSDictionary *zanDic  = [KISDictionaryHaveKey(dic,@"zanList")objectAtIndex:0];
    TestViewController *testVC = [[TestViewController alloc]init];
    NSString *userid =KISDictionaryHaveKey(zanDic, @"userid");
    NSString * nickName=KISDictionaryHaveKey(zanDic, @"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(zanDic, @"nickname");
    }
//    NSString *nickName = KISDictionaryHaveKey(zanDic, @"nickname");
    testVC.userId =userid;
    testVC.nickName = nickName;
    [self.navigationController pushViewController:testVC animated:YES];
 
}


#pragma mark-------
#pragma mark ---发送评论
-(void)updateComment
{
    NSLog(@"commentView-->%@",self.textView.text);

    if (self.textView.text.length<1) {
        [self showMessageWithContent:@"评论不能回复空内容" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    if([self.textView isFirstResponder]){
        [self.textView resignFirstResponder];
    }
    if(self.theEmojiView.hidden == NO){
        self.theEmojiView.hidden = YES;
        [self autoMovekeyBoard:-inPutView.bounds.size.height];
        self.commentInputType = CommentInputTypeKeyboard;
        senderBnt.selected = NO;
    }
    
    //离线评论
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSMutableDictionary *commentUser = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    NSString * nickName = [DataStoreManager queryNickNameForUser:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    [commentUser setObject:@"" forKey:@"img"];
    [commentUser setObject:nickName forKey:@"nickname"];
    [commentUser setObject:@"0" forKey:@"superstar"];
    [commentUser setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID] forKey:@"userid"];
    [commentUser setObject:@"" forKey:@"username"];
   NSString* comment = self.textView.text;

    if (self.textView.placeholder!=nil) {
        NSMutableDictionary *destUser = [NSMutableDictionary dictionary];
        [destUser setObject:KISDictionaryHaveKey(commentOffLineDict, @"id") forKey:@"id"];
        [destUser setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(commentOffLineDict, @"commentUser"), @"nickname") forKey:@"nickname"];
        [destUser setObject:KISDictionaryHaveKey(KISDictionaryHaveKey(commentOffLineDict, @"commentUser"), @"userid") forKey:@"userid"];
        dict =[ NSMutableDictionary dictionaryWithObjectsAndKeys:comment,@"comment",commentUser,@"commentUser",uuid,@"uuid",@"",@"id",@(0),@"commentCellHieght",destUser,@"destUser", nil];
    }else{
      dict =[ NSMutableDictionary dictionaryWithObjectsAndKeys:comment,@"comment",commentUser,@"commentUser",uuid,@"uuid",@"",@"id",@(0),@"commentCellHieght", nil];
    }
    
    //将评论添加到数组里、
    int i = -1;
    for (int j = 0;j<m_dataArray.count;j++) {
        NSMutableDictionary *dic = [m_dataArray objectAtIndex:j];
        if ([KISDictionaryHaveKey(dic, @"id") intValue]==[commentMsgId intValue]) {
            //添加赞数
            int commentNum  = [KISDictionaryHaveKey(dic, @"commentNum")intValue];
            [dic setObject:[NSString stringWithFormat:@"%d",commentNum+1] forKey:@"commentNum"];
            NSMutableArray *arr = KISDictionaryHaveKey(dic, @"commentList");
            [arr insertObject:dict atIndex:0];
            dic = [self contentAnalyzer:dic withReAnalyzer:YES];    //分析器强制更新这一条
            i = [m_dataArray indexOfObject:dic];
        }
    }
    if (i>=0&&i<20) {
        [self saveinfoToUserDefaults:m_dataArray];
    }
    [self showMessageWindowWithContent:@"评论成功" imageType:0];
    [m_myTableView reloadData];
    //执行提交评论操作
    [self postCommentWithMsgId:commentMsgId destUserid:destuserId destCommentId:destMsgId comment:self.textView.text uuid:uuid];
    [self.textView resignFirstResponder];
    commentMsgId =nil;
    destuserId = nil;
    destMsgId = nil;
}

-(void)saveinfoToUserDefaults:(NSMutableArray *)array
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[RootDocPath stringByAppendingString:@"/circleFriend_huancun_01_wx_"] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    BOOL isTrue = [fileManager fileExistsAtPath:path];
    NSDictionary *fileAttr = [fileManager attributesOfItemAtPath:path error:NULL];
    
    if (isTrue && [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue] != 0) {
        NSArray *clearArray = [NSArray array];
        [clearArray writeToFile:path atomically:YES];
        [array writeToFile:path atomically:YES];
    }else{
        [array writeToFile:path atomically:YES];
    }
}
#pragma mark ---tableviewdelegate ----点击自己发的评论-删除  点击他人评论 回复
//点击删除或者点击回复某人的评论
- (void)editCommentOfYouWithCircle:(CircleHeadCell *)mycell withIndexPath:(NSInteger)row
{
    NSDictionary *dic = [m_dataArray objectAtIndex:mycell.tag-100];
    NSDictionary *dict = [KISDictionaryHaveKey(dic, @"commentList") objectAtIndex:row];
    //点击的是自己的评论，弹出删除菜单
    if( [KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"userid")isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
        
        NSString *msgid =[NSString stringWithFormat:@"%@", KISDictionaryHaveKey(dict, @"id")];
        if ([msgid isEqualToString:@""]||[msgid isEqualToString:@" "]) {
            return;
        }
        
        
        UIActionSheet *act = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除评论" otherButtonTitles: nil];
        act.tag = 888888;
        
        [delcommentDic removeAllObjects];
        [delcommentDic setObject:@(mycell.tag-100) forKey:@"mycell"];
        [delcommentDic setObject:@(row) forKey:@"row"];
        [act showInView:self.view];
    }else{//点击的是别人的评论，弹出评论框
        self.textView.text = nil;
        self.textView.placeholder= nil;
        [self.textView becomeFirstResponder];
        [self keyboardLocation:mycell];
        isComeBackComment = YES;
        NSDictionary *dic = [m_dataArray objectAtIndex:mycell.tag-100];
        commentMsgId =KISDictionaryHaveKey(dic, @"id");
        NSArray *array = [dic objectForKey:@"commentList"];
        NSDictionary *dict = [array objectAtIndex:row];
        NSString * nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"alias");
        if ([GameCommon isEmtity:nickName]) {
            nickName=KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
        }
//        NSString* nickName = KISDictionaryHaveKey(KISDictionaryHaveKey(dict, @"commentUser"), @"nickname");
        self.textView.placeholder = [NSString stringWithFormat:@"回复 %@：", nickName];
        self.textView.placeholderColor = [UIColor grayColor];
        
        //将对方信息保存在临时变量
        [commentOffLineDict setDictionary:dict];
        destMsgId =KISDictionaryHaveKey(dict, @"id");
        destuserId = KISDictionaryHaveKey(KISDictionaryHaveKey(dict,@"commentUser"), @"userid");
    }
}
//tableView定位
-(void)keyboardLocation:(CircleHeadCell *)mycell
{
    for (int i=0; i<(mycell.tag-100+1); i++) {
        NSDictionary *dict =[m_dataArray objectAtIndex:i];
        offer+=[[cellhightarray objectForKey:KISDictionaryHaveKey(dict, @"id")]floatValue];
    }
    if(iPhone5){
        offer+=(300-height-15);
    }else{
        offer+=(300-height+65);
    }
    if (abobtMeImageView.hidden==NO) {
        offer+=60;
    }
    [m_myTableView scrollRectToVisible:CGRectMake(0, offer, m_myTableView.frame.size.width, m_myTableView.frame.size.height) animated:YES];
    offer=0;
}
#pragma mark --- clickseeBigImage
//点击查看大图
- (void)bigImgWithCircle:(CircleHeadCell*)myCell WithIndexPath:(NSInteger)row
{
    NSLog(@"点击查看大图");
    NSDictionary *dict = [m_dataArray objectAtIndex:myCell.tag-100];
    NSArray *array = [NSArray  array];

    NSString *imgStr =KISDictionaryHaveKey(dict, @"img");
    NSString *str;
    if ([imgStr isEqualToString:@""] || [imgStr isEqualToString:@" "]) {
        str = @"";
    }else{
        str = [imgStr substringFromIndex:imgStr.length-1];
        NSString *str2;
        if ([str isEqualToString:@","]) {
            str2= [imgStr substringToIndex:imgStr.length-1];
        }
        else {
            str2 = imgStr;
        }
        array = [NSArray array];
        array = [str2 componentsSeparatedByString:@","];
    }
    PhotoViewController * pV = [[PhotoViewController alloc] initWithSmallImages:nil images:array indext:row];
    [self presentViewController:pV animated:NO completion:^{
    }];

}

#pragma mark ---addRefreshHeadview and refreshFootView 
//添加下拉刷新
-(void)addheadView
{
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.activityView.center = header.arrowImage.center;
    header.scrollView = m_myTableView;
    
    header.scrollView = m_myTableView;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        m_currPageCount = 0;
        [self getInfoFromNet];
    };
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
    };
  //  [header beginRefreshing];
    m_header = header;
}

//添加上拉加载更多
-(void)addFootView
{
    MJRefreshFooterView *footer = [MJRefreshFooterView footer];
    CGRect headerRect = footer.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    footer.arrowImage.frame = headerRect;
    footer.activityView.center = footer.arrowImage.center;
    footer.scrollView = m_myTableView;
    
    footer.scrollView = m_myTableView;
    footer.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        [self getInfoFromNet];
    };
    m_footer = footer;
}


//上传赞
-(void)postZanWithMsgId:(NSString *)msgid IsZan:(BOOL)isZan
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgid forKey:@"messageId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"185" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    
    
    
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        NSString* uuid = [[GameCommon shareGameCommon] uuid];
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:
                             msgid,@"msgId",
                             uuid,@"uuid",nil];
        [DataStoreManager saveOfflineZanWithDic:dic];
    }
    else{
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [m_myTableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [m_myTableView reloadData];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}
}

//删除评论
-(void)delcomment
{
    
    NSMutableDictionary *dic = [m_dataArray objectAtIndex:[[delcommentDic objectForKey:@"mycell"]intValue]];
    NSMutableArray *arr = [dic objectForKey:@"commentList"];
    NSString *msgId = KISDictionaryHaveKey([arr objectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]], @"id");
    [NSCharacterSet decimalDigitCharacterSet];

   
    hud.labelText = @"删除中...";
    [hud show:YES];
   
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgId forKey:@"commentId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"195" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [hud hide:YES];
        
        [dic setObject:@([KISDictionaryHaveKey(dic, @"commentListHieght")floatValue]-[KISDictionaryHaveKey([arr objectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]], @"commentCellHieght")floatValue]) forKey:@"commentListHieght"];
        
        [dic setObject:@([KISDictionaryHaveKey(dic, @"cellHieght")floatValue]-[KISDictionaryHaveKey([arr objectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]], @"commentCellHieght")floatValue]) forKey:@"cellHieght"];
        
        [cellhightarray removeObjectForKey:KISDictionaryHaveKey(dic, @"id")];
        [self showMessageWindowWithContent:@"删除成功" imageType:0];
        [arr removeObjectAtIndex:[[delcommentDic objectForKey:@"row"]intValue]];
        [m_myTableView reloadData];
        
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
//上传评论
-(void)postCommentWithMsgId:(NSString *)msgid destUserid:(NSString *)destUserid destCommentId:(NSString *)destCommentId comment:(NSString *)comment uuid:(NSString *)uuid
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:msgid forKey:@"messageId"];
    if (isComeBackComment ==YES) {
    [paramDic setObject:destUserid?destUserid:@"" forKey:@"destUserid"];
    [paramDic setObject:destCommentId?destCommentId:@"" forKey:@"destCommentId"];
    }
    [paramDic setObject:comment forKey:@"comment"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"186" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
   
        //如果没有网，将数据保存到数据库。。。。
    if (app.reach.currentReachabilityStatus ==NotReachable) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:msgid forKey:@"msgId"];
        [dict setObject:destUserid?destUserid:@"" forKey:@"destUserid"];
        [dict setObject:destCommentId?destCommentId:@"" forKey:@"destCommentId"];
        [dict setObject:comment forKey:@"comments"];
        [dict setObject:uuid forKey:@"uuid"];
        [DataStoreManager saveCommentsWithDic:dict];
        return;
    }
    else{
        [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if(![responseObject isKindOfClass:[NSDictionary class]]){
                return ;
            }
            for (int i = 0; i <m_dataArray.count; i++) {
                NSDictionary *dic = [m_dataArray objectAtIndex:i];
                if ([KISDictionaryHaveKey(dic, @"id")intValue]==[msgid intValue]) {
                    NSArray *array = [dic objectForKey:@"commentList"];
                    for (int i = 0; i < array.count; i++) {
                        NSMutableDictionary *commDic = (NSMutableDictionary *)[array objectAtIndex:i];
                        if ([[commDic allKeys]containsObject:@"uuid"]&&[[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(commDic, @"uuid")]isEqualToString:uuid]) {
                            [commDic setObject:KISDictionaryHaveKey(responseObject, @"id") forKey:@"id"];
                        }
                    }
                }
            }
            [m_myTableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, id error) {
            if ([error isKindOfClass:[NSDictionary class]]) {
                if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
                {
                    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                }
            }
        }];
    }
    
    [self.textView resignFirstResponder];
    self.textView.text = nil;
    self.textView.placeholder= nil;
    
}
//#pragma mark --上传顶部图片
-(void)uploadbgImg:(NSString*)uploadImagePath
{
    [hud show:YES];
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:uploadImagePath UpDeleGate:self];

}


// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
//    hud.labelText = [NSString stringWithFormat:@"正在上传 %.2f％",percent];
    
}
/**
 {
 hash = Fg1pj8Y3tNOB905kaCeaAUBrEC94;
 key = 340480FC3CD34A26A45A1D8C386D0104;
 }
 **/
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    [hud hide:YES];
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    if (response) {
        [self uploadsuccessImg:response];
    }
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    [hud hide:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"发送图片失败请重新发送"
                                                   delegate:nil
                                          cancelButtonTitle:@"知道啦"
                                          otherButtonTitles:nil];
    [alert show];
}




-(void)uploadsuccessImg:(NSString *)img
{
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:img forKey:@"coverImg"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"198" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];

}

#pragma mark----
#pragma mark ----查看全部评论
-(void)enterCommentPageWithCell:(CircleHeadCell *)myCell
{
    NSDictionary *dic = [m_dataArray objectAtIndex:myCell.tag-100];
    ReplyViewController *reply = [[ReplyViewController alloc]init];
    reply.messageid = KISDictionaryHaveKey(dic, @"id");
    reply.isHaveArticle = YES;
    [self.navigationController pushViewController:reply animated:YES];
}



- (void)keyboardWillShow:(NSNotification *)notification {
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    self.theEmojiView.hidden = YES;
    self.commentInputType = CommentInputTypeKeyboard;
    senderBnt.selected = NO;
    NSDictionary *userInfo = [notification userInfo];
    
    // Get the origin of the keyboard when it's displayed.
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // Get the top of the keyboard as the y coordinate of its origin in self's view's coordinate system. The bottom of the text view's frame should align with the top of the keyboard's final position.
    CGRect keyboardRect = [aValue CGRectValue];
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    // Animate the resize of the text view's frame in sync with the keyboard's appearance.
    [self autoMovekeyBoard:keyboardRect.size.height];
    height = keyboardRect.size.height;
}


- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary* userInfo = [notification userInfo];
    
    /*
     Restore the size of the text view (fill self's view).
     Animate the resize so that it's in sync with the disappearance of the keyboard.
     */
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [self.view bringSubviewToFront:self.textView];
    [self autoMovekeyBoard:-inPutView.bounds.size.height];
}
-(void) autoMovekeyBoard: (float) h{
    
    //    [UIView beginAnimations:nil context:nil];
    //    [UIView setAnimationDuration:0.2];
	//inPutView.frame = CGRectMake(0.0f, (float)(self.view.frame.size.height-h-inPutView.frame.size.height), 320.0f, inPutView.frame.size.height);
    
    CGRect containerFrame = inPutView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (h + containerFrame.size.height);
	// animations settings
    
	// set views with new info
	inPutView.frame = containerFrame;
}
#pragma mark 输入
#pragma mark HPExpandingTextView delegate
//改变键盘高度
//改变键盘高度
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
	CGRect r = inPutView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	inPutView.frame = r;
}
//评论按钮
-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self updateComment];
    return YES;
}
//手势代理的方法，解决手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isKindOfClass:[UIButton class]]||[touch.view isKindOfClass:[UIScrollView class]])
    {
        return NO;
    }
    return YES;
}

-(void)bierenyedou:(id)sender
{
    InterestingPerpleViewController *invv = [[InterestingPerpleViewController alloc]init];
    [self.navigationController pushViewController:invv animated:YES];
}


-(void)hiddenOrShowMenuImageViewWithCell:(CircleHeadCell*)myCell
{
    
}
- (void)getmsgIdwithCircle:(CircleHeadCell *)myCell withindexPath:(NSInteger)row
{
    
}
-(void)transferClickEventsWithCell:(CircleHeadCell *)myCell withIndexPath:(NSInteger)row
{
    
}
- (void)handleNickNameButton:(CommentCell*)cell
{
    
}
-(void)dealloc
{
    delCellAlertView.delegate = nil;
}



@end
