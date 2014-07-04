//
//  InPlaceConfirmation.m
//  GameGroup
//
//  Created by Marss on 14-7-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InPlaceConfirmation.h"

@implementation InPlaceConfirmation

//-(void)sadasd:(NSString*)groupId MsgContent:(NSString*)msgContent
//{
//    NSString * uuid = [[GameCommon shareGameCommon] uuid];
//    NSString *from=[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]];
//    NSString *to=[groupId stringByAppendingString:[self getDomain:[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]]];
//    
//    [self addNewMessageToTable:[self createMsgDictionarys:msgContent NowTime:[GameCommon getCurrentTime] UUid:uuid MsgStatus:@"2" SenderId:@"you" ReceiveId:groupId MsgType:@"groupchat"]];
//    [self sendMessage:msgContent NowTime:[GameCommon getCurrentTime] UUid:uuid From:from To:to MsgType:@"groupchat" FileType:@"text" Type:@"chat" Payload:nil];
//}
//-(NSString*)getDomain:(NSString*)domain
//{
//    return [GameCommon getGroupDomain:domain];
//}
//
//#pragma mark 创建消息对象
//-(NSMutableDictionary*)createMsgDictionarys:(NSString *)message NowTime:(NSString *)nowTime UUid:(NSString *)uuid MsgStatus:(NSString *)status SenderId:(NSString*)senderId ReceiveId:(NSString*)receiveId MsgType:(NSString*)msgType
//{
//    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
//    [dictionary setObject:message forKey:@"msg"];
//    [dictionary setObject:senderId forKey:@"sender"];
//    [dictionary setObject:nowTime forKey:@"time"];
//    [dictionary setObject:receiveId forKey:@"receiver"];
//    [dictionary setObject:msgType forKey:@"msgType"];
//    [dictionary setObject:uuid forKey:@"messageuuid"];
//    [dictionary setObject:status forKey:@"status"];
//    return dictionary;
//}
@end
