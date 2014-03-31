//
//  VibrationSong.m
//  GameGroup
//
//  Created by 魏星 on 14-3-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "VibrationSong.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
@interface VibrationSong()
@property (nonatomic,retain)NSTimer * timer;
@property (nonatomic,assign)BOOL sound;
@end

@implementation VibrationSong
static VibrationSong *sharedInstance=nil;
+(void)vibrationSong
{
    @synchronized(self)
    {
        if(!sharedInstance)
        {
            sharedInstance=[[self alloc] init];
            sharedInstance.sound = YES;
        }
    }
    if (sharedInstance.sound) {
       // AudioServicesPlayAlertSound(1007);
        AudioServicesPlaySystemSound (0x00000FFF);
        sharedInstance.sound = NO;
    }
    if (sharedInstance.timer) {
        [sharedInstance.timer invalidate];
    }
    sharedInstance.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:sharedInstance selector:@selector(timerDown) userInfo:nil repeats:YES];
}
- (void)timerDown
{
    self.sound = YES;
    [sharedInstance.timer invalidate];
}

@end
