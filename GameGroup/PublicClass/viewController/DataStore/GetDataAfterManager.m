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
#import "CharacterAndTitleService.h"
#define mTime 0.5

@implementation GetDataAfterManager
{
    NSOperationQueue *queuenormal;
    NSOperationQueue *queuegroup;
    NSOperationQueue *queueme ;
    
    NSTimeInterval markTime;
    NSTimeInterval markTimeGroup;
   
    int index;
    int index2;
    dispatch_queue_t queue;
    dispatch_queue_t queue2;
    
    NSTimeInterval markTimeDy;
    NSTimeInterval markTimeDyMe;
    NSTimeInterval markTimeDyGroup;
    
    int dyMsgCount;
    int dyMeMsgCount;
    int dyGroupMsgCount;
}
static GetDataAfterManager *my_getDataAfterManager = NULL;

- (id)init
{
    self = [super init];
    if (self) {
        index=1;
        index2=1;
        dyMsgCount = 0;
        dyMeMsgCount = 0;
        dyGroupMsgCount = 0;
        queuenormal = [[NSOperationQueue alloc]init];
        [queuenormal setMaxConcurrentOperationCount:1];
        queuegroup = [[NSOperationQueue alloc]init];
        [queuegroup setMaxConcurrentOperationCount:1];
        queueme = [[NSOperationQueue alloc]init];
        [queueme setMaxConcurrentOperationCount:1];
        queue = dispatch_queue_create("com.dispatch.normal", DISPATCH_QUEUE_SERIAL);
        queue2 = dispatch_queue_create("com.dispatch.group", DISPATCH_QUEUE_SERIAL);
        self.appDel = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        
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
    NSInvocationOperation *task = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(saveaboutMeMessage:)object:messageContent];
    [queueme addOperation:task];
    
}
-(void)saveaboutMeMessage:(NSDictionary *)messageContent{
    [self performSelectorOnMainThread:@selector(sendAboutMeNSNotification:) withObject:messageContent waitUntilDone:YES];
}
-(void)sendAboutMeNSNotification:(NSDictionary *)messageContent
{
    [DataStoreManager saveDynamicAboutMe:messageContent];
}
//--------------------------------------------正常聊天消息
#pragma mark 收到聊天消息
-(void)newMessageReceived:(NSDictionary *)messageContent
{

    NSString * sender = [messageContent objectForKey:@"sender"];
    if ([DataStoreManager isBlack:sender]) {
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
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTime)*100<0.03*1000) {
        markTime = [[NSDate date] timeIntervalSince1970];
        if (self.cacheMsg) {
            [self.cacheMsg addObject:messageContent];
        }
        if (![self.cellTimer isValid]) {
            if (!self.cacheMsg) {
                self.cacheMsg = [NSMutableArray array];
            }
            [self.cacheMsg addObject:messageContent];
            self.cellTimer = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(stopATime) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.cellTimer forMode:NSRunLoopCommonModes];
        }
        return;
    }
    markTime = [[NSDate date] timeIntervalSince1970];
//    dispatch_barrier_async(queue, ^{
        [DataStoreManager storeNewNormalChatMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
            [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setSoundOrVibrationopen];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
            });
        }];
//    });
}
- (void)stopATime
{
    NSMutableArray *array = [self.cacheMsg mutableCopy];
    [self.cacheMsg removeAllObjects];
    self.cacheMsg = nil;
    if ([self.cellTimer isValid]) {
        [self.cellTimer invalidate];
        self.cellTimer = nil;
    }
    NSInvocationOperation * tasknormal = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(saveNormalChatMessage:)object:array];
    if ([[queuenormal operations] count]>0) {
        [tasknormal addDependency:[[queuenormal operations] lastObject]];
    }
    [queuenormal addOperation:tasknormal];
}

-(void)saveNormalChatMessage:(NSArray *)messageContent{
   [DataStoreManager saveNewNormalChatMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
       dispatch_async(dispatch_get_main_queue(), ^{
           [self setSoundOrVibrationopen];
           [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
       });
       [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"sender") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"normal"];//反馈消息
   }];
}
//--------------------------------------------群组聊天消息
#pragma mark 收到群组聊天消息
-(void)newGroupMessageReceived:(NSDictionary *)messageContent
{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTimeGroup)*100<0.03*1000) {
        markTimeGroup = [[NSDate date] timeIntervalSince1970];
        if (self.cacheMsgGroup) {
            [self.cacheMsgGroup addObject:messageContent];
        }
        if (![self.cellTimerGroup isValid]) {
            if (!self.cacheMsgGroup) {
                self.cacheMsgGroup = [NSMutableArray array];
            }
            [self.cacheMsgGroup addObject:messageContent];
            self.cellTimerGroup = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(stopATimeGroup) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.cellTimerGroup forMode:NSRunLoopCommonModes];
        }
        return;
    }
    markTimeGroup = [[NSDate date] timeIntervalSince1970];
//    dispatch_barrier_async(queue2, ^{
        [DataStoreManager storeNewGroupMsgs:messageContent SaveSuccess:^(NSDictionary *msgDic) {
            [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"groupId") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"group"];//反馈消息
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([[GameCommon getMsgSettingStateByGroupId:[msgDic objectForKey:@"groupId"]] isEqualToString:@"0"]) {//正常模式
                    [self setSoundOrVibrationopen];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
            });
        } ];
//    });
}
- (void)stopATimeGroup
{
    NSMutableArray *array = [self.cacheMsgGroup mutableCopy];
    [self.cacheMsgGroup removeAllObjects];
    self.cacheMsgGroup = nil;
    if ([self.cellTimerGroup isValid]) {
        [self.cellTimerGroup invalidate];
        self.cellTimerGroup = nil;
    }
    NSInvocationOperation *task = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(saveGroupChatMessage:)object:array];
    if ([[queuegroup operations] count]>0) {
        [task addDependency:[[queuegroup operations] lastObject]];
    }
    [queuegroup addOperation:task];
}
-(void)saveGroupChatMessage:(NSArray *)messageContent{
    [DataStoreManager saveNewGroupChatMsg:messageContent SaveSuccess:^(NSDictionary *msgDic) {
        [self comeBackDelivered:KISDictionaryHaveKey(msgDic, @"groupId") msgId:KISDictionaryHaveKey(msgDic, @"msgId") Type:@"group"];//反馈消息
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[GameCommon getMsgSettingStateByGroupId:[msgDic objectForKey:@"groupId"]] isEqualToString:@"0"]) {//正常模式
                [self setSoundOrVibrationopen];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:msgDic];
        });
    }];
}
//--------------------------------------------群通知消息
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
//--------------------------------------------
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
//--------------------------------------------角色，头衔，战斗力变化，
#pragma mark - 头衔、角色、战斗力变化等消息
-(void)otherMessageReceived:(NSDictionary *)info
{
    [info setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:info];
    [DataStoreManager saveOtherMsgsWithData:info];
//    [[CharacterAndTitleService singleton] getCharacterInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    [[CharacterAndTitleService singleton] getTitleInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] Type:@""];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOtherMessage object:nil userInfo:info];
}
//--------------------------------------------好友推荐
#pragma mark 收到推荐好友消息
-(void)recommendFriendReceived:(NSDictionary *)info
{
    [info setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:info];//保存消息
    
    NSArray* recommendArr = [KISDictionaryHaveKey(info, @"msg") JSONValue];
    for (NSDictionary* tempDic in recommendArr) {
        [DataStoreManager saveRecommendWithData:tempDic];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecommendMessage object:nil userInfo:info];
}
//--------------------------------------------动态消息

-(void)dyMessageReceived:(NSDictionary *)info
{
    NSString * msgtype = KISDictionaryHaveKey(info, @"msgType");
    NSString * payload = KISDictionaryHaveKey(info, @"payLoad");
    if ([msgtype isEqualToString:@"frienddynamicmsg"]) {//好友动态
        [self saveDyMessage:payload];
    }
    else if ([msgtype isEqualToString:@"mydynamicmsg"])//与我相关
    {
        [self newdynamicAboutMe:[payload JSONValue]];
        [self saveAboutDyMessage:payload];
    }
    else if([msgtype isEqualToString:@"groupDynamicMsgChange"]){//群组动态
        [self saveGroupDyMessage:payload];
    }
    //未知的动态
    else
    {
        
    }
}
//---------------------------------------好友动态

-(void)saveDyMessage:(NSString *)payload
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTimeDy)*100<0.5*1000) {
        markTimeDy = [[NSDate date] timeIntervalSince1970];
        dyMsgCount++;
        if ([self.cellTimerDy isValid]) {
            [self.cellTimerDy invalidate];
            self.cellTimerDy = nil;
        }
        self.cellTimerDy = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(saveDyMsgTimer:) userInfo:payload repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.cellTimerDy forMode:NSRunLoopCommonModes];
        return;
    }
    markTimeDy = [[NSDate date] timeIntervalSince1970];
    dyMsgCount++;
    [self saveDyMsg:payload];
}
-(void)saveDyMsgTimer:(NSTimer*)timer
{
    [self saveDyMsg:timer.userInfo];
}
-(void)saveDyMsg:(NSString *)payload
{
    if ([self.cellTimerDy isValid]) {
        [self.cellTimerDy invalidate];
        self.cellTimerDy = nil;
    }
    [self saveLastFriendDynimacUserImage:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]) {
        int i =[[[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]intValue];
        i+=dyMsgCount;
        [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:@"dongtaicount_wx"];
    }else{
        int i = 0;
        i+=dyMsgCount;
        [[NSUserDefaults standardUserDefaults]setObject:@(i)forKey:@"dongtaicount_wx"];
    }
    dyMsgCount = 0;
     [[NSNotificationCenter defaultCenter] postNotificationName:@"frienddunamicmsgChange_WX" object:nil userInfo:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
}

//---------------------------------------与我相关
-(void)saveAboutDyMessage:(NSString *)payload
{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    if ((nowTime - markTimeDyMe)*100<0.5*1000) {
        markTimeDyMe = [[NSDate date] timeIntervalSince1970];
        dyMeMsgCount++;
        if ([self.cellTimerDyMe isValid]) {
            [self.cellTimerDyMe invalidate];
            self.cellTimerDyMe = nil;
        }
        self.cellTimerDyMe = [NSTimer scheduledTimerWithTimeInterval:mTime target:self selector:@selector(saveDyMeMsgTimer:) userInfo:payload repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.cellTimerDyMe forMode:NSRunLoopCommonModes];
        return;
    }
    markTimeDyMe = [[NSDate date] timeIntervalSince1970];
    dyMeMsgCount++;
    [self saveDyMeMsg:payload];
}

-(void)saveDyMeMsgTimer:(NSTimer*)timer
{
    [self saveDyMeMsg:timer.userInfo];
}

-(void)saveDyMeMsg:(NSString *)payload
{
    if ([self.cellTimerDyMe isValid]) {
        [self.cellTimerDyMe invalidate];
        self.cellTimerDyMe = nil;
    }
    [self saveLastMyDynimacUserImage:[self getMyDynimacImageInfo:[[NSString stringWithFormat:@"%@",payload] JSONValue]]];
    
    [self saveLastFriendDynimacUserImage:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey: @"mydynamicmsg_huancunCount_wx"]) {
        int i = 0;
        i+=dyMeMsgCount;
        [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:@"mydynamicmsg_huancunCount_wx"];
    }else{
        int i =[[[NSUserDefaults standardUserDefaults]objectForKey: @"mydynamicmsg_huancunCount_wx"]intValue];
        
        i+=dyMeMsgCount;
        [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:@"mydynamicmsg_huancunCount_wx"];
    }
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:haveMyNews];
    [[NSUserDefaults standardUserDefaults] synchronize];
    dyMeMsgCount=0;
    [[NSNotificationCenter defaultCenter]postNotificationName:@"mydynamicmsg_wx" object:nil userInfo:[[NSString stringWithFormat:@"%@",payload] JSONValue]];
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
    [[NSNotificationCenter defaultCenter]postNotificationName:GroupDynamic_msg object:nil userInfo:msgDic];
}
//---------------------------------------

//保存最后一条动态消息
-(NSDictionary*)getMyDynimacImageInfo:(NSDictionary*)payloadDic
{
    NSString *customObject;
    NSString *customUser;
    if ([KISDictionaryHaveKey(payloadDic, @"type")intValue]==4) {
        customObject = @"zanObject";
        customUser = @"zanUser";
    }
    else if ([KISDictionaryHaveKey(payloadDic, @"type")intValue]==5||[KISDictionaryHaveKey(payloadDic, @"type")intValue]==7)
    {
        customObject =@"commentObject";
        customUser = @"commentUser";
    }
    NSString * cusUserImageIds=KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(payloadDic, customObject),customUser), @"img");
    NSDictionary * imageDic = @{@"img":cusUserImageIds};
    return imageDic;
}
-(void)saveLastMyDynimacUserImage:(NSDictionary*)payloadDic
{
    NSMutableData *data= [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver= [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:payloadDic forKey: @"getDatat"];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"mydynamicmsg_huancun_wx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveLastFriendDynimacUserImage:(NSDictionary*)payloadDic
{
    NSMutableData *data= [[NSMutableData alloc]init];
    NSKeyedArchiver *archiver= [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:payloadDic forKey: @"getDatat"];
    [archiver finishEncoding];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"frienddynamicmsg_huancun_wx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

@end
