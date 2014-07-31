//
//  MsgTypeManager.m
//  GameGroup
//
//  Created by Apple on 14-7-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MsgTypeManager.h"

@implementation MsgTypeManager

+(MsgType)getTMsgType:(NSString*)msgtype{
    
    if([msgtype isEqualToString:@"groupchat"])//群组聊天消息
    {
        return MsgTypeGroupchat;
    }
    if ([msgtype isEqualToString:@"normalchat"]) {//正常聊天的消息
      return MsgTypeNormalchat;
    }
    else if ([msgtype isEqualToString:@"sayHello"]){//打招呼的
        return MsgTypeSayHello;
    }
    else if([msgtype isEqualToString:@"deletePerson"])//取消关注
    {
        return MsgTypeDeletePerson;
    }
    else if ([msgtype isEqualToString:@"character"])//角色信息变化
    {
        return MsgTypeCharacter;
    }
    else if ([msgtype isEqualToString:@"pveScore"])//战斗力变化
    {
        return MsgTypePveScore;
    }
    else if ([msgtype isEqualToString:@"title"])//头衔变化
    {
        return MsgTypeTitle;
    }
    else if ([msgtype isEqualToString:@"recommendfriend"])//好友推荐
    {
        return MsgTypeRecommendfriend;
    }
    else if([msgtype isEqualToString:@"frienddynamicmsg"])//好友动态
    {
       return MsgTypeFrienddynamicmsg;
    }
    else if([msgtype isEqualToString:@"mydynamicmsg"])//与我相关动态
    {
        return MsgTypeMydynamicmsg;
    }
    else if([msgtype isEqualToString:@"groupDynamicMsgChange"])//群动态
    {
       return MsgTypeGroupDynamicMsgChange;
    }
    else if([msgtype isEqualToString:@"dailynews"])//新闻
    {
        return MsgTypeDailynews;
    }
    else if([msgtype isEqualToString:@"inGroupSystemMsgJoinGroup"])//好友加入群
    {
        return MsgTypeInGroupSystemMsgJoinGroup;
    }
    else if([msgtype isEqualToString:@"inGroupSystemMsgQuitGroup"]){//好友退出群
        return MsgTypeInGroupSystemMsgQuitGroup;
    }
    else if([msgtype isEqualToString:@"joinGroupApplication"]){//申请加入群
        return MsgTypeJoinGroupApplication;
    }
    else if ([msgtype isEqualToString:@"joinGroupApplicationAccept"]){//入群申请通过
        return MsgTypeJoinGroupApplicationAccept;
    }
    else if ([msgtype isEqualToString:@"joinGroupApplicationReject"]){//入群申请拒绝
        return MsgTypeJoinGroupApplicationReject;
    }
    else if ([msgtype isEqualToString:@"groupApplicationUnderReview"]){//群审核已提交
        return MsgTypeGroupApplicationUnderReview;
    }
    else if ([msgtype isEqualToString:@"groupApplicationAccept"]){//群审核通过
        return MsgTypeGroupApplicationAccept;
    }
    else if ([msgtype isEqualToString:@"groupApplicationReject"]){//群审核被拒绝
        return MsgTypeGroupApplicationReject;
        
    }else if ([msgtype isEqualToString:@"groupLevelUp"]){//群等级提升
        return MsgTypeGroupLevelUp;
        
    }else if ([msgtype isEqualToString:@"disbandGroup"]){//解散群
        return MsgTypeDisbandGroup;
    }
    else if ([msgtype isEqualToString:@"groupUsershipTypeChange"]){//群成员身份变化
        return MsgTypeGroupUsershipTypeChange;
    }
    else if ([msgtype isEqualToString:@"kickOffGroup"]){//被踢出群的消息
        return MsgTypeKickOffGroup;
    }
    else if ([msgtype isEqualToString:@"groupRecommend"]){//群推荐
        return MsgTypeGroupRecommend;
    }
    else if ([msgtype isEqualToString:@"friendJoinGroup"]){//好友加入了新的群组
        return MsgTypeFriendJoinGroup;
    }
    else if ([msgtype isEqualToString:@"groupBillboard"]){//群组公告消息
        return MsgTypeGroupBillboard;
    }
    else if ([msgtype isEqualToString:@"reqeustJoinTeam"]){//申请加入组队
        return MsgTypeReqeustJoinTeam;
    }
    else if ([msgtype isEqualToString:@"teamMemberChange"]){//同意添加,踢出组织,退出组织,占坑,填坑
        return MsgTypeTeamMemberChange;
    }
    else if ([msgtype isEqualToString:@"disbandTeam"]){//解散组队
       return MsgTypeDisbandTeam;
    }
    else if ([msgtype isEqualToString:@"teamInvite"]){//邀请加入组队
       return MsgTypeTeamInvite;
    }
    else{
        return MsgTypeOther;
    }
}

+(PayloadType)getTPayloadType:(NSString*)payloadType
{
    if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"3"]){
        return PayloadTypeDynamic;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"img"]){
        return PayloadTypeImage;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"inGroupSystemMsg"]){
        return PayloadTypeInGroupSystemMsg;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"selectTeamPosition"]){
        return PayloadTypeSelectTeamPosition;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"teamAddType"]){
        return PayloadTypeTeamAddType;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"teamKickType"]){
        return PayloadTypeTeamKickType;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"teamQuitType"]){
        return PayloadTypeTeamQuitType;
    }
    else if ([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"inTeamSystemMsg"]){
        return PayloadTypeInTeamSystemMsg;
    }
    else if([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"historyMsg"]){
        return PayloadTypeHistoryMsg;
    }
    else if([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"teamInvite"]){
        return PayloadTypeTeamInvite;
    }
    else if([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"teamInviteInGroup"]){
        return PayloadTypeTeamInviteInGroup;
    }
    else if([[NSString stringWithFormat:@"%@",payloadType] isEqualToString:@"teamOccupyType"]){
        return PayloadTypeTeamOccupyType;
    }
    else{
        return PayloadTypeOther;
    }
}


//0群聊天消息，1组队通知消息，2组队聊天消息
+(NSInteger)payloadType:(NSDictionary*)plainEntry
{
    NSString * payLoadStr = KISDictionaryHaveKey(plainEntry, @"payload");
    if([GameCommon isEmtity:payLoadStr])
    {
        return 0;
    }
    NSDictionary * payloadDic = [payLoadStr JSONValue];
    PayloadType payloadType = [self getTPayloadType:KISDictionaryHaveKey(payloadDic,@"type")];
    if (payloadType == PayloadTypeInGroupSystemMsg
        ||payloadType == PayloadTypeSelectTeamPosition
        ||payloadType == PayloadTypeTeamAddType
        ||payloadType == PayloadTypeTeamKickType
        ||payloadType == PayloadTypeTeamQuitType
        ||payloadType == PayloadTypeInTeamSystemMsg) {
        return 1;
    }
    else
    {
        if ([GameCommon isEmtity:KISDictionaryHaveKey(payloadDic, @"team")]) {
            return 0;
        }
        return 2;
    }
}
@end
