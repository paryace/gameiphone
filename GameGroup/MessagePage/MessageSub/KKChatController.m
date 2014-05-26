//
//  KKChatController.m
//  XmppDemo
//
//  Created by 夏 华 on 12-7-12.
//  Copyright (c) 2012年 无锡恩梯梯数据有限公司. All rights reserved.
//


#import "KKChatController.h"
#import "MLNavigationController.h"
#import "AppDelegate.h"
#import "XMPPHelper.h"
#import "JSON.h"
#import "KKNewsCell.h"
#import "OnceDynamicViewController.h"
#import "ActivateViewController.h"
#import "TestViewController.h"
#import "MJRefresh.h"
#import "PhotoViewController.h"

#ifdef NotUseSimulator
#import "amrFileCodec.h"
#endif

#define kChatImageSizeWidth @"200"
#define kChatImageSizeHigh @"200"

#define padding 20
#define LocalMessage @"localMessage"
#define NameKeys @"namekeys"

typedef enum : NSUInteger {
    KKChatInputTypeNone,
    KKChatInputTypeKeyboard,
    KKChatInputTypeEmoji,
    KKChatInputTypeAdd
} KKChatInputType;

typedef enum : NSUInteger {
    KKChatMsgTypeText,
    KKChatMsgTypeLink,
    KKChatMsgTypeImage
} KKChatMsgType;

typedef void(^ChangMessageProgressBlock)(double progress,NSString *uuid);
typedef void(^SendImageMessageSuccessBlock)(BOOL isSucces);

@interface KKChatController ()<UIAlertViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
{
    NSMutableArray *messages;   //信息
    UIMenuItem *copyItem;
    UIMenuItem *delItem;
    BOOL myActive;
    NSMutableArray *wxSDArray;
    
}

@property (nonatomic, assign) KKChatInputType kkchatInputType;
@property (nonatomic, strong) UILabel *unReadL;
@property (nonatomic, strong) MJRefreshHeaderView *kkChatControllerRefreshHeadView;
@property (nonatomic, strong) UIButton *kkChatAddButton;
@property (nonatomic, strong) UIView *inPutView;
@property (nonatomic, strong) UIView *kkChatAddView;
@property (nonatomic, strong) EmojiView *theEmojiView;
@property (nonatomic, copy) ChangMessageProgressBlock changeMessageBlock;
@property (nonatomic, copy) SendImageMessageSuccessBlock sendImageMessageSuccessBlock;
@property (nonatomic, strong) KKMessageCell *currentCell;
@property (nonatomic, strong) NSMutableArray *messages;
@end

@implementation KKChatController

@synthesize myHeadImg;
@synthesize tView;
@synthesize messageTextField;
@synthesize chatWithUser;
@synthesize nickName;
@synthesize session;
@synthesize recorder;
@synthesize messages;

- (id)init
{
    self = [super init];
    if (self) {
        _unreadNo = 0;
    }
    return self;
}
- (void)loadView
{
    [super loadView];
    // If you create your views manually, you MUST override this method and use it to create your views.
    // If you use Interface Builder to create your views, then you must NOT override this method.
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (![[DataStoreManager queryMsgRemarkNameForUser:self.chatWithUser] isEqualToString:@""]) {
        self.nickName = [DataStoreManager queryMsgRemarkNameForUser:self.chatWithUser];//刷新别名
        self.titleLabel.text = self.nickName;
        //[self.tView reloadData];
    }
    
}

//初始化会话界面UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    //监听通知（收到新消息，与发送消息成功）
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageAck object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newMesgReceived:)
                                                 name:kNewMessageReceived
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(messageAck:)
                                                 name:kMessageAck
                                               object:nil];//消息是否发送成功
    

    
    wxSDArray = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeMyActive:)
                                                 name:@"wxr_myActiveBeChanged"
                                               object:nil];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",
                               [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    
    DSuser *friend = [DSuser MR_findFirstWithPredicate:predicate];
    myActive = [friend.action boolValue];
    postDict = [NSMutableDictionary dictionary];
    canAdd = YES;
    //previousTime = 0;
    touchTimeFinal = 0;
    touchTimePre = 0;
    uDefault = [NSUserDefaults standardUserDefaults];
    currentID = [uDefault objectForKey:@"account"];
    
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    //添加背景
    UIImageView * bgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                      0,
                                                                      320,
                                                                      self.view.frame.size.height)];
    bgV.backgroundColor = kColorWithRGB(246, 246, 246, 1.0);
    [self.view addSubview:bgV];
    
    //从数据库中取出与这个人的聊天记录
    messages = [[NSMutableArray alloc]
                initWithArray:[DataStoreManager
                               qureyCommonMessagesWithUserID:self.chatWithUser
                               FetchOffset:0]];
    
    
    NSLog(@"从数据库中取出与 %@ 的聊天纪律:messages%@",self.chatWithUser, messages);
    
    [self normalMsgToFinalMsg];
    [self sendReadedMesg];//发送已读消息???????????
    
    self.myHeadImg = [DataStoreManager
                      queryFirstHeadImageForUser_userManager:[[NSUserDefaults standardUserDefaults]
                                                              objectForKey:kMYUSERID]];
    
    [self.view addSubview:self.tView];
    [self kkChatAddRefreshHeadView];    //添加下拉刷新组件
    
    //滚动到最后一行/Users/admin/Desktop/gameiphone/GameGroup/MessagePage/MessageSub/chat/KKChatCell.m
    if (messages.count>0) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    
    ifAudio = NO;
    ifEmoji = NO;
    
    [self.view addSubview:self.inPutView];  //输入框
	
    [self setTopViewWithTitle:@"" withBackButton:YES];
    
    [self.view addSubview:self.titleLabel]; //导航条标题
    
    [self.view addSubview:self.unReadL]; //未读数量
    
    
    
    
//    [self registerKeybordNotification];
    
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
//    if (version >= 5.0) {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(keyboardWillShow:)
//                                                     name:UIKeyboardDidChangeFrameNotification
//                                                   object:nil];
//    }
//    else{
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
//    }
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    //???????????
//    btnLongTap = [[UILongPressGestureRecognizer alloc] initWithTarget:self
//                                                               action:@selector(btnLongTapAction:)];
//    btnLongTap.minimumPressDuration = 1;
    
    //清空此人所有的未读消息
    [DataStoreManager blankMsgUnreadCountForUser:self.chatWithUser];
    
    
    //图片与表情按钮
    [self.view addSubview:self.theEmojiView];
    self.theEmojiView.hidden = YES;
    [self.view addSubview:self.kkChatAddView];
    self.kkChatAddView.hidden = YES;
    
    //长按以后的按钮-》
    copyItem = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(copyMsg)];
    //    UIMenuItem *copyItem2 = [[UIMenuItem alloc] initWithTitle:@"转发"action:@selector(transferMsg)];
    delItem = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteMsg)];
    menu = [UIMenuController sharedMenuController];
    
    //个人资料按钮
    UIButton *profileButton=[UIButton buttonWithType:UIButtonTypeCustom];
    profileButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    [profileButton setBackgroundImage:[UIImage imageNamed:@"user_info_normal.png"] forState:UIControlStateNormal];
    [profileButton setBackgroundImage:[UIImage imageNamed:@"user_info_click.png"] forState:UIControlStateHighlighted];
    [profileButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.view addSubview:profileButton];
    [self.view bringSubviewToFront:profileButton];
    [profileButton addTarget:self action:@selector(userInfoClick) forControlEvents:UIControlEventTouchUpInside];
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"正在处理图片...";
    [self.view addSubview:hud];
    
}

#pragma mark ---TabView 显示方法
//用message构建一条TabViewCell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //数据读取
    NSMutableDictionary *dict = [messages objectAtIndex:indexPath.row];
   
    NSString *sender = KISDictionaryHaveKey(dict, @"sender");
    NSString *time = [KISDictionaryHaveKey(dict, @"time") substringToIndex:10];
    NSString *msgType = KISDictionaryHaveKey(dict, @"msgType");
    NSString *status = KISDictionaryHaveKey(dict, @"status");
    NSDictionary *payload = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
    //NSString *uuid = KISDictionaryHaveKey(payload, @"messageid");
    
    
    //动态消息
    if ([msgType isEqualToString:@"payloadchat"]) {
        
        //传说中的复用！
        static NSString *identifier = @"newsCell";
        KKNewsCell *cell =(KKNewsCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[KKNewsCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        
        CGSize size = CGSizeMake([[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:0] floatValue],
                                 [[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:1] floatValue]);
        size.width = size.width<20?20:size.width;
        size.height = size.height<20?20:size.height;
        
        NSDictionary* msgDic = [[self.finalMessageArray
                                 objectAtIndex:indexPath.row] JSONValue];
        
        CGSize titleSize = [self getPayloadMsgTitleSize:[GameCommon
                                                         getNewStringWithId:KISDictionaryHaveKey(msgDic, @"title")]];
        CGSize contentSize = CGSizeZero;
        cell.titleLabel.text = KISDictionaryHaveKey(msgDic, @"title");

        contentSize = [self getPayloadMsgContentSize:[GameCommon
                                                      getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msg")]
                                           withThumb:YES];
        
        //动态缩略图
        if ([GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"thumb")].length > 0 && ![KISDictionaryHaveKey(msgDic, @"thumb") isEqualToString:@"null"]) {
            NSString* imgStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"thumb")];
            NSURL * titleImage = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/30",imgStr]];
            cell.thumbImgV.imageURL = titleImage;
            
        }
        else
        {
            cell.thumbImgV.imageURL = nil;
        }
        
        cell.contentLabel.text = KISDictionaryHaveKey(msgDic, @"msg");
        UIImage *bgImage = nil;
        
        if ([sender isEqualToString:@"you"]) {
            
            //头像
            [cell setHeadImgByMe:self.myHeadImg];
            
            
            [cell.thumbImgV setFrame:CGRectMake(55,
                                                40 + titleSize.height,
                                                40,
                                                40)];
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"我", timeStr];
                        bgImage = [[UIImage imageNamed:@"bubble_05"]
                       stretchableImageWithLeftCapWidth:15
                       topCapHeight:22];
            
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30,
                                                  padding*2-15,
                                                  size.width+25,
                                                  size.height+20)];
            
            [cell.bgImageView setBackgroundImage:bgImage
                                        forState:UIControlStateNormal];
            
            
            //响应点击和长按
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchBegin:)
                       forControlEvents:UIControlEventTouchDown];
            
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchEnd:)
                       forControlEvents:UIControlEventTouchUpInside];
            
            [cell.bgImageView setTag:(indexPath.row+1)];
            
            
            [cell.titleLabel setFrame:CGRectMake(padding + 35,
                                                 33,
                                                 titleSize.width,
                                                 titleSize.height+(contentSize.height > 0 ? 0 : 5))];
            [cell.contentLabel setFrame:CGRectMake(padding + 50 +28,
                                                   35 + titleSize.height + (titleSize.height > 0 ? 5 : 0),
                                                   contentSize.width,
                                                   contentSize.height)];
            //刷新
            [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,
                                                 (size.height+20)/2 + padding*2-15)
                              status:status];
        }else
        {
            [cell.thumbImgV setFrame:CGRectMake(70,
                                                40 + titleSize.height,
                                                40,40)];
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", self.nickName, timeStr];
            
            [cell setHeadImgByChatUser:self.chatUserImg]; //头像设置成对方
            
            bgImage = [[UIImage imageNamed:@"bubble_04.png"]
                       stretchableImageWithLeftCapWidth:15
                       topCapHeight:22];
            
            [cell.bgImageView setFrame:CGRectMake(padding-10+45,
                                                  padding*2-15,
                                                  size.width+35,
                                                  size.height + 20)];
            
            [cell.bgImageView setBackgroundImage:bgImage
                                        forState:UIControlStateNormal];
            
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchBegin:)
                       forControlEvents:UIControlEventTouchDown];
            
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchEnd:)
                       forControlEvents:UIControlEventTouchUpInside];
            [cell.bgImageView setTag:(indexPath.row+1)];
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
            [cell.titleLabel setFrame:CGRectMake(padding + 50,
                                                 33,
                                                 titleSize.width,
                                                 titleSize.height+(contentSize.height > 0 ? 0 : 5))];
            [cell.contentLabel setFrame:CGRectMake(padding + 50 + 45,
                                                   35 + titleSize.height + (titleSize.height > 0 ? 5 : 0),
                                                   contentSize.width,
                                                   contentSize.height)];
        }
        
        //显示双方聊天的时间
        if (indexPath.row>0) {
            if ([time intValue]-[[[[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"] substringToIndex:10]intValue]<60) {
                cell.senderAndTimeLabel.hidden = YES;
            }
            else
            {
                cell.senderAndTimeLabel.hidden = NO;
            }
        }
        else
            cell.senderAndTimeLabel.hidden = NO;

        return cell;
    }
    
    //图片消息
    else if ([KISDictionaryHaveKey(payload, @"type") isEqualToString:@"img"]) {
        //CELL重用
        static NSString *identifier = @"imgCell";
        KKImgCell *cell = (KKImgCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKImgCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
       // cell.messageContentView.attributedText = [self.finalMessageArray objectAtIndex:indexPath.row];
        
        CGSize size = CGSizeMake([[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:0] floatValue],[[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:1] floatValue]);
        
        size.width = size.width<20?20:size.width;
        size.height = size.height<20?20:size.height;
        cell.progressView.hidden=YES;
        
        if ([sender isEqualToString:@"you"])
        {
            //设置时间Label
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"我", timeStr];
            
            //头像
            [cell setHeadImgByMe:self.myHeadImg];
            
            [cell.bgImageView setTag:(indexPath.row+1)];
            //failImage 失败图标
            [cell.failImage addTarget:self action:@selector(offsetButtonTouchBegin:) forControlEvents:UIControlEventTouchDown];
            [cell.failImage addTarget:self action:@selector(offsetButtonTouchEnd:) forControlEvents:UIControlEventTouchUpInside];
            [cell.failImage setTag:(indexPath.row+1)];
             cell.msgImageView.placeholderImage = [UIImage imageNamed:@"placeholder.png"];
               //根据uuid取缩略图
            NSString* uuid_thumimg = KISDictionaryHaveKey(dict, @"messageuuid");
//                NSLog(@"thumbimg取图%@",uuid);
//                NSMutableDictionary *finalimgs = self.finalImage;
            UIImage* thumbimg = KISDictionaryHaveKey(self.finalImage,uuid_thumimg);
            if (thumbimg&&thumbimg!=nil){
                cell.msgImageView.image = thumbimg;
            }
           // }
      
//            [cell.msgImageView setFrame:CGRectMake(320-size.width - padding-44,padding*2-15,size.width,size.height)];
            [cell.msgImageView setFrame:CGRectMake(320-size.width - padding-44,padding*2-15,100,100)];
            //显示为缩略图

            cell.msgImageView.hidden = NO;
            cell.msgImageView.tag = indexPath.row;
            [cell.progressView setFrame:CGRectMake(320-size.width - padding-44,padding*2-10+100,size.width,50)];
            
            //msgImageView响应手势
            cell.msgImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tabPress =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookBigImg:)];
            UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImg:)];
            [cell.msgImageView addGestureRecognizer:tabPress];
            [cell.msgImageView addGestureRecognizer:longPress];
            
            //刷新状态
            [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60,(size.height+20)/2 + padding*2-15)status:status];
        }
        else{
            //设置时间
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", self.nickName, timeStr];
            
            [cell setHeadImgByChatUser:self.chatUserImg]; //头像设置成对方
            
            [cell.bgImageView setTag:(indexPath.row+1)];
          
//            [cell.msgImageView setFrame:CGRectMake(220-size.width - padding-38,padding*2-15,size.width,size.height)];
            [cell.msgImageView setFrame:CGRectMake(220-size.width - padding-38,padding*2-15,100,100)];
            
            cell.msgImageView.tag = indexPath.row;
            cell.msgImageView.placeholderImage = [UIImage imageNamed:@"placeholder.png"];
            //显示为缩略图
            NSString *kkChatImageMsg = KISDictionaryHaveKey(payload, @"msg");
            NSURL *kkChatImageMsgUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/%@/%@",kkChatImageMsg,kChatImageSizeWidth,kChatImageSizeHigh]];
            cell.msgImageView.imageURL =kkChatImageMsgUrl;
            cell.msgImageView.hidden = NO;
            
            //msgImageView响应手势
            cell.msgImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tabPress =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookBigImg:)];
            UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self
                                                                                                   action:@selector(longPressImg:)];
            [cell.msgImageView addGestureRecognizer:tabPress];
            [cell.msgImageView addGestureRecognizer:longPress];
            
            //刷新
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
        }
        
        //显示双方聊天的时间
        if (indexPath.row > 0) {
            if ([time intValue]-[[[[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"] substringToIndex:10]intValue]<60) {
                cell.senderAndTimeLabel.hidden = YES;
            }
            else
            {
                cell.senderAndTimeLabel.hidden = NO;
            }
        }
        else
            cell.senderAndTimeLabel.hidden = NO;
        
        return  cell;
    }
    
    //普通消息
    else
    {
        //CELL重用
        static NSString *identifier = @"msgCell";
        KKMessageCell *cell = (KKMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKMessageCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        NSString* msg = KISDictionaryHaveKey(dict, @"msg");
        [cell.messageContentView setEmojiText:msg];
        
        CGSize size = CGSizeMake([[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:0] floatValue],
                                 [[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:1] floatValue]);
        
        size.width = size.width<20?20:size.width;
        size.height = size.height<20?20:size.height;

        
        UIImage *bgImage = nil;
        
        //你自己发送的消息
        if ([sender isEqualToString:@"you"]) {
            
            //设置时间Label
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", @"我", timeStr];
            
            //头像
            [cell setHeadImgByMe:self.myHeadImg];
            
            //设置背景气泡
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30,
                                                  padding*2-15,
                                                  size.width+25,
                                                  size.height+20)];
            
            bgImage = [[UIImage imageNamed:@"bubble_02.png"]
                       stretchableImageWithLeftCapWidth:15
                       topCapHeight:22];
            [cell.bgImageView setBackgroundImage:bgImage
                                        forState:UIControlStateNormal];
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchBegin:)
                       forControlEvents:UIControlEventTouchDown];
            
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchEnd:)
                       forControlEvents:UIControlEventTouchUpInside];
            
            [cell.bgImageView setTag:(indexPath.row+1)];
            
            //failImage 失败图标
            [cell.failImage addTarget:self
                               action:@selector(offsetButtonTouchBegin:)
                     forControlEvents:UIControlEventTouchDown];
            [cell.failImage addTarget:self
                               action:@selector(offsetButtonTouchEnd:)
                     forControlEvents:UIControlEventTouchUpInside];
            [cell.failImage setTag:(indexPath.row+1)];
            
            //如果是其他消息
            [cell.messageContentView setFrame:CGRectMake(320-size.width - padding-15-10-25,
                                                         padding*2-4,
                                                         size.width,
                                                         size.height)];
            cell.messageContentView.hidden = NO;
            
            //刷新
            [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,
                                                 (size.height+20)/2 + padding*2-15)
                              status:status];
          
        }else { //不是你，是对方
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@ %@", self.nickName, timeStr];
            
            [cell setHeadImgByChatUser:self.chatUserImg]; //头像设置成对方
            
            //设置背景气泡
            bgImage = [[UIImage imageNamed:@"bubble_01.png"]
                       stretchableImageWithLeftCapWidth:15
                       topCapHeight:22];
            [cell.bgImageView setFrame:CGRectMake(padding-10+45,
                                                  padding*2-15,
                                                  size.width+25,
                                                  size.height+20)];
            [cell.bgImageView setBackgroundImage:bgImage
                                        forState:UIControlStateNormal];
            [cell.bgImageView addTarget:self
                                 action:@selector(offsetButtonTouchBegin:)
                       forControlEvents:UIControlEventTouchDown];
            [cell.bgImageView setTag:(indexPath.row+1)];
            
            //设置文字区域
            [cell.messageContentView setFrame:CGRectMake(padding+7+45,
                                                         padding*2-4,
                                                         size.width,
                                                         size.height)];
            
            cell.messageContentView.hidden = NO;
            
            //刷新
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
            
        }
        
        //显示双方聊天的时间
        if (indexPath.row > 0) {
            if ([time intValue]-[[[[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"] substringToIndex:10]intValue]<60) {
                cell.senderAndTimeLabel.hidden = YES;
            }
            else
            {
                cell.senderAndTimeLabel.hidden = NO;
            }
        }
        else
            cell.senderAndTimeLabel.hidden = NO;
 
        
        return cell;
    }
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    float theH = [[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:1] floatValue];
    theH += padding*2 + 10;
    
    CGFloat height = theH < 65 ? 65 : theH;
    
    return height;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [messages count];
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
//加号（图片，照片，位置等）
- (UIView *)kkChatAddView{
    
    if (!_kkChatAddView) {
        _kkChatAddView = [[UIView alloc] init];
        _kkChatAddView.frame = CGRectMake(0,
                                          self.view.frame.size.height-125,
                                          320,
                                          125);
//        _kkChatAddView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        _kkChatAddView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chatMorebg.png"]];
        NSArray *kkChatButtonsTitle = @[@"相册",@"相机"];
        
        for (int i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = CGRectMake(10+i%4*80, 0+i/4*126.5, 70, 105);
            //            button.backgroundColor = [UIColor greenColor];
            [button addTarget:self
                       action:@selector(kkChatAddViewButtonsClick:)
             forControlEvents:UIControlEventTouchUpInside];
            
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"kkChatAddViewButtonsNomal_%d",i]]
                    forState:UIControlStateNormal];
            
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"kkChatAddViewButtonsHighlight_%d",i]]
                    forState:UIControlStateHighlighted];
            
            [button setTitleColor:UIColorFromRGBA(0x4c4c4c, 1)
                         forState:UIControlStateNormal];
            
            [button setImageEdgeInsets:UIEdgeInsetsMake(15, 10, 40, 10)];
            [button setTitle:[kkChatButtonsTitle objectAtIndex:i]
                    forState:UIControlStateNormal];
             button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleEdgeInsets:UIEdgeInsetsMake(70, -80, 10, 10)];
            [_kkChatAddView addSubview:button];
            
        }
    }
    return _kkChatAddView;
}

//输入框
- (UIView *)inPutView{
    if (!_inPutView) {
        _inPutView = [[UIView alloc] init];
        _inPutView.frame = CGRectMake(0,
                                      self.view.frame.size.height-50,
                                      320,
                                      50);
        
        UIImage *rawEntryBackground = [UIImage imageNamed:@"chat_input.png"];
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13
                                                                           topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(10, 7, 225, 35);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
        UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13
                                                                 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0,0,self.inPutView.frame.size.width,self.inPutView.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        //    self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        // view hierachy
        [_inPutView addSubview:imageView];
        [_inPutView addSubview:entryImageView];
        [_inPutView addSubview:self.textView];
        [_inPutView addSubview:self.kkChatAddButton];
        [_inPutView addSubview:self.emojiBtn];
        
    }
    return _inPutView;
}

- (UILabel *)unReadL{
    if (!_unReadL) {
        
        _unReadL = [[UILabel alloc] init];
        _unReadL.frame = CGRectMake(35, KISHighVersion_7 ? 20 : 0, 20, 20);
        if (_unreadNo>0) {
            _unReadL.text = [NSString stringWithFormat:@"%d",_unreadNo];
        }
        _unReadL.backgroundColor = [UIColor redColor];
        _unReadL.layer.cornerRadius = 10;
        _unReadL.layer.masksToBounds=YES;
        _unReadL.textColor = [UIColor whiteColor];
        _unReadL.textAlignment = NSTextAlignmentCenter;
        _unReadL.font = [UIFont systemFontOfSize:14];
        _unReadL.hidden = YES;
        
    }
    return _unReadL;
}

- (UIButton *)kkChatAddButton{
    if (!_kkChatAddButton) {
        _kkChatAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _kkChatAddButton.frame = CGRectMake(240,
                                            self.inPutView.frame.size.height-12-36,
                                            45,
                                            45);
        [_kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]
                          forState:UIControlStateNormal];
        
        [_kkChatAddButton addTarget:self
                             action:@selector(kkChatAddButtonClick:)
                   forControlEvents:UIControlEventTouchUpInside];
    }
    return _kkChatAddButton;
}

- (UIButton *)emojiBtn{
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emojiBtn.frame = CGRectMake(277,
                                     self.inPutView.frame.size.height-12-36,
                                     45,
                                     45);
        [_emojiBtn setImage:[UIImage imageNamed:@"emoji.png"]
                   forState:UIControlStateNormal];
        [_emojiBtn addTarget:self
                      action:@selector(kkChatEmojiBtnClicked:)
            forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
}

//导航条标题
- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100,
                                                                startX - 44,
                                                                120,
                                                                44)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = self.nickName;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
        
    }
    return _titleLabel;
}

- (UITableView *)tView{
    if(!tView) {
        tView = [[UITableView alloc] initWithFrame:CGRectMake(0,
                                                              startX,
                                                              320,
                                                              self.view.frame.size.height-startX-55)
                                             style:UITableViewStylePlain];
        [tView setBackgroundColor:[UIColor clearColor]];
        tView.delegate = self;
        tView.dataSource = self;
        tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return tView;
}

- (HPGrowingTextView *)textView{
    if(!_textView){
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(10, 7, 225, 35)];
        _textView.isScrollable = NO;
        _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 6;
        // you can also set the maximum height in points with maxHeight
        // textView.maxHeight = 200.0f;
        _textView.returnKeyType = UIReturnKeySend; //just as an example
        _textView.font = [UIFont systemFontOfSize:15.0f];
        _textView.delegate = self;
        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        _textView.backgroundColor = [UIColor clearColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _textView;
}
//改变我的激活状态
- (void)changeMyActive:(NSNotification*)notification
{
    if ([notification.userInfo[@"active"] intValue] == 2) {
        myActive = YES;
    }else
    {
        myActive = NO;
    }
}
//发送已读消息
- (void)sendReadedMesg
{
    for(NSMutableDictionary* plainEntry in messages)
    {
        NSString *msgType = KISDictionaryHaveKey(plainEntry, @"msgType");
        NSString *status = KISDictionaryHaveKey(plainEntry, @"status");
        NSString *sender = KISDictionaryHaveKey(plainEntry, @"sender");
        if ([msgType isEqualToString:@"normalchat"] && ![status isEqualToString:@"4"] && ![sender isEqualToString:@"you"]) {
            NSString*readMagIdString = KISDictionaryHaveKey(plainEntry, @"messageuuid");
            [self comeBackDisplayed:self.chatWithUser msgId:readMagIdString];
        }
    }
}
//计算单条消息的高度
-(CGFloat)getMsgHight:(NSDictionary*)plainEntry
{
    NSArray * hh = [self cacuMsgSize:plainEntry];
    CGFloat theH = [[hh objectAtIndex:1] floatValue];
    theH += padding*2 + 10;
    CGFloat height = theH < 65 ? 65 : theH;
    return height;
}


//计算所有message的高度
//并将messageCell中的文本转化为指定样式
//计算现在message的时间格式
//计算缩略图 (调优：如果有缩略图就补刷新）
-(void)normalMsgToFinalMsg
{
    NSMutableArray* formattedEntries = [NSMutableArray arrayWithCapacity:messages.count];
    NSMutableArray* heightArray = [NSMutableArray array];
    NSMutableArray* times = [NSMutableArray arrayWithCapacity:messages.count];
    NSMutableDictionary* imgs = [[NSMutableDictionary alloc]init];
    for(int i=0; i<messages.count;i++)
    {
        NSDictionary* plainEntry = messages[i];
        NSArray * hh = [self cacuMsgSize:plainEntry];
        [heightArray addObject:hh];
        [times addObject:[self getMsgTime:plainEntry]];
        NSMutableAttributedString *mas=[self getNSMutableByMsgNSDictionary:plainEntry];
        [formattedEntries addObject:mas];
        KKChatMsgType kkChatMsgType=[self msgType:plainEntry];
        if(kkChatMsgType==KKChatMsgTypeImage){
            NSString *uuid = KISDictionaryHaveKey(plainEntry, @"messageuuid");
            UIImage* uidimage=[self getImage:plainEntry];
            if (uidimage) {
                [imgs setObject:[self getImage:plainEntry] forKey:uuid];
            }
        }
    }
    self.finalImage = imgs;
    self.finalMessageTime =times;
    self.finalMessageArray = formattedEntries;
    self.HeightArray = heightArray;
}

//单条消息放到集合里
-(void)newMsgToArray:(NSDictionary*)plainEntry
{
    NSArray * hh = [self cacuMsgSize:plainEntry];
    [self.HeightArray addObject:hh];
    [self addImageToArray:plainEntry];
    [self.finalMessageTime addObject:[self getMsgTime:plainEntry]];
     NSMutableAttributedString *mas=[self getNSMutableByMsgNSDictionary:plainEntry];
    [self.finalMessageArray addObject:mas];
}
//单条消息放到集合指定位置
-(void)overReadMsgToArray:(NSDictionary*)plainEntry Index:(NSUInteger)index
{
    NSArray * hh = [self cacuMsgSize:plainEntry];
    [self.HeightArray insertObject:hh atIndex:index];
    [self addImageToArray:plainEntry];
    [self.finalMessageTime insertObject:[self getMsgTime:plainEntry] atIndex:index];
    NSMutableAttributedString *mas=[self getNSMutableByMsgNSDictionary:plainEntry];
    [self.finalMessageArray insertObject:mas atIndex:index];
}

//根据消息类型获取消息NSMutableAttributedString
-(NSMutableAttributedString*)getNSMutableByMsgNSDictionary:(NSDictionary*)plainEntry
{
    NSMutableAttributedString* mas =[[NSMutableAttributedString alloc]init];
    NSString *message = [plainEntry objectForKey:@"msg"];
    KKChatMsgType kkChatMsgType=[self msgType:plainEntry];
    switch (kkChatMsgType) {
        case KKChatMsgTypeText:{//文字
            mas=[self getNSMutable:message];
            break;
        }
        case KKChatMsgTypeLink:{//分享动态链接
            mas=KISDictionaryHaveKey(plainEntry, @"payload");
            break;
        }
        case KKChatMsgTypeImage:{//图片
            mas=[[NSMutableAttributedString alloc] init];
            break;
        }
        default://其他
            mas=[[NSMutableAttributedString alloc] init];
            break;
    }
    return mas;
}


//本地缩略图片缓存起来
-(void)addImageToArray:(NSDictionary*)plainEntry
{
    KKChatMsgType kkChatMsgType=[self msgType:plainEntry];
   if(kkChatMsgType==KKChatMsgTypeImage){
       NSString *uuid = KISDictionaryHaveKey(plainEntry, @"messageuuid");
       UIImage* uidimage=[self getImage:plainEntry];
       if (uidimage) {
           [self.finalImage setObject:[self getImage:plainEntry] forKey:uuid];
       }
    }
}

//格式化时间
-(NSString*)getMsgTime:(NSDictionary*)plainEntry
{
    NSString *time = [KISDictionaryHaveKey(plainEntry, @"time") substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}


//缓存图片
-(UIImage*) getImage:(NSDictionary*) plainEntry
{
    //本地缩略图片缓存起来
    NSString *uuid = KISDictionaryHaveKey(plainEntry, @"messageuuid");
    if(![self.finalImage objectForKey:uuid]) //如果没有这个uuid，才执行这个压缩过程
    {
        NSDictionary* payload = [KISDictionaryHaveKey(plainEntry, @"payload") JSONValue];
        NSString *kkChatImagethumb = KISDictionaryHaveKey(payload, @"thumb");
        UIImage *image = [[UIImage alloc]initWithContentsOfFile:kkChatImagethumb];
        if(image){
            return image;
            NSLog(@"finalmesg添加%@",uuid);
        }
        else
        {
            NSString *kkChatImageMsg = KISDictionaryHaveKey(payload, @"msg");
            NSString *imgurl =[NSString stringWithFormat:BaseImageUrl@"%@/%@/%@",kkChatImageMsg,kChatImageSizeWidth,kChatImageSizeHigh];
            NSURL *kkChatImageMsgUrl = [NSURL URLWithString:imgurl];
            EGOImageView *image = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
            image.imageURL = kkChatImageMsgUrl;
            return image.image;
            NSLog(@"finalmesg添加%@",uuid);
        }
    }
    else{//如果有这个uuid 那么就再赋值
        UIImage *image = [self.finalImage objectForKey:uuid];
        return image;
    }
}
//计算每条消息的大小，放到array里边
-(NSArray*)cacuMsgSize:(NSDictionary*) plainEntry
{
    NSArray *array = [NSArray array];
    NSString *message = [plainEntry objectForKey:@"msg"];
    KKChatMsgType kkChatMsgType=[self msgType:plainEntry];
    switch (kkChatMsgType) {
        case KKChatMsgTypeText:
        {
            NSString *emojiStr = [UILabel getStr:message];
            CGSize size = [emojiStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(200, MAXFLOAT)];
            NSNumber * width = [NSNumber numberWithFloat:size.width];
            NSNumber * height = [NSNumber numberWithFloat:size.height];
            array= [NSArray arrayWithObjects:width,height, nil];
            break;
        }
        case KKChatMsgTypeLink:
        {
            NSDictionary* magDic = [KISDictionaryHaveKey(plainEntry, @"payload") JSONValue];
            CGSize titleSize = [self getPayloadMsgTitleSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(magDic, @"title")]];
            CGSize contentSize = CGSizeZero;
            float higF = 0;
            contentSize = [self getPayloadMsgContentSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(magDic, @"msg")] withThumb:YES];
            higF = contentSize.height;
            NSNumber * height = [NSNumber numberWithFloat:(contentSize.height > 40 ? (titleSize.height + contentSize.height + 5) : titleSize.height + 45)];
            array=[NSArray arrayWithObjects:[NSNumber numberWithFloat:195],height, nil];
            break;
        }
        case KKChatMsgTypeImage:
        {
            CGSize size =  CGSizeMake(100, 100);
            NSNumber * width = [NSNumber numberWithFloat:size.width];
            NSNumber * height = [NSNumber numberWithFloat:size.height];
            array=[NSArray arrayWithObjects:width,height, nil];
            break;
        }
        default:
            break;
    }
    return array;
}
//返回消息类型枚举
-(KKChatMsgType)msgType:(NSDictionary*) plainEntry
{
    NSString *msgType = KISDictionaryHaveKey(plainEntry, @"msgType");
    //动态
    if ([msgType isEqualToString:@"payloadchat"]) {
        return KKChatMsgTypeLink;
    }
    //图片
    else if ([[[KISDictionaryHaveKey(plainEntry, @"payload") JSONValue] objectForKey:@"type"] isEqualToString:@"img"])
    {
        return KKChatMsgTypeImage;
    }
    //文字
    else{
        return KKChatMsgTypeText;
    }
}
//格式化的文字（带表情的样式）
-(NSMutableAttributedString*) getNSMutable:(NSString*)str
{
    NSMutableAttributedString* mas = [[NSMutableAttributedString alloc]initWithString:str];
//    不再使用OHASBasicHTMLParser来显示表情
//    NSMutableAttributedString* mas = [OHASBasicHTMLParser attributedStringByProcessingMarkupInString:str];
//    OHParagraphStyle* paragraphStyle = [OHParagraphStyle defaultParagraphStyle];
//    paragraphStyle.textAlignment = kCTJustifiedTextAlignment;
//    paragraphStyle.lineBreakMode = kCTLineBreakByWordWrapping;
//    paragraphStyle.firstLineHeadIndent = 0.f;
//    paragraphStyle.lineSpacing = 5.f;
//    [mas setParagraphStyle:paragraphStyle];
//    [mas setFont:[UIFont systemFontOfSize:15]];
//    [mas setTextAlignment:kCTTextAlignmentLeft lineBreakMode:kCTLineBreakByWordWrapping];
    return mas;
}

//删除controll里缓存的message相关对象
-(void)deleteFinalMsg
{
    [messages removeObjectAtIndex:readyIndex];
    [self.finalMessageArray removeObjectAtIndex:readyIndex];
    [self.HeightArray removeObjectAtIndex:readyIndex];
    [self.finalMessageTime removeObjectAtIndex:readyIndex];
}


- (CGSize)getPayloadMsgTitleSize:(NSString*)theTitle
{
    return (theTitle.length > 0)?[theTitle sizeWithFont:[UIFont boldSystemFontOfSize:14.0] constrainedToSize:CGSizeMake(200, 50)] : CGSizeZero;
}
- (CGSize)getPayloadMsgContentSize:(NSString*)theContent withThumb:(BOOL)haveThumb
{
    return (theContent.length > 0)?[theContent sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(haveThumb ? 150 : 180, 80)] : CGSizeZero;
}


//点击加号中的按钮
- (void)kkChatAddViewButtonsClick:(UIButton *)sender{
    NSLog(@"%d",sender.tag);
    UIImagePickerController *imagePicker = nil;
    switch (sender.tag) {

        case 0: //相册
        {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate=self;
                imagePicker.allowsEditing = NO;
            }
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                //                [self presentModalViewController:imagePicker animated:YES];
                [self presentViewController:imagePicker animated:YES completion:^{
//                    hud = [[MBProgressHUD alloc] initWithView:self.view];
//                    hud.labelText = @"正在处理图片...";
//                    [imagePicker.view addSubview:hud];
//                    
//                    [hud show:YES];
                }];
            }
            else {
                UIAlertView *libraryAlert=[[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"您的设备不支持相册" delegate:self cancelButtonTitle:@"了解" otherButtonTitles:nil];
                [libraryAlert show];
            }
            
        }
            break;
        case 1: //拍照
        {
            if (imagePicker==nil) {
                imagePicker=[[UIImagePickerController alloc]init];
                imagePicker.delegate = self;
                imagePicker.allowsEditing = NO;
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
            break;
        default:
            break;
    }
}
#pragma mark - 从相机或相册获取到图片

//从相机中选取图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0){
}
//从相册中选取图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"正在处理图片...";
    [picker.view.superview addSubview:hud];
    
    [hud show:YES];
    
    UIImage * upImage = (UIImage *)[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage* thumbimg = [NetManager image:upImage centerInSize:CGSizeMake(200, 200)];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString* openImgPath=[self writeImageToFile:thumbimg];
    NSString* upImagePath=[self writeImageToFile:upImage];
    if (openImgPath!=nil) {
        [self sendImageMsgD:openImgPath BigImagePath:upImagePath UUID:uuid]; //一条图片消息写到本地
        [self uploadImage:upImage cellIndex:(messages.count-1)];  //上传图片
    }
    else
    {
        NSLog(@"fail");
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [hud hide:YES];
    }];
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(UIImage*)thumbimg
{
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@_me.jpg",path,uuid];
    if ([UIImageJPEGRepresentation(thumbimg, 1.0) writeToFile:openImgPath atomically:YES]) {
        return openImgPath;
    }
    return nil;
}

#pragma mark 图片聊天上传图片
-(void)uploadImage:(UIImage*)image cellIndex:(int)index
{
    //开启进度条 - 在最后一个ＣＥＬＬ处。
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(index) inSection:0];
    KKImgCell * cell = (KKImgCell *)[self.tView cellForRowAtIndexPath:indexPath];
    cell.progressView.hidden = NO;
    cell.progressView.progress = 0.0f;
   
    NetManager *netmanager=[[NetManager alloc] init];
    [netmanager uploadImage:image WithURLStr:BaseUploadImageUrl ImageName:@"1" TheController:self
    Progress:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite)
    {
        @synchronized (self) {
            double progress = (double)totalBytesWritten/(double)totalBytesExpectedToWrite;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"fafafaf-------->>>%f",progress);
                cell.progressView.progress = progress;
                if (progress == 1) {
                    cell.progressView.progress = 1.0f;
                    cell.progressView.hidden = YES;
                }
            });
        }
    }
    Success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         NSString *imageMsg = [NSString stringWithFormat:@"%@",responseObject];
         dispatch_async(dispatch_get_main_queue(), ^{
             cell.progressView.hidden = YES;
             if(index < messages.count){
                 [self sendImageMsg:imageMsg UUID:KISDictionaryHaveKey(messages[index], @"messageuuid")];    //改图片地址，并发送消息
             }
         });
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         dispatch_async(dispatch_get_main_queue(), ^{
             cell.progressView.hidden = YES;
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送图片失败请重新发送" delegate:nil
                                                   cancelButtonTitle:@"知道啦"otherButtonTitles:nil];
             [alert show];
             [self refreMessageStatus:index Status:@"0"];
         });
     }];
}


// 刷新消息状态
-(void)refreMessageStatus:(int)index Status:(NSString*)status
{
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(index) inSection:0];
    NSMutableDictionary *dict = [messages objectAtIndex:index];
    NSString *uuid = KISDictionaryHaveKey(dict, @"messageuuid");
    [dict setObject:status forKey:@"status"];
    [DataStoreManager refreshMessageStatusWithId:uuid status:status];
    [messages replaceObjectAtIndex:index withObject:dict];
    [self.tView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
}
//刷新消息状态
-(void)refreMessageStatus2:(NSMutableDictionary*)msgDictionary Status:(NSString*)status
{
    NSString *uuid = KISDictionaryHaveKey(msgDictionary, @"messageuuid");
    NSInteger index = [self getMsgRowWithId:uuid];
    [self refreMessageStatus:index Status:status];
}


-(void)kkChatEmojiBtnClicked:(UIButton *)sender
{
    if (!myActive) {
        UIAlertView * UnActionAlertV = [[UIAlertView alloc] initWithTitle:@"您尚未激活"
                                                                  message:@"未激活用户不能发送聊天消息"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                        otherButtonTitles:@"去激活", nil];
        [UnActionAlertV show];
        return ;
    }
    //    if (!ifEmoji||self.kkchatInputType != KKChatInputTypeEmoji) {
    if (self.kkchatInputType != KKChatInputTypeEmoji) {
        ifEmoji = YES;
        self.kkchatInputType = KKChatInputTypeEmoji;
        
        ifAudio = NO;
        [sender setImage:[UIImage imageNamed:@"keyboard.png"]forState:UIControlStateNormal];
        [self.kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
        
        self.textView.hidden = NO;
      //  audioRecordBtn.hidden = YES;
        [self showEmojiScrollView];
        
    }
    else
    {
        [self.textView.internalTextView becomeFirstResponder];
        ifEmoji = NO;
        self.kkchatInputType = KKChatInputTypeKeyboard;
        self.theEmojiView.hidden = YES;
        [m_EmojiScrollView removeFromSuperview];
        [emojiBGV removeFromSuperview];
        [m_Emojipc removeFromSuperview];
        [sender setImage:[UIImage imageNamed:@"emoji.png"]forState:UIControlStateNormal];
        
    }
}

- (void)kkChatAddButtonClick:(UIButton *)sender{
    if (!myActive) {
        UIAlertView * UnActionAlertV = [[UIAlertView alloc] initWithTitle:@"您尚未激活"
                                                                  message:@"未激活用户不能发送聊天消息"
                                                                 delegate:self
                                                        cancelButtonTitle:@"取消"
                                                        otherButtonTitles:@"去激活", nil];
        [UnActionAlertV show];
        return ;
    }
    
    if (self.kkchatInputType != KKChatInputTypeAdd) {   //点击切到发送
        self.kkchatInputType = KKChatInputTypeAdd;
        
        [sender setImage:[UIImage imageNamed:@"keyboard.png"]forState:UIControlStateNormal];
        [self.emojiBtn setImage:[UIImage imageNamed:@"emoji.png"]forState:UIControlStateNormal];
        [self showEmojiScrollView];
        
    }else{      //点击切回键盘
        [self.textView.internalTextView becomeFirstResponder];
        ifEmoji = NO;
        self.kkchatInputType = KKChatInputTypeKeyboard;
        self.theEmojiView.hidden = YES;
        [m_EmojiScrollView removeFromSuperview];
        [emojiBGV removeFromSuperview];
        [m_Emojipc removeFromSuperview];
        [sender setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]
                forState:UIControlStateNormal];
        
    }
    return;
}


-(void)showEmojiScrollView
{
    
    switch (self.kkchatInputType) {
        case KKChatInputTypeEmoji:
        {
            [self.textView resignFirstResponder];
            self.inPutView.frame = CGRectMake(0,self.view.frame.size.height-227-self.inPutView.frame.size.height,320,self.inPutView.frame.size.height);
            self.theEmojiView.hidden = NO;
            self.kkChatAddView.hidden = YES;
            self.theEmojiView.frame = CGRectMake(0,self.view.frame.size.height-253,320,253);
            [self autoMovekeyBoard:253];
        }
            break;
        case KKChatInputTypeAdd:
        {
            [self.textView resignFirstResponder];
            self.inPutView.frame = CGRectMake(0,self.view.frame.size.height-125-self.inPutView.frame.size.height,320,self.inPutView.frame.size.height);
            self.theEmojiView.hidden = YES;
            self.kkChatAddView.hidden = NO;
            self.kkChatAddView.frame = CGRectMake(0,self.view.frame.size.height-125,320,125);
            [self autoMovekeyBoard:125];
        }
            break;
            
        default:
            break;
    }
    
}
-(void)emojiSendBtnDo
{
    [self sendButton:nil];
}
#pragma mark 用户详情
-(void)userInfoClick
{
    //PersonDetailViewController* detailV = [[PersonDetailViewController alloc] init];
    TestViewController *detailV = [[TestViewController alloc]init];
    detailV.userId = self.chatWithUser;
    detailV.nickName = self.nickName;
    detailV.isChatPage = YES;
    
    [self.navigationController pushViewController:detailV
                                         animated:YES];
}

-(void)toContactProfile
{
    TestViewController * detailV = [[TestViewController alloc] init];
    detailV.userId = self.chatWithUser;
    detailV.nickName = self.nickName;
    detailV.isChatPage = YES;
    [self.navigationController pushViewController:detailV
                                         animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self sendButton:nil];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    if ([touch view]==clearView) {
        [self.textView resignFirstResponder];
        if (self.kkchatInputType != KKChatInputTypeNone) {
            [self autoMovekeyBoard:0];
            self.kkchatInputType = KKChatInputTypeNone;
            [UIView animateWithDuration:0.2 animations:^{
                self.theEmojiView.frame = CGRectMake(0,self.theEmojiView.frame.origin.y+260+startX-44,320,253);
                self.kkChatAddView.frame = CGRectMake(0,self.theEmojiView.frame.origin.y+260+startX-44, 320,253);
                m_EmojiScrollView.frame = CGRectMake(0,m_EmojiScrollView.frame.origin.y+260,320,253);
                emojiBGV.frame = CGRectMake(0,emojiBGV.frame.origin.y+260+startX-44,320,emojiBGV.frame.size.height);
                m_Emojipc.frame = CGRectMake(0, m_Emojipc.frame.origin.y+260+startX-44,320,m_Emojipc.frame.size.height);
                
                
            } completion:^(BOOL finished) {
                self.theEmojiView.hidden = YES;
                self.kkChatAddView.hidden = YES;
                [m_EmojiScrollView removeFromSuperview];
                [emojiBGV removeFromSuperview];
                [m_Emojipc removeFromSuperview];
            }];
            [self.emojiBtn setImage:[UIImage imageNamed:@"emoji.png"]forState:UIControlStateNormal];
            [self.kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
        }
        
        [clearView removeFromSuperview];
        if ([popLittleView superview]) {
            [popLittleView removeFromSuperview];
        }
        canAdd = YES;
    }
    
    
    
}

- (void)viewDidUnload
{
    [self setTView:nil];
    [self setMessageTextField:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
#pragma mark -
#pragma mark Responding to keyboard events
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    
	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
}

-(void) autoMovekeyBoard: (float) h{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect containerFrame = self.inPutView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (h + containerFrame.size.height);
	self.inPutView.frame = containerFrame;
    
//    CGRect cgmm=CGRectMake(0.0f,startX,320.0f,self.view.frame.size.height-startX-self.inPutView.frame.size.height-h-20);
//    self.tView.frame=cgmm;
    
    CGRect cgmm = self.tView.frame;
     cgmm.origin.y = startX-h;
    
    self.tView.frame=cgmm;
    [UIView commitAnimations];
    
    if (messages.count>0) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    
    if (h>0&&canAdd) {
        canAdd = NO;
        clearView = [[UIView alloc] initWithFrame:CGRectMake(0,startX,320,self.view.frame.size.height-startX-self.inPutView.frame.size.height-h)];
        [clearView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:clearView];
    }
    if ([clearView superview]) {
        [clearView setFrame:CGRectMake(0,startX, 320,self.view.frame.size.height-startX-self.inPutView.frame.size.height-h)];
    }
}
#pragma mark -
#pragma mark HPExpandingTextView delegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (myActive) {
        [menu setMenuItems:@[]];
        return YES;
    }
    UIAlertView * UnActionAlertV = [[UIAlertView alloc]initWithTitle:@"您尚未激活"
                                                             message:@"未激活用户不能发送聊天消息"
                                                            delegate:self
                                                   cancelButtonTitle:@"取消"
                                                   otherButtonTitles:@"去激活", nil];
    [UnActionAlertV show];
    
//    [self.kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]
//                          forState:UIControlStateNormal];
    return NO;
}

- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self.kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]
                          forState:UIControlStateNormal];
    
}
//改变键盘高度
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
	CGRect r = self.inPutView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
	self.inPutView.frame = r;
    
    if ([clearView superview]) {
        [clearView setFrame:CGRectMake(0,startX,320,clearView.frame.size.height+diff)];
    }
//    self.tView.frame = CGRectMake(0.0f, startX,320.0f,self.tView.frame.size.height+diff);
    
    CGRect tvRect=self.tView.frame;
    tvRect.origin.y = tvRect.origin.y+diff;
    self.tView.frame=tvRect;
    
    if (messages.count>0) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]
                          atScrollPosition:UITableViewScrollPositionBottom
                                  animated:YES];
    }
    //    [senBtn setFrame:CGRectMake(282, inPutView.frame.size.height-37.5, 28, 27.5)];
    [picBtn setFrame:CGRectMake(285,self.inPutView.frame.size.height-12-27,25,27)];
    [self.emojiBtn setFrame:CGRectMake(277,self.inPutView.frame.size.height-12-36,45,45)];
    [self.kkChatAddButton setFrame:CGRectMake(242,self.inPutView.frame.size.height-12-36,45,45)];
    [audioBtn setFrame:CGRectMake(8,self.inPutView.frame.size.height-12-27,25,27)];
}

-(BOOL)growingTextViewShouldReturn:(HPGrowingTextView *)growingTextView
{
    [self sendButton:nil];
    return YES;
}

//消息发送成功
- (void)messageAck:(NSNotification *)notification
{
    NSDictionary* tempDic = notification.userInfo;
    NSString* src_id = KISDictionaryHaveKey(tempDic, @"src_id");
    if ([tempDic isKindOfClass:[NSDictionary class]]) {
        NSString* status = [DataStoreManager queryMessageStatusWithId:src_id];
        NSInteger changeRow = [self getMsgRowWithId:src_id];
        if (changeRow < 0) {
            return;
        }
        NSMutableDictionary *dict = [messages objectAtIndex:changeRow];
        if ([status isEqualToString:@"2"]) {//发送中-> 失败
            [DataStoreManager refreshMessageStatusWithId:src_id status:@"0"];//超时
            [dict setObject:@"0" forKey:@"status"];
            [messages replaceObjectAtIndex:changeRow withObject:dict];
            [self.tView reloadData];
        }
        else//送达、已读、失败
        {
            [dict setObject:status forKey:@"status"];
//            [messages replaceObjectAtIndex:changeRow withObject:dict];
            
            [self refreMessageStatus2:dict Status:status];
//            [self refreStatusView:status cellIndex:changeRow];
        }
    }
}

//根据uuid获取message所在的RowIndex
- (NSInteger)getMsgRowWithId:(NSString*)msgUUID
{
    if (messages.count>0 && msgUUID && msgUUID.length > 0)
    {
        for (int i = 0; i < [messages count]; i++) {
            NSDictionary* tempDic = [messages objectAtIndex:i];
            if ([KISDictionaryHaveKey(tempDic, @"messageuuid") isEqualToString:msgUUID]) {
                return i;
            }
        }
        return -1;
    }
    return -1;
}
//根据uuid获取message
- (NSMutableDictionary*)getMsgWithId:(NSString*)msgUUID
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc]init];
    if (messages.count>0 && msgUUID && msgUUID.length > 0)
    {
        for (int i = 0; i < [messages count]; i++) {
            NSMutableDictionary* tempDic = [messages objectAtIndex:i];
            if ([KISDictionaryHaveKey(tempDic, @"messageuuid") isEqualToString:msgUUID]) {
                return messages[i];
            }
        }
    }
    return  dict;
}

#pragma mark -
#pragma mark UI/UE : 响应各种交互操作
- (void)keyboardWillShow:(NSNotification *)notification {

    
    ifEmoji = NO;
    self.kkchatInputType = KKChatInputTypeKeyboard;
    
    self.theEmojiView.hidden = YES;
    self.kkChatAddView.hidden = YES;
    
    [m_EmojiScrollView removeFromSuperview];
    [emojiBGV removeFromSuperview];
    [m_Emojipc removeFromSuperview];
    [self.emojiBtn setImage:[UIImage imageNamed:@"emoji.png"]
                   forState:UIControlStateNormal];
    if ([clearView superview]) {
        [clearView removeFromSuperview];
    }
    if ([popLittleView superview]) {
        [popLittleView removeFromSuperview];
    }
    canAdd = YES;
    
    /*
     Reduce the size of the text view so that it's not obscured by the keyboard.
     Animate the resize so that it's in sync with the appearance of the keyboard.
     */
    
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
    if (self.kkchatInputType==KKChatInputTypeEmoji||self.kkchatInputType==KKChatInputTypeAdd) {
        
    }else
    {
        [self autoMovekeyBoard:0];
    }
    
    
}-(NSString *)selectedEmoji:(NSString *)ssss
{
	if (self.textView.text == nil) {
		self.textView.text = ssss;
	}
	else {
		self.textView.text = [self.textView.text stringByAppendingString:ssss];
	}
    
    return 0;
}
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
-(void)addEmojiScrollView
{
    if (self.textView.text.length>=1) {
        self.textView.text = [self.textView.text substringToIndex:(self.textView.text.length-1)];
    }
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}





//点击他人的头像
-(void)chatUserHeadImgClicked:(id)Sender
{
    [self toContactProfile];
}

//点击我的头像
-(void)myHeadImgClicked:(id)Sender
{
    TestViewController * detailV = [[TestViewController alloc] init];
    
    detailV.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    detailV.nickName = [DataStoreManager queryRemarkNameForUser:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    detailV.isChatPage = YES;
    [self.navigationController pushViewController:detailV animated:YES];
}

-(void)offsetButtonTouchBegin:(UIButton *)sender
{
    touchTimePre = [[NSDate date] timeIntervalSince1970];
    tempBtn = sender;
    [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(endIt:) userInfo:nil repeats:NO];
}

//结束点击
-(void)offsetButtonTouchEnd:(UIButton *)sender
{
    if ([[NSDate date] timeIntervalSince1970]-touchTimePre<=1) {    //单击
        NSMutableDictionary *dict = [messages objectAtIndex:(tempBtn.tag-1)];
        NSString* msgType = KISDictionaryHaveKey(dict, @"msgType");
        NSString* status = KISDictionaryHaveKey(dict, @"status");
        
        if ([msgType isEqualToString:@"payloadchat"]) {     //如果是playloadchat消息（动态，图片），点击进入新的View
            NSDictionary* msgDic = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
            OnceDynamicViewController* detailVC = [[OnceDynamicViewController alloc] init];
            detailVC.messageid = KISDictionaryHaveKey(msgDic, @"messageid");
            detailVC.delegate = nil;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        else if([msgType isEqualToString:@"normalchat"] && [status isEqualToString:@"0"])   //是否重发 （普通消息，且status=0)
        {
            UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"delegate:self cancelButtonTitle:@"取消"
                                                 destructiveButtonTitle:Nil otherButtonTitles:@"重新发送", nil];
            sheet.tag = 124;
            [sheet showInView:self.view];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        ActivateViewController * actVC = [[ActivateViewController alloc]init];
        [self.navigationController pushViewController:actVC animated:YES];
    }
}
//响应按键
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 124) {
        if (buttonIndex == 1) { //点击取消
            return;
        }//buttonIndex ==0 为 点击了重发按钮
        
        
        NSInteger cellIndex = tempBtn.tag-1;
        NSMutableDictionary* dict = [messages objectAtIndex:cellIndex];
        KKChatMsgType kkChatMsgType=[self msgType:dict];
        if (kkChatMsgType==KKChatMsgTypeImage) {
            [self reSendimageMsg:dict cellIndex:cellIndex];
        }else{
            [self reSendMsg:dict]; //重发普通消息
        }
    }
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    //    return (action == @selector(copyMsg));
    //    return (action == @selector(transferMsg));
    //    return (action == @selector(deleteMsg));
    if (action == @selector(copyMsg) || action == @selector(transferMsg) || action == @selector(deleteMsg))
    {
        return YES;
    }
    else
        return NO;
}

//监听bgView的长按
-(void)endIt:(UIButton *)sender
{
    if (tempBtn.highlighted == YES) {//长按
        NSLog(@"haha");

        [self canBecomeFirstResponder];
        [self becomeFirstResponder];
    
        //弹出菜单
        indexPathTo = [[NSIndexPath indexPathForRow:(tempBtn.tag-1) inSection:0] copy];
        KKMessageCell * cell = (KKMessageCell *)[self.tView cellForRowAtIndexPath:indexPathTo];
        tempStr = [[[messages objectAtIndex:indexPathTo.row] objectForKey:@"msg"] copy];
        CGRect rect = [self.view convertRect:tempBtn.frame fromView:cell.contentView];
        readyIndex = tempBtn.tag-1; //设置当前要操作的cell idnex
        [menu setMenuItems:[NSArray arrayWithObjects:copyItem,delItem,nil]];
        [menu setTargetRect:CGRectMake(rect.origin.x, rect.origin.y, 60, 90) inView:self.view];
        [menu setMenuVisible:YES animated:YES];
    }
    
    //[yy setBackgroundImage:nil forState:UIControlStateNormal];
}

-(void)copyMsg
{
    [popLittleView removeFromSuperview];
    if ([clearView superview]) {
        [clearView removeFromSuperview];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = tempStr;
}



- (void)sendButton:(id)sender {
    //本地输入框中的信息
    NSString *message = self.textView.text;
    if (message.length==0||[[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0) {
        //如果发送信息为空或者为空格的时候弹框提示
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"不能发送空消息" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    if (message.length>255) {
        [self showAlertViewWithTitle:nil message:@"发送字数太多，请分条发送" buttonTitle:@"确定"];
        return;
    }
    self.textView.text = @"";
    [self sendMsg:message];
    
}

#pragma mark将发送图片的消息保存数据库
- (void)sendImageMsgD:(NSString *)imageMsg BigImagePath:(NSString*)bigimagePath UUID:(NSString *)uuid{
    
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* payloadStr=[self createPayLoadStr:uuid ImageId:@"" ThumbImage:imageMsg BigImagePath:bigimagePath];
    NSMutableDictionary *dictionary =  [self createMsgDictionary:@"[图片]" NowTime:nowTime UUid:uuid MsgStatus:@"1"];
    [dictionary setObject:payloadStr forKey:@"payload"];
    [self addNewMessageToTable:dictionary];
}

#pragma mark 发送图片消息
- (void)sendImageMsg:(NSString *)imageMsg  UUID:(NSString *)uuid{
    NSLog(@"图片上传成功， 开始发送图片消息+++++%@",[imageMsg class]);
    if (imageMsg.length==0)
    {
        return;
    }
    if ([[imageMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"不能发送空消息" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    NSMutableDictionary* messageDict = [self getMsgWithId:uuid];
    NSDictionary* pay = [KISDictionaryHaveKey(messageDict, @"payload") JSONValue];
    NSString* strThumb = KISDictionaryHaveKey(pay, @"thumb");
    NSString* srtBigImage= KISDictionaryHaveKey(pay, @"title");
    NSString * payloadStr=[self createPayLoadStr:uuid ImageId:imageMsg ThumbImage:strThumb BigImagePath:srtBigImage];
    [messageDict setObject:payloadStr forKey:@"payload"]; //将图片地址替换为已经上传的网络地址
    [self reSendMsg:messageDict];
    [self refreWX];
}
#pragma mark 发送文本消息
-(void)sendMsg:(NSString *)message
{
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString *from=[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]];
    NSString *to=[self.chatWithUser stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]];
    NSMutableDictionary *dictionary=[self createMsgDictionary:message NowTime:nowTime UUid:uuid MsgStatus:@"2"];
    [self addNewMessageToTable:dictionary];
    [self sendMessage:message NowTime:nowTime UUid:uuid From:from To:to MsgType:@"normalchat" FileType:@"text" Type:@"chat" Payload:nil];
    [self refreWX];
}
#pragma mark 添加一条新的消息到列表
-(void)addNewMessageToTable:(NSMutableDictionary*)dictionary
{
    [messages addObject:dictionary];//添加到当前消息集合 内存
    [self newMsgToArray:dictionary];//计算高度，添加高度到内存
    [DataStoreManager storeMyMessage:dictionary];//添加到数据库
    [self.tView reloadData];//刷新列表
    if (messages.count>0) {//定位到列表最后
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark 重新发文本消息
- (void)reSendMsg:(NSMutableDictionary*)messageDict
{
    //添加新消息
    NSString* message = KISDictionaryHaveKey(messageDict, @"msg");
    NSString* uuid = KISDictionaryHaveKey(messageDict, @"messageuuid");
    NSString* sendtime = KISDictionaryHaveKey(messageDict, @"time");
    NSString* msgType = KISDictionaryHaveKey(messageDict, @"msgType");
    NSString* payloadStr = KISDictionaryHaveKey(messageDict, @"payload");
    

    NSString *from=[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]];
    NSString *to=[self.chatWithUser stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]];
    
    [messageDict setObject:@"2" forKey:@"status"];
    if (payloadStr!=nil&&![payloadStr isEqualToString:@""]) {
        [messageDict setObject:payloadStr forKey:@"payload"];
    }
    [self refreMessageStatus2:messageDict Status:@"2"];
    [self sendMessage:message NowTime:sendtime UUid:uuid From:from To:to MsgType:msgType FileType:@"text" Type:@"chat" Payload:payloadStr];
}

#pragma mark 重发图片消息
- (void)reSendimageMsg:(NSMutableDictionary*)messageDict cellIndex:(NSInteger)cellIndex
{
    NSDictionary *payloads = [KISDictionaryHaveKey(messageDict, @"payload") JSONValue];
    NSString *imageUrl = KISDictionaryHaveKey(payloads, @"msg");
    NSString *thumb = KISDictionaryHaveKey(payloads, @"title");
    if ([self isReUploadImage:thumb]==YES) {//如果已经成功 ，把message再发一遍
        if (imageUrl.length==0)
        {
            return;
        }
        [messageDict setObject:@"2" forKey:@"status"];
        [self reSendMsg:messageDict];
    }
    else{//如果之前没上传成功,读取本地图片，再次上传
        UIImage *imgFromUrl=[[UIImage alloc]initWithContentsOfFile:thumb];
        [self refreMessageStatus2:messageDict Status:@"2"];
        [self uploadImage:imgFromUrl cellIndex:cellIndex];
    }
}
/*
 * 判端图片是否上传成功
 */
-(BOOL)isReUploadImage:(NSString*)thumb
{
    if (thumb&&thumb.length>0)
    {
        return NO;
    }
    else{
        return YES;
    }
}
#pragma mark 发送Xmpp消息
-(void)sendMessage:(NSString *)message NowTime:(NSString *)nowTime UUid:(NSString *)uuid From:(NSString*)from To:(NSString*)to MsgType:(NSString*)msgType FileType:(NSString*)fileTyp Type:(NSString*)type Payload:(NSString*)payloadStr
{
    NSXMLElement *mes = [self createMes:nowTime Message:message UUid:uuid From:from To:to FileType:fileTyp MsgType:msgType Type:type];
    if(payloadStr!=nil&&![payloadStr isEqualToString:@""]){
        NSXMLElement * payload = [NSXMLElement elementWithName:@"payload"];
        [payload setStringValue:payloadStr];
        [mes addChild:payload];
    }
    NSLog(@"sendMsg------------>>>>%@",mes);
    [self.appDel.xmppHelper sendMessage:mes];
}

#pragma mark 更新消息再数据库的状态
-(void)updateMsgByUuid:(NSMutableDictionary*)messageDict
{
    NSString *uuid = KISDictionaryHaveKey(messageDict, @"messageuuid");
    [DataStoreManager refreshMessageStatusWithId:uuid status:@"2"];
}
#pragma mark 刷新消息状态
-(void)refreStatusView:(NSString*)status cellIndex:(NSInteger)cellIndex
{
    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    CGSize size = CGSizeMake([[[self.HeightArray objectAtIndex:indexpath.row] objectAtIndex:0] floatValue],[[[self.HeightArray objectAtIndex:indexpath.row] objectAtIndex:1] floatValue]);
    KKImgCell * cell = (KKImgCell *)[self.tView cellForRowAtIndexPath:indexpath];
    [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,(size.height+20)/2 + padding*2-15)status:status];
}
#pragma mark 判断是否需要执行第一次打招呼
-(void)refreWX
{
    [wxSDArray removeAllObjects];
    [wxSDArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
    if (![wxSDArray containsObject:self.chatWithUser]) {
        [self getSayHello];
    }
}

#pragma mark 创建payload
-(NSString*)createPayLoadStr:(NSString*)uuid ImageId:(NSString*)imageId ThumbImage:(NSString*)thumbImage BigImagePath:(NSString*)bigImagePath
{
    NSDictionary * dic = @{@"thumb":thumbImage,
                           @"title":bigImagePath,
                           @"shiptype": @"",
                           @"messageid":@"",
                           @"msg":imageId,
                           @"type":@"img"};
    return [dic JSONFragment];
}
#pragma mark 生成XML消息文档
-(NSXMLElement*)createMes:(NSString *)nowTime Message:(NSString*)message UUid:(NSString *)uuid From:(NSString*)from To:(NSString*)to FileType:(NSString*)fileType MsgType:(NSString*)msgType Type:(NSString*)type
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:type];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:to];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:from];
    [mes addAttributeWithName:@"msgtype" stringValue:msgType];
    [mes addAttributeWithName:@"fileType" stringValue:fileType];  //如果发送图片音频改这里
    [mes addAttributeWithName:@"msgTime" stringValue:nowTime];
    [mes addAttributeWithName:@"id" stringValue:uuid];
    [mes addChild:body];
    NSLog(@"消息uuid ~!~~ %@", uuid);
    return mes;
}

#pragma mark 创建消息对象
-(NSMutableDictionary*)createMsgDictionary:(NSString *)message NowTime:(NSString *)nowTime UUid:(NSString *)uuid MsgStatus:(NSString *)status
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:message forKey:@"msg"];
    [dictionary setObject:@"you" forKey:@"sender"];
    [dictionary setObject:nowTime forKey:@"time"];
    [dictionary setObject:self.chatWithUser forKey:@"receiver"];
    [dictionary setObject:self.nickName?self.nickName:@"" forKey:@"nickname"];
    [dictionary setObject:self.chatUserImg?self.chatUserImg:@"" forKey:@"img"];
    [dictionary setObject:@"normalchat" forKey:@"msgType"];
    [dictionary setObject:uuid forKey:@"messageuuid"];
    [dictionary setObject:status forKey:@"status"];
    return dictionary;
}

#pragma mark 删除
-(void)deleteMsg
{
    [popLittleView removeFromSuperview];
    if ([clearView superview]) {
        [clearView removeFromSuperview];
    }
    //删除聊天消息
    
    NSString* uuid = KISDictionaryHaveKey(messages[readyIndex], @"messageuuid");
    [DataStoreManager deleteMsgInCommentWithUUid:uuid];
    [self deleteFinalMsg]; //删除controll里缓存的message相关对象
    [self.finalImage removeObjectForKey:uuid];  //删除图片缓存
    
    
    if (messages.count>0) {
        [DataStoreManager refreshThumbMsgsAfterDeleteCommonMsg:[messages lastObject]ForUser:self.chatWithUser ifDel:NO];
    }
    else
    {
        [DataStoreManager refreshThumbMsgsAfterDeleteCommonMsg:[messages lastObject]ForUser:self.chatWithUser ifDel:YES];
    }
    [self.tView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPathTo]withRowAnimation:UITableViewRowAnimationRight];
    [self.tView reloadData];
    
}
#pragma mark 历史聊天记录展示
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {

}

#pragma mark 是否是打招呼  如果改变打招呼则运行
-(void)getSayHello
{
    NSMutableDictionary * postDict1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:chatWithUser forKey:@"touserid"];
    [postDict1 addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict1 setObject:@"153" forKey:@"method"];
    [postDict1 setObject:paramDict forKey:@"params"];
    
    [postDict1 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]
                  forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl
                                   Parameters:postDict1
                                      success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                          [wxSDArray addObject:self.chatWithUser];
                                          [DataStoreManager storeThumbMsgUser:chatWithUser type:@"1"];
                                          [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sayHello_wx_info_id"];
                                          [[NSUserDefaults standardUserDefaults] setObject:wxSDArray
                                                                                    forKey:@"sayHello_wx_info_id"];
                                          
                                      } failure:^(AFHTTPRequestOperation *operation, id error) {
                                      }];
}
#pragma mark - 下拉刷新

- (void)kkChatAddRefreshHeadView{
    
    __block NSArray *array;
    __block int loadHistoryArrayCount;
    __block KKChatController *chat = self;
    __block float loadMoreMsgHeight = 0;
    MJRefreshHeaderView *header = [MJRefreshHeaderView header];
    header.scrollView = self.tView;
    [header.statusLabel setHidden:YES];
    [header.lastUpdateTimeLabel setHidden:YES];
    
    CGRect headerRect = header.arrowImage.frame;
    headerRect.size = CGSizeMake(30, 30);
    header.arrowImage.frame = headerRect;
    header.arrowImage.center = CGPointMake(160, header.arrowImage.center.y+15);
    header.activityView.center = header.arrowImage.center;
    header.beginRefreshingBlock = ^(MJRefreshBaseView *refreshView) {
        
        array = [DataStoreManager qureyCommonMessagesWithUserID:self.chatWithUser
                 
                                                    FetchOffset:messages.count];
        
        loadMoreMsgHeight = 0;
        for (int i = 0; i < array.count; i++) {
            [messages insertObject:array[i] atIndex:i];
            [self overReadMsgToArray:array[i] Index:i];
            loadMoreMsgHeight+=[self getMsgHight:array[i]];
        }
        loadHistoryArrayCount = array.count;
        [header endRefreshing];
    };
    
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        [chat.tView reloadData];
        if (loadHistoryArrayCount==0) {
            return;
        }
        
        [chat.tView scrollRectToVisible:CGRectMake(0,
                                                   loadMoreMsgHeight,
                                                   chat.tView.frame.size.width,
                                                   chat.tView.frame.size.height) animated:NO];
        
    };
    header.refreshStateChangeBlock = ^(MJRefreshBaseView *refreshView, MJRefreshState state) {
        
        switch (state) {
            case MJRefreshStateNormal:
                
                break;
            case MJRefreshStatePulling:
                
                break;
            case MJRefreshStateRefreshing:
                
                break;
            case MJRefreshStateWillRefreshing:
                
                break;
                
            default:
                break;
        }
        
    };
    self.kkChatControllerRefreshHeadView = header;
    
}
#pragma mark KKMessageDelegate
- (void)newMesgReceived:(NSNotification*)notification
{
    
    NSDictionary* tempDic = notification.userInfo;
    NSRange range = [KISDictionaryHaveKey(tempDic,  @"sender")rangeOfString:@"@"];
    NSString * sender = [KISDictionaryHaveKey(tempDic,  @"sender")substringToIndex:range.location];

    if ([sender isEqualToString:self.chatWithUser]) {
        NSString * msgId = KISDictionaryHaveKey(tempDic, @"msgId");
        [tempDic setValue:msgId forKey:@"messageuuid"];
        [messages setValue:@"4" forKey:@"status"];
        [messages addObject:tempDic];
        [self newMsgToArray:tempDic];
        [self.tView reloadData];
        if (messages.count>0) {
            [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        
        [self comeBackDisplayed:sender msgId:msgId];//发送已读消息
    }
    else
    {
        self.unReadL.hidden = NO;
        _unreadNo++;
        if (_unreadNo>0) {
            if (_unreadNo>99) {
                self.unReadL.text =@"N+";
            }else{
                self.unReadL.text = [NSString stringWithFormat:@"%d",_unreadNo];
            }
        }
    }
}
//发送已读消息
- (void)comeBackDisplayed:(NSString*)sender msgId:(NSString*)msgId
{
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"src_id",@"true",@"received",@"Displayed",@"msgStatus", nil];
    NSString* message=[dic JSONRepresentation];
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString *from=[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]];
    NSString *to=[sender stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]];
    
    NSXMLElement *mes = [self createMes:nowTime Message:message UUid:uuid From:from To:to FileType:@"text" MsgType:@"msgStatus" Type:@"normal"];
    
    if (![self.appDel.xmppHelper sendMessage:mes]) {
        return;
    }
    [DataStoreManager refreshMessageStatusWithId:msgId status:@"4"];
}



#pragma mark 点击图片
-(void)lookBigImg:(UITapGestureRecognizer*)sender
{
    NSDictionary *dict = [messages objectAtIndex:sender.view.tag];
    NSDictionary *payload = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
    NSString *senderId=KISDictionaryHaveKey(dict, @"sender");
    NSString *str=KISDictionaryHaveKey(payload, @"msg");
    
    if ([senderId isEqualToString:@"you"]) {
        str=KISDictionaryHaveKey(payload, @"title");
        if(str==nil||[str isEqualToString:@""]){
            str = KISDictionaryHaveKey(payload, @"msg");
            if (str==nil||[str isEqualToString:@""]) {
                str=KISDictionaryHaveKey(payload, @"thumb");
            }
        }
    }else{
        str=KISDictionaryHaveKey(payload, @"msg");//先加载网络图片
        if(str==nil||[str isEqualToString:@""]){//网络图片没有加载本地的大图
            str = KISDictionaryHaveKey(payload, @"title");
            if (str==nil||[str isEqualToString:@""]) {//本地大图没有就加载本地的小图
                str=KISDictionaryHaveKey(payload, @"thumb");
            }
        }
    }
    
    NSLog(@"加载的图片地址：%@",str);
    NSArray *array = [NSArray arrayWithObjects:str, nil];
    PhotoViewController *photo = [[PhotoViewController alloc]initWithSmallImages:nil images:array indext:0];
    //photo.isComeFrmeUrl = YES;
    [self presentViewController:photo animated:NO completion:^{
        
    }];
}

#pragma mark 长按图片
-(void)longPressImg:(UITapGestureRecognizer*)sender
{
    
    EGOImageView* imgV = (EGOImageView*)sender.view;
    readyIndex = imgV.tag ;//设置当前要操作的cell idnex
    indexPathTo = [[NSIndexPath indexPathForRow:(imgV.tag) inSection:0] copy];
    
    //弹出菜单
    KKMessageCell * cell = (KKMessageCell *)[self.tView cellForRowAtIndexPath:indexPathTo];
   // tempStr = [[[messages objectAtIndex:indexPathTo.row] objectForKey:@"msg"] copy];
    CGRect rect = [self.view convertRect:imgV.frame fromView:cell.contentView];
    NSLog(@"----------------------长按tag=%d图片",imgV.tag);
    
    [menu setMenuItems:[NSArray arrayWithObjects:delItem, nil]];
    [menu setTargetRect:CGRectMake(rect.origin.x, rect.origin.y, 60, 90) inView:self.view];
    [menu setMenuVisible:YES animated:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    //清除未读
    [DataStoreManager blankMsgUnreadCountForUser:self.chatWithUser];
   // [[NSNotificationCenter defaultCenter] removeObserver:self]; //移除所有观察者，不再监听消息。

}



@end
