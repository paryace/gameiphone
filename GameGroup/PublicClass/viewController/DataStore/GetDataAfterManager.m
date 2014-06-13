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
@implementation GetDataAfterManager

static GetDataAfterManager *my_getDataAfterManager = NULL;

- (id)init
{
    self = [super init];
    if (self) {
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
//根据类型保存消息
-(void)storeNewMessage:(NSDictionary *)messageContent
{
    BOOL isVibrationopen=[self isVibrationopen];;
    BOOL isSoundOpen = [self isSoundOpen];
    if (isSoundOpen) {
        [SoundSong soundSong];
    }
    if (isVibrationopen) {
        [VibrationSong vibrationSong];
    }
    
    NSString * type = KISDictionaryHaveKey(messageContent, @"msgType");
    type = type?type:@"notype";
    NSString * msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    if ([GameCommon isEmtity:msgId]) {
        return;
    }
    
    if([type isEqualToString:@"normalchat"])//正常聊天
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:COMMONUSER];//普通聊天消息
    }
    else if ([type isEqualToString:@"sayHello"] || [type isEqualToString:@"deletePerson"])//加好友或者删除好友
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:SAYHELLOS];//关注和取消关注
    }
    else if([type isEqualToString:@"recommendfriend"])//好友推荐
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:RECOMMENDFRIEND];//好友推荐
    }
    else if([type isEqualToString:@"dailynews"])//每日一闻
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:DAILYNEWS];
        
    }else if ([type isEqualToString:@"character"] || [type isEqualToString:@"pveScore"]
              || [type isEqualToString:@"title"])//头衔，角色，战斗力
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:OTHERMESSAGE];//其他消息
    }
    else if ([type isEqualToString:@"groupchat"])//群组消息
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:GROUPMSG];//其他消息
    }
    else if ([type isEqualToString:@"joinGroupApplication"])//群组消息
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:JOINGROUPMSG];//其他消息
    }
    else if ([type isEqualToString:@"joinGroupApplication"]
             ||[type isEqualToString:@"joinGroupApplicationAccept"]
             ||[type isEqualToString:@"joinGroupApplicationReject"]
             
             ||[type isEqualToString:@"groupApplicationUnderReview"]
             ||[type isEqualToString:@"groupApplicationAccept"]
             ||[type isEqualToString:@"groupApplicationReject"]
             ||[type isEqualToString:@"groupLevelUp"]//群等级提升
             ||[type isEqualToString:@"groupBillboard"]//群公告
             ||[type isEqualToString:@"friendJoinGroup"]//群组消息
             ||[type isEqualToString:@"disbandGroup"])//解散群
    {
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
    [DataStoreManager saveDynamicAboutMe:messageContent];
}

#pragma mark 收到聊天消息
-(void)newMessageReceived:(NSDictionary *)messageContent
{
     NSString * sender = [messageContent objectForKey:@"sender"];
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");

    if ([DataStoreManager savedMsgWithID:msgId]) {
        return;
    }
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
    [self storeNewMessage:messageContent];//保存消息
    [DataStoreManager saveDSCommonMsg:messageContent];
    
    if (![DataStoreManager ifHaveThisUserInUserManager:sender]) {
        [[UserManager singleton]requestUserFromNet:sender];
    }else{//更新消息表
        NSDictionary* user=[[UserManager singleton] getUser:sender];
        [DataStoreManager storeThumbMsgUser:sender nickName:KISDictionaryHaveKey(user, @"nickname") andImg:KISDictionaryHaveKey(user,@"img")];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}
#pragma mark 收到群聊天消息
-(void)newGroupMessageReceived:(NSDictionary *)messageContent
{
    NSString * sender = [messageContent objectForKey:@"sender"];
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    
    if ([DataStoreManager isHasdGroMsg:msgId]) {
        return;
    }
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:messageContent];
    [DataStoreManager saveDSGroupMsg:messageContent];
    
    if (![DataStoreManager ifHaveThisUserInUserManager:sender]) {
        [[UserManager singleton]requestUserFromNet:sender];
    }else{//更新消息表
        NSDictionary* user=[[UserManager singleton] getUser:sender];
        [DataStoreManager storeThumbMsgUser:sender nickName:KISDictionaryHaveKey(user, @"nickname") andImg:KISDictionaryHaveKey(user,@"img")];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}
#pragma mark 申请加入群消息
-(void)JoinGroupMessageReceived:(NSDictionary *)messageContent
{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:messageContent];
    [DataStoreManager saveDSGroupApplyMsg:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kJoinGroupMessage object:nil userInfo:messageContent];
}
#pragma mark 加入群，退出群，解散群
-(void)changGroupMessageReceived:(NSDictionary *)messageContent
{
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    if ([DataStoreManager isHasdGroMsg:msgId]) {
        return;
    }
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:messageContent];
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
//            NSRange range = [[info objectForKey:@"sender"] rangeOfString:@"@"];
//            NSString * sender = [[info objectForKey:@"sender"] substringToIndex:range.location];
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
