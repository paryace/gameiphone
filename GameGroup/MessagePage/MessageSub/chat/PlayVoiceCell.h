//
//  PlayVoiceCell.h
//  GameGroup
//
//  Created by 魏星 on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKChatCell.h"
#import "RecordAudio.h"

@protocol SendAudioMsgDeleGate;

@interface PlayVoiceCell : KKChatCell<QiniuUploadDelegate,RecordAudioDelegate,NSURLConnectionDataDelegate>
@property (nonatomic, strong) UILabel      *audioTimeSizeLb;
@property (nonatomic, strong) UIImageView  * voiceImageView;
@property (nonatomic, assign) id<SendAudioMsgDeleGate>mydelegate;
@property (nonatomic, assign) id<SendFileMessageDelegate>uploaddelegate;
@property (nonatomic, copy)   NSString     * sendType;
@property (nonatomic, strong) UIImageView  * audioRedImg;
@property (nonatomic, assign) int            cellCount;
@property (nonatomic, strong) NSDictionary * infoDict;
-(void)uploadAudio:(NSInteger)index;
-(void)downLoadAudioFromNet:(NSString *)net address:(NSString *)address;
-(void)startPaly;
-(void)stopPlay;
@end
@protocol SendAudioMsgDeleGate <NSObject>

-(void)sendAudioMsg:(NSString *)audio Index:(NSInteger)index;

@end