//
//  XMPPHelper.m
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "XMPPHelper.h"
#import "XMPP.h"
#import "ReceiveMessageDelegate.h"
#import "XMPPAutoPing.h"
#import "XMPPJID.h"
#import "TempData.h"
#import "XMPPReconnect.h"
#import "JSON.h"
#import "GameXmppStream.h"
#import "GameXmppReconnect.h"

@implementation XMPPHelper
-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

-(void)setupStream
{
    self.xmppStream = [[GameXmppStream alloc] init];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_queue_create("com.dispatch.xmpphelper", DISPATCH_QUEUE_SERIAL)];
    self.xmppStream.enableBackgroundingOnSocket = YES;
    self.xmppReconnect = [[GameXmppReconnect alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppReconnect setAutoReconnect:YES];
    [self.xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppReconnect activate:self.xmppStream];
    XMPPAutoPing* ping=[[XMPPAutoPing alloc] init];
    [ping activate:self.xmppStream];
    ping.pingTimeout=2;
    [ping addDelegate:self delegateQueue:  dispatch_get_main_queue()];
    self.xmppPing=[[XMPPPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppPing activate:self.xmppStream];
    [self.xmppPing addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
}
- (void)goOnline {
	XMPPPresence *presence = [XMPPPresence presence];
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline {
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[[self xmppStream] sendElement:presence];
}
-(BOOL)connect{
    if (![self.xmppStream isDisconnected]) {
        return YES;
        NSLog(@"连接不成功");
    }
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]]]] ;
    NSString* host=[[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    
    NSArray* hostArray = [host componentsSeparatedByString:@":"];
    host = [hostArray objectAtIndex:0];
    
    [self.xmppStream setHostName:host];
    [self.xmppReconnect manualStart];
    
    return YES;
}

-(void)disconnect{
    [self goOffline];
    [self.xmppStream disconnect];
}
-(BOOL)isDisconnected
{
    return [self.xmppStream isDisconnected];
}
-(BOOL)isConnecting
{
    return [self.xmppStream isConnecting];
}
-(BOOL)isConnected
{
    return [self.xmppStream isConnected];
}

#pragma mark 进入程序网络变化
- (void)appBecomeActiveWithNet:(NSNotification*)notification
{
    Reachability* reach = notification.object;
    if ([reach currentReachabilityStatus] == NotReachable ) {//有网
        if ([self isConnected]) {
            [self disconnect];
        }
    }
    if ([reach currentReachabilityStatus] != NotReachable  && [[TempData sharedInstance] isHaveLogin]) {//有网
        if (![self isConnected]) {
            [self connect];
        }
    }
}

//===========XMPP委托事件============

//此方法在stream开始连接服务器的时候调用
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSError *error = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectSuccess" object:nil userInfo:nil];
    });
    //验证密码
    [[self xmppStream] authenticateWithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] error:&error];
    if(error!=nil)
    {
    }
}

//此方法在stream连接断开的时候调用
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_disconnect" object:nil userInfo:nil];
    });
}

// 2.关于验证的
//验证失败后调用
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
    /*NSLog(@"not authenticated %@",error);
    NSError *err=[[NSError alloc] initWithDomain:@"WeShare" code:-100 userInfo:@{@"detail": @"ot-authorized"}];
    self.fail(err);
   [self.notConnect notConnectted];*/
}


//验证成功后调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    /*self.xmppvCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
    self.xmppvCardTempModule=[[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppvCardStorage];
    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppvCardTempModule];
    [self.xmppvCardTempModule   activate:self.xmppStream];
    [self.xmppvCardAvatarModule activate:self.xmppStream];
    [self getmyvcard];*/
    dispatch_async(dispatch_get_main_queue(), ^{
         [[NSNotificationCenter defaultCenter] postNotificationName:@"connectSuccess" object:nil userInfo:nil];
    });
   
    [self goOnline];
    
}

-(BOOL)sendMessage:(NSXMLElement *)message
{
    if (![self isConnected]) {
        return NO;
    }
    else
    {
        [self.xmppStream sendElement:message];
        
        return YES;
    }
}


- (void)xmppStreamWillConnect:(XMPPStream *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startConnect" object:nil];
}
#pragma mark 收到消息后调用
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    [self.receiveMessageDelegate onMessage:message];
}
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
}
//接受到好友状态更新
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    DDXMLNode *errorNode = (DDXMLNode *)error;
    //遍历错误节点
    for(DDXMLNode *node in [errorNode children])
    {
        //若错误节点有【冲突】
        if([[node name] isEqualToString:@"conflict"])
        {
            //停止轮训检查链接状态
            //[_timer invalidate];
            //弹出登陆冲突,点击OK后logout
            NSString *message = [NSString stringWithFormat:@"在其他地方登陆"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 9999;
            [alert show];
        }
    }
}

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender{
    [self disconnect];
}

- (void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout{
    [self disconnect];
}
- (void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt{
}

@end
