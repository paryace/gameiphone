//
//  WQPlaySound.m
//  GameGroup
//
//  Created by Apple on 14-8-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "WQPlaySound.h"
#import <AVFoundation/AVFoundation.h>

@implementation WQPlaySound
-(id)initForPlayingVibrate
{
    self = [super init];
    if (self) {
        soundID = kSystemSoundID_Vibrate;
    }
    return self;
}

-(id)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"inplace_sound" ofType:@"mp3"];
        if (path) {
            //注册声音到系统
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&soundID);
            AudioServicesPlaySystemSound(soundID);
        }
        AudioServicesPlaySystemSound(soundID);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）

        
        
        
        
//        NSString *path = [[NSBundle mainBundle] pathForResource:resourceName ofType:type];
//        if (path) {
//            SystemSoundID theSoundID;
//            OSStatus error =  AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
//            if (error == kAudioServicesNoError) {
//                soundID = theSoundID;
//            }else {
//                NSLog(@"Failed to create sound ");
//            }
//        }
        
    }
    return self;
}

-(id)initForPlayingSoundEffectWith:(NSString *)filename
{
    self = [super init];
    if (self) {
        NSURL *fileURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
        if (fileURL != nil)
        {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError){
                soundID = theSoundID;
            }else {
                NSLog(@"Failed to create sound ");
            }
        }
    }
    return self;
}


-(void)initSound{
    
    
//        NSString *path = [[NSBundle mainBundle] pathForResource:@"inplace_sound" ofType:@"mp3"];
//        if (path) {
//            //注册声音到系统
//            AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
//            AudioServicesPlaySystemSound(shake_sound_male_id);
//        }
//        AudioServicesPlaySystemSound(shake_sound_male_id);   //播放注册的声音，（此句代码，可以在本类中的任意位置调用，不限于本方法中）
}

-(void)play
{
    AudioServicesPlaySystemSound(soundID);
}

-(void)dealloc
{
    AudioServicesDisposeSystemSoundID(soundID);
}
@end
