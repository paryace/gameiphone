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
SendMsgDeleGate,DropDownChooseDelegate,DropDownChooseDataSource>
{
    NSString * userName;
    NSUserDefaults * uDefault;
    NSMutableDictionary * peopleDict;
    UILongPressGestureRecognizer *btnLongTap;
    UIButton * tempBtn; //被点击的按钮
    UIView * popLittleView;
    UIView * btnBG;
    int readyIndex;                 //设置当前待操作cell的INDEX
    NSIndexPath * indexPathTo;      //设置当前待操作cell的indexPathTo
    NSString * tempStr;
    UIView * clearView;
    BOOL canAdd;
    NSString * currentID;
    UIImageView * inputbg;
    UIButton * senBtn;
    int previousTime;
    int touchTimePre;
    int touchTimeFinal;
    NSMutableDictionary * userInfoDict;
    NSMutableDictionary * postDict;
    NSString * myHeadImg;
    NSDictionary * tempDict;
    
    BOOL ifAudio;
    BOOL ifEmoji;
    
    UIButton * audioBtn;
    UIButton * picBtn;
    
    UIButton * audioplayButton;
    
    UIScrollView *m_EmojiScrollView;
    UIPageControl *m_Emojipc;
    UIView * emojiBGV;
    
    NSMutableDictionary *recordSetting;
    AVAudioPlayer * audioPlayer;
    NSString * rootRecordPath;
    NSMutableArray * animationOne;
    NSMutableArray * animationTwo;
    UIMenuController * menu;
    NSString * available;//本群状态   0:正常，1:不可用（解散了） 2:已经被踢出
    NSString * groupUsershipType;//跟这个群得关系 0:群主 1:管理员 2:群成员 3:陌生人
}
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
@property (strong,nonatomic) MsgNotifityView * dotVApp;//申请
@property (strong,nonatomic) MsgNotifityView * dotVInplace;//就位
@property (strong,nonatomic) MsgNotifityView * dotVPosition;//位置

@property (assign, nonatomic)  NSInteger unreadNo;  //未读消息的现实数量
@property (strong, nonatomic)  NSString* myHeadImg; //我的头像
@property (strong, nonatomic)  NSString* myNickName; //我的昵称
@property(nonatomic, retain) NSString *chatUserImg; //聊天对象的头像
@property (strong, nonatomic)  UITableView *tView;  //消息cell组成的TableVIew
@property (strong, nonatomic)  NSMutableArray *finalMessageArray;//带样式的String 通过normalMsgToFinalMsg方式,将普通文本转化为带样式的文本
@property (strong, nonatomic)  NSMutableArray *finalMessageTime; //消息的时间
@property (strong, nonatomic)  NSMutableDictionary *finalImage; //消息的图片
@property (strong, nonatomic)  NSMutableArray *HeightArray;
@property (strong, nonatomic)  UITextField *messageTextField;
@property(nonatomic, retain) NSString *chatWithUser;
@property(nonatomic, retain) NSString *nickName;
@property(nonatomic, retain)   NSString *type;//聊天类型normal：跟某个用户聊天 group：群聊
@property (assign, nonatomic)  NSInteger unreadMsgCount;//未读的消息数
@property (assign, nonatomic)  BOOL isTeam;//是否是组队消息
@property(nonatomic, retain)   NSString *gameId;
@property(nonatomic, retain)   NSString *roomId;




@property (strong,nonatomic) AppDelegate * appDel;
@property (strong,nonatomic) HPGrowingTextView *textView;

- (void)sendButton:(id)sender;



@end
