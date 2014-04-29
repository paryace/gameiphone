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
#import "OHASBasicHTMLParser.h"
#import "EmojiView.h"
#import "KKMessageCell.h"
#import "KKChatCell.h"
#import "KKImgCell.h"

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
EmojiViewDelegate>
{
    //    UILabel    *titleLabel;
    NSString * userName;
    // NSMutableDictionary * userDefaults;
    NSUserDefaults * uDefault;
    NSMutableDictionary * peopleDict;
    //    UIView * inPutView;
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
    //UIButton * emojiBtn;
    UIButton * picBtn;
    //UIButton * audioRecordBtn;
    
    //NSTimeInterval beginTime;
    UIButton * audioplayButton;
    //UIImageView *recordAnimationIV;
    
    UIScrollView *m_EmojiScrollView;
    UIPageControl *m_Emojipc;
    UIView * emojiBGV;
    
    //    EmojiView * theEmojiView;
    
    NSMutableDictionary *recordSetting;
    AVAudioPlayer * audioPlayer;
    NSString * rootRecordPath;
    NSMutableArray * animationOne;
    NSMutableArray * animationTwo;
    
    UIMenuController * menu;
}
@property (nonatomic, strong) UIButton *emojiBtn;   //表情按钮
@property (nonatomic, strong) UILabel *titleLabel;  //导航条标题
@property (assign, nonatomic)  NSInteger unreadNo;  //未读消息的现实数量
@property (strong, nonatomic)  NSString* myHeadImg; //我的头像
@property (strong, nonatomic)  UITableView *tView;  //消息cell组成的TableVIew
@property (strong, nonatomic)  NSMutableArray *finalMessageArray;       //带样式的String 通过normalMsgToFinalMsg方式， 将普通文本转化为带样式的文本
@property (strong, nonatomic)  NSMutableArray *HeightArray;
@property (strong, nonatomic)  UITextField *messageTextField;
//@property (strong, nonatomic)  UIButton * sendBtn;
@property(nonatomic, retain) NSString *chatWithUser;
@property(nonatomic, assign) BOOL ifFriend;
@property(nonatomic, retain) NSString *nickName;
@property(nonatomic, retain) NSString *friendStatus;
@property(nonatomic, retain) NSString *chatUserImg; //聊天对象的头像
@property (strong,nonatomic) AppDelegate * appDel;
@property (strong,nonatomic) HPGrowingTextView *textView;
@property (nonatomic,retain) AVAudioSession *session;
@property (nonatomic,retain) AVAudioRecorder *recorder;
- (void)sendButton:(id)sender;



@end
