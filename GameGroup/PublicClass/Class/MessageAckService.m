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
        NSLog(@"InitMessageAck--Service");
         [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageAck:)name:kMessageAck object:nil];
        self.cacheMessages = [NSMutableArray array];
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(task) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
    return self;
}

-(void)task
{
    for (NSDictionary * message in self.cacheMessages) {
        long long beforeTime =([KISDictionaryHaveKey(message, @"sendBeforeTime") longLongValue]);
        
        if ([self getCurrentTime] - beforeTime>20*1000) {
            NSLog(@"%lld",[self getCurrentTime] - beforeTime);
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
    [message setObject:[NSString stringWithFormat:@"%lld",[self getCurrentTime]] forKey:@"sendBeforeTime"];
    [self.cacheMessages addObject:message];
}

//消息发送成功
- (void)messageAck:(NSNotification *)notification
{
    NSDictionary* tempDic = notification.userInfo;
    for(NSMutableDictionary* msg in self.cacheMessages){
        NSString * id1= KISDictionaryHaveKey(tempDic, @"src_id");
        NSString * id2= KISDictionaryHaveKey(msg, @"messageuuid");
        if ([id1 isEqualToString:id2]) {
            [self.cacheMessages removeObject:msg];
        }
    }
}

@end
