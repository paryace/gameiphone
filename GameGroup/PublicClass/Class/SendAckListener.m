//
//  SendAckListener.m
//  GameGroup
//
//  Created by 魏星 on 14-3-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SendAckListener.h"
#import "NSObject+SBJSON.h"
static SendAckListener *my_SendAckListener = NULL;

@implementation SendAckListener

+ (SendAckListener*)singleton
{
    @synchronized(self)
    {
		if (my_SendAckListener == nil)
		{
			my_SendAckListener = [[self alloc] init];
		}
	}
	return my_SendAckListener;
}
-(id)init
{  self = [super init];
    if (self) {
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeBackDelivered:) name:kNewMessageReceived object:nil];
    }
    return self;
}
//- (void)comeBackDelivered:(NSNotification*)notification//发送送达消息
//{
//    NSDictionary* messageContent = notification.userInfo;
//    NSRange range = [[messageContent objectForKey:@"sender"] rangeOfString:@"@"];
//    NSString * sender = [[messageContent objectForKey:@"sender"] substringToIndex:range.location];
//    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
//    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"src_id",@"true",@"received",@"Delivered",@"msgStatus", nil];
//    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
//    [body setStringValue:[dic JSONRepresentation]];
//    
//    //生成XML消息文档
//    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
//    [mes addAttributeWithName:@"id" stringValue:msgId];
//    [mes addAttributeWithName:@"msgtype" stringValue:@"msgStatus"];
//    //消息类型
//    [mes addAttributeWithName:@"type" stringValue:@"normal"];
//    
//    //发送给谁
//    [mes addAttributeWithName:@"to" stringValue:[sender stringByAppendingString:[[TempData sharedInstance] getDomain]]];
//    NSLog(@"[messageContent objectForKey:%@",[messageContent objectForKey:@"sender"]);
//    //由谁发送
//    [mes addAttributeWithName:@"from" stringValue:[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[TempData sharedInstance] getDomain]]];
//    
//    //    [mes addAttributeWithName:@"msgtype" stringValue:@"normalchat"];
//    [mes addAttributeWithName:@"msgTime" stringValue:[GameCommon getCurrentTime]];
//    //    NSString* uuid = [[GameCommon shareGameCommon] uuid];
//    //    [mes addAttributeWithName:@"id" stringValue:uuid];
//    //    NSLog(@"消息uuid ~!~~ %@", uuid);
//    //组合
//    [mes addChild:body];
//    if (![self.xmpphelper sendMessage:mes]) {
//        return;
//    }
//}

@end
