//
//  MessageSetting.m
//  GameGroup
//
//  Created by Marss on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MessageSetting.h"
#import "SoundSong.h"
#import "VibrationSong.h"

static MessageSetting *messageSetting = NULL;

@implementation MessageSetting

+ (MessageSetting*)singleton
{
    @synchronized(self)
    {
		if (messageSetting == nil)
		{
			messageSetting = [[self alloc] init];
		}
	}
	return messageSetting;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMyActive:) name:@"wxr_myActiveBeChanged" object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSoundOff:) name:@"wx_sounds_open" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSoundOpen:) name:@"wx_sounds_off" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeVibrationOff:) name:@"wx_vibration_off" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeVibrationOn:) name:@"wx_vibration_open" object:nil];
    }
    return self;
}

-(void)changeSoundOpen:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"wx_sound_tixing_count"];
}
-(void)changeSoundOff:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"wx_sound_tixing_count"];
}
-(void)changeVibrationOff:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"wx_Vibration_tixing_count"];
}
-(void)changeVibrationOn:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"wx_Vibration_tixing_count"];
}

//声音
-(BOOL)isSoundOpen
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"]intValue]==1) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}
//震动
-(BOOL)isVibrationopen
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"]intValue]==1) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}
//设置声音或者震动
-(void)setSoundOrVibrationopen
{
    BOOL isVibrationopen=[self isVibrationopen];;
    BOOL isSoundOpen = [self isSoundOpen];
    if (isSoundOpen) {
        [SoundSong soundSong];
    }
    if (isVibrationopen) {
        [VibrationSong vibrationSong];
    }
}

- (void)changeMyActive:(NSNotification*)notification
{
    if ([notification.userInfo[@"active"] intValue] == 2) {
        [DataStoreManager reSetMyAction:YES];
    }else
    {
        [DataStoreManager reSetMyAction:NO];
    }
}
@end
