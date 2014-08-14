//
//  MsgTypeManager.h
//  GameGroup
//
//  Created by Apple on 14-7-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//


/*groupchat：群组聊天
normalchat:正常聊天
sayHello:打招呼
deletePerson:取消关注
character：角色变化
pveScore：pve战斗力变化
title：头衔变化
recommendfriend：好友推荐
frienddynamicmsg：好友动态
mydynamicmsg：与我相关
groupDynamicMsgChange：群组动态
dailynews：每日一问
inGroupSystemMsgJoinGroup：好友加入群
inGroupSystemMsgQuitGroup：好友退出群
joinGroupApplication：申请加入群
joinGroupApplicationAccept：入群申请通过
joinGroupApplicationReject：群申请拒绝
groupApplicationUnderReview：群申请已提交
groupApplicationAccept：群申请通过
groupApplicationReject：群申请被拒绝
groupLevelUp：群等级提升
disbandGroup：解散群
groupUsershipTypeChange:群成员身份变化
kickOffGroup：被提出群的消息
groupRecommend：群推荐
friendJoinGroup：好友加入了新的群组
groupBillboard：群公告
reqeustJoinTeam：申请加入组队
teamMemberChange：同意添加,踢出组织,退出组织,占坑,填坑
disbandTeam：解散组队
teamInvite：组队邀请
teamRecommend:组队偏好消息
startTeamPreparedConfirm发起就位确认
teamPreparedUserSelect选择就位确认状态
teamPreparedConfirmResult就位确认结果*/


#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger,MsgType){
    MsgTypeGroupchat=1,
    MsgTypeNormalchat=2,
    MsgTypeSayHello=3,
    MsgTypeDeletePerson=4,
    MsgTypeCharacter=5,
    MsgTypePveScore=6,
    MsgTypeTitle=7,
    MsgTypeRecommendfriend=8,
    MsgTypeFrienddynamicmsg=9,
    MsgTypeMydynamicmsg=10,
    MsgTypeGroupDynamicMsgChange=11,
    MsgTypeDailynews=12,
    MsgTypeInGroupSystemMsgJoinGroup=13,
    MsgTypeInGroupSystemMsgQuitGroup=14,
    MsgTypeJoinGroupApplication=15,
    MsgTypeJoinGroupApplicationAccept=16,
    MsgTypeJoinGroupApplicationReject=17,
    MsgTypeGroupApplicationUnderReview=18,
    MsgTypeGroupApplicationAccept=19,
    MsgTypeGroupApplicationReject=20,
    MsgTypeGroupLevelUp=21,
    MsgTypeDisbandGroup=22,
    MsgTypeGroupUsershipTypeChange=23,
    MsgTypeKickOffGroup=24,
    MsgTypeGroupRecommend=25,
    MsgTypeFriendJoinGroup=26,
    MsgTypeGroupBillboard=27,
    MsgTypeReqeustJoinTeam=28,
    MsgTypeTeamMemberChange=29,
    MsgTypeDisbandTeam=30,
    MsgTypeTeamInvite=31,
    MsgTypeOther=32,
    MsgTypeStartTeamPreparedConfirm=33,
    MsgTypeTeamPreparedUserSelect=34,
    MsgTypeTeamPreparedConfirmResult=35
};

typedef NS_ENUM(NSInteger,PayloadType){
    PayloadTypeDynamic=1,
    PayloadTypeImage=2,
    PayloadTypeHistoryMsg=3,
    PayloadTypeInGroupSystemMsg=4,
    PayloadTypeSelectTeamPosition=5,
    PayloadTypeTeamAddType=6,
    PayloadTypeTeamKickType=7,
    PayloadTypeTeamQuitType=8,
    PayloadTypeInTeamSystemMsg=9,
    PayloadTypeTeamInvite=10,
    PayloadTypeTeamInviteInGroup=11,
    PayloadTypeTeamClaimAddType=12,
    PayloadTypeTeamOccupyType=13,
    PayloadTypeStartTeamPreparedConfirm=14,
    PayloadTypeTeamPreparedUserSelectOk = 15,
    PayloadTypeTeamPreparedUserSelectCancel = 16,
    PayloadTypeTeamPreparedConfirmResultSuccess = 17,
    payloadTypeTeamPreparedConfirmResultFail = 18,
    payloadTypeTeamClaimAddType = 19,
    PayloadTypeOther=100
};

@interface MsgTypeManager : NSObject
+(MsgType)getTMsgType:(NSString*)msgtype;
+(PayloadType)getTPayloadType:(NSString*)payloadType;

+(NSInteger)payloadType:(NSDictionary*)plainEntry;
@end
