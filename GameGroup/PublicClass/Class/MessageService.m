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
    NSLog(@"消息uuid ~!~~ %@", uuid);
    return mes;
}


#pragma mark 创建payload
+(NSString*)createPayLoadStr:(NSString*)uuid ImageId:(NSString*)imageId ThumbImage:(NSString*)thumbImage BigImagePath:(NSString*)bigImagePath
{
    return [self createPayLoadStr:thumbImage title:bigImagePath shiptype:@"" messageid:@"" msg:imageId type:@"img"];
}

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
@end
