 //
//  GetDataAfterManager.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-17.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "GetDataAfterManager.h"
#import "NSObject+SBJSON.h"
#import "SoundSong.h"
#import "UserManager.h"
#import "DSuser.h"
#import "VibrationSong.h"
#import "CharacterAndTitleService.h"
#import "MessageSetting.h"
#import <AVFoundation/AVFoundation.h>
#define mTime 0.5
static GetDataAfterManager *my_getDataAfterManager = NULL;

@implementation GetDataAfterManager
{
    int index;
    int index2;
    NSTimeInterval markTimeDy;
    NSTimeInterval markTimeDyMe;
    NSTimeInterval markTimeDyGroup;
    
    int dyMsgCount;
    int dyMeMsgCount;
    int dyGroupMsgCount;
}
static SystemSoundID shake_sound_male_id = 0;
+ (GetDataAfterManager*)shareManageCommon
{
    @synchronized(self)
    {
		if (my_getDataAfterManager == nil)
		{
			my_getDataAfterManager = [[self alloc] init];
		}
	}
	return my_getDataAfterManager;
}

- (id)init
{
    self = [super init];
    if (self) {
        index=1;
        index2=1;
        dyMsgCount = 0;
        dyMeMsgCount = 0;
        dyGroupMsgCount = 0;
        self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

//--------------------------------------------收到新闻消息
#pragma mark 收到新闻消息
-(void)dailynewsReceived:(NSDictionary * )messageContent
{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [DataStoreManager saveDSNewsMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
         [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewsMessage object:nil userInfo:msgDic];
        });
    }];
}
//--------------------------------------------收到与我相关动态消息
#pragma mark --收到与我相关动态消息
-(void)newdynamicAboutMe:(NSDictionary *)messageContent;
{
    [DataStoreManager saveDynamicAboutMe:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
     }];
}

//--------------------------------------------正常聊天消息
#pragma mark 收到聊天消息
-(void)newMessageReceived:(NSMutableDictionary *)messageContent
{
    NSString * sender = [messageContent objectForKey:@"sender"];
    //黑名单
    if ([DataStoreManager isBlack:sender]) {
         [self comeBackDelivered:sender msgId:KISDictionaryHaveKey(messageContent, @"msgId") Type:@"normal"];//反馈消息
        return;
    }
    
    
//    if ([[[KISDictionaryHaveKey(messageContent, @"payload") JSONValue]objectForKey:@"type"]isEqualToString:@"audio"]) {
//        NSString *title =[[KISDictionaryHaveKey(messageContent, @"payload") JSONValue]objectForKey:@"messageid"];
//        NSString *filePath = [NSString stringWithFormat:@"%@%@",QiniuBaseImageUrl,title];
//        [NetManager downloadAudioWithBaseURLStr:filePath audioId:title completion:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
//      
//        }];
//    }
    
    //账号激活
    if ([KISDictionaryHaveKey(messageContent, @"payload") JSONValue][@"active"]){//发送通知 判断账号是否激活
        [[NSNotificationCenter defaultCenter] postNotificationName:@"wxr_myActiveBeChanged" object:nil userInfo:[KISDictionaryHaveKey(messageContent, @"payload") JSONValue]];
    }
    //1 打过招呼，2 未打过招呼
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"]) {
        NSArray *array = (NSArray *)[[NSUserDefaults standardUserDefaults]objectForKey:@"sayHello_wx_info_id"];
        if ([array containsObject:sender]) {
            [messageContent setValue:@"1" forKey:@"sayHiType"];
        }else{
            [messageContent setValue:@"2" forKey:@"sayHiType"];
        }
    }else{
        [self getSayHiUserIdWithInfo:messageContent];
    }
    [DataStoreManager storeNewNormalChatMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}

//--------------------------------------------群组聊天消息
#pragma mark 收到群组聊天消息
-(void)newGroupMessageReceived:(NSDictionary *)messageContent
{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    //位置改变消息
    if (payloadDic && [KISDictionaryHaveKey(payloadDic, @"team") isEqualToString:@"teamchat"]) {
        [messageContent setValue:KISDictionaryHaveKey(payloadDic, @"teamPosition") forKey:@"teamPosition"];
        if ([KISDictionaryHaveKey(payloadDic, @"type") isEqualToString:@"selectTeamPosition"]) {
            [DataStoreManager updatePosition:[GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"roomId")] GameId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"gameid")] GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(messageContent, @"groupId")] UserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(messageContent, @"sender")] TeamPosition:[[ItemManager singleton]createPosition:KISDictionaryHaveKey(payloadDic, @"teamPosition")] Successcompletion:^(BOOL success, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:kChangPosition object:nil userInfo:messageContent];
                });
            }];
        }
    }
    
    [DataStoreManager storeNewGroupMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"groupId") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"group"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[GameCommon getMsgSettingStateByGroupId:[msgDic objectForKey:@"groupId"]] isEqualToString:@"0"]) {//正常模式
                [[MessageSetting singleton] setSoundOrVibrationopen];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    } ];
}

//--------------------------------------------群通知消息
#pragma mark 申请加入群消息
-(void)JoinGroupMessageReceived:(NSDictionary *)messageContent
{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [DataStoreManager saveDSGroupApplyMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kJoinGroupMessage object:nil userInfo:msgDic];
        });
        
    }];
}


#pragma mark 解散群
-(void)disbandGroupMessageReceived:(NSDictionary *)messageContent{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        
    }];
    [[GroupManager singleton] changGroupState:groupId GroupState:@"1" GroupShipType:@"3"];//改变本地群的状态
    [DataStoreManager saveDSGroupApplyMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
             NSDictionary * dic = @{@"groupId":groupId};
            [[NSNotificationCenter defaultCenter] postNotificationName:kDisbandGroup object:nil userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
        
    }];
}


#pragma mark 被踢出群
-(void)kickOffGroupMessageReceived:(NSDictionary *)messageContent{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [[GroupManager singleton] changGroupState:groupId GroupState:@"2" GroupShipType:@"3"];//改变本地群的状态
    [DataStoreManager saveDSGroupApplyMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            NSDictionary * dic = @{@"groupId":groupId,@"state":@"2"};
            [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffGroupGroup object:nil userInfo:dic];
        });
        
    }];
}
#pragma mark 入群申请被通过
-(void)joinGroupApplicationAcceptMessageReceived:(NSDictionary *)messageContent{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [[GroupManager singleton] changGroupState:groupId GroupState:@"0" GroupShipType:@"0"];
    [DataStoreManager saveDSGroupApplyMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
             NSDictionary * dic = @{@"groupId":groupId,@"state":@"0"};
            [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffGroupGroup object:nil userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kJoinGroupMessage object:nil userInfo:msgDic];
        });
        
    }];
}

#pragma mark 群组公告消息
-(void)groupBillBoardMessageReceived:(NSDictionary *)messageContent
{
    if (![[NSUserDefaults standardUserDefaults]objectForKey: Billboard_msg_count]) {
        int i=1;
        [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:Billboard_msg_count];
    }else{
        int i =[[[NSUserDefaults standardUserDefaults]objectForKey: Billboard_msg_count]intValue];
        [[NSUserDefaults standardUserDefaults]setObject:@(i+1) forKey:Billboard_msg_count];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [DataStoreManager saveDSGroupApplyMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:Billboard_msg object:nil userInfo:msgDic];
        });
    }];
}

#pragma mark 加入群，退出群
-(void)changGroupMessageReceived:(NSDictionary *)messageContent
{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"payload")];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
        
    }];
}


//------------------------------------------------------------------------组队消息
#pragma mark 申请加入组队
-(void)TeamNotifityMessageReceived:(NSDictionary *)messageContent
{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    if ([GameCommon isEmtity:groupId]) {
        return;
    }
    //申请加入组队通知的消息
    [DataStoreManager saveTeamNotifityMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
       
    }];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [payloadDic setValue:@"inGroupSystemMsg" forKey:@"type"];
    [messageContent setValue:[payloadDic JSONFragment] forKey:@"payload"];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
         [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kJoinTeamMessage object:nil userInfo:msgDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}

#pragma mark 踢出组队
-(void)teamKickTypeMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = KISDictionaryHaveKey(payloadDic, @"groupId");
     NSString * userId = KISDictionaryHaveKey(payloadDic, @"userid");
    [messageContent setValue:groupId forKey:@"groupId"];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    if ([userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {//假如是自己被踢出
        [[GroupManager singleton] changGroupState:groupId GroupState:@"2" GroupShipType:@"3"];//改变本地群的状态
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",@"selectType_",groupId]];//清除位置信息
        NSDictionary * dic = @{@"groupId":groupId,@"state":@"2"};
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffMyTeam object:nil userInfo:dic];
        });
    }
    [[TeamManager singleton] deleteMenberUserInfo:payloadDic GroupId:groupId];//删除组队成员
    [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
    }];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary * dic = @{@"groupId":groupId,@"state":@"2"};
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffGroupGroup object:nil userInfo:dic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];}

#pragma mark 解散组队
-(void)teamTissolveTypeMessageReceived:(NSDictionary*)messageContent{
    NSDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    NSString * teamUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"teamUsershipType")];
    if ([GameCommon isEmtity:teamUsershipType]) {
        teamUsershipType = @"1";
    }
    [messageContent setValue:groupId forKey:@"groupId"];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    
    [DataStoreManager updateDSTeamNotificationMsgCount:groupId SayHightType:@"3"];//把该组队的所有未读消息设置为0
    [DataStoreManager updateDSTeamNotificationMsgCount:groupId SayHightType:@"4"];//把该组队的所有未读消息设置为0
    [DataStoreManager blankGroupMsgUnreadCountForUser:groupId];//把所有未读消息标记为0
    [[GroupManager singleton] changGroupState:groupId GroupState:@"1" GroupShipType:@"3"];//改变本地群的状态
    if ([teamUsershipType intValue]==0) {//如果解散的是自己的队伍
        [[TeamManager singleton] clearTeamMessage:groupId];
        [self comeBackDelivered:KISDictionaryHaveKey(messageContent, @"sender") msgId:KISDictionaryHaveKey(messageContent, @"msgId") Type:@"normal"];//反馈消息
        NSDictionary * dic = @{@"groupId":groupId};
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kDisbandMyTeam object:nil userInfo:dic];
        });
    }else{//如果是别人的队伍解散了
        [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        }];
        [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
            NSDictionary * dic = @{@"groupId":groupId};
            [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MessageSetting singleton] setSoundOrVibrationopen];
                [[NSNotificationCenter defaultCenter] postNotificationName:kDisbandGroup object:nil userInfo:dic];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
            });
        }];
    }
}
#pragma mark 加入组队
-(void)teamMemberMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = KISDictionaryHaveKey(payloadDic, @"groupId");
    [messageContent setValue:groupId forKey:@"groupId"];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [[TeamManager singleton] saveMemberUserInfo:payloadDic GroupId:groupId];//组队添加新成员
    [DataStoreManager updateTeamNotifityMsgState:KISDictionaryHaveKey(KISDictionaryHaveKey(payloadDic, @"teamUser"), @"userid") State:@"1" GroupId:groupId];//把所有的通知消息状态标记为1
    [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
       
    }];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kteamMessage object:nil userInfo:msgDic];
        });
    }];
}
#pragma mark 退出组队
-(void)teamQuitTypeMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = KISDictionaryHaveKey(payloadDic, @"groupId");
    NSString * userId = KISDictionaryHaveKey(payloadDic, @"userid");
    [messageContent setValue:groupId forKey:@"groupId"];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [[TeamManager singleton] deleteMenberUserInfo:payloadDic GroupId:groupId];//删除组队成员
    if ([userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {//如果是自己退出
        [[GroupManager singleton] changGroupState:groupId GroupState:@"2" GroupShipType:@"3"];//改变本地群的状态
        [[TeamManager singleton] clearTeamMessage:groupId];//清除消息
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@%@",@"selectType_",groupId]];//清除位置信息
        [self comeBackDelivered:KISDictionaryHaveKey(messageContent, @"sender") msgId:KISDictionaryHaveKey(messageContent, @"msgId") Type:@"normal"];//反馈消息
        NSDictionary * dic = @{@"groupId":groupId,@"state":@"2"};
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffMyTeam object:nil userInfo:dic];
        });
    }else {//否则是他人退出
        [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
            
        }];
        [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
            [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
            dispatch_async(dispatch_get_main_queue(), ^{
                [[MessageSetting singleton] setSoundOrVibrationopen];
                [[NSNotificationCenter defaultCenter] postNotificationName:kteamMessage object:nil userInfo:msgDic];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
            });
        }];
    }
}
#pragma mark 占坑
-(void)teamClaimAddTypeMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = KISDictionaryHaveKey(payloadDic, @"groupId");
    [messageContent setValue:groupId forKey:@"groupId"];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        
    }];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
            [[NSNotificationCenter defaultCenter] postNotificationName:kteamMessage object:nil userInfo:msgDic];
        });
    }];
    
    
    [self comeBackDelivered:KISDictionaryHaveKey(messageContent, @"sender") msgId:KISDictionaryHaveKey(messageContent, @"msgId") Type:@"normal"];//反馈消息
}
#pragma mark 填坑
-(void)teamOccupyTypeMessageReceived:(NSDictionary *)messageContent{
    [self comeBackDelivered:KISDictionaryHaveKey(messageContent, @"sender") msgId:KISDictionaryHaveKey(messageContent, @"msgId") Type:@"normal"];//反馈消息
}
#pragma mark 邀请加入
-(void)teamInviteTypeMessageReceived:(NSDictionary *)messageContent{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:@"normalchat" forKeyPath:@"msgType"];
    [DataStoreManager storeNewNormalChatMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}
#pragma mark 群邀请加入
-(void)teamInviteInGroupTypeMessageReceived:(NSDictionary*)messageContent{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:@"normalchat" forKeyPath:@"msgType"];
    [DataStoreManager storeNewNormalChatMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}
#pragma mark 组队偏好
-(void)teamRecommendMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    [DataStoreManager savePreferenceMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        NSInteger state = [[PreferencesMsgManager singleton] getPreferenceState:KISDictionaryHaveKey(payloadDic, @"gameid") PreferenceId:KISDictionaryHaveKey(payloadDic, @"preferenceId")];
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            if (state == 1) {
                [[MessageSetting singleton] setSoundOrVibrationopen];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kteamRecommend object:nil userInfo:msgDic];
        });
    }];
}
#pragma mark 发起就位确认的消息
-(void)startTeamPreparedConfirmMessageReceived:(NSDictionary *)messageContent{
    [DataStoreManager saveTeamPreparedMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        
    }];
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:[GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")] forKey:@"groupId"];
    [[TeamManager singleton] updateTeamUserState:[GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")] UserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"userid")] MemberList:KISDictionaryHaveKey(payloadDic, @"memberList") State:@"1"];
    
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
            [self initSound];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];

}

#pragma mark 确定就位确认
-(void)teamPreparedUserSelectMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = KISDictionaryHaveKey(payloadDic, @"groupId");
    NSString * userid = KISDictionaryHaveKey(payloadDic, @"userid");
    NSString * teamPosition = KISDictionaryHaveKey(payloadDic, @"teamPosition");
    if ([GameCommon isEmtity:teamPosition]||[teamPosition isEqualToString:@"null"]) {
        teamPosition = @"未选";
    }
    [messageContent setValue:groupId forKey:@"groupId"];
    [messageContent setValue:teamPosition forKey:@"teamPosition"];
    [[TeamManager singleton] updateTeamUserState:payloadDic];//更新就位确认的状态
    [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
      
    }];
    [DataStoreManager saveDSGroupMsgOKCancel:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [msgDic setValue:userid forKey:@"sender"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}
#pragma mark 就位确认结果
-(void)teamPreparedConfirmResultMessageReceived:(NSDictionary *)messageContent{
    NSMutableDictionary * payloadDic = [self getPayloadDic:messageContent];
    NSString * groupId = KISDictionaryHaveKey(payloadDic, @"groupId");
    [messageContent setValue:groupId forKey:@"groupId"];
    [DataStoreManager saveTeamThumbMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        
    }];
    [DataStoreManager saveDSGroupMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        dispatch_async(dispatch_get_main_queue(), ^{
             [[TeamManager singleton] resetTeamUserState:[GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")]];
            [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}

#pragma mark 其他不认识的消息
-(void)otherAnyMessageReceived:(NSDictionary *)messageContent{
    [self comeBackDelivered:KISDictionaryHaveKey(messageContent, @"sender") msgId:KISDictionaryHaveKey(messageContent, @"msgId") Type:@"normal"];//反馈消息
}

-(NSMutableDictionary*)getPayloadDic:(NSDictionary *)messageContent{
    NSString* payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(messageContent, @"payload")];
    return [payloadStr JSONValue];
}


//--------------------------------------------
#pragma mark 收到验证好友请求消息
-(void)newAddReq:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
    [DataStoreManager changshiptypeWithUserId:fromUser type:shiptype];
     [self comeBackDelivered:KISDictionaryHaveKey(userInfo, @"sender") msgId:KISDictionaryHaveKey(userInfo, @"msgId") Type:@"normal"];//反馈消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kFriendHelloReceived object:nil userInfo:userInfo];
    });
}

#pragma mark 收到取消关注 删除好友请求消息
-(void)deletePersonReceived:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");    
    [DataStoreManager changshiptypeWithUserId:fromUser type:shiptype];
    DSuser *dUser = [DataStoreManager getInfoWithUserId:fromUser];
    [DataStoreManager cleanIndexWithNameIndex:dUser.nameIndex withType:@"1"];
    [self comeBackDelivered:KISDictionaryHaveKey(userInfo, @"sender") msgId:KISDictionaryHaveKey(userInfo, @"msgId") Type:@"normal"];//反馈消息
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteAttention object:nil userInfo:userInfo];
    });
}
//--------------------------------------------角色，头衔，战斗力变化，
#pragma mark - 头衔、角色、战斗力变化等消息
-(void)otherMessageReceived:(NSDictionary *)info
{
    [DataStoreManager saveOtherMsgsWithData:info SaveSuccess:^(NSDictionary *msgDic) {
        [[CharacterAndTitleService singleton] getTitleInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] Type:@""];
         [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kOtherMessage object:nil userInfo:msgDic];
        });
    }];
  
}
//--------------------------------------------好友推荐
#pragma mark 收到推荐好友消息
-(void)recommendFriendReceived:(NSDictionary *)info
{
    [info setValue:@"1" forKey:@"sayHiType"];
    NSArray* recommendArr = [KISDictionaryHaveKey(info, @"msg") JSONValue];
    [DataStoreManager saveRecommendWithData:recommendArr MsgInfo:info SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            [[MessageSetting singleton] setSoundOrVibrationopen];
            [[NSNotificationCenter defaultCenter] postNotificationName:kRecommendMessage object:nil userInfo:msgDic];
        });
    }];
}
//--------------------------------------------动态消息
#pragma mark 好友动态消息
-(void)dyMessageReceived:(NSDictionary *)info
{
    NSString * payload = KISDictionaryHaveKey(info, @"payLoad");
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
    [DataStoreManager saveCricleCountWithType:2 img:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")] userid:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"frienddunamicmsgChange_WX" object:nil userInfo:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
    });
    [self comeBackDelivered:KISDictionaryHaveKey(info, @"sender") msgId:KISDictionaryHaveKey(info, @"msgId") Type:@"normal"];//反馈消息
}
#pragma mark 与我相关动态消息
-(void)dyMeMessageReceived:(NSDictionary *)info{
    NSString * payload = KISDictionaryHaveKey(info, @"payLoad");
    [self newdynamicAboutMe:[payload JSONValue]];

   //保存与我相关数量~~凑
    NSDictionary *dic =[payload JSONValue];
    NSString *imgStr;
    if ([[dic allKeys]containsObject:@"commentObject"]) {
        imgStr = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"commentObject"]objectForKey:@"commentUser"]objectForKey:@"img"]];
    }
    else if ([[dic allKeys]containsObject:@"zanObject"]){
        imgStr = [NSString stringWithFormat:@"%@",[[[dic objectForKey:@"zanObject"]objectForKey:@"zanUser"]objectForKey:@"img"]];
    }
    [DataStoreManager saveCricleCountWithType:1 img:imgStr userid:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:@"mydynamicmsg_wx" object:nil userInfo:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
    });
     [self comeBackDelivered:KISDictionaryHaveKey(info, @"sender") msgId:KISDictionaryHaveKey(info, @"msgId") Type:@"normal"];//反馈消息
}
#pragma mark 群动态消息
-(void)dyGroupMessageReceived:(NSDictionary *)info{
    NSString * payload = KISDictionaryHaveKey(info, @"payLoad");
    [self saveGroupDyMessage:payload];
     [self comeBackDelivered:KISDictionaryHaveKey(info, @"sender") msgId:KISDictionaryHaveKey(info, @"msgId") Type:@"normal"];//反馈消息
}
//---------------------------------------群动态
-(void)saveGroupDyMessage:(NSString *)payload
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTimeDyGroup)*100<0.5*1000) {
        markTimeDyGroup = [[NSDate date] timeIntervalSince1970];
        dyGroupMsgCount++;
        if ([self.cellTimerDyGroup isValid]) {
            [self.cellTimerDyGroup invalidate];
            self.cellTimerDyGroup = nil;
        }
        self.cellTimerDyGroup = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(saveDyGroupMsgTimer:) userInfo:payload repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.cellTimerDyGroup forMode:NSRunLoopCommonModes];
        return;
    }
    markTimeDyGroup = [[NSDate date] timeIntervalSince1970];
    dyGroupMsgCount++;
    [self saveDyGroupMsg:payload];
}

-(void)saveDyGroupMsgTimer:(NSTimer*)timer
{
    [self saveDyGroupMsg:timer.userInfo];
}

-(void)saveDyGroupMsg:(NSString *)payload
{
    if ([self.cellTimerDyGroup isValid]) {
        [self.cellTimerDyGroup invalidate];
        self.cellTimerDyGroup = nil;
    }
    NSDictionary* msgDic = [[NSString stringWithFormat:@"%@",payload] JSONValue];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,KISDictionaryHaveKey(msgDic, @"groupId")]]) {
        int i =[[[NSUserDefaults standardUserDefaults]objectForKey: [NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,KISDictionaryHaveKey(msgDic, @"groupId")]]intValue];
        i+=dyGroupMsgCount;
         [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,KISDictionaryHaveKey(msgDic, @"groupId")]];
    }else{
        int i = 0;
        i+=dyGroupMsgCount;
         [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,KISDictionaryHaveKey(msgDic, @"groupId")]];
    }
    dyGroupMsgCount = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter]postNotificationName:GroupDynamic_msg object:nil userInfo:msgDic];
    });
}

//--------------------------------------反馈消息
#pragma mark 发送反馈消息
- (void)comeBackDelivered:(NSString*)sender msgId:(NSString*)msgId Type:(NSString*)type//发送送达消息
{
    NSDictionary * dic = @{@"msgId":msgId,@"senderId":sender,@"type":type};
    [self comeBack:dic];
}
- (void)comeBack:(NSDictionary*)msgDic
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:KISDictionaryHaveKey(msgDic, @"msgId"),@"src_id",@"true",@"received",@"Delivered",@"msgStatus", nil];
    NSString * nowTime=[GameCommon getCurrentTime];
    NSString * message=[dic JSONRepresentation];
    NSString * userid = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * domaim = [[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN];
    NSString * from =[NSString stringWithFormat:@"%@%@",userid,domaim];
    NSString *to=[NSString stringWithFormat:@"%@%@",KISDictionaryHaveKey(msgDic, @"senderId"),[self getDomain:domaim Type:KISDictionaryHaveKey(msgDic, @"type")]];
    NSXMLElement *mes = [MessageService createMes:nowTime Message:message UUid:KISDictionaryHaveKey(msgDic, @"msgId") From:from To:to FileType:@"text" MsgType:@"msgStatus" Type:@"normal"];
    NSLog(@"GetDataAfterManager--sendComBackMessage--->>%@",mes);
    if (![self.appDel.xmppHelper sendMessage:mes]) {
        return;
    }
}
-(NSString*)getDomain:(NSString*)domain Type:(NSString*)type
{
    if ([type isEqualToString:@"normal"]) {
        return domain;
    }else if([type isEqualToString:@"group"]){
        return [GameCommon getGroupDomain:domain];
    }
    return domain;
}
//--------------------------------------
#pragma mark --获取你和谁说过话
-(void)getSayHiUserIdWithInfo:(NSDictionary *)info
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"" forKey:@"touserid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"154" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"sayHello_wx_info_id"];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSString * sender = [info objectForKey:@"sender"];
            if ([responseObject containsObject:sender]) {
                [info setValue:@"1" forKey:@"sayHiType"];
            }else{
                [info setValue:@"2" forKey:@"sayHiType"];
            }
        }

    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
    
}

-(void)initSound{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"inplace_sound" ofType:@"mp3"];
    if (path) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path],&shake_sound_male_id);
        AudioServicesPlaySystemSound(shake_sound_male_id);
    }
    AudioServicesPlaySystemSound(shake_sound_male_id);
}

@end
