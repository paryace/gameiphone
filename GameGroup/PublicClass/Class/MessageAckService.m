//
//  MessageAckService.m
//  GameGroup
//
//  Created by apple on 14-7-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MessageAckService.h"

static MessageAckService *messageAck = NULL;

@implementation MessageAckService

+ (MessageAckService*)singleton
{
    @synchronized(self)
    {
		if (messageAck == nil)
		{
			messageAck = [[self alloc] init];
		}
	}
	return messageAck;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAck:)name:kMessageAck object:nil];
        self.cacheMessages = [NSMutableDictionary dictionary];
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(task) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}
-(void)task
{
    NSArray * keyArray = [self.cacheMessages allKeys];
    for (NSString * timeKey in keyArray) {
        NSDictionary * message = [self.cacheMessages objectForKey:timeKey];
        long long beforeTime =([timeKey longLongValue]);
        if ([self getCurrentTime] - beforeTime>20*1000) {
            NSString* uuid = KISDictionaryHaveKey(message, @"messageuuid");
            NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"src_id",@"true", @"received",@"0",@"msgState",nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:dic];
        }
    }
}


-(long long)getCurrentTime{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime*1000;
    return (long long)nowTime;
}

-(void)addMessage:(NSMutableDictionary*)message
{
    [self.cacheMessages setObject:message forKey:[NSString stringWithFormat:@"%lld",[self getCurrentTime]]];
}

//消息发送成功
- (void)messageAck:(NSNotification *)notification
{
    NSDictionary* tempDic = notification.userInfo;
    NSArray * keyArray = [self.cacheMessages allKeys];
    for (NSString * timeKey in keyArray) {
        NSDictionary * msg = [self.cacheMessages objectForKey:timeKey];
        NSString * id1= KISDictionaryHaveKey(tempDic, @"src_id");
        NSString * id2= KISDictionaryHaveKey(msg, @"messageuuid");
        if ([id1 isEqualToString:id2]) {
            [self.cacheMessages removeObjectForKey:timeKey];
        }
    }
}

@end
