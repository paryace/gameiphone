//
//  KKChatController.h
//  XmppDemo
//
//  Created by 夏 华 on 12-7-12.
//  Copyright (c) 2012年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "XMPPFramework.h"
#import "HPGrowingTextView.h"
#import "TempData.h"
#import "TestViewController.h"
#import "MyProfileViewController.h"
#import "selectContactPage.h"
#import "PBEmojiLabel.h"
#import "EmojiView.h"
#import "KKMessageCell.h"
#import "KKChatCell.h"
#import "KKImgCell.h"
#import "QiniuUploadDelegate.h"
#import "DropDownChooseDelegate.h"
#import "NewTeamMenuView.h"
#import "LocationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import <AudioToolbox/AudioToolbox.h>
#import "RecordAudio.h"
#import "PlayVoiceCell.h"
#import "KxMenu.h"
#import "NewTeamApplyListView.h"
#import "SendFileMessageDelegate.h"
#import "TeamInvitationController.h"
#import "CustomInputView.h"
#import "CTAssetsPickerController.h"
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
#import "ItemManager.h"
#import "ItemInfoViewController.h"
#import "KKTeamInviteCell.h"
#import "H5CharacterDetailsViewController.h"
#import "KKSimpleMsgCell.h"
#import "InplaceTimer.h"
#import "NewTeamMenuView.h"
#import "InvitationMembersViewController.h"
#import "MessagePageViewController.h"
#import "NewFriendPageController.h"
#import "NewItemMainViewController.h"
#import "NewFriendPageController.h"
#import "FindViewController.h"
#import "MePageViewController.h"
#import "AudioManager.h"
#import "ShowRecordView.h"
#import "amrFileCodec.h"
#import "RecorderManager.h"
#import "PlayerManager.h"

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
    kkchatMsgAudio,
    kkchatMsgJoinTeam,
    kkChatMsgJoinGroup
} KKChatMsgType;

@class AppDelegate, XMPPHelper;



@interface KKChatController : BaseViewController
<UITableViewDelegate,
UITableViewDataSource,
UITextFieldDelegate,
UIAlertViewDelegate,
UIActionSheetDelegate,
UIScrollViewDelegate,
AVAudioRecorderDelegate,
AVAudioSessionDelegate,
AVAudioPlayerDelegate,
HPGrowingTextViewDelegate,
KKChatCellDelegate,
EmojiViewDelegate,
QiniuUploadDelegate,
SendMsgDeleGate,
DropDownChooseDelegate,
DropDownChooseDataSource,
DetailDelegate,
LocationViewDelegate,

RecordAudioDelegate,
SendAudioMsgDeleGate,
ApplyDetailDelegate,
SendFileMessageDelegate,
UIGestureRecognizerDelegate,
CustomInputDelegate,
CTAssetsPickerControllerDelegate,
AudioDownLoaderDelegate,
UIAlertViewDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
RecordingDelegate,
PlayingDelegate>

@property (nonatomic, strong) UIView *recordView;
@property (nonatomic, strong) UIImageView *recordImgView;
@property (nonatomic, strong) UIButton * audioBtn;   //声音按钮
@property (nonatomic, strong) UIButton *startRecordBtn;//录音btn
@property (nonatomic, strong) UIButton *emojiBtn;   //表情按钮
@property (nonatomic, strong) UILabel *titleLabel;  //导航条标题
@property (nonatomic, strong) UIButton *groupCircleBtn;  //群动态
@property (nonatomic, strong) UIImageView *circleImage;  //群动态///
@property (nonatomic, strong) UILabel *groupCircleText;  //群动态数量
@property (nonatomic, strong) UILabel *groupunReadMsgLable;  //群消息未读条数
@property (nonatomic, strong) UIView * noReadView;  //
@property (nonatomic, strong) UILabel* noReadLable;  //
@property (nonatomic, strong) UIButton * titleImageV;
@property (nonatomic, strong) UIButton *titleButton;  //
@property (nonatomic, strong) UIImageView* topImageView;
@property (nonatomic, strong) MsgNotifityView * dotPosition;
@property (strong, nonatomic)  NSString* myHeadImg; //我的头像
@property (strong, nonatomic)  NSString* myNickName; //我的昵称
@property (nonatomic, retain) NSString *chatUserImg; //聊天对象的头像
@property (strong, nonatomic)  UITableView *tView;  //消息cell组成的TableVIew
@property (strong, nonatomic)  NSMutableArray *finalMessageArray;//带样式的String 通过normalMsgToFinalMsg方式,将普通文本转化为带样式的文本
@property (strong, nonatomic)  NSMutableArray *finalMessageTime; //消息的时间
@property (strong, nonatomic)  NSMutableDictionary *finalImage; //消息的图片
@property (strong, nonatomic)  NSMutableArray *HeightArray;
@property (strong, nonatomic)  UITextField *messageTextField;
@property (nonatomic, retain) NSString *chatWithUser;
@property (nonatomic, retain) NSString *nickName;
@property (nonatomic, retain)   NSString *type;//聊天类型normal：跟某个用户聊天 group：群聊
@property (assign, nonatomic)  NSInteger unreadMsgCount;//未读的消息数
@property (assign, nonatomic)  BOOL isTeam;//是否是组队消息
@property (nonatomic, retain)   NSString *gameId;
@property (nonatomic, retain)   NSString *roomId;
@property (nonatomic, copy)  NSString* available;//本群状态   0:正常，1:不可用（解散了） 2:已经被踢出
@property (nonatomic, copy)  NSString* groupUsershipType;//跟这个群得关系 0:群主 1:管理员 2:群成员 3:陌生人
@property (strong,nonatomic) AppDelegate * appDel;
@property (strong,nonatomic) HPGrowingTextView *textView;
@property (nonatomic, assign) KKChatInputType kkchatInputType;
@property (nonatomic, strong) UILabel *unReadL;
@property (nonatomic, strong) UIButton *kkChatAddButton;
@property (nonatomic, strong) UIView *inPutView;
@property (nonatomic, strong) UIView *kkChatAddView;
@property (nonatomic, strong) EmojiView *theEmojiView;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSArray *typeData_list;
@property (assign, nonatomic)  NSInteger groupCricleMsgCount;// 群动态的未读消息
@property (nonatomic,strong) NewTeamMenuView * newTeamMenuView;
@property (nonatomic,strong) NewTeamApplyListView * newTeamApplyListView;
@property (nonatomic,strong) UIButton * topItemView;
@property (nonatomic,strong) UIImageView * leftImage;
@property (nonatomic,strong) UIImageView * rightImage;
@property (nonatomic, copy) NSString * filename;// 声音路径
@property (nonatomic,assign)NSInteger clickCellNum;

- (void)sendButton:(id)sender;



@end
