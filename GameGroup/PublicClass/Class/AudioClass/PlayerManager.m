//
//  PlayerManager.m
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "PlayerManager.h"

@interface PlayerManager ()

- (void)startProximityMonitering;  //开启距离感应器监听(开始播放时)
- (void)stopProximityMonitering;   //关闭距离感应器监听(播放完成时)

@end

@implementation PlayerManager

@synthesize decapsulator;

static PlayerManager *mPlayerManager = nil;

+ (PlayerManager *)sharedManager {
    @synchronized(self) {
        if (mPlayerManager == nil)
        {
            mPlayerManager = [[PlayerManager alloc] init];
        }
    }
    return mPlayerManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(mPlayerManager == nil)
        {
            mPlayerManager = [super allocWithZone:zone];
            return mPlayerManager;
        }
    }
    
    return nil;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:)name:@"UIDeviceProximityStateDidChangeNotification"object:nil];
        [self stopProximityMonitering];
    }
    return self;
}
//开始播放语音
- (void)playAudioWithFileName:(NSString *)filename delegate:(id<PlayingDelegate>)newDelegate {
    if ( ! filename) {
        return;
    }
    if ([filename rangeOfString:@".spx"].location != NSNotFound) {
        if (self.decapsulator) {
            [self.decapsulator stopPlaying];
            self.decapsulator = nil;
        }
        self.delegate = nil;
        self.delegate = newDelegate;
        self.decapsulator = [[Decapsulator alloc] initWithFileName:filename];
        self.decapsulator.delegate = self;
        [self audioPlayeeDidBeginPlay];
        [self.decapsulator play];
        NSLog(@"-----startPlay----");
        [self startProximityMonitering];
    }else {
        [self.delegate playingStoped];
    }
}

//停止播放
- (void)stopPlaying {
    if (self.decapsulator) {
        [self.decapsulator stopPlaying];
        self.decapsulator = nil;
    }
    //关闭距离监听
    [self stopProximityMonitering];
    [self.delegate playingStoped];
    [self audioPlayerDidFinishPlaying];
    NSLog(@"-----stopPlay-----");
}
//音乐播放完成
- (void)decapsulatingAndPlayingOver {
    NSLog(@"-----playFinish-----");
    [self stopPlaying];
}
-(void)audioPlayeeDidBeginPlay{
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSLog(@"----audioPlayeeDidBeginPlay----");
}
//初始化
- (void)audioPlayerDidFinishPlaying{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    audioSession = nil;
    NSLog(@"----audioPlayerDidFinishPlaying----");
}
//播放模式改变
- (void)sensorStateChange:(NSNotification *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
         NSLog(@"----听筒模式----");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];//听筒模式
    }else {
        NSLog(@"----扬声器模式----");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];//扬声器模式
    }
}

- (void)startProximityMonitering {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
    NSLog(@"开启距离监听");
}

- (void)stopProximityMonitering {
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    NSLog(@"关闭距离监听");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
