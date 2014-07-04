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
#import "MyTask.h"

@implementation GetDataAfterManager

static GetDataAfterManager *my_getDataAfterManager = NULL;
NSOperationQueue *queuenormal ;
NSOperationQueue *queuegroup ;
NSOperationQueue *queueme ;

- (id)init
{
    self = [super init];
    if (self) {
        queuenormal = [[NSOperationQueue alloc]init];
        [queuenormal setMaxConcurrentOperationCount:1];
        queuegroup = [[NSOperationQueue alloc]init];
        [queuegroup setMaxConcurrentOperationCount:1];
        queueme = [[NSOperationQueue alloc]init];
        [queueme setMaxConcurrentOperationCount:1];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMyActive:) name:@"wxr_myActiveBeChanged" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSoundOff:) name:@"wx_sounds_open" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeSoundOpen:) name:@"wx_sounds_off" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeVibrationOff:) name:@"wx_vibration_off" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeVibrationOn:) name:@"wx_vibration_open" object:nil];

    }
    return self;
}
-(void)changeSoundOpen:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"wx_sound_tixing_count"];
    
}
-(void)changeSoundOff:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"wx_sound_tixing_count"];
}
-(void)changeVibrationOff:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"1" forKey:@"wx_Vibration_tixing_count"];
}
-(void)changeVibrationOn:(id)sender
{
    [[NSUserDefaults standardUserDefaults]setObject:@"2" forKey:@"wx_Vibration_tixing_count"];
}



- (void)changeMyActive:(NSNotification*)notification
{
    if ([notification.userInfo[@"active"] intValue] == 2) {
        [DataStoreManager reSetMyAction:YES];
    }else
    {
        [DataStoreManager reSetMyAction:NO];
    }
}
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

//声音
-(BOOL)isSoundOpen
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"]intValue]==1) {
             return YES;
        }else{
             return NO;
        }
    }else{
        return YES;
    }
}
//震动
-(BOOL)isVibrationopen
{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"])
    {
        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"]intValue]==1) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}
//设置声音或者震动
-(void)setSoundOrVibrationopen
{
    BOOL isVibrationopen=[self isVibrationopen];;
    BOOL isSoundOpen = [self isSoundOpen];
    if (isSoundOpen) {
        [SoundSong soundSong];
    }
    if (isVibrationopen) {
        [VibrationSong vibrationSong];
    }
}

//根据类型保存消息
-(void)storeNewMessage:(NSDictionary *)messageContent
{

    NSString * type = KISDictionaryHaveKey(messageContent, @"msgType")?KISDictionaryHaveKey(messageContent, @"msgType"):@"notype";
    if ([GameCommon isEmtity:KISDictionaryHaveKey(messageContent, @"msgId")]) {
        return;
    }
    else if([type isEqualToString:@"recommendfriend"])//好友推荐
    {
        [self setSoundOrVibrationopen];
        [DataStoreManager storeNewMsgs:messageContent senderType:RECOMMENDFRIEND];//好友推荐
    }
    else if([type isEqualToString:@"dailynews"])//每日一闻
    {
        [self setSoundOrVibrationopen];
        [DataStoreManager storeNewMsgs:messageContent senderType:DAILYNEWS];
        
    }else if ([type isEqualToString:@"character"] || [type isEqualToString:@"pveScore"]
              || [type isEqualToString:@"title"])//头衔，角色，战斗力
    {
        [self setSoundOrVibrationopen];
        [DataStoreManager storeNewMsgs:messageContent senderType:OTHERMESSAGE];//其他消息
    }
    else if ([type isEqualToString:@"joinGroupApplication"]
             ||[type isEqualToString:@"joinGroupApplicationAccept"]
             ||[type isEqualToString:@"joinGroupApplicationReject"]
             ||[type isEqualToString:@"groupApplicationUnderReview"]
             ||[type isEqualToString:@"groupApplicationAccept"]
             ||[type isEqualToString:@"groupApplicationReject"]
             ||[type isEqualToString:@"groupLevelUp"]//群等级提升
             ||[type isEqualToString:@"friendJoinGroup"]//群组消息
             ||[type isEqualToString:@"groupUsershipTypeChange"]//群成员身份变化
             ||[type isEqualToString:@"kickOffGroup"]//被踢出群的消息
             ||[type isEqualToString:@"groupRecommend"]//群推荐
             ||[type isEqualToString:@"disbandGroup"])//解散群
    {
        [self setSoundOrVibrationopen];
        [DataStoreManager storeNewMsgs:messageContent senderType:JOINGROUPMSG];//其他消息
    }
}
#pragma mark 收到新闻消息
-(void)dailynewsReceived:(NSDictionary * )messageContent
{
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    if ([DataStoreManager savedNewsMsgWithID:msgId]) {
        return;
    }
    [self storeNewMessage:messageContent];
    [DataStoreManager saveDSNewsMsgs:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsMessage object:nil userInfo:messageContent];
}
#pragma mark --收到与我相关动态消息
-(void)newdynamicAboutMe:(NSDictionary *)messageContent;
{
    int index=1;
    MyTask *task = [[MyTask alloc]initWithTarget:self selector:@selector(saveaboutMeMessage:)object:messageContent];
    task.operationId=index++;
    if ([[queuenormal operations] count]>0) {
        MyTask *theBeforeTask=[[queuenormal operations] lastObject];
        [task addDependency:theBeforeTask];
    }
    [queuenormal addOperation:task];
    
}
-(void)saveaboutMeMessage:(NSDictionary *)messageContent{
    [self performSelectorOnMainThread:@selector(sendAboutMeNSNotification:) withObject:messageContent waitUntilDone:YES];
}
-(void)sendAboutMeNSNotification:(NSDictionary *)messageContent
{
    [DataStoreManager saveDynamicAboutMe:messageContent];
}

#pragma mark 收到聊天消息
-(void)newMessageReceived:(NSDictionary *)messageContent
{
    NSString * sender = [messageContent objectForKey:@"sender"];
    if ([DataStoreManager isBlack:sender]) {
        NSLog(@"黑名单用户 不作操作");
        return;
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
    [self setSoundOrVibrationopen];
    [self sendNSNotification:messageContent];
    
//    NSInvocationOperation *task = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(saveNormalChatMessage:)object:messageContent];
//    [queuenormal addOperation:task];
}

-(void)saveNormalChatMessage:(NSDictionary *)messageContent{
    [self performSelectorOnMainThread:@selector(sendNSNotification:) withObject:messageContent waitUntilDone:YES];
}
-(void)sendNSNotification:(NSDictionary *)messageContent
{
    [DataStoreManager storeNewNormalChatMsgs:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}

#pragma mark 收到群组聊天消息
-(void)newGroupMessageReceived:(NSDictionary *)messageContent
{
    if ([[GameCommon getMsgSettingStateByGroupId:[messageContent objectForKey:@"groupId"]] isEqualToString:@"0"]) {//正常模式
        [self setSoundOrVibrationopen];
    }
    [messageContent setValue:@"1" forKey:@"sayHiType"];

    [self sendGroupNSNotification:messageContent];
//    NSInvocationOperation *task = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(saveGroupChatMessage:)object:messageContent];
//    [queuegroup addOperation:task];
}

-(void)saveGroupChatMessage:(NSDictionary *)messageContent{
    [self performSelectorOnMainThread:@selector(sendGroupNSNotification:) withObject:messageContent waitUntilDone:YES];
}
-(void)sendGroupNSNotification:(NSDictionary *)messageContent
{
    [DataStoreManager storeNewGroupMsgs:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}

#pragma mark 申请加入群消息
-(void)JoinGroupMessageReceived:(NSDictionary *)messageContent
{
    NSString* msgType = KISDictionaryHaveKey(messageContent, @"msgType");
    NSString* payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(messageContent, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    if ([msgType isEqualToString:@"disbandGroup"])
    {//解散群
        NSDictionary * dic = @{@"groupId":groupId};
        [self changGroupMessageReceived:messageContent];
        [DataStoreManager deleteJoinGroupApplicationByGroupId:groupId];//删除群通知
        [DataStoreManager deleteGroupMsgWithSenderAndSayType:groupId];//删除历史记录
        [DataStoreManager deleteThumbMsgWithGroupId:groupId];//删除回话列表该群的消息
        [[GroupManager singleton] changGroupState:groupId GroupState:@"1" GroupShipType:@"3"];//改变本地群的状态
        [[NSNotificationCenter defaultCenter] postNotificationName:kDisbandGroup object:nil userInfo:dic];
    }
    if ([msgType isEqualToString:@"kickOffGroup"])
    {//被T出该群
        NSDictionary * dic = @{@"groupId":groupId,@"state":@"2"};
        [DataStoreManager deleteGroupMsgWithSenderAndSayType:groupId];//删除历史记录
        [DataStoreManager deleteJoinGroupApplicationByGroupId:groupId];//删除群通知
        [DataStoreManager deleteThumbMsgWithGroupId:groupId];//删除回话列表该群的消息
        [[GroupManager singleton] changGroupState:groupId GroupState:@"2" GroupShipType:@"3"];//改变本地群的状态
        [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffGroupGroup object:nil userInfo:dic];
    }
    if ([msgType isEqualToString:@"joinGroupApplicationAccept"])
    {//入群申请通过
        NSDictionary * dic = @{@"groupId":groupId,@"state":@"0"};
        [[GroupManager singleton] changGroupState:groupId GroupState:@"0" GroupShipType:@"0"];
        [[NSNotificationCenter defaultCenter]postNotificationName:kKickOffGroupGroup object:nil userInfo:dic];
    }
    [self storeNewMessage:messageContent];
    [DataStoreManager saveDSGroupApplyMsg:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJoinGroupMessage object:nil userInfo:messageContent];
}

#pragma mark 群组公告消息
-(void)groupBillBoardMessageReceived:(NSDictionary *)messageContent
{
    [DataStoreManager saveDSGroupApplyMsg:messageContent];
    [[NSNotificationCenter defaultCenter]postNotificationName:Billboard_msg object:nil userInfo:messageContent];
    if (![[NSUserDefaults standardUserDefaults]objectForKey: Billboard_msg_count]) {
        int i=1;
        [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:Billboard_msg_count];
    }else{
        int i =[[[NSUserDefaults standardUserDefaults]objectForKey: Billboard_msg_count]intValue];
        [[NSUserDefaults standardUserDefaults]setObject:@(i+1) forKey:Billboard_msg_count];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];

}
#pragma mark 加入群，退出群，解散群
-(void)changGroupMessageReceived:(NSDictionary *)messageContent
{
    NSString* payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(messageContent, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    if ([DataStoreManager isHasdGroMsg:msgId]) {
        return;
    }
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [messageContent setValue:groupId forKey:@"groupId"];
    [DataStoreManager saveDSGroupMsg:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}
#pragma mark 收到验证好友请求消息
-(void)newAddReq:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
    [self storeNewMessage:userInfo];
    [DataStoreManager changshiptypeWithUserId:fromUser type:shiptype];
    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendHelloReceived object:nil userInfo:userInfo];
}

#pragma mark 收到取消关注 删除好友请求消息
-(void)deletePersonReceived:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
    [self storeNewMessage:userInfo];
    
    [DataStoreManager changshiptypeWithUserId:fromUser type:shiptype];
     DSuser *dUser = [DataStoreManager getInfoWithUserId:fromUser];
    [DataStoreManager cleanIndexWithNameIndex:dUser.nameIndex withType:@"1"];

    [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteAttention object:nil userInfo:userInfo];
}

#pragma mark - 头衔、角色、战斗力变化等消息
-(void)otherMessageReceived:(NSDictionary *)info
{
    [info setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:info];
    
    [DataStoreManager saveOtherMsgsWithData:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOtherMessage object:nil userInfo:info];
}

#pragma mark 收到推荐好友消息
-(void)recommendFriendReceived:(NSDictionary *)info
{
    [info setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:info];//保存消息
    
    NSArray* recommendArr = [KISDictionaryHaveKey(info, @"msg") JSONValue];
    for (NSDictionary* tempDic in recommendArr) {
        [DataStoreManager saveRecommendWithData:tempDic];
    }
}

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

@end
