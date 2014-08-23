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

@interface PlayVoiceCell : KKChatCell<QiniuUploadDelegate,RecordAudioDelegate>
@property (nonatomic,strong)UIButton * button;
@property (nonatomic,strong)UIImageView  * voiceImageView;
@property (nonatomic,assign)id<SendAudioMsgDeleGate>mydelegate;
@property (nonatomic,copy)NSString * sendType;
@property (nonatomic,assign)int cellCount;

-(void)uploadAudio:(NSString*)audioPath cellIndex:(NSInteger)index;
-(void)setIMGAnimationWithArray:(NSMutableArray *)array; //设置动画img
-(void)startPaly;
-(void)stopPlay;
@end
@protocol SendAudioMsgDeleGate <NSObject>

-(void)sendAudioMsg:(NSString *)audio Index:(NSInteger)index;
-(void)refreStatus:(NSInteger)cellIndex;
-(void)playAudioWithCell:(PlayVoiceCell*)cell;
@end