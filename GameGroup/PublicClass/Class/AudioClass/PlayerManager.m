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
@synthesize avAudioPlayer;

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
        [[AVAudioSession sharedInstance] setActive:YES error:nil];//设置可以在静音模式下播放
    }
    return self;
}

- (void)playAudioWithFileName:(NSString *)filename delegate:(id<PlayingDelegate>)newDelegate {
    if ( ! filename) {
        return;
    }
    if ([filename rangeOfString:@".spx"].location != NSNotFound) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
        [self stopPlaying];
        self.delegate = newDelegate;
        self.decapsulator = [[Decapsulator alloc] initWithFileName:filename];
        self.decapsulator.delegate = self;
        [self.decapsulator play];
        [self startProximityMonitering];
    }else {
        [self.delegate playingStoped];
    }
}

- (void)stopPlaying {
    //关闭距离监听
    [self stopProximityMonitering];

    if (self.decapsulator) {
        [self.decapsulator stopPlaying];
        self.decapsulator = nil;
    }
    if (self.avAudioPlayer) {
        [self.avAudioPlayer stop];
        self.avAudioPlayer = nil;
    }
    
    [self.delegate playingStoped];
}

- (void)decapsulatingAndPlayingOver {
    [self.delegate playingStoped];
    [self stopProximityMonitering];
}

- (void)sensorStateChange:(NSNotification *)notification {
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
    }else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionDuckOthers error:nil];
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
