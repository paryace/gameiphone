//
//  MessageService.m
//  GameGroup
//
//  Created by Marss on 14-6-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MessageService.h"

@implementation MessageService
#pragma mark 生成XML消息文档
+(NSXMLElement*)createMes:(NSString *)nowTime Message:(NSString*)message UUid:(NSString *)uuid From:(NSString*)from To:(NSString*)to FileType:(NSString*)fileType MsgType:(NSString*)msgType Type:(NSString*)type
{
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:message];
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:type];
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:to];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:from];
    [mes addAttributeWithName:@"msgtype" stringValue:msgType];
    [mes addAttributeWithName:@"fileType" stringValue:fileType];//如果发送图片音频改这里
    [mes addAttributeWithName:@"msgTime" stringValue:nowTime];
    [mes addAttributeWithName:@"id" stringValue:uuid];
    [mes addChild:body];
    return mes;
}

#pragma mark 创建发送正常图片消息的payload
+(NSString*)createPayLoadStr:(NSString*)imageId ThumbImage:(NSString*)thumbImage BigImagePath:(NSString*)bigImagePath
{
    NSDictionary * dic = @{@"thumb":thumbImage,
                           @"title":bigImagePath,
                           @"msg":imageId,
                           @"type":@"img"};
    return [dic JSONFragment];
}


#pragma mark 创建发送组队图片消息的payload
+(NSString*)createPayLoadStr:(NSString*)imageId ThumbImage:(NSString*)thumbImage BigImagePath:(NSString*)bigImagePath TeamPosition:(NSString*)teamPosition gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team{
    NSDictionary * payloadDic = @{
                                  @"thumb":thumbImage,
                                  @"title":bigImagePath,
                                  @"msg":imageId,
                                  @"type":@"img",
                                  @"teamPosition":teamPosition,
                                  @"gameid":gameid,
                                  @"roomId":roomId,
                                  @"team":team};
    return  [payloadDic JSONFragment];
}

#pragma mark 创建发送组队文字消息的payload
+(NSString*)createPayLoadStr:(NSString*)teamPosition gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team{
    NSDictionary * dic = @{@"teamPosition":teamPosition,
                           @"gameid":gameid,
                           @"roomId": roomId,
                           @"team":team};
    return [dic JSONFragment];
}
#pragma mark 创建发送系统消息的payload
+(NSString*)createPayLoadStr:(NSString*)msgType{
    NSDictionary * dic = @{@"type":msgType};
    return [dic JSONFragment];
}

#pragma mark 创建发送位置变更消息的payload
+(NSString*)createPayLoadStr:(NSString*)type TeamPosition:(NSString*)teamPosition gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team
{
    NSDictionary * dic = @{@"type":type,
                           @"teamPosition":teamPosition,
                           @"gameid":gameid,
                           @"roomId": roomId,
                           @"team":team};
    return [dic JSONFragment];
}

#pragma mark 创建分享动态消息的payload
+(NSString*)createPayLoadStr:(NSString*)thumb title:(NSString*)title shiptype:(NSString*)shiptype messageid:(NSString*)messageid msg:(NSString*)msg type:(NSString*)type
{
    NSDictionary * dic = @{@"thumb":thumb,
                           @"title":title,
                           @"shiptype": shiptype,
                           @"messageid":messageid,
                           @"msg":msg,
                           @"type":type};
    return [dic JSONFragment];
}


#pragma mark 创建其他消息的payload
+(NSString*)createPayLoadStr:(NSString*)type gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team GroupId:(NSString*)groupId UserId:(NSString*)userid
{
    NSDictionary * dic = @{@"type":type,
                           @"gameid":gameid,
                           @"roomId": roomId,
                           @"team":team,
                           @"groupId":groupId,
                           @"userid":userid};
    return [dic JSONFragment];
}



#pragma mark OtherMessage
+(void)groupNotAvailable:(NSString*)payloadType Message:(NSString*)message GroupId:(NSString*)groupId gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team UserId:(NSString*)userid
{
    NSString* nowTime = [GameCommon getCurrentTime];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];    
    NSString * payloadStr = [MessageService createPayLoadStr:payloadType gameid:gameid roomId:roomId team:team GroupId:groupId UserId:userid];
    
    NSMutableDictionary *dictionary =  [self createMsgDictionarys:message NowTime:nowTime UUid:uuid MsgStatus:@"1" SenderId:@"you" ReceiveId:groupId MsgType:@"groupchat"];
    [dictionary setObject:payloadStr forKey:@"payload"];
    [dictionary setObject:groupId forKey:@"groupId"];
    [DataStoreManager storeMyGroupMessage:dictionary Successcompletion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kSendSystemMessage object:nil userInfo:dictionary];
    }];
}

#pragma mark 创建消息对象
+(NSMutableDictionary*)createMsgDictionarys:(NSString *)message NowTime:(NSString *)nowTime UUid:(NSString *)uuid MsgStatus:(NSString *)status SenderId:(NSString*)senderId ReceiveId:(NSString*)receiveId MsgType:(NSString*)msgType
{
    NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:message forKey:@"msg"];
    [dictionary setObject:senderId forKey:@"sender"];
    [dictionary setObject:nowTime forKey:@"time"];
    [dictionary setObject:receiveId forKey:@"receiver"];
    [dictionary setObject:msgType forKey:@"msgType"];
    [dictionary setObject:uuid forKey:@"messageuuid"];
    [dictionary setObject:status forKey:@"status"];
    return dictionary;
}
@end
