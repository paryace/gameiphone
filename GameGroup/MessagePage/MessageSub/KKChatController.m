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
#import "UpLoadFileService.h"
#import "MessageService.h"
#import "GroupInformationViewController.h"
#import "KKSystemMsgCell.h"
#import "KKHistoryMsgCell.h"
#import "GroupCricleViewController.h"
#import "TeamChatListView.h"
#import "ItemManager.h"
#import "ItemInfoViewController.h"
#import "KKTeamInviteCell.h"
#import "H5CharacterDetailsViewController.h"
#import "KKSimpleMsgCell.h"
#import "InplaceTimer.h"
#import "NewTeamMenuView.h"
#import "InvitationMembersViewController.h"

#import "AudioManager.h"
#import "ShowRecordView.h"
#import "amrFileCodec.h"

#ifdef NotUseSimulator
#endif

#define kChatImageSizeWidth @"200"
#define kChatImageSizeHigh @"200"
#define DEGREES_TO_RADIANS(angle) ((angle)/180.0 *M_PI)

#define padding 20
#define spaceEnd 100
#define maxWight 200
#define LocalMessage @"localMessage"
#define NameKeys @"namekeys"
#define topViewHight 52

typedef enum : NSUInteger {
    KKChatInputTypeNone,
    KKChatInputTypeKeyboard,
    KKChatInputTypeEmoji,
    KKChatInputTypeAdd
} KKChatInputType;

typedef enum : NSUInteger {
    KKChatMsgTypeText,
    KKChatMsgTypeLink,
    KKChatMsgTypeImage,
    KKChatMsgTypeSystem,
    KKChatMsgHistory,
    KKChatMsgTeamInvite,
    KKChatMsgSimple,
    kkchatMsgAudio
} KKChatMsgType;


@interface KKChatController ()<UIAlertViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate>
{
    NSMutableArray *messages;   //信息
    UIMenuItem *copyItem;
    UIMenuItem *delItem;
    UIButton *profileButton;
    BOOL myActive;
    NSMutableArray *wxSDArray;
    NSInteger offHight;//群消息需要多加上的高度
    NSInteger historyMsg;
    NSInteger screenHeigth;
    
    NSInteger offsetTopHight;
    BOOL endOfTable;
    BOOL oTherPage;
    BOOL teamUsershipType;
    BOOL isMenuShow;
    BOOL isApplyShow;
    NSMutableDictionary * selectType;
    
    /*
     录音
     */
    
    RecordAudio *recordAudio;
    NSData *curAudio;
    BOOL isRecording;
    ShowRecordView *showRecordView;
    BOOL saveAudioSuccess;
    
}

@property (nonatomic, assign) KKChatInputType kkchatInputType;
@property (nonatomic, strong) UILabel *unReadL;
@property (nonatomic, strong) UIButton *kkChatAddButton;
@property (nonatomic, strong) UIView *inPutView;
@property (nonatomic, strong) UIView *kkChatAddView;
@property (nonatomic, strong) EmojiView *theEmojiView;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSArray *typeData_list;
@property (assign, nonatomic)  NSInteger groupCricleMsgCount;// 群动态的未读消息
@property (nonatomic, strong) TeamChatListView * dropDownView;
@property (nonatomic,strong) NewTeamMenuView * newTeamMenuView;
@property (nonatomic,strong) NewTeamApplyListView * newTeamApplyListView;
@property (nonatomic,strong) UIButton * topItemView;
@property (nonatomic,strong) UIImageView * leftImage;
@property (nonatomic,strong) UIImageView * rightImage;
@end

@implementation KKChatController
static double startRecordTime=0;
static double endRecordTime=0;

@synthesize tView;
@synthesize chatWithUser;


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
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    oTherPage=NO;
    //接收消息监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessageReceived object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newMesgReceived:)name:kNewMessageReceived object:nil];
    //ack消息监听//消息是否发送成功
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageAck object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAck:)name:kMessageAck object:nil];
    [self refreTitleText];
    [self showErrorDialog];
    if ([self.type isEqualToString:@"group"]) {
        [self initGroupCricleMsgCount];//初始化群动态的未读消息数
    }
}


-(void)viewWillDisappear:(BOOL)animated
{
    if (!oTherPage) {
        //监听通知（收到新消息，与发送消息成功）
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNewMessageReceived object:nil];
        //ack反馈消息通知
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kMessageAck object:nil];
    }
    [[InplaceTimer singleton] stopTimer:self.gameId RoomId:self.roomId GroupId:self.chatWithUser];
    if ([self.type isEqualToString:@"normal"]) {
        [DataStoreManager blankMsgUnreadCountForUser:self.chatWithUser Successcompletion:^(BOOL success, NSError *error) {
            
        }];
    }else if ([self.type isEqualToString:@"group"]){
        [DataStoreManager blankGroupMsgUnreadCountForUser:self.chatWithUser Successcompletion:^(BOOL success, NSError *error) {
            
        }];
    }
}
//设置Title
-(void)refreTitleText
{
    if ([self.type isEqualToString:@"normal"]) {
        NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:self.chatWithUser];
        if (!simpleUserDic) {
            self.nickName = @"";
        }else{
            NSString * userNickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            self.nickName = userNickName;
        }
    }else if([self.type isEqualToString:@"group"]){
        NSMutableDictionary * groupInfo = [[GroupManager singleton] getGroupInfo:self.chatWithUser];
        if (!groupInfo) {
            self.available = @"0";
            self.nickName = @"";
            self.groupUsershipType = @"2";
        }else{
            self.available = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupInfo, @"available")];
            self.groupUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupInfo, @"groupUsershipType")];
            if (self.isTeam) {
                NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:self.gameId] RoomId:[GameCommon getNewStringWithId:self.roomId]];
                self.nickName = [NSString stringWithFormat:@"%@%@",[self getMemberCount:teamInfo],KISDictionaryHaveKey(groupInfo, @"groupName")];
            }else{
                self.nickName = KISDictionaryHaveKey(groupInfo, @"groupName");
            }
        }
    }
    self.titleLabel.text = self.nickName;
}
-(void)showErrorDialog{
    if (![self isGroupAvaitable]) {
        [self showInVisableDialog];
    }else {
        if ([self isOut]) {
            [self showOutDialog];
        }
    }
}
-(void)showInVisableDialog{
    UIAlertView * errorDialog = [[UIAlertView alloc] initWithTitle:@"提示" message:self.isTeam?@"对不起，该队伍已经解散":@"对不起，该群组已经解散" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil, nil];
    errorDialog.tag = 10001;
    [errorDialog show];
}

-(void)showOutDialog{
    UIAlertView * errorDialog = [[UIAlertView alloc] initWithTitle:@"提示" message:self.isTeam?@"对不起，您已经不在该组队里":@"对不起，您已经不在该群组里" delegate:self cancelButtonTitle:@"确定"otherButtonTitles:nil, nil];
    errorDialog.tag = 10001;
    [errorDialog show];

}

-(NSString*)getMemberCount:(NSMutableDictionary*)teamInfo{
    return [NSString stringWithFormat:@"[%@/%@]",KISDictionaryHaveKey(teamInfo, @"memberCount"),KISDictionaryHaveKey(teamInfo, @"maxVol")];
}


//初始化会话界面UI
- (void)viewDidLoad
{
    [super viewDidLoad];
    //激活监听
    wxSDArray = [[NSMutableArray alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMyActive:)name:@"wxr_myActiveBeChanged"object:nil];
    //群信息更新完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupInfoUploaded:) name:groupInfoUpload object:nil];
    //用户信息更新完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userInfoUploaded:) name:userInfoUpload object:nil];
    //解散该群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisbandGroup:) name:kDisbandGroup object:nil];
    //被剔出该群
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onkickOffGroupGroup:) name:kKickOffGroupGroup object:nil];
    //群动态消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedGroupDynamicMsg:) name:GroupDynamic_msg object:nil];
    //组队人数变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(teamMemberCountChang:) name:UpdateTeamMemberCount object:nil];
    //发送系统消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSystemMessage:) name:kSendSystemMessage object:nil];

    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showRecordAudioDB:) name:RECORDAUDIOBD object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(saveAudioSuccessed:) name:KSAVEAUDIOSUCCESS object:nil];
    
    
    [self initMyInfo];
    postDict = [NSMutableDictionary dictionary];
    self.typeData_list = [NSArray array];
    canAdd = YES;
    historyMsg = 0;
    endOfTable = YES;
    oTherPage= NO;
    if([self.type isEqualToString:@"normal"]){
        offHight = 0;
    }else if([self.type isEqualToString:@"group"])
    {
        offHight = 20;
    }
    
    saveAudioSuccess = NO;
    recordAudio = [[RecordAudio alloc]init];
    recordAudio.delegate = self;
    curAudio = [[NSData alloc]init];

    
    uDefault = [NSUserDefaults standardUserDefaults];
    currentID = [uDefault objectForKey:@"account"];
    self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.view.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
    [self.view addSubview:self.tView];
    [self kkChatAddRefreshHeadView];//添加下拉刷新组件
    

    //从数据库中取出与这个人的聊天记录
    messages = [self getMsgArray:0 PageSize:20];
    [self normalMsgToFinalMsg];
    if (messages.count>0) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
    ifAudio = NO;
    ifEmoji = NO;
    [self.view addSubview:self.inPutView];  //输入框
    [self setTopViewWithTitle:@"" withBackButton:YES];
    [self.view addSubview:self.unReadL]; //未读数量
    [self changMsgToRead];
    UIButton * titleBtn = self.titleButton;
    [titleBtn addSubview:self.titleLabel]; //导航条标题

    if ([self.type isEqualToString:@"group"]&&!self.isTeam) {
        [self.view addSubview:self.groupCircleImage]; //群动态入口
        if (self.unreadMsgCount>20&&self.unreadMsgCount<100) {
            _titleLabel.hidden = YES;
            [titleBtn addSubview:self.groupunReadMsgLable];//群未读消息数
            
            CGSize textSize = [_groupunReadMsgLable.text sizeWithFont:[UIFont boldSystemFontOfSize:18] constrainedToSize:CGSizeMake(200, 20) lineBreakMode:NSLineBreakByWordWrapping];
            _groupunReadMsgLable.frame = CGRectMake((200-textSize.width)/2, 10, textSize.width, 20);
            _titleImageV = [[UIButton alloc]initWithFrame:CGRectMake((200-textSize.width)/2+textSize.width+2, 13.5, 13, 13)];
            [_titleImageV setBackgroundImage:KUIImage(@"group_chat_title_img_normal") forState:UIControlStateNormal];
            [_titleImageV setBackgroundImage:KUIImage(@"group_chat_title_img_click") forState:UIControlStateHighlighted];
            [titleBtn addSubview:_titleImageV];
        }else{
            _titleLabel.hidden = NO;
        }
    }
    [self.view addSubview:titleBtn];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification
        object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification
        object:nil];
    //图片与表情按钮
    [self.view addSubview:self.theEmojiView];
    self.theEmojiView.hidden = YES;
    [self.view addSubview:self.kkChatAddView];
    self.kkChatAddView.hidden = YES;
    //长按以后的按钮-》
    copyItem = [[UIMenuItem alloc] initWithTitle:@"复制"action:@selector(copyMsg)];
    delItem = [[UIMenuItem alloc] initWithTitle:@"删除"action:@selector(deleteMsg)];
    menu = [UIMenuController sharedMenuController];
    
    //个人资料按钮
    profileButton=[UIButton buttonWithType:UIButtonTypeCustom];
    profileButton.frame=CGRectMake(320-65, KISHighVersion_7?20:0, 65, 44);
    if (self.isTeam) {
        [profileButton setBackgroundImage:[UIImage imageNamed:@"team_menu_icon.png"] forState:UIControlStateNormal];
    }else{
        [profileButton setBackgroundImage:[UIImage imageNamed:@"user_info_normal.png"] forState:UIControlStateNormal];
        [profileButton setBackgroundImage:[UIImage imageNamed:@"user_info_click.png"] forState:UIControlStateHighlighted];
    }
    [profileButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
    [self.view addSubview:profileButton];
    [self.view bringSubviewToFront:profileButton];
    [profileButton addTarget:self action:@selector(userInfoClick) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.isTeam) {
       NSMutableDictionary *  teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:self.gameId] RoomId:[GameCommon getNewStringWithId:self.roomId]];
        if ([KISDictionaryHaveKey(teamInfo, @"teamUsershipType") intValue]==0) {
            teamUsershipType = YES;
        }
        
        
        self.topItemView=[UIButton buttonWithType:UIButtonTypeCustom];
        self.topItemView.frame=CGRectMake(0,startX, 320, 0);
        [self.topItemView setBackgroundImage:KUIImage([self getBgImage]) forState:UIControlStateNormal];
        [self.topItemView.titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [self.topItemView addTarget:self action:@selector(showTeamInfoView) forControlEvents:UIControlEventTouchUpInside];
        self.topItemView.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.topItemView.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//UIColorFromRGBA(0x339adf, 1)
        [self.topItemView setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:self.topItemView];
        
        
        self.leftImage = [[UIImageView alloc] initWithFrame:CGRectMake(10, 52/4, 52/2, 52/2)];
        self.leftImage.image = KUIImage([self getleftIcon]);
        [self.topItemView addSubview:self.leftImage];
        
        self.rightImage = [[UIImageView alloc] initWithFrame:CGRectMake(320-22-10, (52-22)/2, 22, 22)];
        self.rightImage.image = KUIImage(@"team_right_top");
        [self.topItemView addSubview:self.rightImage];
        
        
        //就位确认
        self.newTeamMenuView = [[NewTeamMenuView alloc] initWithFrame:CGRectMake(0, kScreenHeigth, kScreenWidth,kScreenHeigth) GroupId:self.chatWithUser RoomId:self.roomId GameId:self.gameId teamUsershipType:teamUsershipType];
        self.newTeamMenuView.mSuperView = self.view;
        self.newTeamMenuView.detaildelegate = self;
        [self.view addSubview:self.newTeamMenuView];
        [self hideExtendedChooseView];
        if (!teamUsershipType) {
            [self initOrHideListView];
        }
        
        self.newTeamApplyListView = [[NewTeamApplyListView alloc] initWithFrame:CGRectMake(0, kScreenHeigth, kScreenWidth,kScreenHeigth) GroupId:self.chatWithUser RoomId:self.roomId GameId:self.gameId teamUsershipType:teamUsershipType];
        self.newTeamApplyListView.mSuperView = self.view;
        self.newTeamApplyListView.detaildelegate = self;
        [self.view addSubview:self.newTeamApplyListView];
        [self hideApplyListExtendedChooseView];
        if (teamUsershipType) {
            [self initOrHideApplyListView];
        }
    }
    
    showRecordView = [[ShowRecordView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    showRecordView.center = self.view.center;
    showRecordView.hidden = YES;
    [self.view addSubview:showRecordView];
    
    
    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.labelText = @"正在处理图片...";
    [self.view addSubview:hud];
}
-(NSString*)getBgImage{
    if (!teamUsershipType) {
        return @"team_inpace_top";
    }
    return @"team_apply_top";
}
-(NSString*)getleftIcon{
    if (!teamUsershipType) {
        return @"team_inpace_icon";
    }
    return @"team_apply_icon_chat";
}

//
-(void)initOrHideApplyListView{
    NSInteger  msgC = [DataStoreManager getDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"3"];
    if (msgC>0) {
        [self showTopItemView:[NSString stringWithFormat:@"%d条申请",msgC]];
    }else{
        [self hideTopItemView];
    }
}

-(void)initOrHideListView{
    NSInteger onClickState = [DataStoreManager getTeamUser:self.chatWithUser UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    if(onClickState == 0){
        if (!teamUsershipType) {
            [self mHideTopMenuView];
        }
    }else if(onClickState == 1){
        if (!teamUsershipType) {
            [self mShowTopMenuView:@"就位确认消息"];
        }
    }
}

#pragma mark 用户详情
-(void)userInfoClick
{
    oTherPage = YES;
    if ([self.type isEqualToString:@"normal"]) {
        TestViewController *detailV = [[TestViewController alloc]init];
        detailV.userId = self.chatWithUser;
        detailV.nickName = self.nickName;
        detailV.isChatPage = YES;
        [self.navigationController pushViewController:detailV animated:YES];
    }else if([self.type isEqualToString:@"group"])
    {
        if (self.isTeam) {//队伍详情
            [self showFilterMenu];
            return;
        }
        GroupInformationViewController *gr = [[GroupInformationViewController alloc]init];
        gr.groupId =[GameCommon getNewStringWithId:self.chatWithUser];
        [self.navigationController pushViewController:gr animated:YES];
    }
}

#pragma mark 显示组队详情View
-(void)showTeamInfoView{
    if (teamUsershipType) {
        [self showOrHideApplyListControl];
        [self readTeamApplyMsg];
    }else{
        [self showOrHideControl];
        [self readInpaceMsg];
    }
}

//显示房间过滤菜单
-(void)showFilterMenu
{
    NSArray * menuarry = [NSArray array];
    NSArray * iconarry = [NSArray array];
    
    if (teamUsershipType) {
        menuarry = @[@"选择位置",@"队员列表",@"邀请好友",@"入队申请",@"队伍详情"];
        iconarry = @[@"team_position_icon",@"team_memberlist_icon",@"team_invitation_icon",@"team_apply_icon",@"team_detail_icon"];
    }else{
        menuarry = @[@"选择位置",@"队员列表",@"邀请好友",@"队伍详情"];
        iconarry = @[@"team_position_icon",@"team_memberlist_icon",@"team_invitation_icon",@"team_detail_icon"];
    }
    NSMutableArray *menuItems = [NSMutableArray array];
    for (int i = 0; i<menuarry.count; i++) {
        KxMenuItem *menuItem = [KxMenuItem menuItem:menuarry[i] image:KUIImage(iconarry[i]) target:self action:@selector(pushMenuItem:)];
        menuItem.tag =i;
        menuItem.alignment = NSTextAlignmentCenter;
        [menuItems addObject:menuItem];
    }
    KxMenuItem *first = [KxMenuItem menuItem:@"组队菜单" image:nil target:nil action:NULL];
    first.foreColor = [UIColor colorWithRed:47/255.0f green:112/255.0f blue:225/255.0f alpha:1.0];
    first.alignment = NSTextAlignmentCenter;
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(320-5-50, startX-40, 50, 25) menuItems:menuItems];
}
#pragma mark -- 筛选
- (void) pushMenuItem:(KxMenuItem*)sender
{
    NSInteger index = sender.tag;
    if (teamUsershipType) {
        if (index == 0) {
            [self positionAction];
        }else if(index == 1){
            [self showOrHideControl];
        }else if (index == 2){
            [self invitationAtion];
        }else if (index == 3){
            [self showOrHideApplyListControl];
        }else if (index == 4){
            [self teamInfoAction];
        }
    }else {
        if (index == 0) {
            [self positionAction];
        }else if(index == 1){
            [self showOrHideControl];
        }else if (index == 2){
            [self invitationAtion];
        }else if (index == 3){
            [self teamInfoAction];
        }
    }
    NSLog(@"---index--%d",index);
  
}

//////队员列表
//显示或者隐藏控制
-(void)showOrHideControl{
    [self showOrHideView];
}
//显示或者隐藏布局
-(void)showOrHideView{
    if (isMenuShow) {
        isMenuShow = NO;
        [self hideExtendedChooseView];
    }else{
        isMenuShow = YES;
        [self showChooseListViewInSection];
    }
}
//隐藏队员列表
- (void)hideExtendedChooseView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.newTeamMenuView.frame = CGRectMake(0, kScreenHeigth, kScreenWidth,kScreenHeigth);
    }completion:^(BOOL finished) {
        self.newTeamMenuView.hidden = YES;
        [self.newTeamMenuView hideView];
    }];
    
}
//显示队员列表
-(void)showChooseListViewInSection
{
    [UIView animateWithDuration:0.3 animations:^{
        self.newTeamMenuView.hidden = NO;
        [self.newTeamMenuView showView];
        self.newTeamMenuView.frame = CGRectMake(0, KISHighVersion_7?20:0, kScreenWidth,kScreenHeigth);
    }completion:^(BOOL finished) {
    }];
}


//显示头部View
-(void)showTopItemView:(NSString*)titleText{
    [UIView animateWithDuration:0.3 animations:^{
        self.topItemView.hidden = NO;
        [self.topItemView setTitle:titleText forState:UIControlStateNormal];
        self.topItemView.frame = CGRectMake(0, startX, 320, topViewHight);
         tView.frame = CGRectMake(0,startX+topViewHight,320,kScreenHeigth-startX-topViewHight-55);
    }completion:^(BOOL finished) {
        
    }];
    offsetTopHight = topViewHight;
   
}
//隐藏头部View
-(void)hideTopItemView{
    [UIView animateWithDuration:0.3 animations:^{
        self.topItemView.frame = CGRectMake(0, startX, 320, 0);
        tView.frame = CGRectMake(0,startX,320,self.view.frame.size.height-startX-55);
    }completion:^(BOOL finished) {
         self.topItemView.hidden = YES;
    }];
    offsetTopHight = 0;
    
}
#pragma mark -- 跳转角色详情
-(void)itemOnClick:(NSDictionary*)charaDic{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"failedmsg")] isEqualToString:@"404"]
        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"failedmsg")] isEqualToString:@"notSupport"]) {
        [self showMessageWithContent:@"角色不存在或者暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
    VC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"characterId")];
    VC.gameId =  [GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"gameid")];
    VC.characterName = KISDictionaryHaveKey(charaDic, @"characterName");
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark -- 头像点击
-(void)headImgClick:(NSString*)userId{
    NSString *userid = [GameCommon getNewStringWithId:userId];
    TestViewController *itemInfo = [[TestViewController alloc]init];
    itemInfo.userId = userid;
    [self.navigationController pushViewController:itemInfo animated:YES];
}
#pragma mark -- 清除消息
-(void)readInpaceAction{
    [self readNoreadMsg];
    [self setNoreadMsgView];
    [self setInplaceMsgCount];
}
#pragma mark -- 显示隐藏View
-(void)doShowOrHideViewControl{
    [self showOrHideControl];
}


#pragma mark -- 隐藏头部消息提示view
-(void)mHideTopMenuView{
    [self hideTopItemView];
}
#pragma mark -- 显示头部消息提示view
-(void)mShowTopMenuView:(NSString*)titleText{
    [self showTopItemView:titleText];
}
/////


//////申请列表
//显示或者隐藏控制
-(void)showOrHideApplyListControl{
    [self showApplyListOrHideView];
}
//显示或者隐藏布局
-(void)showApplyListOrHideView{
    if (isApplyShow) {
        isApplyShow = NO;
        [self hideApplyListExtendedChooseView];
    }else{
        isApplyShow = YES;
        [self showApplyListViewInSection];
    }
}
//隐藏队员列表
- (void)hideApplyListExtendedChooseView
{
    [UIView animateWithDuration:0.3 animations:^{
        self.newTeamApplyListView.frame = CGRectMake(0, kScreenHeigth, kScreenWidth,kScreenHeigth);
    }completion:^(BOOL finished) {
        self.newTeamApplyListView.hidden = YES;
        [self.newTeamApplyListView hideView];
    }];
    
}
//显示队员列表
-(void)showApplyListViewInSection
{
    [UIView animateWithDuration:0.3 animations:^{
        self.newTeamApplyListView.hidden = NO;
        [self.newTeamApplyListView showView];
        self.newTeamApplyListView.frame = CGRectMake(0, KISHighVersion_7?20:0, kScreenWidth,kScreenHeigth);
    }completion:^(BOOL finished) {
    }];
}

#pragma mark -- 跳转角色详情
-(void)itemApplyListOnClick:(NSDictionary*)charaDic{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"failedmsg")] isEqualToString:@"404"]
        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"failedmsg")] isEqualToString:@"notSupport"]) {
        [self showMessageWithContent:@"角色不存在或者暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
        return;
    }
    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
    VC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"characterId")];
    VC.gameId =  [GameCommon getNewStringWithId:KISDictionaryHaveKey(charaDic, @"gameid")];
    VC.characterName = KISDictionaryHaveKey(charaDic, @"characterName");
    [self.navigationController pushViewController:VC animated:YES];
}
#pragma mark -- 头像点击
-(void)headImgApplyListClick:(NSString*)userId{
    NSString *userid = [GameCommon getNewStringWithId:userId];
    TestViewController *itemInfo = [[TestViewController alloc]init];
    itemInfo.userId = userid;
    [self.navigationController pushViewController:itemInfo animated:YES];
}
#pragma mark -- 清除消息
-(void)readAppMsgAction{
    [self readTeamApplyMsg];
}
#pragma mark -- 显示隐藏View
-(void)doApplyListShowOrHideViewControl{
    [self showOrHideApplyListControl];
}
#pragma mark -- 隐藏View
-(void)mHideApplyListTopMenuView{
    [self hideTopItemView];
}
#pragma mark -- 显示View
-(void)mShowApplyListTopMenuView{
    [self initOrHideApplyListView];
}

//
-(void)readTeamApplyMsg{
    [DataStoreManager updateDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"1"];
    [DataStoreManager updateDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"3" Successcompletion:^(BOOL success, NSError *error) {
        [self readNoreadMsg];
        [self setNoreadMsgView];
        [self setNotifyMsgCount];
        [self hideTopItemView];
    }];
}

//
-(void)readInpaceMsg{
    [DataStoreManager updateDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"1"];
    [DataStoreManager updateDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"4" Successcompletion:^(BOOL success, NSError *error) {
        [self readNoreadMsg];
        [self setNoreadMsgView];
        [self setInplaceMsgCount];
    }];
}

/////


//选择位置
-(void)returnChooseInfoFrom:(UIViewController *)vc info:(NSDictionary *)info{
    NSMutableDictionary * clickType = [info mutableCopy];
    if ([selectType isKindOfClass:[NSDictionary class]]&&[KISDictionaryHaveKey(clickType, @"value") isEqualToString:KISDictionaryHaveKey(selectType, @"value")]) {
        return;
    }
    [[ItemManager singleton] setTeamPosition:self.gameId UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] RoomId:self.roomId PositionTag:clickType GroupId:self.chatWithUser reSuccess:^(id responseObject) {
        selectType = clickType;
        [self sendOtherMsg:[NSString stringWithFormat:@"选择了 %@",KISDictionaryHaveKey(selectType, @"value")] TeamPosition:KISDictionaryHaveKey(selectType, @"value")];
        [self changPosition];
        [self setPositionMsgCount];
    } reError:^(id error) {
        [self showErrorAlertView:error];
    }];
}

//跳转位置页面
-(void)positionAction{
    LocationViewController *itemInfo = [[LocationViewController alloc]init];
    itemInfo.gameid = self.gameId;
    itemInfo.mydelegate = self;
    [self.navigationController pushViewController:itemInfo animated:YES];
}
//邀请好友页面
-(void)invitationAtion{
    InvitationMembersViewController *invc = [[InvitationMembersViewController alloc]init];
    invc.gameId = [GameCommon getNewStringWithId:self.gameId];
    invc.groupId = [GameCommon getNewStringWithId:self.chatWithUser];
    invc.roomId = [GameCommon getNewStringWithId:self.roomId];
    [self.navigationController pushViewController:invc animated:YES];
}
//入队申请
-(void)applyAction{
    [self refreJoinApplyMsgCount];
    TeamApplyController *itemInfo = [[TeamApplyController alloc]init];
    itemInfo.groipId = self.chatWithUser;
    itemInfo.roomId = self.roomId;
    itemInfo.gameId = self.gameId;
    itemInfo.teamUsershipType = teamUsershipType;
    [self.navigationController pushViewController:itemInfo animated:YES];
}
//组队详情
-(void)teamInfoAction{
    ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
    itemInfo.itemId = [GameCommon getNewStringWithId:self.roomId];
    itemInfo.gameid =[GameCommon getNewStringWithId:self.gameId];
    [self.navigationController pushViewController:itemInfo animated:YES];
}
/////

//设置组队未读消息数量
-(void)setNotifyMsgCount{
    NSInteger  msgC = [DataStoreManager getDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"3"];
    [self setNotifyMsgCount:msgC];
}

-(void)setNotifyMsgCount:(NSInteger)msgC{
    if (msgC>0) {
        self.dotVApp.hidden = NO;
        [self.dotVApp setMsgCount:msgC];
    }else{
        [self.dotVApp setMsgCount:0];
        self.dotVApp.hidden = YES;
    }
}

//设置就位确认未读消息数量
-(void)setInplaceMsgCount{
   NSInteger msgC = [DataStoreManager getDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"4"];
    [self setInplaceMsgCount:msgC];
}

-(void)setInplaceMsgCount:(NSInteger)msgC{
    if (msgC>0) {
        self.dotVInplace.hidden = NO;
        [self.dotVInplace setMsgCount:msgC IsSimple:YES];
    }else{
        [self.dotVInplace setMsgCount:0 IsSimple:YES];
        self.dotVInplace.hidden = YES;
    }
}
//设置就位确认未读消息数量
-(void)setPositionMsgCount{
    NSInteger positionCount;
    if (selectType) {
        positionCount = 0;
    }else {
        positionCount = 1;
    }
    [self setPositionMsgCount:positionCount];
}
-(void)setPositionMsgCount:(NSInteger)positionCount{
    if (positionCount>0) {
        self.dotVPosition.hidden = NO;
        [self.dotVPosition setMsgCount:positionCount IsSimple:YES];
    }else{
        [self.dotVPosition setMsgCount:0 IsSimple:YES];
        self.dotVPosition.hidden = YES;
    }
}

#pragma mark -- 分类请求成功通知
-(void)updateTeamType:(id)responseObject
{
    if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
        self.typeData_list = responseObject;
        [self.dropDownView.customPhotoCollectionView reloadData];
    }
}
//改变数据库位置
-(void)changPosition
{
    [self changGroupMsgLocation:self.chatWithUser UserId:@"you" TeamPosition:KISDictionaryHaveKey(selectType, @"value")];
    [self.tView reloadData];
}
//改变列表位置
-(void)changGroupMsgLocation:(NSString*)groupId UserId:(NSString*)userid TeamPosition:(NSString*)teamPosition
{
    for (NSDictionary * msgDic in messages) {
        if ([KISDictionaryHaveKey(msgDic, @"sender") isEqualToString:userid]) {
            [msgDic setValue:teamPosition forKey:@"teamPosition"];
        }
    }
}
//------------------------------------------------------------------------------------------------------------
#pragma mark -- dropDownListDelegate
-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    if (section == 0){
        if (self.typeData_list&&index<self.typeData_list.count) {
            NSMutableDictionary * clickType = [self.typeData_list objectAtIndex:index];
            if ([selectType isKindOfClass:[NSDictionary class]]&&[KISDictionaryHaveKey(clickType, @"value") isEqualToString:KISDictionaryHaveKey(selectType, @"value")]) {
                return;
            }
            [[ItemManager singleton] setTeamPosition:self.gameId UserId:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] RoomId:self.roomId PositionTag:clickType GroupId:self.chatWithUser reSuccess:^(id responseObject) {
                selectType = clickType;
                [self sendOtherMsg:[NSString stringWithFormat:@"选择了 %@",KISDictionaryHaveKey(selectType, @"value")] TeamPosition:KISDictionaryHaveKey(selectType, @"value")];
                [self changPosition];
                [self setPositionMsgCount];
            } reError:^(id error) {
                [self showErrorAlertView:error];
            }];
        }else{
            [self showAlertViewWithTitle:@"提示" message:@"选择位置出错" buttonTitle:@"确定"];
        }
    }
}
-(BOOL) clickAtSection:(NSInteger)section
{
    if (section==0) {
        [[ItemManager singleton] getMyGameLocation:self.gameId reSuccess:^(id responseObject) {
            [self updateTeamType:responseObject];
        } reError:^(id error) {
        }];
        return YES;
    }else if(section == 1){
        return YES;
    }else if(section==2){
        [self refreJoinApplyMsgCount];
        return YES;
    }
    return NO;
}
//#pragma mark -- dropdownList DataSource
//-(NSInteger)numberOfSections
//{
//    return 3;
//}
//-(NSInteger)numberOfRowsInSection:(NSInteger)section
//{
//    if (section==0) {
//        return self.typeData_list.count;
//    }
//    return 0;
//}
//-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
//{
//    if (section==0) {
//        if (self.typeData_list.count>0) {
//            return KISDictionaryHaveKey([self.typeData_list objectAtIndex:index], @"value");
//        }
//    }else if (section==1){
//        return @"";
//    }
//    return @"申请";
//}
//
//-(NSInteger)defaultShowSection:(NSInteger)section
//{
//    return 0;
//}
//头像点击进入个人详情
//- (void)headImgClick:(NSString*)userId {
//    NSString *userid = [GameCommon getNewStringWithId:userId];
//    TestViewController *itemInfo = [[TestViewController alloc]init];
//    itemInfo.userId = userid;
//    [self.navigationController pushViewController:itemInfo animated:YES];
//}
////cell点击进入角色详情
//- (void)itemOnClick:(NSMutableDictionary*)dic{
//    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"404"]
//        ||[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"failedmsg")] isEqualToString:@"notSupport"]) {
//        [self showMessageWithContent:@"角色不存在或者暂不支持" point:CGPointMake(kScreenWidth/2, kScreenHeigth/2)];
//        return;
//    }
//    H5CharacterDetailsViewController* VC = [[H5CharacterDetailsViewController alloc] init];
//    VC.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterId")];
//    VC.gameId =  [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
//    VC.characterName = KISDictionaryHaveKey(dic, @"characterName");
//    [self.navigationController pushViewController:VC animated:YES];
//}
////刷新就位确认消息数量
//- (void)buttonOnClick{
//    [self readNoreadMsg];
//    [self setNoreadMsgView];
//    [self setInplaceMsgCount];
//}
//刷新申请加入组队消息的数量
-(void)refreJoinApplyMsgCount{
    [DataStoreManager updateDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"1"];
    [DataStoreManager updateDSTeamNotificationMsgCount:self.chatWithUser SayHightType:@"3" Successcompletion:^(BOOL success, NSError *error) {
        [self readNoreadMsg];
        [self setNoreadMsgView];
        [self setNotifyMsgCount];
    }];
}

//------------------------------------------------------------------------------------------------------------


-(void)changMsgToRead
{
    if ([self.type isEqualToString:@"normal"]) {
        [self sendReadedMesg];//发送已读消息
    }
    if ([self.type isEqualToString:@"normal"]) {
        [DataStoreManager blankMsgUnreadCountForUser:self.chatWithUser Successcompletion:^(BOOL success, NSError *error) {
            [self readNoreadMsg];
            [self setNoreadMsgView];
        }];
    }else if ([self.type isEqualToString:@"group"]){
        [DataStoreManager blankGroupMsgUnreadCountForUser:self.chatWithUser Successcompletion:^(BOOL success, NSError *error) {
            [self readNoreadMsg];
            [self setNoreadMsgView];
        }];
    }
    
}


-(NSMutableArray*)getMsgArray:(NSInteger)FetchOffset PageSize:(NSInteger)pageSize
{
    if([self.type isEqualToString:@"normal"]){
        return [[NSMutableArray alloc]initWithArray:[DataStoreManager qureyCommonMessagesWithUserID:self.chatWithUser FetchOffset:FetchOffset PageSize:pageSize]];
    }else if([self.type isEqualToString:@"group"])
    {
       return  [[NSMutableArray alloc]initWithArray:[DataStoreManager qureyGroupMessagesGroupID:self.chatWithUser FetchOffset:FetchOffset PageSize:pageSize]];
    }
    return nil;
}
//初始我的信息（激活状态，头像）
-(void)initMyInfo
{
    myActive = YES;
    DSuser * friend = [DataStoreManager queryDUser:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
//    myActive = [friend.action boolValue];
    self.myNickName = friend.nickName;
    self.myHeadImg = [ImageService getImageOneId:friend.headImgID];
}
//改变我的激活状态
- (void)changeMyActive:(NSNotification*)notification
{
     myActive = YES;
//    if ([notification.userInfo[@"active"] intValue] == 2) {
//        myActive = YES;
//    }else
//    {
//        myActive = NO;
//    }
}

#pragma mark ---TabView 显示方法
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSMutableDictionary *dict = [messages objectAtIndex:indexPath.row];
    NSString *sender = KISDictionaryHaveKey(dict, @"sender");
    NSString *time = [KISDictionaryHaveKey(dict, @"time") substringToIndex:10];
    NSString *status = KISDictionaryHaveKey(dict, @"status");
    CGSize size = CGSizeMake([[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:0] floatValue],[[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:1] floatValue]);
    size.width = size.width<20?20:size.width;
    size.height = size.height<20?20:size.height;
    
    KKChatMsgType kkChatMsgType = [self msgType:dict];
    //动态消息
    if (kkChatMsgType == KKChatMsgTypeLink) {
        static NSString *identifier = @"newsCell";
        KKNewsCell *cell =(KKNewsCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (cell == nil) {
            cell = [[KKNewsCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        NSDictionary* msgDic = [[self.finalMessageArray objectAtIndex:indexPath.row] JSONValue];
        CGSize titleSize = [self getPayloadMsgTitleSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"title")]];
        CGSize contentSize = CGSizeZero;
        cell.titleLabel.text = KISDictionaryHaveKey(msgDic, @"title");
        contentSize = [self getPayloadMsgContentSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msg")]withThumb:YES];
        NSString * dImageId=[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"thumb")];
        if ([GameCommon isEmtity:dImageId] ||[dImageId isEqualToString:@"null"]) {
            cell.thumbImgV.imageURL = nil;
        }else
        {
            cell.thumbImgV.imageURL = [ImageService getImageUrl3:dImageId Width:70];
        }
        if (indexPath.row==0) {
            cell.senderAndTimeLabel.hidden=YES;
        }else{
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            NSString* pTime = [[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"];
            [cell setMsgTime:timeStr lastTime:time previousTime:pTime];
        }
        cell.contentLabel.text = KISDictionaryHaveKey(msgDic, @"msg");
        [cell.bgImageView setTag:(indexPath.row+1)];
        UIImage *bgImage = nil;
        if ([sender isEqualToString:@"you"]) {
            //头像
            [cell setHeadImgByMe:self.myHeadImg];
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            [cell.thumbImgV setFrame:CGRectMake(55,40 + titleSize.height,40,40)];
            bgImage = [[UIImage imageNamed:@"bubble_05"]stretchableImageWithLeftCapWidth:15 topCapHeight:22];
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30,padding*2-15,size.width+25,size.height+20)];
             cell.senderNickName.hidden=YES;
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            [cell.failImage setTag:(indexPath.row+1)];
            [cell.failImage addTarget:self action:@selector(resendMsgClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.titleLabel setFrame:CGRectMake(padding + 35, 33,titleSize.width,titleSize.height+(contentSize.height > 0 ? 0 : 5))];
            [cell.contentLabel setFrame:CGRectMake(padding + 50 +28,35 + titleSize.height + (titleSize.height > 0 ? 5 : 0), contentSize.width,contentSize.height)];
            [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,(size.height+20)/2 + padding*2-15)status:status];
        }else
        {
            [cell.thumbImgV setFrame:CGRectMake(70,40 + titleSize.height,40,40)];
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:sender];
            NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
            NSString * userNickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            [cell setHeadImgByChatUser:userImage];
            [cell setUserPosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            
            if([self.type isEqualToString:@"normal"]){
                cell.senderNickName.hidden=YES;
            }else if([self.type isEqualToString:@"group"]){
                cell.senderNickName.hidden=NO;
                cell.senderNickName.text = userNickName;
            }
            
            bgImage = [[UIImage imageNamed:@"bubble_04.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:22];
            [cell.bgImageView setFrame:CGRectMake(padding-10+45,padding*2-15+offHight,size.width+35,size.height + 20)];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
            [cell.titleLabel setFrame:CGRectMake(padding + 50,33+offHight,titleSize.width,titleSize.height+(contentSize.height > 0 ? 0 : 5))];
            [cell.contentLabel setFrame:CGRectMake(padding + 50 + 45,35 + titleSize.height + (titleSize.height > 0 ? 5+offHight : 0+offHight),contentSize.width,contentSize.height)];
        }
        return cell;
    }
    //邀请加入组队
    else if (kkChatMsgType == KKChatMsgTeamInvite) {
        static NSString *identifier = @"teamInviteCell";
        KKTeamInviteCell *cell =(KKTeamInviteCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKTeamInviteCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        NSDictionary* msgDic = [[self.finalMessageArray objectAtIndex:indexPath.row] JSONValue];
        CGSize titleSize = [self getPayloadMsgTitleSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"msg")]];
        CGSize contentSize = CGSizeZero;
        cell.titleLabel.text = KISDictionaryHaveKey(msgDic, @"msg");
        contentSize = [self getPayloadMsgContentSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"description")]withThumb:YES];
        NSString * dImageId=[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"img")];
        cell.thumbImgV.imageURL = [ImageService getImageStr:dImageId Width:70];
        
        if (indexPath.row==0) {
            cell.senderAndTimeLabel.hidden=YES;
        }else{
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            NSString* pTime = [[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"];
            [cell setMsgTime:timeStr lastTime:time previousTime:pTime];
        }
        cell.contentLabel.text = KISDictionaryHaveKey(msgDic, @"description");
        [cell.bgImageView setTag:(indexPath.row+1)];
        UIImage *bgImage = nil;
        if ([sender isEqualToString:@"you"]) {
            //头像
            [cell setHeadImgByMe:self.myHeadImg];
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            [cell.thumbImgV setFrame:CGRectMake(55,40 + titleSize.height,40,40)];
            bgImage = [[UIImage imageNamed:@"bubble_05"]stretchableImageWithLeftCapWidth:15 topCapHeight:22];
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30,padding*2-15,size.width+25,size.height+20)];
            cell.senderNickName.hidden=YES;
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            [cell.failImage setTag:(indexPath.row+1)];
            [cell.failImage addTarget:self action:@selector(resendMsgClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.titleLabel setFrame:CGRectMake(padding + 35, 33,titleSize.width,titleSize.height+(contentSize.height > 0 ? 0 : 5))];
            cell.lineImage.hidden = YES;
            [cell.contentLabel setFrame:CGRectMake(padding + 50 +28,35 + titleSize.height + (titleSize.height > 0 ? 5 : 0), contentSize.width,contentSize.height)];
            [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,(size.height+20)/2 + padding*2-15)status:status];
        }else
        {
            [cell.thumbImgV setFrame:CGRectMake(70,40 + titleSize.height,40,40)];
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:sender];
            NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
            NSString * userNickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            [cell setHeadImgByChatUser:userImage];
            [cell setUserPosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            if([self.type isEqualToString:@"normal"]){
                cell.senderNickName.hidden=YES;
            }else if([self.type isEqualToString:@"group"]){
                cell.senderNickName.hidden=NO;
                cell.senderNickName.text = userNickName;
            }
            
            bgImage = [[UIImage imageNamed:@"bubble_04.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:22];
            [cell.bgImageView setFrame:CGRectMake(padding-10+45,padding*2-15+offHight,size.width+35,size.height + 20)];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
            [cell.titleLabel setFrame:CGRectMake(padding + 50,33+offHight,titleSize.width,titleSize.height+(contentSize.height > 0 ? 0 : 5))];
            [cell.contentLabel setFrame:CGRectMake(padding + 50 + 45,35 + titleSize.height + (titleSize.height > 0 ? 5+offHight : 0+offHight),contentSize.width,contentSize.height)];
            [cell.lineImage  setFrame:CGRectMake(cell.titleLabel.frame.origin.x,cell.titleLabel.frame.origin.y+cell.titleLabel.frame.size.height+2,size.width+10,1)];
            cell.lineImage.hidden=YES;
        }
        return cell;
    }
    
    //图片消息
    else if (kkChatMsgType == KKChatMsgTypeImage) {
        NSString * payloadStr = KISDictionaryHaveKey(dict, @"payload");
        NSDictionary *payload = [payloadStr JSONValue];
        static NSString *identifier = @"imgMsgCell";
        KKImgCell *cell = (KKImgCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKImgCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.sendMsgDeleGate = self;
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        cell.progressView.hidden=YES;
        if (indexPath.row==0) {
            cell.senderAndTimeLabel.hidden=YES;
        }else{
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            NSString* pTime = [[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"];
            [cell setMsgTime:timeStr lastTime:time previousTime:pTime];
        }
        if ([sender isEqualToString:@"you"])
        {
            [cell setHeadImgByMe:self.myHeadImg];
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            [cell.bgImageView setTag:(indexPath.row+1)];
            
            [cell.failImage setTag:(indexPath.row+1)];
            [cell.failImage addTarget:self action:@selector(resendMsgClick:) forControlEvents:UIControlEventTouchUpInside];
            
            cell.msgImageView.placeholderImage = [UIImage imageNamed:@"placeholder.png"];
            cell.senderNickName.hidden=YES;
               //根据uuid取缩略图
            NSString* uuid_thumimg = KISDictionaryHaveKey(dict, @"messageuuid");
            UIImage* thumbimg = KISDictionaryHaveKey(self.finalImage,uuid_thumimg);
            if (thumbimg&&![thumbimg isEqual:@""]){
                cell.msgImageView.image = thumbimg;
            }else{
                NSString *kkChatImageMsg = KISDictionaryHaveKey(payload, @"msg");
                if (kkChatImageMsg) {
                    cell.msgImageView.imageURL = [ImageService getImageUrl3:kkChatImageMsg Width:200];
                }
            }
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
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:sender];
            NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
            NSString * userNickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            [cell setHeadImgByChatUser:userImage];
            [cell setUserPosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            if([self.type isEqualToString:@"normal"]){
                cell.senderNickName.hidden=YES;
            }else if([self.type isEqualToString:@"group"]){
                cell.senderNickName.hidden=NO;
                cell.senderNickName.text = userNickName;
            }
            [cell.bgImageView setTag:(indexPath.row+1)];
            [cell.msgImageView setFrame:CGRectMake(220-size.width - padding-38,padding*2-15+offHight,100,100)];
            cell.msgImageView.tag = indexPath.row;
            cell.msgImageView.placeholderImage = [UIImage imageNamed:@"placeholder.png"];
            //显示为缩略图
            NSString *kkChatImageMsg = KISDictionaryHaveKey(payload, @"msg");
            if (kkChatImageMsg) {
                cell.msgImageView.imageURL = [ImageService getImageUrl3:kkChatImageMsg Width:200];
            }else{
                cell.msgImageView.imageURL = nil;
            }
            cell.msgImageView.hidden = NO;
            cell.msgImageView.userInteractionEnabled = YES;
            UITapGestureRecognizer* tabPress =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(lookBigImg:)];
            UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressImg:)];
            [cell.msgImageView addGestureRecognizer:tabPress];
            [cell.msgImageView addGestureRecognizer:longPress];
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
        }
        return  cell;
    }
    //加入群，退出群，解散群
    else if (kkChatMsgType == KKChatMsgTypeSystem) {
        static NSString *identifier = @"systemMsgCell";
        KKSystemMsgCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[KKSystemMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        NSString* msg = KISDictionaryHaveKey(dict, @"msg");
        if (indexPath.row==0) {
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            cell.timeLable.text = [NSString stringWithFormat:@"%@", timeStr];
        }else{
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            NSString* pTime = [[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"];
            [cell setMsgTime:timeStr lastTime:time previousTime:pTime];
        }
        cell.msgLable.text = msg;
        CGSize textSize = [cell.timeLable.text sizeWithFont:[UIFont boldSystemFontOfSize:12] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
        cell.timeLable.frame=CGRectMake((320-textSize.width)/2, 2, textSize.width, textSize.height);
        cell.lineImage1.frame=CGRectMake(5, 10, (320-textSize.width)/2-10, 1);
        cell.lineImage2.frame=CGRectMake(cell.timeLable.frame.origin.x+cell.timeLable.frame.size.width+5, 10, (320-textSize.width)/2-10, 1);
        CGSize msgLabletextSize = [cell.msgLable.text sizeWithFont:[UIFont boldSystemFontOfSize:10] constrainedToSize:CGSizeMake(maxWight, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
        cell.msgLable.frame=CGRectMake((320-msgLabletextSize.width)/2, 22, msgLabletextSize.width+5, msgLabletextSize.height+2);
        return cell;
    }
    else if (kkChatMsgType == KKChatMsgSimple)
    {
        static NSString *identifier = @"simpleMsgCell";
        KKSimpleMsgCell *cell = (KKSimpleMsgCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKSimpleMsgCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        if (indexPath.row==0) {
            cell.senderAndTimeLabel.hidden=YES;
        }else{
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            NSString* pTime = [[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"];
            [cell setMsgTime:timeStr lastTime:time previousTime:pTime];
        }
        NSString* msg = KISDictionaryHaveKey(dict, @"msg");
        [cell.messageContentView setEmojiText:msg];
        [cell.bgImageView setTag:(indexPath.row+1)];
        UIImage *bgImage = nil;

        NSString * payLoadStr = KISDictionaryHaveKey(dict, @"payload");
        NSDictionary * payloadDic = [payLoadStr JSONValue];
        NSString * types = KISDictionaryHaveKey(payloadDic,@"type");
        NSString * senderId = KISDictionaryHaveKey(payloadDic,@"userid");
        if([types isEqualToString:@"selectTeamPosition"]){
            senderId = sender;
        }
        //你自己发送的消息
        if ([[GameCommon getNewStringWithId:senderId] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]||[sender isEqualToString:@"you"]) {
            [cell setHeadImgByMe:self.myHeadImg];
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            cell.senderNickName.hidden =YES;
            bgImage = [[UIImage imageNamed:[self getBgImage:types IsMe:YES]]stretchableImageWithLeftCapWidth:15 topCapHeight:20];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            cell.iconImageV.image = KUIImage([self getIcon:types]);
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30-19,padding*2-10,size.width+25+20,size.height+10)];
            [cell.iconImageV setFrame:CGRectMake(320-size.width - padding-15-10-25-16-5, padding*2+4-6,13.5,13.5)];
            [cell.messageContentView setFrame:CGRectMake(320-size.width - padding-15-10-25-5, padding*2-5,size.width,size.height)];
            cell.messageContentView.textColor = [UIColor whiteColor];
            [cell hideStateView];
            
        }else { //不是你，是对方
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:senderId];
            NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
            NSString * userNickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            [cell setHeadImgByChatUser:userImage];
            [cell setUserPosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            bgImage = [[UIImage imageNamed:[self getBgImage:types IsMe:NO]]stretchableImageWithLeftCapWidth:15 topCapHeight:20];
            cell.senderNickName.hidden=NO;
            cell.senderNickName.text = userNickName;
            cell.messageContentView.textColor = [UIColor whiteColor];
            cell.iconImageV.image = KUIImage([self getIcon:types]);
            [cell.bgImageView setFrame:CGRectMake(padding-10+45, padding*2-15+offHight,size.width+25+20,size.height+10)];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            [cell.iconImageV setFrame:CGRectMake(padding+7+50-5,padding*2-2+offHight-5,13.5,13.5)];
            [cell hideStateView];
            [cell.messageContentView setFrame:CGRectMake(padding+7+45+14+10-5,padding*2-4+offHight-5,size.width,size.height)];
        }
        return cell;
    }else if (kkChatMsgType ==kkchatMsgAudio){
        static NSString *identifier = @"kkchatMegAudio";
        PlayVoiceCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[PlayVoiceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.mydelegate = self;
        cell.tag = indexPath.row+100;
        if ([sender isEqualToString:@"you"]) {
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            [cell setHeadImgByMe:self.myHeadImg];
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30,padding*2-15,size.width+25,size.height+20)];
           UIImage * bgImage = [[UIImage imageNamed:@"bubble_norla_you.png"]stretchableImageWithLeftCapWidth:5 topCapHeight:22];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            cell.voiceImageView.frame =CGRectMake(320-size.width - padding-15-10-25, padding*2-4,size.width,size.height);
            
        }else{
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:sender];

            NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
            [cell setHeadImgByChatUser:userImage];
            
            
            cell.voiceImageView.image = KUIImage(@"ReceiverVoiceNodePlaying003");
            cell.voiceImageView.frame = CGRectMake(padding+7+45,padding*2-4+offHight,17,size.height);
            [cell.bgImageView setFrame:CGRectMake(padding-10+45, padding*2-15+offHight,size.width+25,size.height+20)];
           UIImage * bgImage = [[UIImage imageNamed:@"bubble_01.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:22];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
        }
        [cell.bgImageView addTarget:self action:@selector(playAudio:) forControlEvents:UIControlEventTouchUpInside];
        cell.bgImageView.tag = 100+indexPath.row;

        return cell;
    }
    
    //以上是历史消息
    else if (kkChatMsgType == KKChatMsgHistory){
        static NSString *identifier = @"historyMsgCell";
        KKHistoryMsgCell *cell =[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[KKHistoryMsgCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.msgLable.text =  @"以上是历史消息";
        return cell;
    }
    //普通消息
    else
    {
        static NSString *identifier = @"normalMsgCell";
        KKMessageCell *cell = (KKMessageCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[KKMessageCell alloc] initWithMessage:dict reuseIdentifier:identifier];
        }
        cell.myChatCellDelegate = self;
        [cell setMessageDictionary:dict];
        if (indexPath.row==0) {
            cell.senderAndTimeLabel.hidden=YES;
        }else{
            NSString* timeStr = [self.finalMessageTime objectAtIndex:indexPath.row];
            NSString* pTime = [[messages objectAtIndex:(indexPath.row-1)] objectForKey:@"time"];
            [cell setMsgTime:timeStr lastTime:time previousTime:pTime];
        }
        NSString* msg = KISDictionaryHaveKey(dict, @"msg");
        [cell.messageContentView setEmojiText:msg];
        [cell.bgImageView setTag:(indexPath.row+1)];
        UIImage *bgImage = nil;
        //你自己发送的消息
        if ([sender isEqualToString:@"you"]) {
            [cell setHeadImgByMe:self.myHeadImg];
            [cell setMePosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            cell.senderNickName.hidden =YES;
            [cell.bgImageView setFrame:CGRectMake(320-size.width - padding-20-10-30,padding*2-15,size.width+25,size.height+20)];
            bgImage = [[UIImage imageNamed:@"bubble_norla_you.png"]stretchableImageWithLeftCapWidth:5 topCapHeight:22];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            [cell.failImage setTag:(indexPath.row+1)];
            [cell.failImage addTarget:self action:@selector(resendMsgClick:) forControlEvents:UIControlEventTouchUpInside];
            [cell.messageContentView setFrame:CGRectMake(320-size.width - padding-15-10-25, padding*2-4,size.width,size.height)];
            cell.messageContentView.hidden = NO;
            [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,(size.height+20)/2 + padding*2-15)status:status];
          
        }else { //不是你，是对方
            NSMutableDictionary * simpleUserDic = [[UserManager singleton] getUser:sender];
            NSString * userImage = KISDictionaryHaveKey(simpleUserDic, @"img");
            NSString * userNickName = KISDictionaryHaveKey(simpleUserDic, @"nickname");
            [cell setHeadImgByChatUser:userImage];
            [cell setUserPosition:self.isTeam TeanPosition:KISDictionaryHaveKey(dict, @"teamPosition")];
            bgImage = [[UIImage imageNamed:@"bubble_01.png"]stretchableImageWithLeftCapWidth:15 topCapHeight:22];
            if([self.type isEqualToString:@"normal"]){
                cell.senderNickName.hidden=YES;
            }else if([self.type isEqualToString:@"group"]){
                cell.senderNickName.hidden=NO;
                cell.senderNickName.text = userNickName;
            }
            [cell.bgImageView setFrame:CGRectMake(padding-10+45, padding*2-15+offHight,size.width+25,size.height+20)];
            [cell.bgImageView setBackgroundImage:bgImage forState:UIControlStateNormal];
            [cell.messageContentView setFrame:CGRectMake(padding+7+45,padding*2-4+offHight,size.width,size.height)];
            cell.messageContentView.hidden = NO;
            cell.statusLabel.hidden = YES;
            cell.failImage.hidden=YES;
        }
        return cell;
    }
}
-(NSString*)getBgImage:(NSString*)payloadType IsMe:(BOOL)isMe{
    if ([payloadType isEqualToString:@"selectTeamPosition"]) {
        if (isMe) {
            return @"select_position_bg_me.png";
        }
        return @"select_position_bg_other.png";
    }else if ([payloadType isEqualToString:@"teamPreparedUserSelectOk"]){
        if (isMe) {
            return @"select_ok_bg_me.png";
        }
        return @"select_ok_bg_other.png";
    }
    else if ([payloadType isEqualToString:@"teamPreparedUserSelectCancel"]){
        if (isMe) {
            return @"select_cancel_bg_me.png";
        }
        return @"select_cancel_bg_other.png";
    }
    if (isMe) {
        return @"bubble_norla_you.png";
    }
    return @"bubble_01.png";
}


-(NSString*)getIcon:(NSString*)payloadType{
    if ([payloadType isEqualToString:@"selectTeamPosition"]) {
        return @"select_position_icon.png";
    }else if ([payloadType isEqualToString:@"teamPreparedUserSelectOk"]){
        return @"select_ok_icon.png";
    }
    else if ([payloadType isEqualToString:@"teamPreparedUserSelectCancel"]){
        return @"select_cancel_icon.png";
    }
    return @"";
}

//每一行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableDictionary *dict = [messages objectAtIndex:indexPath.row];
    float theH = [[[self.HeightArray objectAtIndex:indexPath.row] objectAtIndex:1] floatValue];
    return [self getCellHight:dict msgHight:theH];
}
//行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([messages count]!=0) {
        return [messages count];
    }
    return 0;
}
//点击重发红点
-(void)resendMsgClick:(UIButton*)sender
{
    tempBtn = sender;
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择"delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:Nil otherButtonTitles:@"重新发送", nil];
    sheet.tag = 124;
    [sheet showInView:self.view];
}
//Cell点击
-(void)onCellBgClick:(UIButton*)sender
{
    NSMutableDictionary *dict = [messages objectAtIndex:(sender.tag-1)];
    KKChatMsgType kkChatMsgType=[self msgType:dict];
    if (kkChatMsgType == KKChatMsgTypeLink) {//动态消息
        NSDictionary* msgDic = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
        OnceDynamicViewController* detailVC = [[OnceDynamicViewController alloc] init];
        detailVC.messageid = KISDictionaryHaveKey(msgDic, @"messageid");
        detailVC.delegate = nil;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if(kkChatMsgType == KKChatMsgTeamInvite){
        NSDictionary* msgDic = [KISDictionaryHaveKey(dict, @"payload") JSONValue];
        ItemInfoViewController *itemInfo = [[ItemInfoViewController alloc]init];
        itemInfo.itemId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"roomId")];
        itemInfo.gameid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(msgDic, @"gameid")];
        [self.navigationController pushViewController:itemInfo animated:YES];

    }
}
//Cell长按
-(void)onCellBgLongClick:(UITapGestureRecognizer*)sender
{
    UIButton* bgBtn = (UIButton*)sender.view;
    tempBtn = bgBtn;
    readyIndex = bgBtn.tag-1;
    [self canBecomeFirstResponder];
    [self becomeFirstResponder];
    //弹出菜单
    indexPathTo = [[NSIndexPath indexPathForRow:(readyIndex) inSection:0] copy];
    KKMessageCell * cell = (KKMessageCell *)[self.tView cellForRowAtIndexPath:indexPathTo];
    tempStr = [[[messages objectAtIndex:indexPathTo.row] objectForKey:@"msg"] copy];
    CGRect rect = [self.view convertRect:tempBtn.frame fromView:cell.contentView];
    
    [menu setMenuItems:[NSArray arrayWithObjects:copyItem,delItem,nil]];
    [menu setTargetRect:CGRectMake(rect.origin.x, rect.origin.y, 60, 90) inView:self.view];
    [menu setMenuVisible:YES animated:YES];
}
#pragma mark - Views
//表情按钮
- (EmojiView *)theEmojiView{
    if (!_theEmojiView) {
        _theEmojiView = [[EmojiView alloc]initWithFrame:CGRectMake(0,self.view.frame.size.height-253,320,253)WithSendBtn:YES];
        _theEmojiView.delegate = self;
    }
    return _theEmojiView;
}
//加号（图片，照片，位置等）
- (UIView *)kkChatAddView{
    if (!_kkChatAddView) {
        _kkChatAddView = [[UIView alloc] init];
        _kkChatAddView.frame = CGRectMake(0, self.view.frame.size.height-125, 320,125);
        _kkChatAddView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"chatMorebg.png"]];
        NSArray *kkChatButtonsTitle = @[@"相册",@"相机"];
        for (int i = 0; i < 2; i++) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.tag = i;
            button.frame = CGRectMake(10+i%4*80, 0+i/4*126.5, 70, 105);
            [button addTarget:self action:@selector(kkChatAddViewButtonsClick:) forControlEvents:UIControlEventTouchUpInside];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"kkChatAddViewButtonsNomal_%d",i]]forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"kkChatAddViewButtonsHighlight_%d",i]]forState:UIControlStateHighlighted];
            [button setTitleColor:UIColorFromRGBA(0x4c4c4c, 1)forState:UIControlStateNormal];
            [button setImageEdgeInsets:UIEdgeInsetsMake(15, 10, 40, 10)];
            [button setTitle:[kkChatButtonsTitle objectAtIndex:i]forState:UIControlStateNormal];
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
        _inPutView.frame = CGRectMake(0, self.view.frame.size.height-50,320,50);
        UIImage *rawEntryBackground = [UIImage imageNamed:@"chat_input.png"];
        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13
                                                                           topCapHeight:22];
        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
        entryImageView.frame = CGRectMake(50, 7, 185, 35);
        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
        UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0,0,self.inPutView.frame.size.width,self.inPutView.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [_inPutView addSubview:imageView];
        [_inPutView addSubview:entryImageView];
        [_inPutView addSubview:self.audioBtn];
        [_inPutView addSubview:self.textView];
        [_inPutView addSubview:self.kkChatAddButton];
        [_inPutView addSubview:self.emojiBtn];
        [_inPutView addSubview:self.startRecordBtn];
    }
    return _inPutView;
}

#pragma mark --创建声音buton
-(UIButton *)audioBtn
{
    _audioBtn = [[UIButton alloc]initWithFrame:CGRectMake(5, 5, 40, 40)];
    _audioBtn.backgroundColor = [UIColor clearColor];
    _audioBtn.titleLabel.numberOfLines = 0;
    [_audioBtn setImage:KUIImage(@"audioBtn") forState:UIControlStateNormal];
//    if (!_audioBtn.selected) {
//        [_audioBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
//    }else{
//        [_audioBtn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    }
    [_audioBtn setImage:KUIImage(@"keyboard") forState:UIControlStateSelected];

    [_audioBtn addTarget:self action:@selector(showStartRecordBtn:) forControlEvents:UIControlEventTouchUpInside];
    return _audioBtn;
}

/*
 --创建长按录音button
 */
-(UIButton *)startRecordBtn
{
    _startRecordBtn = [[UIButton alloc]initWithFrame:CGRectMake(50, 7, 185, 35)];
    [_startRecordBtn setImage:KUIImage(@"chat_recordAudio_normal") forState:UIControlStateNormal];
    [_startRecordBtn setTitle:@"长按录音" forState:UIControlStateNormal];

    [_startRecordBtn addTarget:self action:@selector(startRecording:) forControlEvents:UIControlEventTouchDown];
    [_startRecordBtn addTarget:self action:@selector(stopRecording:) forControlEvents:UIControlEventTouchUpInside];
    _startRecordBtn.hidden = YES;
    return _startRecordBtn;
    
}

/*
 创建录音秃瓢
 
 */
#pragma mark-----通知  录音中 更改图片
-(void)showRecordAudioDB:(NSNotification*)info
{
    NSDictionary *dic = info.userInfo;
    double cus = [[dic objectForKey:@"low"] doubleValue];
    [showRecordView changeBDimgWithimg:cus];
}




#pragma mark----录音发送录音方法
-(void)showStartRecordBtn:(UIButton *)sender
{
    if (!sender.selected) {
        sender.selected = YES;
        [self.textView resignFirstResponder];
//        [_audioBtn setTitle:@"键盘" forState:UIControlStateSelected];
        _startRecordBtn.hidden = NO;
    }else{
        sender.selected = NO;
//        [_audioBtn setTitle:@"录音" forState:UIControlStateNormal];
        _startRecordBtn.hidden = YES;
        [self.textView becomeFirstResponder];
    }
}


-(void)startRecording:(UIButton *)sender
{
    [recordAudio stopPlay];
    [recordAudio startRecord];
    startRecordTime = [NSDate timeIntervalSinceReferenceDate];
    
    [curAudio release],
    curAudio=nil;
    showRecordView.hidden = NO;
//    [self showMsg:@"开始录音。。。"];
;
}

-(void)playAudio:(UIButton *)sender
{
    NSInteger i = sender.tag;
    NSDictionary *dic = [messages objectAtIndex:i-100];
    NSDictionary *dict = [[dic objectForKey:@"payload"]JSONValue];
    
    NSString *filePath =[NSString stringWithFormat:@"%@%@",QiniuBaseImageUrl,[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"messageid")]];
    
    
    if ([self isFileExist:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"messageid")]]) {
        
        NSString *filePath =[NSString stringWithFormat:@"%@/%@",RootDocPath,[[AudioManager singleton]changeStringWithString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dict, @"messageid")]]];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self PlayVoice:data];
    }
    else {
        NSURL *url  =[NSURL URLWithString:filePath];
        NSData *data = [NSData dataWithContentsOfURL:url];
        [self PlayVoice:data];

    }
    
    
    NSLog(@"%@",dict);
}

- (BOOL) isFileExist:(NSString *)fileName
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",RootDocPath,[[AudioManager singleton]changeStringWithString:fileName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:filePath];
    return result;
}
#pragma mark ---播放声音

- (void)PlayVoice:(NSData *)data {
    
    if(data.length>0)[recordAudio play:data];
}
-(void)saveAudioSuccessed:(id)sender
{
    saveAudioSuccess =YES;
}

-(void)stopRecording:(UIButton *)sender
{
    endRecordTime = [NSDate timeIntervalSinceReferenceDate];
    showRecordView . hidden = YES;
    NSURL *url = [recordAudio stopRecord];
    
    endRecordTime -= startRecordTime;
    if (endRecordTime<1.00f) {
        NSLog(@"录音时间过短");
//        [self showMsg:@"录音时间过短,应大于2秒"];
        [self showMessageWindowWithContent:@"录音时间过短,应大于2秒" imageType:0];
        return;
    } else if (endRecordTime>30.00f){
        [self showMessageWindowWithContent:@"录音时间过短,应小于30秒" imageType:0];
        return;
    }
//    NSDate *date = [NSDate date];
//    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
//    [dateformatter setDateFormat:@"YYYYMMdd"];
//    NSString * locationString=[dateformatter stringFromDate:date];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];

    
    if (url != nil) {
        
        curAudio = EncodeWAVEToAMR([NSData dataWithContentsOfURL:url],1,16,uuid);
        
        if (curAudio) {
            [curAudio retain];
        }
    }
    if (curAudio.length >0) {
        [self sendAudioMsgD:[NSString stringWithFormat:@"%@%@.amr",RootDocPath,uuid] UUID:uuid Body:@""];
        
        NSInteger imageIndex = [self getMsgRowWithId:uuid];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(imageIndex) inSection:0];
        PlayVoiceCell * cell = (PlayVoiceCell *)[self.tView cellForRowAtIndexPath:indexPath];
        NSString *str =[NSString stringWithFormat:@"%@/%@.amr",RootDocPath,uuid];
        
        [cell uploadAudio:str cellIndex:(imageIndex)];
        NSLog(@"-----------%@----%d",str,imageIndex);
    } else {
        
    }

}

#pragma mark ---声音代理
-(void)RecordStatus:(int)status {
    if (status==0){
        //播放中
    } else if(status==1){
        //完成
        NSLog(@"播放完成");
    }else if(status==2){
        //出错
        NSLog(@"播放出错");
    }
}
//-(void)playAudioWithCell:(PlayVoiceCell*)cell
//{
//    NSDictionary *dic = [messages objectAtIndex:cell.tag];
//    
//}


-(void)readNoreadMsg
{
    NSMutableArray *array = (NSMutableArray *)[DataStoreManager qAllThumbMessagesWithType:@"1"];
    _unreadNo  = [GameCommon getNoreadMsgCount:array];
}

//未读消息数红点
- (UILabel *)unReadL{
    if (!_unReadL) {
        
        _unReadL = [[UILabel alloc] init];
        _unReadL.frame = CGRectMake(35, KISHighVersion_7 ? 20 : 0, 20, 20);
        _unReadL.backgroundColor = [UIColor redColor];
        _unReadL.layer.cornerRadius = 10;
        _unReadL.layer.masksToBounds=YES;
        _unReadL.textColor = [UIColor whiteColor];
        _unReadL.textAlignment = NSTextAlignmentCenter;
        _unReadL.font = [UIFont systemFontOfSize:12];
        _unReadL.hidden = YES;
    }
    return _unReadL;
}

-(void)setNoreadMsgView
{
    if (_unreadNo>0) {
         _unReadL.hidden = NO;
        if (_unreadNo>99) {
            _unReadL.frame = CGRectMake(35, KISHighVersion_7 ? 20 : 0, 20, 20);
            _unReadL.text = [NSString stringWithFormat:@"%@",@"N+"];
        }else{
             _unReadL.text = [NSString stringWithFormat:@"%d",_unreadNo];
        }
    }else{
         _unReadL.hidden = YES;
    }
}


//群动态入口
- (UIButton *)groupCircleImage{
    if(!_groupCircleBtn){
        _groupCircleBtn = [[UIButton alloc] initWithFrame:CGRectMake(320-37-13,startX+5,40,40)];
        _groupCircleBtn.backgroundColor = [UIColor clearColor];
        [_groupCircleBtn setBackgroundImage:KUIImage(@"chat_group_circle_normal") forState:UIControlStateNormal];
        [_groupCircleBtn addTarget:self action:@selector(groupCricleButtonClick:)forControlEvents:UIControlEventTouchUpInside];
        
        _groupCircleText = [[UILabel alloc] initWithFrame:CGRectMake(5,5,30,16)];
        _groupCircleText .text = @"0";
        _groupCircleText.textAlignment = NSTextAlignmentCenter;
        _groupCircleText.backgroundColor = [UIColor clearColor];
        _groupCircleText.font = [UIFont systemFontOfSize:16];
        _groupCircleText.textColor = [UIColor whiteColor];
        [_groupCircleBtn addSubview:_groupCircleText];

        
        _circleImage = [[UIImageView alloc] initWithFrame:CGRectMake(13,4,16,16)];
        _circleImage.backgroundColor = [UIColor clearColor];
        _circleImage.image = KUIImage(@"group_cricle_image");
        [_groupCircleBtn addSubview:_circleImage];

        
        UILabel *groupCircleLable = [[UILabel alloc] initWithFrame:CGRectMake(5,18,30,16)];
        groupCircleLable .text = @"群动态";
        groupCircleLable.backgroundColor = [UIColor clearColor];
        groupCircleLable.font = [UIFont systemFontOfSize:10];
        groupCircleLable.textColor = [UIColor whiteColor];
        [_groupCircleBtn addSubview:groupCircleLable];
    }
    return _groupCircleBtn;
}

- (UIButton *)titleButton{
    if(!_titleButton){
        _titleButton = [[UIButton alloc] initWithFrame:CGRectMake(60,startX-40,200,40)];
        _titleButton.backgroundColor = [UIColor clearColor];
        if ([self.type isEqualToString:@"group"]&&self.unreadMsgCount>20) {
            [_titleButton addTarget:self action:@selector(loadMoreMsg:)forControlEvents:UIControlEventTouchUpInside];
        }
    }
    return _titleButton;
}
//导航条标题
- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,10,200,20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.text = self.nickName;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    }
    return _titleLabel;
}
//群的未读消息数
- (UILabel *)groupunReadMsgLable{
    if(!_groupunReadMsgLable){
        _groupunReadMsgLable = [[UILabel alloc] initWithFrame:CGRectMake(0,10,200,20)];
        _groupunReadMsgLable.backgroundColor = [UIColor clearColor];
        _groupunReadMsgLable.text = [NSString stringWithFormat:@"%@%d%@",@"(未读消息",self.unreadMsgCount,@"条)"];
        _groupunReadMsgLable.textAlignment = NSTextAlignmentCenter;
        _groupunReadMsgLable.textColor = [UIColor whiteColor];
        _groupunReadMsgLable.font = [UIFont systemFontOfSize:18];
    }
    return _groupunReadMsgLable;
}

//加号按钮
- (UIButton *)kkChatAddButton{
    if (!_kkChatAddButton) {
        _kkChatAddButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _kkChatAddButton.frame = CGRectMake(240,self.inPutView.frame.size.height-12-36,45,45);
        [_kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
        [_kkChatAddButton addTarget:self action:@selector(kkChatAddButtonClick:)forControlEvents:UIControlEventTouchUpInside];
    }
    return _kkChatAddButton;
}
//表情
- (UIButton *)emojiBtn{
    if (!_emojiBtn) {
        _emojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _emojiBtn.frame = CGRectMake(277, self.inPutView.frame.size.height-12-36,45,45);
        [_emojiBtn setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
        [_emojiBtn addTarget:self action:@selector(kkChatEmojiBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
    }
    return _emojiBtn;
}



- (UITableView *)tView{
    if(!tView) {
        tView = [[UITableView alloc] initWithFrame:CGRectMake(0,startX+offsetTopHight,320,self.view.frame.size.height-startX-offsetTopHight-55)style:UITableViewStylePlain];
        [tView setBackgroundColor:[UIColor clearColor]];
        tView.delegate = self;
        tView.dataSource = self;
        tView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return tView;
}

- (HPGrowingTextView *)textView{
    if(!_textView){
        _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(45, 7, 185, 35)];
        _textView.isScrollable = NO;
        _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
        _textView.minNumberOfLines = 1;
        _textView.maxNumberOfLines = 6;
        _textView.returnKeyType = UIReturnKeySend;
        _textView.font = [UIFont systemFontOfSize:15.0f];
        _textView.delegate = self;
        _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        _textView.backgroundColor = [UIColor clearColor];
        _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return _textView;
}
//初始化群动态的未读消息数
-(void)initGroupCricleMsgCount
{
    NSNumber *bullboardMsgCount = [[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,self.chatWithUser]];
    _groupCricleMsgCount =[bullboardMsgCount intValue];
    [self setGroupDynamicMsg:_groupCricleMsgCount];
}
#pragma mark 收到群动态消息
-(void)receivedGroupDynamicMsg:(NSNotification*)sender
{
    if ([self.chatWithUser isEqualToString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(sender.userInfo, @"groupId")]]) {
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(sender.userInfo, @"groupId")] isEqualToString:self.chatWithUser]) {
            [self initGroupCricleMsgCount];
        }
    }
}
//设置群动态的未读消息数
-(void)setGroupDynamicMsg:(NSInteger)msgCount
{
    if (msgCount>0) {
        _circleImage.hidden = YES;
        _groupCircleText.hidden=NO;
        if (msgCount > 99) {
            _groupCircleText.text = @"99+";
        }
        else{
            _groupCircleText.text =[NSString stringWithFormat:@"%d",msgCount] ;
        }
    }else
    {
        _circleImage.hidden = NO;
        _groupCircleText.hidden=YES;
    }
}
//群动态入口
- (void)groupCricleButtonClick:(UIButton *)sender{
    
    oTherPage = YES;
    [[NSUserDefaults standardUserDefaults]setObject:0 forKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,self.chatWithUser]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _groupCricleMsgCount=0;
    [self setGroupDynamicMsg:_groupCricleMsgCount];
    GroupCricleViewController *addVC = [[GroupCricleViewController alloc]init];
    addVC.groupId=self.chatWithUser;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (void)msgNoReadButtonClick:(UIButton *)sender{
    
}

//加载全部
- (void)loadMoreMsg:(UIButton *)sender{
    if (self.unreadMsgCount<20) {
        return;
    }
    NSArray *array = [self getMsgArray:20 PageSize:self.unreadMsgCount-20];
    [self hideUnReadLable];
    for (int i = 0; i < array.count; i++) {
        [messages insertObject:array[i] atIndex:i];
        [self overReadMsgToArray:array[i] Index:i];
    }
    [self addGroupHistoryMsg];
    [self.tView reloadData];
    [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)loadMessage:(NSInteger)FetchOffset PageSize:(NSInteger)pageSize
{
    NSArray *array = [self getMsgArray:FetchOffset PageSize:pageSize];
    for (int i = 0; i < array.count; i++) {
        [messages insertObject:array[i] atIndex:i];
        [self overReadMsgToArray:array[i] Index:i];
    }
}

//隐藏未读消息数量
-(void)hideUnReadLable
{
    if (_groupunReadMsgLable&&_groupunReadMsgLable.hidden==NO) {
        _groupunReadMsgLable.hidden=YES;
        _titleLabel.hidden = NO;
        _titleImageV.hidden = YES;
        self.unreadMsgCount=0;
    }
}
//将当前会话的所有消息改为已读，发送已读消息
- (void)sendReadedMesg
{
    for(NSMutableDictionary* plainEntry in messages)
    {
        NSString *msgType = KISDictionaryHaveKey(plainEntry, @"msgType");
        NSString *status = KISDictionaryHaveKey(plainEntry, @"status");
        NSString *sender = KISDictionaryHaveKey(plainEntry, @"sender");
        if ([msgType isEqualToString:@"normalchat"] && ![[NSString stringWithString:status] isEqualToString:@"4"] && ![sender isEqualToString:@"you"]) {
            NSString*readMagIdString = KISDictionaryHaveKey(plainEntry, @"messageuuid");
            [self comeBackDisplayed:self.chatWithUser msgId:readMagIdString];
        }
    }
}
//计算单条Cell的高度
-(CGFloat)getCellHight:(NSDictionary*)msgDic msgHight:(CGFloat)hight
{
    KKChatMsgType kkChatMsgType = [self msgType:msgDic];
    if (kkChatMsgType == KKChatMsgHistory) {
        return 25;
    }
    if (kkChatMsgType == KKChatMsgTypeSystem)
    {
        CGFloat theH = hight;
        theH += padding*2 ;
        CGFloat height = theH;
        if (self.isTeam) {
            if (height<40) {
                height+=40;
            }
        }
        return height;
//        return 47;
    }
    if (kkChatMsgType ==kkchatMsgAudio) {
        return 70;
    }
    NSString * senderId = KISDictionaryHaveKey(msgDic, @"sender");
    CGFloat theH = hight;
    if ([self.type isEqualToString:@"group"]) {
        if (![senderId isEqualToString:@"you"]) {
            theH+=offHight;
        }
    }
    theH += padding*2 + 10;
    CGFloat height = theH;
    if (self.isTeam) {
        if (height<70) {
            height+=13;
        }
    }
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
                [imgs setObject:uidimage forKey:uuid];
            }
        }
    }
    self.finalImage = imgs;
    self.finalMessageTime =times;
    self.finalMessageArray = formattedEntries;
    self.HeightArray = heightArray;
}

//单条消息放到集合里
-(CGFloat)newMsgToArray:(NSDictionary*)plainEntry
{
    NSArray * hh = [self cacuMsgSize:plainEntry];
    [self.HeightArray addObject:hh];
    [self addImageToArray:plainEntry];
    [self.finalMessageTime addObject:[self getMsgTime:plainEntry]];
     NSMutableAttributedString *mas=[self getNSMutableByMsgNSDictionary:plainEntry];
    [self.finalMessageArray addObject:mas];
    return  [[hh objectAtIndex:1] floatValue];
}
//单条消息放到集合指定位置
-(CGFloat)overReadMsgToArray:(NSDictionary*)plainEntry Index:(NSUInteger)index
{
    NSArray * hh = [self cacuMsgSize:plainEntry];
    [self.HeightArray insertObject:hh atIndex:index];
    [self addImageToArray:plainEntry];
    [self.finalMessageTime insertObject:[self getMsgTime:plainEntry] atIndex:index];
    NSMutableAttributedString *mas=[self getNSMutableByMsgNSDictionary:plainEntry];
    [self.finalMessageArray insertObject:mas atIndex:index];
    return  [[hh objectAtIndex:1] floatValue];
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
        case KKChatMsgTeamInvite:{//邀请加入组队
            mas=KISDictionaryHaveKey(plainEntry, @"payload");
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
           [self.finalImage setObject:uidimage forKey:uuid];
       }
    }
}

//格式化时间
-(NSString*)getMsgTime:(NSDictionary*)plainEntry
{
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)[[NSDate date] timeIntervalSince1970]];
    NSString* strTime = [NSString stringWithFormat:@"%d",[[KISDictionaryHaveKey(plainEntry, @"time") substringToIndex:10] intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
}


//缓存图片
-(UIImage*) getImage:(NSDictionary*) plainEntry
{
    //本地缩略图片缓存起来
    NSString *uuid = KISDictionaryHaveKey(plainEntry, @"messageuuid");
    if ([GameCommon isEmtity:uuid]) {
        return nil;
    }
    if(![self.finalImage objectForKey:uuid]) //如果没有这个uuid，才执行这个压缩过程
    {
        NSDictionary* payload = [KISDictionaryHaveKey(plainEntry, @"payload") JSONValue];
        NSString *kkChatImagethumb = KISDictionaryHaveKey(payload, @"thumb");
         NSString *kkChatImageMsg = KISDictionaryHaveKey(payload, @"msg");
        if (![GameCommon isEmtity:kkChatImagethumb]) {
            UIImage *image = [[UIImage alloc]initWithContentsOfFile:kkChatImagethumb];
            if(image){
                return image;
            }
            return nil;
        }else{
            if (![GameCommon isEmtity:kkChatImageMsg]) {
                EGOImageView *imageView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
                imageView.imageURL = [ImageService getImageUrl3:kkChatImageMsg Width:200];
                return imageView.image;
            }else{
                return nil;
            }
        }
    }
    return [self.finalImage objectForKey:uuid];
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
            array=[NSArray arrayWithObjects:[NSNumber numberWithFloat:100],[NSNumber numberWithFloat:100], nil];
            break;
        }
        case KKChatMsgTypeSystem:
        {
            CGSize msgLabletextSize = [message sizeWithFont:[UIFont boldSystemFontOfSize:10] constrainedToSize:CGSizeMake(maxWight, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
            array=[NSArray arrayWithObjects:[NSNumber numberWithFloat:msgLabletextSize.width],[NSNumber numberWithFloat:msgLabletextSize.height], nil];
//            array=[NSArray arrayWithObjects:[NSNumber numberWithFloat:320],[NSNumber numberWithFloat:47], nil];
            break;
        }
            case kkchatMsgAudio:
        {
            array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:100],[NSNumber numberWithFloat:40], nil];
        }
        case KKChatMsgSimple:
        {
            NSString *emojiStr = [UILabel getStr:message];
            CGSize size = [emojiStr sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(200, MAXFLOAT)];
            NSNumber * width = [NSNumber numberWithFloat:size.width];
            NSNumber * height = [NSNumber numberWithFloat:size.height];
            array= [NSArray arrayWithObjects:width,height, nil];
            break;
        }
        case KKChatMsgHistory:
        {
            array=[NSArray arrayWithObjects:[NSNumber numberWithFloat:320],[NSNumber numberWithFloat:25], nil];
            break;
        }
        case KKChatMsgTeamInvite:
        {
            NSDictionary* magDic = [KISDictionaryHaveKey(plainEntry, @"payload") JSONValue];
            CGSize titleSize = [self getPayloadMsgTitleSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(magDic, @"msg")]];
            CGSize contentSize = CGSizeZero;
            float higF = 0;
            contentSize = [self getPayloadMsgContentSize:[GameCommon getNewStringWithId:KISDictionaryHaveKey(magDic, @"description")] withThumb:YES];
            higF = contentSize.height;
            NSNumber * height = [NSNumber numberWithFloat:(contentSize.height > 40 ? (titleSize.height + contentSize.height + 5) : titleSize.height + 45)];
            array=[NSArray arrayWithObjects:[NSNumber numberWithFloat:195],height, nil];
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
    NSString * payLoadStr = KISDictionaryHaveKey(plainEntry, @"payload");
    //普通文字消息
    if([GameCommon isEmtity:payLoadStr])
    {
        return KKChatMsgTypeText;
    }
    NSDictionary * payloadDic = [payLoadStr JSONValue];
    NSString * types = KISDictionaryHaveKey(payloadDic,@"type");
    if ([[NSString stringWithFormat:@"%@",types] isEqualToString:@"3"])
    {
        return KKChatMsgTypeLink;
    }
    else if ([[NSString stringWithFormat:@"%@",types] isEqualToString:@"audio"]){
        return kkchatMsgAudio;
    }
    //图片
    else if ([[NSString stringWithFormat:@"%@",types] isEqualToString:@"img"])
    {
        return KKChatMsgTypeImage;
        
    }
    //系统消息
    else if ([[NSString stringWithFormat:@"%@",types] isEqualToString:@"inGroupSystemMsg"]//系统消息
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamAddType"]//加入组队
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamKickType"]//提出组队
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamQuitType"]//退出组队
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"inTeamSystemMsg"]//解散组队
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"startTeamPreparedConfirm"]//发起就位确认
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamPreparedConfirmResultSuccess"]//就位确认成功
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamPreparedConfirmResultFail"]//就位确认失败
             ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamClaimAddType"])//占坑消息
    {
        return KKChatMsgTypeSystem;
    }
    else if([[NSString stringWithFormat:@"%@",types] isEqualToString:@"selectTeamPosition"]
            ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamPreparedUserSelectOk"]//同意就位确认
            ||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamPreparedUserSelectCancel"]//拒绝就位确认
            ){
        return KKChatMsgSimple;
    }
    else if([[NSString stringWithFormat:@"%@",types] isEqualToString:@"historyMsg"])//以上是历史消息
    {
        return KKChatMsgHistory;
    }
    else if ([[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamInvite"]||[[NSString stringWithFormat:@"%@",types] isEqualToString:@"teamInviteInGroup"])//组队邀请
    {
        return KKChatMsgTeamInvite;
    }
    //文字
    else
    {
        return KKChatMsgTypeText;
    }
}


//格式化的文字（带表情的样式）
-(NSMutableAttributedString*) getNSMutable:(NSString*)str
{
    NSMutableAttributedString* mas = [[NSMutableAttributedString alloc]initWithString:str];
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
    

    
    if (![self isGroupAvaitable]) {
        [self showInVisableDialog];
        return;
    }else {
        if ([self isOut]) {
            [self showOutDialog];
            return;
        }
    }

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
                oTherPage = YES;
                imagePicker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePicker animated:YES completion:^{
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
                oTherPage = YES;
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
    
     NSData *thumbImageData = UIImageJPEGRepresentation(thumbimg, 1);
    NSData *upImageData = [self compressImage:upImage];
    
    NSString* openImgPath=[self writeImageToFile:thumbImageData];
    NSString* upImagePath=[self writeImageToFile:upImageData];
    if (openImgPath!=nil) {
        [self sendImageMsgD:openImgPath BigImagePath:upImagePath UUID:uuid Body:@"[图片]"]; //一条图片消息写到本地
        NSInteger imageIndex = [self getMsgRowWithId:uuid];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(imageIndex) inSection:0];
        KKImgCell * cell = (KKImgCell *)[self.tView cellForRowAtIndexPath:indexPath];
        [cell uploadImage:upImagePath cellIndex:(imageIndex)];
    }
    else
    {
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [hud hide:YES];
    }];
}

//将图片保存到本地，返回保存的路径
-(NSString*)writeImageToFile:(NSData*)thumbimgData
{
    NSString *path = [RootDocPath stringByAppendingPathComponent:@"tempImage"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:path] == NO)
    {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString  *openImgPath = [NSString stringWithFormat:@"%@/%@_me.jpg",path,uuid];
    if ([thumbimgData writeToFile:openImgPath atomically:YES]) {
        return openImgPath;
    }
    return nil;
}
//压缩图片
-(NSData*)compressImage:(UIImage*)thumbimg
{
    UIImage * a = [NetManager compressImage:thumbimg targetSizeX:640 targetSizeY:1136];
    NSData *imageData = UIImageJPEGRepresentation(a, 0.7);
    return imageData;
}
// 刷新消息状态
-(void)refreMessageStatus:(int)index Status:(NSString*)status
{
    if (index<0) {
        return;
    }
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(index) inSection:0];
    NSMutableDictionary *dict = [messages objectAtIndex:index];
    NSString *uuid = KISDictionaryHaveKey(dict, @"messageuuid");
    [dict setObject:status forKey:@"status"];
    if ([self.type isEqualToString:@"normal"]) {
        [DataStoreManager refreshMessageStatusWithId:uuid status:status];
    }else if([self.type isEqualToString:@"group"]){
        [DataStoreManager refreshGroupMessageStatusWithId:uuid status:status];
    }
    [messages replaceObjectAtIndex:index withObject:dict];
    KKChatCell * cell = (KKChatCell *)[self.tView cellForRowAtIndexPath:indexPath];
    [cell setViewState:status];
}
//刷新消息状态
-(void)refreMessageStatus2:(NSMutableDictionary*)msgDictionary Status:(NSString*)status
{
    NSString *uuid = KISDictionaryHaveKey(msgDictionary, @"messageuuid");
    NSInteger index = [self getMsgRowWithId:uuid];
    [self refreMessageStatus:index Status:status];
}



-(void)hideTopView{
    self.dropDownView.hidden = YES;
    self.dotVApp.hidden = YES;
    self.dotVInplace.hidden = YES;
    self.dotVPosition.hidden = YES;
}

-(void)showTopView{
    self.dropDownView.hidden = NO;
    self.dotVApp.hidden = NO;
    self.dotVInplace.hidden = NO;
    self.dotVPosition.hidden = NO;
}


-(void)kkChatEmojiBtnClicked:(UIButton *)sender
{
    if (!myActive) {
         [self showUnActionAlert];
        return ;
    }
    if (self.kkchatInputType != KKChatInputTypeEmoji) {
        ifEmoji = YES;
        self.kkchatInputType = KKChatInputTypeEmoji;
        ifAudio = NO;
        _audioBtn.selected = NO;
        _startRecordBtn.hidden = YES;
        [sender setImage:[UIImage imageNamed:@"keyboard.png"]forState:UIControlStateNormal];
        [self.kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
        self.textView.hidden = NO;
        [self showEmojiScrollView];
//        if (self.isTeam) {
//            [self hideTopView];
//        }
        
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
        [self showUnActionAlert];
        return ;
    }
    _audioBtn.selected = NO;
    _startRecordBtn.hidden = YES;

    if (self.kkchatInputType != KKChatInputTypeAdd) {   //点击切到发送
        self.kkchatInputType = KKChatInputTypeAdd;
        
        [sender setImage:[UIImage imageNamed:@"keyboard.png"]forState:UIControlStateNormal];
        [self.emojiBtn setImage:[UIImage imageNamed:@"emoji.png"]forState:UIControlStateNormal];
        [self showEmojiScrollView];
//        if (self.isTeam) {
//            [self hideTopView];
//        }
        
    }else{//点击切回键盘
        [self.textView.internalTextView becomeFirstResponder];
        ifEmoji = NO;
        self.kkchatInputType = KKChatInputTypeKeyboard;
        self.theEmojiView.hidden = YES;
        [m_EmojiScrollView removeFromSuperview];
        [emojiBGV removeFromSuperview];
        [m_Emojipc removeFromSuperview];
        [sender setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
    }
    return;
}
-(void)showUnActionAlert
{
    UIAlertView * UnActionAlertV = [[UIAlertView alloc] initWithTitle:@"您尚未激活" message:@"未激活用户不能发送聊天消息"delegate:self
                cancelButtonTitle:@"取消"otherButtonTitles:@"去激活", nil];
    [UnActionAlertV show];
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

-(void)toContactProfile:(NSString*)userId
{
    oTherPage = YES;
    TestViewController * detailV = [[TestViewController alloc] init];
    detailV.userId = userId;
    [self.navigationController pushViewController:detailV animated:YES];
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
//            if (self.isTeam) {
//                [self showTopView];
//            }
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

-(void) autoMovekeyBoard:(float) h{
    [self hideOrShowInputView:h];
}


-(void)hideOrShowInputView:(float) h{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    CGRect containerFrame = self.inPutView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (h + containerFrame.size.height);
	self.inPutView.frame = containerFrame;
    if (messages.count<4) {
        CGRect cgmm = self.tView.frame;
        cgmm.size.height=self.view.frame.size.height-startX-55-h-(self.isTeam?offsetTopHight:0);
        self.tView.frame=cgmm;
    }else{
        CGRect cgmm = self.tView.frame;
        if (cgmm.size.height<(self.view.frame.size.height-startX-55)) {
            cgmm.size.height=self.view.frame.size.height-startX-55;
        }
        if (self.inPutView.frame.size.height>50) {
            h+=(self.inPutView.frame.size.height-50);
        }
        cgmm.origin.y = startX-h+(self.isTeam?offsetTopHight:0);
        cgmm.size.height = self.isTeam?cgmm.size.height-offsetTopHight:cgmm.size.height;
        self.tView.frame=cgmm;
    }
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



#pragma mark HPExpandingTextView delegate
- (BOOL)growingTextViewShouldBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (myActive) {
        [menu setMenuItems:@[]];
        return YES;
    }
    [self showUnActionAlert];
    return NO;
}
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    [self.kkChatAddButton setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
    
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

    CGRect tvRect=self.tView.frame;
    tvRect.origin.y = tvRect.origin.y+diff;
    self.tView.frame=tvRect;
    
    if (messages.count>0) {
        [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
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

//#pragma mark -消息发送成功
//- (void)messageAck:(NSNotification *)notification
//{
//    NSDictionary* tempDic = notification.userInfo;
//    NSString * msgId = KISDictionaryHaveKey(tempDic, @"src_id");
//    NSInteger changeRow = [self getMsgRowWithId:msgId];
//    [self refreMessageStatus:changeRow Status:[GameCommon getNewStringWithId:KISDictionaryHaveKey(tempDic, @"msgState")]];
//}


#pragma mark -消息发送成功
- (void)messageAck:(NSNotification *)notification
{
    NSDictionary* stateDic = notification.userInfo;
    NSString * msgId = KISDictionaryHaveKey(stateDic, @"src_id");
    if (messages.count>0 && msgId && msgId.length > 0)
    {
        for (int i = 0; i < [messages count]; i++) {
            NSMutableDictionary* tempDic = [messages objectAtIndex:i];
            if ([KISDictionaryHaveKey(tempDic, @"messageuuid") isEqualToString:msgId]) {
                if (i<0) {
                    return;
                }
                [tempDic setObject:KISDictionaryHaveKey(stateDic, @"msgState") forKey:@"status"];
                if ([self.type isEqualToString:@"normal"]) {
                    [DataStoreManager refreshMessageStatusWithId:msgId status:KISDictionaryHaveKey(stateDic, @"msgState")];
                }else if([self.type isEqualToString:@"group"]){
                    [DataStoreManager refreshGroupMessageStatusWithId:msgId status:KISDictionaryHaveKey(stateDic, @"msgState")];
                }
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(i) inSection:0];
                KKChatCell * cell = (KKChatCell *)[self.tView cellForRowAtIndexPath:indexPath];
                if (![cell isKindOfClass:[KKSystemMsgCell class]]) {
                    [cell setViewState:KISDictionaryHaveKey(stateDic, @"msgState")];
                }
            }
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
#pragma mark UI/UE : 响应各种交互操作
- (void)keyboardWillShow:(NSNotification *)notification {

    
    ifEmoji = NO;
    self.kkchatInputType = KKChatInputTypeKeyboard;
    
    self.theEmojiView.hidden = YES;
    self.kkChatAddView.hidden = YES;
    
    [m_EmojiScrollView removeFromSuperview];
    [emojiBGV removeFromSuperview];
    [m_Emojipc removeFromSuperview];
    [self.emojiBtn setImage:[UIImage imageNamed:@"emoji.png"]forState:UIControlStateNormal];
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
    
//    if (self.isTeam) {
//        [self hideTopView];
//    }
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
//    if (self.isTeam) {
//        [self showTopView];
//    }
}
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
    KKChatCell * kkcc = Sender;
     NSString* userId = KISDictionaryHaveKey(kkcc.message, @"sender");
    [self toContactProfile:userId];
}

//点击我的头像
-(void)myHeadImgClicked:(id)Sender
{
    oTherPage = YES;
    TestViewController * detailV = [[TestViewController alloc] init];
    detailV.userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    detailV.nickName = [DataStoreManager queryRemarkNameForUser:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    detailV.isChatPage = YES;
    [self.navigationController pushViewController:detailV animated:YES];
}
//跳转激活页面
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10001) {
        if (buttonIndex == 0) {
            [[TeamManager singleton] clearTeamMessage:self.chatWithUser];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }else {
        if (buttonIndex == 1) {
            ActivateViewController * actVC = [[ActivateViewController alloc]init];
            [self.navigationController pushViewController:actVC animated:YES];
        }
    }
}
//响应按键
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 124) {
        if (buttonIndex == 1) { //点击取消
            return;
        }
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
    if (action == @selector(copyMsg) || action == @selector(transferMsg) || action == @selector(deleteMsg))
    {
        return YES;
    }
    else
        return NO;
}
//拷贝消息
-(void)copyMsg
{
    [popLittleView removeFromSuperview];
    if ([clearView superview]) {
        [clearView removeFromSuperview];
    }
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = tempStr;
}


//发送消息
- (void)sendButton:(id)sender {
    //本地输入框中的信息
    if (![self isGroupAvaitable]) {
        [self showInVisableDialog];//该群组或者组队已经解散
        return;
    }else {
        if ([self isOut]) {//已经不再该群组或者组队里面
            [self showOutDialog];
            return;
        }
    }
    NSString *message = self.textView.text;
    if (message.length==0||[[message stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]length]==0) {
        //如果发送信息为空或者为空格的时候弹框提示
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"不能发送空消息" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return ;
    }
    if (([self.available intValue]==2)&&([self.groupUsershipType intValue]==3)) {//已被踢出该群
        [self showOutDialog];
        return ;
    }
    if (message.length>255) {
        [self showAlertViewWithTitle:nil message:@"发送字数太多，请分条发送" buttonTitle:@"确定"];
        return;
    }
    self.textView.text = @"";
    [self sendMsg:message];
}

-(NSString*)getMsgBody:(NSString*)msgText
{
    if ([self.type isEqualToString:@"group"]) {
        NSDictionary * dic = @{@"userNickName":self.myNickName,@"content":msgText};
        return [dic JSONFragment];
    }
    return msgText;
}

#pragma mark将发送图片的消息保存数据库
- (void)sendImageMsgD:(NSString *)imageMsg BigImagePath:(NSString*)bigimagePath UUID:(NSString *)uuid Body:(NSString*)body{
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* payloadStr;
    if (self.isTeam) {
         payloadStr = [MessageService createPayLoadStr:@"" ThumbImage:imageMsg BigImagePath:bigimagePath TeamPosition:KISDictionaryHaveKey(selectType, @"value") gameid:self.gameId roomId:self.roomId team:@"teamchat"];
    }else{
       payloadStr=[MessageService createPayLoadStr:@"" ThumbImage:imageMsg BigImagePath:bigimagePath];
    }
     NSMutableDictionary *messageDict =  [self createMsgDictionarys:body NowTime:nowTime UUid:uuid MsgStatus:@"2" SenderId:@"you" ReceiveId:self.chatWithUser MsgType:[self getMsgType]];
    if (self.isTeam) {
        [messageDict setObject:KISDictionaryHaveKey(selectType, @"value")forKey:@"teamPosition"];
    }
    [messageDict setObject:payloadStr forKey:@"payload"];
    
    [self addNewMessageToTable:messageDict];
    [[MessageAckService singleton] addMessage:messageDict];
}



#pragma mark 发送图片消息
- (void)sendImageMsg:(NSString *)imageMsg  UUID:(NSString *)uuid{
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
    NSString * payloadStr;
    
    if (self.isTeam) {
        payloadStr = [MessageService createPayLoadStr:imageMsg ThumbImage:strThumb BigImagePath:srtBigImage TeamPosition:KISDictionaryHaveKey(selectType, @"value") gameid:self.gameId roomId:self.roomId team:@"teamchat"];
        
        
    }else{
       payloadStr=[MessageService createPayLoadStr:imageMsg ThumbImage:strThumb BigImagePath:srtBigImage];
    }
    [DataStoreManager changeMyMessage:uuid PayLoad:payloadStr];
    if (self.isTeam) {
        [messageDict setObject:KISDictionaryHaveKey(selectType, @"value") forKey:@"teamPosition"];
    }
    [messageDict setObject:payloadStr forKey:@"payload"]; //将图片地址替换为已经上传的网络地址
    [self reSendMsg:messageDict];
    [self refreWX];
}
#pragma mark 发送文本消息
-(void)sendMsg:(NSString *)message
{
    NSString * uuid = [[GameCommon shareGameCommon] uuid];
    NSString *from=[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]];
    NSString *to=[self.chatWithUser stringByAppendingString:[self getDomain:[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]]];

    NSMutableDictionary * messageDict = [self createMsgDictionarys:message NowTime:[GameCommon getCurrentTime] UUid:uuid MsgStatus:@"2" SenderId:@"you" ReceiveId:self.chatWithUser MsgType:[self getMsgType]];
    NSString * payloadStr= nil;
    if (self.isTeam) {
         payloadStr=[MessageService createPayLoadStr:KISDictionaryHaveKey(selectType, @"value") gameid:self.gameId roomId:self.roomId team:@"teamchat"];
        [messageDict setObject:KISDictionaryHaveKey(selectType, @"value") forKey:@"teamPosition"];
        [messageDict setObject:payloadStr forKey:@"payload"];
    }
    [self addNewMessageToTable:messageDict];
    [[MessageAckService singleton] addMessage:messageDict];
    [self sendMessage:message NowTime:[GameCommon getCurrentTime] UUid:uuid From:from To:to MsgType:[self getMsgType] FileType:@"text" Type:@"chat" Payload:payloadStr];
    [self refreWX];
}
#pragma mark 发送声音消息

- (void)sendAudioMsg:(NSString *)audioMsg  UUID:(NSString *)uuid{
    if (audioMsg.length==0)
    {
        return;
    }
    if ([[audioMsg stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"不能发送空消息" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    NSMutableDictionary* messageDict = [self getMsgWithId:uuid];
    NSDictionary* pay = [KISDictionaryHaveKey(messageDict, @"payload") JSONValue];
//    NSString* messageid = KISDictionaryHaveKey(pay, @"messageid");
//    NSString* srtBigImage= KISDictionaryHaveKey(pay, @"title");
    NSString * payloadStr;
    
    if (self.isTeam) {
        payloadStr = [MessageService createPayLoadAudioStr:audioMsg TeamPosition:KISDictionaryHaveKey(selectType, @"value") gameid:self.gameId roomId:self.roomId team:@"teamchat"];
        
    }else{
        payloadStr = [MessageService createPayLoadAudioStr:audioMsg];
    }
    [DataStoreManager changeMyMessage:uuid PayLoad:payloadStr];
    if (self.isTeam) {
        [messageDict setObject:KISDictionaryHaveKey(selectType, @"value") forKey:@"teamPosition"];
    }
    [messageDict setObject:payloadStr forKey:@"payload"]; //将图片地址替换为已经上传的网络地址
    [self reSendMsg:messageDict];
    [self refreWX];
    
    [[AudioManager singleton]RewriteTheAddressWithAddress:[NSString stringWithFormat:@"%@.amr",uuid] name2:audioMsg];
}



#pragma mark 发送声音消息
- (void)sendAudioMsgD:(NSString *)audioMsg UUID:(NSString *)uuid Body:(NSString*)body{
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* payloadStr;
    if (self.isTeam) {
        payloadStr = [MessageService createPayLoadAudioStr:audioMsg TeamPosition:KISDictionaryHaveKey(selectType, @"value") gameid:self.gameId roomId:self.roomId team:@"teamchat"];
    }else{
        payloadStr=[MessageService createPayLoadAudioStr:audioMsg];
    }
    NSMutableDictionary *messageDict =  [self createMsgDictionarys:body NowTime:nowTime UUid:uuid MsgStatus:@"2" SenderId:@"you" ReceiveId:self.chatWithUser MsgType:[self getMsgType]];
    if (self.isTeam) {
        [messageDict setObject:KISDictionaryHaveKey(selectType, @"value")forKey:@"teamPosition"];
    }
    [messageDict setObject:payloadStr forKey:@"payload"];
    
    [self addNewMessageToTable:messageDict];
    [[MessageAckService singleton] addMessage:messageDict];
}
-(NSString*)getDomain:(NSString*)domain
{
    if ([self.type isEqualToString:@"normal"]) {
        return domain;
    }else if([self.type isEqualToString:@"group"]){
        return [GameCommon getGroupDomain:domain];
    }
    return domain;
}

-(NSString*)getMsgType
{
    if ([self.type isEqualToString:@"normal"]) {
        return @"normalchat";
    }else if([self.type isEqualToString:@"group"]){
        return @"groupchat";
    }
    return @"normalchat";
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat distanceFromBottom = scrollView.contentSize.height - scrollView.contentOffset.y;
    if(distanceFromBottom - scrollView.frame.size.height<spaceEnd)
    {
        endOfTable = YES;
    }else{
        endOfTable = NO;
    }
}
#pragma mark 添加一条新的消息到列表
-(void)addNewMessageToTable:(NSMutableDictionary*)dictionary
{
    if (messages.count>=50) {
        [self clearMessage];
        [self loadMessage:0 PageSize:20];
        [self.tView reloadData];
    }
    if([self.type isEqualToString:@"group"]){
        [dictionary setObject:self.chatWithUser forKey:@"groupId"];
        if (![self isGroupAvaitable]) {//本群不可用
            [dictionary setObject:@"1" forKey:@"status"];
        }
        [self addNewOneMessageToTable:dictionary];
        [DataStoreManager storeMyGroupThumbMessage:dictionary];//群组聊天消息添加到数据库
        if (![self isGroupAvaitable]) {//本群不可用
            [self groupNotAvailable:self.isTeam?@"inTeamSystemMsg":@"inGroupSystemMsg" Message:self.isTeam?@"该组队已经解散":@"该群已经解散" GroupId:self.chatWithUser];
        }
    }
    if ([self.type isEqualToString:@"normal"]) {
        [self addNewOneMessageToTable:dictionary];
        [DataStoreManager storeMyMessage:dictionary];//正常聊天消息添加到数据库
    }
}
//群是否可用
-(BOOL)isGroupAvaitable
{
    if ([self.type isEqualToString:@"group"]&&([self.available intValue]==1)&&([self.groupUsershipType intValue]==3)) {
        return NO;
    }
    return YES;
}
//是否在群里面
-(BOOL)isOut{
    if ([self.type isEqualToString:@"group"]&&([self.available intValue]==2)&&([self.groupUsershipType intValue]==3)) {
        return YES;
    }
    return NO;
}

#pragma mark 添加本群不可用消息
-(void)groupNotAvailable:(NSString*)payloadType Message:(NSString*)message GroupId:(NSString*)groupId
{
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString * payloadStr=[MessageService createPayLoadStr:payloadType];
    NSMutableDictionary *dictionary =  [self createMsgDictionarys:message NowTime:nowTime UUid:uuid MsgStatus:@"1" SenderId:@"you" ReceiveId:groupId MsgType:@"groupchat"];
    [dictionary setObject:payloadStr forKey:@"payload"];
    [dictionary setObject:groupId forKey:@"groupId"];
    [self addNewOneMessageToTable:dictionary];
    [DataStoreManager storeMyGroupMessage:dictionary Successcompletion:^(BOOL success, NSError *error) {
    }];
}
#pragma mark 添加以上是历史消息
-(void)addGroupHistoryMsg
{
    historyMsg = 1;
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSString * payloadStr=[MessageService createPayLoadStr:@"historyMsg"];
    NSMutableDictionary *dictionary =  [self createMsgDictionarys:@"以上是历史消息" NowTime:nowTime UUid:uuid MsgStatus:@"1" SenderId:@"you" ReceiveId:self.chatWithUser MsgType:@"groupchat"];
    [dictionary setObject:payloadStr forKey:@"payload"];
    [dictionary setObject:self.chatWithUser forKey:@"groupId"];
    [messages insertObject:dictionary atIndex:0];
    [self overReadMsgToArray:dictionary Index:0];
}

#pragma mark 发送其他消息（位置变更，...）
-(void)sendOtherMsg:(NSString *)message TeamPosition:(NSString*)teamPosition
{
    NSString * uuid = [[GameCommon shareGameCommon] uuid];
    NSString *from=[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]];
    NSString *to=[self.chatWithUser stringByAppendingString:[self getDomain:[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]]];
    NSMutableDictionary * messageDict = [self createMsgDictionarys:message NowTime:[GameCommon getCurrentTime] UUid:uuid MsgStatus:@"1" SenderId:@"you" ReceiveId:self.chatWithUser MsgType:[self getMsgType]];
    
    NSString *  payloadStr=[MessageService createPayLoadStr:@"selectTeamPosition" TeamPosition:teamPosition gameid:self.gameId roomId:self.roomId team:@"teamchat"];
    
    [messageDict setObject:payloadStr forKey:@"payload"];
    [self addNewMessageToTable:messageDict];
    [self sendMessage:message NowTime:[GameCommon getCurrentTime] UUid:uuid From:from To:to MsgType:[self getMsgType] FileType:@"text" Type:@"chat" Payload:payloadStr];
}

-(void)addNewOneMessageToTable:(NSDictionary*)dictionary
{
    [messages addObject:dictionary];
    [self newMsgToArray:dictionary];
    [self.tView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(messages.count-1) inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
    
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
    NSString* sendtime = [GameCommon getCurrentTime];
    NSString* msgType = KISDictionaryHaveKey(messageDict, @"msgType");
    NSString* payloadStr = KISDictionaryHaveKey(messageDict, @"payload");
    NSString* domain = [[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN];
    NSString* fromUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString *from=[fromUserId stringByAppendingString:domain];
    NSString *to=[self.chatWithUser stringByAppendingString:[self getDomain:domain]];
    
    [messageDict setObject:@"2" forKey:@"status"];
    if (payloadStr!=nil&&![payloadStr isEqualToString:@""]) {
        [messageDict setObject:payloadStr forKey:@"payload"];
    }
    [[MessageAckService singleton] addMessage:messageDict];
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
        [self refreMessageStatus2:messageDict Status:@"2"];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:(cellIndex) inSection:0];
        KKImgCell * cell = (KKImgCell *)[self.tView cellForRowAtIndexPath:indexPath];
         [cell uploadImage:thumb cellIndex:cellIndex];
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
    if (![self isGroupAvaitable]) {
        return;
    }
    NSXMLElement *mes = [MessageService createMes:nowTime Message:[self getMsgBody:message] UUid:uuid From:from To:to FileType:fileTyp MsgType:msgType Type:type];
    if(payloadStr!=nil&&![payloadStr isEqualToString:@""]){
        NSXMLElement * payload = [NSXMLElement elementWithName:@"payload"];
        [payload setStringValue:payloadStr];
        [mes addChild:payload];
    }
    NSLog(@"发送出去的msg--->>>%@",mes);
    [self.appDel.xmppHelper sendMessage:mes];
}

#pragma mark 更新消息再数据库的状态
-(void)updateMsgByUuid:(NSMutableDictionary*)messageDict
{
    NSString *uuid = KISDictionaryHaveKey(messageDict, @"messageuuid");
    if ([self.type isEqualToString:@"normal"]) {
        [DataStoreManager refreshMessageStatusWithId:uuid status:@"2"];
    }else if([self.type isEqualToString:@"group"])
    {
        [DataStoreManager refreshGroupMessageStatusWithId:uuid status:@"2"];
    }
    
}
#pragma mark 刷新消息状态
-(void)refreStatusView:(NSString*)status cellIndex:(NSInteger)cellIndex
{
    NSIndexPath* indexpath = [NSIndexPath indexPathForRow:cellIndex inSection:0];
    CGSize size = CGSizeMake([[[self.HeightArray objectAtIndex:indexpath.row] objectAtIndex:0] floatValue],[[[self.HeightArray objectAtIndex:indexpath.row] objectAtIndex:1] floatValue]);
    KKChatCell * cell = (KKChatCell *)[self.tView cellForRowAtIndexPath:indexpath];
    [cell refreshStatusPoint:CGPointMake(320-size.width-padding-60 -15,(size.height+20)/2 + padding*2-15)status:status];
}
#pragma mark 判断是否需要执行第一次打招呼
-(void)refreWX
{
    if ([self.type isEqualToString:@"group"]) {
        return;
    }
    [wxSDArray removeAllObjects];
    [wxSDArray addObjectsFromArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]];
    if (![wxSDArray containsObject:self.chatWithUser]) {
        [self getSayHello];
    }
}

#pragma mark 创建消息对象
-(NSMutableDictionary*)createMsgDictionarys:(NSString *)message NowTime:(NSString *)nowTime UUid:(NSString *)uuid MsgStatus:(NSString *)status
                                   SenderId:(NSString*)senderId ReceiveId:(NSString*)receiveId MsgType:(NSString*)msgType
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:message forKey:@"msg"];
    [dictionary setObject:senderId forKey:@"sender"];
    [dictionary setObject:nowTime forKey:@"time"];
    [dictionary setObject:receiveId forKey:@"receiver"];
    [dictionary setObject:msgType forKey:@"msgType"];
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
    NSString* userId = KISDictionaryHaveKey(messages[readyIndex], @"sender");
    
    if([self .type isEqualToString:@"normal"]){
        [DataStoreManager deleteMsgInCommentWithUUid:uuid];
    }else if ([self.type isEqualToString:@"group"])
    {
        [DataStoreManager deleteGroupMsgInCommentWithUUid:uuid];
    }
    [self deleteFinalMsg]; //删除controll里缓存的message相关对象
    [self.finalImage removeObjectForKey:uuid];  //删除图片缓存

    if (messages.count>0) {
        [DataStoreManager refreshThumbMsgsAfterDeleteCommonMsg:[messages lastObject]ForUser:userId ifDel:NO];
    }
    else
    {
        [DataStoreManager refreshThumbMsgsAfterDeleteCommonMsg:[messages lastObject]ForUser:userId ifDel:YES];
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
    [paramDict setObject:self.chatWithUser forKey:@"touserid"];
    [postDict1 addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict1 setObject:@"153" forKey:@"method"];
    [postDict1 setObject:paramDict forKey:@"params"];
    [postDict1 setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict1
                success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              [wxSDArray addObject:self.chatWithUser];
                              [DataStoreManager storeThumbMsgUser:self.chatWithUser type:@"1"];
                              [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"sayHello_wx_info_id"];
                              [[NSUserDefaults standardUserDefaults] setObject:wxSDArray forKey:@"sayHello_wx_info_id"];
                              
                } failure:^(AFHTTPRequestOperation *operation, id error) {
                }];
}
#pragma mark - 下拉刷新

- (void)kkChatAddRefreshHeadView{
    
    __block NSArray *array;
    __block int loadHistoryArrayCount;
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
        [self hideUnReadLable];
        array = [self getMsgArray:messages.count-historyMsg PageSize:20];
        loadMoreMsgHeight = 0;
        for (int i = 0; i < array.count; i++) {
            [messages insertObject:array[i] atIndex:i];
            CGFloat  msgHight=[self overReadMsgToArray:array[i] Index:i];
            loadMoreMsgHeight+=[self getCellHight:array[i] msgHight:msgHight];
        }
        loadHistoryArrayCount = array.count;
        [header endRefreshing];
    };
    
    header.endStateChangeBlock = ^(MJRefreshBaseView *refreshView) {
        [self.tView reloadData];
        if (loadHistoryArrayCount==0) {
            return;
        }
        [self.tView scrollRectToVisible:CGRectMake(0,loadMoreMsgHeight,self.tView.frame.size.width,self.tView.frame.size.height) animated:NO];
    };
    
}
#pragma mark 群信息更新完成
-(void)groupInfoUploaded:(NSNotification *)notification
{
    if (![self.type isEqualToString:@"group"]) {
        return;
    }
    NSString * groupId = KISDictionaryHaveKey(notification.userInfo, @"groupId");
    if (![[GameCommon getNewStringWithId:groupId] isEqualToString:[GameCommon getNewStringWithId:self.chatWithUser]])
    {
        return;
    }
    [self refreTitleText];
    [self.tView reloadData];
}

#pragma mark 发送系统消息
-(void)sendSystemMessage:(NSNotification *)notification{
    
    NSDictionary * dictionary = notification.userInfo;
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dictionary, @"groupId")] isEqualToString:[GameCommon getNewStringWithId:self.chatWithUser]]) {
        [self addNewOneMessageToTable:dictionary];
    }
}
#pragma mark 组队人数添加
-(void)teamMemberCountChang:(NSNotification *)notification
{
    NSDictionary * dic = notification.userInfo;
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameId")] isEqualToString:[GameCommon getNewStringWithId:self.gameId]]
        &&[[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")] isEqualToString:[GameCommon getNewStringWithId:self.roomId]]) {
        [self refreTitleText];
    }
}

#pragma mark 用户信息更新完成
-(void)userInfoUploaded:(NSNotification *)notification
{
    if (![self.type isEqualToString:@"normal"]) {
        return;
    }
    NSDictionary *userDictionary = KISDictionaryHaveKey(notification.userInfo, @"user");
    NSString * userId = KISDictionaryHaveKey(userDictionary, @"userid");
    if (![userId isEqualToString:self.chatWithUser])
    {
        return;
    }
    [self refreTitleText];
    [self.tView reloadData];
}
#pragma mark 该群组解散通知
- (void)onDisbandGroup:(NSNotification*)notification
{
    NSString * groupId = KISDictionaryHaveKey(notification.userInfo, @"groupId");
    if (![[GameCommon getNewStringWithId:groupId] isEqualToString:[GameCommon getNewStringWithId:self.chatWithUser]])
    {
        return;
    }
    self.available = @"1";
    self.groupUsershipType = @"3";
}

#pragma mark 被剔出该群通知或者收到同意加入群的消息通知
- (void)onkickOffGroupGroup:(NSNotification*)notification
{
    if (![self.type isEqualToString:@"group"]) {
        return;
    }
    NSString * groupId = KISDictionaryHaveKey(notification.userInfo, @"groupId");
    NSString * state = KISDictionaryHaveKey(notification.userInfo, @"state");
    if (![[GameCommon getNewStringWithId:groupId] isEqualToString:[GameCommon getNewStringWithId:self.chatWithUser]])
    {
        return;
    }
    self.available = state;
    if ([state isEqualToString:@"2"]) {//被踢出了该群
        self.groupUsershipType = @"3";
        [messages removeAllObjects];
        [self.tView reloadData];
    }
}


#pragma mark 接收到新消息
- (void)newMesgReceived:(NSNotification*)notification
{
    NSDictionary* tempDic = notification.userInfo;
    NSString * msgType  = KISDictionaryHaveKey(tempDic, @"msgType");
    if([msgType isEqualToString:@"groupchat"]
       ||[msgType isEqualToString:@"disbandGroup"]
       ||[msgType isEqualToString:@"inGroupSystemMsgJoinGroup"]
       ||[msgType isEqualToString:@"inGroupSystemMsgQuitGroup"]
       ||[msgType isEqualToString:@"requestJoinTeam"]//申请加入组队
       ||[msgType isEqualToString:@"teamMemberChange"]//加入,退出,踢出
       ||[msgType isEqualToString:@"disbandTeam"]//解散组队
       ||[msgType isEqualToString:@"startTeamPreparedConfirm"]//发起就位确认
       ||[msgType isEqualToString:@"teamPreparedUserSelect"]//选择就位确认
        ||[msgType isEqualToString:@"teamPreparedConfirmResult"])//就位确认结果
        {
        NSString * groupID = KISDictionaryHaveKey(tempDic, @"groupId");
        [self setNewMsg:tempDic Sender:groupID];
        //改变组队位置
        if (self.isTeam) {
            if ([KISDictionaryHaveKey([KISDictionaryHaveKey(tempDic, @"payload") JSONValue], @"type") isEqualToString:@"selectTeamPosition"]) {//位置选择
                [self changGroupMsgLocation:self.chatWithUser UserId:KISDictionaryHaveKey(tempDic, @"sender") TeamPosition:KISDictionaryHaveKey(tempDic, @"teamPosition")];
                [self.tView reloadData];
            }else if ([msgType isEqualToString:@"requestJoinTeam"]) {//申请加入组队
                [self readNoreadMsg];
                [self setNoreadMsgView];
                [self setNotifyMsgCount];
            }else if ([msgType isEqualToString:@"startTeamPreparedConfirm"]) {//发起就位确认
                [self readNoreadMsg];
                [self setNoreadMsgView];
                [self setInplaceMsgCount];
            }
        }
    }else{
        NSString * sender = KISDictionaryHaveKey(tempDic, @"sender");
        NSString * msgId = KISDictionaryHaveKey(tempDic, @"msgId");
        [self setNewMsg:tempDic Sender:sender];
        [self comeBackDisplayed:sender msgId:msgId];//发送已读消息
    }
}
-(void)clearMessage
{
        [messages removeAllObjects];
        [self.HeightArray removeAllObjects];
        [self.finalImage removeAllObjects];
        [self.finalMessageTime removeAllObjects];
        [self.finalMessageArray removeAllObjects];
}
-(void)setNewMsg:(NSDictionary*)tempDic Sender:(NSString*)sender
{
    if ([sender isEqualToString:self.chatWithUser]) {
        NSString * msgId = KISDictionaryHaveKey(tempDic, @"msgId");
        [tempDic setValue:msgId forKey:@"messageuuid"];
        [tempDic setValue:@"4" forKey:@"status"];
            
        if (messages.count>=60&&endOfTable) {
            [self clearMessage];
            [self loadMessage:0 PageSize:20];
            [self.tView reloadData];
        }
            
        [messages addObject:tempDic];
        [self newMsgToArray:tempDic];
        [self.tView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:(messages.count-1) inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
        if (endOfTable) {
            if (messages.count>0) {
                [self.tView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messages.count-1 inSection:0]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            }
        }
    }
    else
    {
        _unreadNo++;
        [self setNoreadMsgView];
    }
}


//发送已读消息
- (void)comeBackDisplayed:(NSString*)sender msgId:(NSString*)msgId
{
    dispatch_queue_t queueload = dispatch_queue_create("com.living.game.comeBack", NULL);
    dispatch_async(queueload, ^{
        NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"src_id",@"true",@"received",@"Displayed",@"msgStatus", nil];
        NSString* message=[dic JSONRepresentation];
        NSString* nowTime = [GameCommon getCurrentTime];
        NSString* uuid = [[GameCommon shareGameCommon] uuid];
        NSString* fromUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
        NSString* domain = [[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN];
        NSString *from=[fromUserId stringByAppendingString:domain];
        NSString *to=[sender stringByAppendingString:domain];
        NSXMLElement *mes = [MessageService createMes:nowTime Message:message UUid:uuid From:from To:to FileType:@"text" MsgType:@"msgStatus" Type:@"normal"];
        if (![self.appDel.xmppHelper sendMessage:mes]) {
            return;
        }
        [DataStoreManager refreshMessageStatusWithId:msgId status:@"4"];
    });
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
    oTherPage=YES;
    NSArray *array = [NSArray arrayWithObjects:str, nil];
    PhotoViewController *photo = [[PhotoViewController alloc]initWithSmallImages:nil images:array indext:0];
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
    CGRect rect = [self.view convertRect:imgV.frame fromView:cell.contentView];
    [menu setMenuItems:[NSArray arrayWithObjects:delItem, nil]];
    [menu setTargetRect:CGRectMake(rect.origin.x, rect.origin.y, 60, 90) inView:self.view];
    [menu setMenuVisible:YES animated:YES];
}

//发送消息
-(void)sendMsg:(NSString *)imageId Index:(NSInteger)index
{
    [self sendImageMsg:imageId UUID:KISDictionaryHaveKey(messages[index], @"messageuuid")];//改图片地址，并发送消息
}
-(void)sendAudioMsg:(NSString *)audio Index:(NSInteger)index
{
    [self sendAudioMsg:audio UUID:KISDictionaryHaveKey(messages[index], @"messageuuid")];
}

 // 刷新状态
-(void)refreStatus:(NSInteger)cellIndex
{
    [self refreMessageStatus:cellIndex Status:@"0"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


//弹出提示框
-(void)showErrorAlertView:(id)error
{
    if ([error isKindOfClass:[NSDictionary class]]) {
        if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
        {
            UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
        }
    }
}

@end
