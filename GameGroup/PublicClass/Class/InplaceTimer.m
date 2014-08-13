//
//  InplaceTimer.m
//  GameGroup
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InplaceTimer.h"
#define secondsCount 45//秒


static InplaceTimer *inplaceTimer = NULL;

@implementation InplaceTimer{
    long long  timerCount;
    NSTimer * countDownTimer;
}

+ (InplaceTimer*)singleton
{
    @synchronized(self)
    {
		if (inplaceTimer == nil)
		{
			inplaceTimer = [[self alloc] init];
		}
	}
	return inplaceTimer;
}

-(void)reStartTimer:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId timeDeleGate:(id<TimeDelegate>) timedeleGate{
     NSLog(@"reStartTimer--->>");
    NSString * userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"inplace_time_%@_%@_%@",userId,gameId,roomId]];
    if (!time) {
        return;
    }
    NSInteger onClickState = [DataStoreManager getTeamUser:groupId UserId:userId];
    if (onClickState==0) {
        [self resetTimer:gameId RoomId:roomId];
        return;
    }
    NSLog(@"currentTIme-->--%@",time);
    long long offsetTime =secondsCount - ([self getCurrentTime] - [time longLongValue]);
    NSLog(@"offsetTime-->>%lld",offsetTime);
    if (offsetTime<0) {
        [self resetTimer:gameId RoomId:roomId];
        [[TeamManager singleton] resetTeamUserState:[GameCommon getNewStringWithId:groupId]];
        return;
    }
    self.delegate = timedeleGate;
    NSDictionary * dic = @{@"gameId":gameId,@"roomId":roomId,@"groupId":groupId};
    timerCount = offsetTime;
    NSLog(@"startTimeCount--->>>%lld",timerCount);
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod:) userInfo:dic repeats:YES];
}

-(void)startTimer:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId timeDeleGate:(id<TimeDelegate>) timedeleGate{
     self.delegate = timedeleGate;
    NSLog(@"startTimer--->>");
    NSDictionary * dic = @{@"gameId":gameId,@"roomId":roomId,@"groupId":groupId};
    timerCount = secondsCount;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeFireMethod:) userInfo:dic repeats:YES];
}

-(void)stopTimer:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId{
    NSLog(@"StopTimer--->>");
    NSString * userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"inplace_time_%@_%@_%@",userId,gameId,roomId]];
    if (!time) {
        NSString *lasttimeString=[NSString stringWithFormat:@"%lld",[self getCurrentTime]];
        NSLog(@"lastTime--%@",lasttimeString);
        [[NSUserDefaults standardUserDefaults] setValue:lasttimeString forKey:[NSString stringWithFormat:@"inplace_time_%@_%@_%@",userId,gameId,roomId]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    if (countDownTimer&&[countDownTimer isValid]) {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    if (self.delegate) {
        self.delegate = nil;
    }
}


-(void)resetTimer:(NSString*)gameId RoomId:(NSString*)roomId{
     NSLog(@"resetTimer--->>");
    if (countDownTimer&&[countDownTimer isValid]) {
        [countDownTimer invalidate];
        countDownTimer = nil;
    }
    if (self.delegate) {
        self.delegate = nil;
    }
    NSString * userId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"inplace_time_%@_%@_%@",userId,gameId,roomId]];
}

-(void)timeFireMethod:(NSTimer*)timer{
    timerCount--;
    if (self.delegate) {
        [self.delegate timingTime:timerCount];
    }
    if(timerCount==0){
        NSLog(@"finishTime--->>");
        NSDictionary * infoDic = timer.userInfo;
        [self resetTimer:[GameCommon getNewStringWithId:KISDictionaryHaveKey(infoDic, @"gameId")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(infoDic, @"roomId")]];
        [[TeamManager singleton] resetTeamUserState:[GameCommon getNewStringWithId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(infoDic, @"groupId")]]];
    }
}

-(long long)getCurrentTime{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime;
    return (long long)nowTime;
}

@end
