//
//  PlayVoiceCell.h
//  GameGroup
//
//  Created by 魏星 on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKChatCell.h"
@protocol SendAudioMsgDeleGate;

@interface PlayVoiceCell : KKChatCell<QiniuUploadDelegate>
@property (nonatomic,strong)UIButton * button;
@property (nonatomic,strong)UIImageView  * voiceImageView;
@property (nonatomic,assign)id<SendAudioMsgDeleGate>mydelegate;

-(void)uploadAudio:(NSString*)audioPath cellIndex:(NSInteger)index;
-(void)startPaly;
-(void)stopPlay;
@end
@protocol SendAudioMsgDeleGate <NSObject>

-(void)sendAudioMsg:(NSString *)audio Index:(NSInteger)index;
-(void)refreStatus:(NSInteger)cellIndex;
-(void)playAudioWithCell:(PlayVoiceCell*)cell;
@end