//
//  RecceiveMessageService.m
//  GameGroup
//
//  Created by Apple on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "RecceiveMessageService.h"
#import "ChatDelegate.h"
#import "AddReqDelegate.h"
#import "CommentDelegate.h"
#import "NotConnectDelegate.h"
#import "DeletePersonDelegate.h"
#import "OtherMessageReceive.h"
#import "RecommendFriendDelegate.h"

static RecceiveMessageService *recceiveMessageService = NULL;

@implementation RecceiveMessageService

+ (RecceiveMessageService*)shareManageCommon
{
    @synchronized(self)
    {
		if (recceiveMessageService == nil)
		{
			recceiveMessageService = [[self alloc] init];
		}
	}
	return recceiveMessageService;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}
-(void)onMessage:(XMPPMessage *)message
{
    NSString *msg = [GameCommon getNewStringWithId:[[message elementForName:@"body"] stringValue]];
    if(msg==nil){
        return;
    }
    NSString *msgtype = [[message attributeForName:@"msgtype"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *to = [[message attributeForName:@"to"] stringValue];
    NSString *msgId = [[message attributeForName:@"id"] stringValue];
    NSString * fromId = [from substringToIndex:([from rangeOfString:@"@"].location == NSNotFound) ? 0 : [from rangeOfString:@"@"].location];
    NSString * toId = [to substringToIndex:([to rangeOfString:@"@"].location == NSNotFound) ? 0 : [to rangeOfString:@"@"].location];
    NSString *type = [[message attributeForName:@"type"] stringValue];
    NSString * time = [[message attributeForName:@"msgTime"] stringValue];
    NSString *msgTime = time?time:[GameCommon getCurrentTime];
    NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"msg"];//消息内容
    [dict setObject:fromId forKey:@"sender"];//发送者用户id
    [dict setObject:msgId?msgId:@"" forKey:@"msgId"];//消息id
    [dict setObject: msgTime forKey:@"time"];//消息接收到的时间
    [dict setObject:msgtype?msgtype:@"" forKey:@"msgType"];
    [dict setObject:toId forKey:@"toId"];
    
    if ([type isEqualToString:@"chat"])
    {
        if([msgtype isEqualToString:@"groupchat"])//群组聊天消息
        {
            if ([GameCommon isEmtity:msgId]) {
                return;
            }
            [dict setObject:KISDictionaryHaveKey([msg JSONValue], @"content") forKey:@"msg"];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
                NSDictionary * teamPosition = [payload JSONValue];
                if (teamPosition && [KISDictionaryHaveKey(teamPosition, @"team") isEqualToString:@"teamchat"]) {
                    [dict setObject:KISDictionaryHaveKey(teamPosition, @"teamPosition") forKey:@"teamPosition"];
                    if ([KISDictionaryHaveKey(teamPosition, @"type") isEqualToString:@"selectTeamPosition"]) {
                        [DataStoreManager changGroupMsgLocation:[[message attributeForName:@"groupid"] stringValue] UserId:fromId TeamPosition:KISDictionaryHaveKey(teamPosition, @"teamPosition")];
                    }
                }
            }
            [dict setObject:[[message attributeForName:@"groupid"] stringValue] forKey:@"groupId"];
            [self.chatDelegate newGroupMessageReceived:dict];
            return;
        }
        
        if ([msgtype isEqualToString:@"normalchat"]) {//正常聊天的消息
            if ([GameCommon isEmtity:msgId]) {
                return;
            }
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate newMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"sayHello"]){//打招呼的
            if (payload.length > 0) {
                [dict setObject:KISDictionaryHaveKey([payload JSONValue], @"shiptype") forKey:@"shiptype"];
            }
            else
                [dict setObject:@""  forKey:@"shiptype"];
            [self.deletePersonDelegate newAddReq:dict];
        }
        else if([msgtype isEqualToString:@"deletePerson"])//取消关注
        {
            if (payload.length > 0) {
                [dict setObject:KISDictionaryHaveKey([payload JSONValue], @"shiptype") forKey:@"shiptype"];
            }
            else{
                [dict setObject:@""  forKey:@"shiptype"];
            }
            [self.deletePersonDelegate deletePersonReceived:dict];
        }
        else if ([msgtype isEqualToString:@"character"] || [msgtype isEqualToString:@"pveScore"] || [msgtype isEqualToString:@"title"])//角色信息改变
        {
            NSString *title = KISDictionaryHaveKey([payload JSONValue],@"title");
            [dict setObject:title?title:@"" forKey:@"title"];
            [self.otherMsgReceiveDelegate otherMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"recommendfriend"])//好友推荐
        {
            NSArray* arr = [msg JSONValue];
            NSString* dis = @"";
            if (arr.count<1) {
                return;
            }
            if ([arr isKindOfClass:[NSArray class]]) {
                if ([arr count] != 0) {
                    NSMutableDictionary* dic = [arr objectAtIndex:0];
                    if (![dic isKindOfClass:[NSDictionary class]]) {
                        return;
                    }
                    dis = [NSString stringWithFormat:@"%@%@",KISDictionaryHaveKey(dic, @"recommendMsg") ,KISDictionaryHaveKey(dic, @"nickname")];
                }
            }
            [dict setObject:dis forKey:@"disStr"];
            [self.recommendReceiveDelegate recommendFriendReceived:dict];
        }
        else if([msgtype isEqualToString:@"frienddynamicmsg"])//好友动态
        {
            [dict setObject:payload forKey:@"payLoad"];
            [self.chatDelegate dyMessageReceived:dict];
        }
        else if([msgtype isEqualToString:@"mydynamicmsg"])//与我相关动态
        {
            [dict setObject:payload forKey:@"payLoad"];
            [self.chatDelegate dyMeMessageReceived:dict];
        }
        else if([msgtype isEqualToString:@"groupDynamicMsgChange"])//群动态
        {
            [dict setObject:payload forKey:@"payLoad"];
            [self.chatDelegate dyGroupMessageReceived:dict];
        }
        else if([msgtype isEqualToString:@"dailynews"])//新闻
        {
            NSString *title = [[message elementForName:@"payload"] stringValue];
            [dict setObject:title?title:@"" forKey:@"title"];
            [self.chatDelegate dailynewsReceived:dict];
        }
        else if([msgtype isEqualToString:@"inGroupSystemMsgJoinGroup"]//好友加入群
                ||[msgtype isEqualToString:@"inGroupSystemMsgQuitGroup"])//好友退出群
        {
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate changGroupMessageReceived:dict];
        }
        else if([msgtype isEqualToString:@"joinGroupApplication"]//申请加入群
                ||[msgtype isEqualToString:@"joinGroupApplicationAccept"]//入群申请通过
                ||[msgtype isEqualToString:@"joinGroupApplicationReject"]//入群申请拒绝
                ||[msgtype isEqualToString:@"groupApplicationUnderReview"]//群审核已提交
                ||[msgtype isEqualToString:@"groupApplicationAccept"]///群审核通过
                ||[msgtype isEqualToString:@"groupApplicationReject"]//群审核被拒绝
                ||[msgtype isEqualToString:@"groupLevelUp"]//群等级提升disbandGroup
                ||[msgtype isEqualToString:@"disbandGroup"]//解散群
                ||[msgtype isEqualToString:@"groupUsershipTypeChange"]//群成员身份变化
                ||[msgtype isEqualToString:@"kickOffGroup"]//被踢出群的消息
                ||[msgtype isEqualToString:@"groupRecommend"]//群推荐
                ||[msgtype isEqualToString:@"friendJoinGroup"]){//好友加入了新的群组
            [dict setObject:[self getMsgTitle:msgtype] forKey:@"msgTitle"];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate JoinGroupMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"groupBillboard"]){//群组公告消息
            [dict setObject:[self getMsgTitle:msgtype] forKey:@"msgTitle"];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate groupBillBoardMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"requestJoinTeam"]){//申请加入组队
            [dict setObject:[self getMsgTitle:msgtype] forKey:@"msgTitle"];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate TeamNotifityMessageReceived:dict];//
        }
        else if ([msgtype isEqualToString:@"teamMemberChange"]){//同意添加,踢出组织,退出组织,占坑,填坑
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            NSMutableDictionary * payloadDis = [payload JSONValue];
            NSString * payLoadType = KISDictionaryHaveKey(payloadDis, @"type");
            
            if([payLoadType isEqualToString:@"teamAddType"]){//同意添加
                [self.chatDelegate teamMemberMessageReceived:dict];
            }
            else if ([payLoadType isEqualToString:@"teamKickType"]){//踢出组织
                [self.chatDelegate teamKickTypeMessageReceived:dict];
            }
            else if ([payLoadType isEqualToString:@"teamQuitType"]){//退出组织
                [self.chatDelegate teamQuitTypeMessageReceived:dict];
            }
            else if ([payLoadType isEqualToString:@"teamClaimAddType"]){//占坑
                [self.chatDelegate teamClaimAddTypeMessageReceived:dict];
            }
            else if ([payLoadType isEqualToString:@"teamOccupyType"]){//填坑
                [self.chatDelegate teamOccupyTypeMessageReceived:dict];
            }
        }
        
        else if ([msgtype isEqualToString:@"disbandTeam"]){//解散组织
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate teamTissolveTypeMessageReceived:dict];
        }
    }
    
    if ([type isEqualToString:@"normal"]&& ([msgtype isEqualToString:@"msgStatus"]))
    {
        NSDictionary* bodyDic = [[GameCommon getNewStringWithId:msg] JSONValue];
        if ([bodyDic isKindOfClass:[NSDictionary class]]) {
            NSString* src_id = KISDictionaryHaveKey(bodyDic, @"src_id");
            if (src_id.length <= 0) {
                return;
            }
            NSString * msgStatus = KISDictionaryHaveKey(bodyDic, @"msgStatus");
            if ([msgStatus isEqualToString:@"Delivered"]) {//是否送达
                [bodyDic setValue:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"3" : @"0" forKeyPath:@"msgState"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:bodyDic];
                });
            }
            else if ([msgStatus isEqualToString:@"Displayed"]) {//是否已读
                [bodyDic setValue:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"4" : @"0" forKeyPath:@"msgState"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:bodyDic];
                });
            }
        }
    }
    if ([type isEqualToString:@"normal"] && [fromId isEqualToString:@"messageack"])//消息发送服务器状态告知
    {
        msg = [msg stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary* msgData = [msg JSONValue];
        NSString* src_id = KISDictionaryHaveKey(msgData, @"src_id");
        if (src_id.length <= 0) {
            return;
        }
        [msgData setValue:@"1" forKeyPath:@"msgState"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:msgData];
        });
    }}

-(NSString*)getMsgTitle:(NSString*)msgtype
{
    if([msgtype isEqualToString:@"joinGroupApplication"]){
        return @"申请加入群";
    }else if ([msgtype isEqualToString:@"joinGroupApplicationAccept"]){
        return @"入群申请通过";
    }else if ([msgtype isEqualToString:@"joinGroupApplicationReject"]){
        return @"入群申请拒绝";
    }else if ([msgtype isEqualToString:@"groupApplicationUnderReview"]){
        return @"群审核已提交";
    }else if ([msgtype isEqualToString:@"groupApplicationAccept"]){
        return  @"群审核通过";
    }else if ([msgtype isEqualToString:@"groupApplicationReject"]){
        return  @"群审核被拒绝";
    }else if ([msgtype isEqualToString:@"groupLevelUp"]){
        return  @"群等级提升";
    }else if ([msgtype isEqualToString:@"groupBillboard"]){
        return  @"群公告";
    }else if ([msgtype isEqualToString:@"friendJoinGroup"]){
        return  @"好友加入了新的群组";
    }else if ([msgtype isEqualToString:@"disbandGroup"]){
        return @"解散群";
    }
    return @"新的群消息";
}
@end
