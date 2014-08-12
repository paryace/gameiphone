//
//  MessageService.h
//  GameGroup
//
//  Created by Marss on 14-6-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSON.h"

@interface MessageService : NSObject
+(NSXMLElement*)createMes:(NSString *)nowTime Message:(NSString*)message UUid:(NSString *)uuid From:(NSString*)from To:(NSString*)to FileType:(NSString*)fileType MsgType:(NSString*)msgType Type:(NSString*)type;

#pragma mark 创建发送正常图片消息的payload
+(NSString*)createPayLoadStr:(NSString*)imageId ThumbImage:(NSString*)thumbImage BigImagePath:(NSString*)bigImagePath;

#pragma mark 创建发送组队图片消息的payload
+(NSString*)createPayLoadStr:(NSString*)imageId ThumbImage:(NSString*)thumbImage BigImagePath:(NSString*)bigImagePath TeamPosition:(NSString*)teamPosition gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team;

#pragma mark 创建发送组队文字消息的payload
+(NSString*)createPayLoadStr:(NSString*)teamPosition gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team;

#pragma mark 创建发送系统消息的payload
+(NSString*)createPayLoadStr:(NSString*)msgType;

#pragma mark 创建发送位置变更消息的payload
+(NSString*)createPayLoadStr:(NSString*)type TeamPosition:(NSString*)teamPosition gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team;

#pragma mark 创建分享动态消息的payload
+(NSString*)createPayLoadStr:(NSString*)thumb title:(NSString*)title shiptype:(NSString*)shiptype messageid:(NSString*)messageid msg:(NSString*)msg type:(NSString*)type;

+(void)groupNotAvailable:(NSString*)payloadType Message:(NSString*)message GroupId:(NSString*)groupId gameid:(NSString*)gameid roomId:(NSString*)roomId team:(NSString*)team UserId:(NSString*)userid;
@end
