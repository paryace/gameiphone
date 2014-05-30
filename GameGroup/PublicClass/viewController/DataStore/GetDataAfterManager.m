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

-(void)storeNewMessage:(NSDictionary *)messageContent
{
    BOOL isVibrationopen=[self isVibrationopen];;
    BOOL isSoundOpen = [self isSoundOpen];
    
    NSLog(@"messageContent==%@",messageContent);
    NSString * type = KISDictionaryHaveKey(messageContent, @"msgType");
    type = type?type:@"notype";
    NSLog(@"%@",type);
    
    if([type isEqualToString:@"normalchat"])
    {
        NSLog(@"%@",KISDictionaryHaveKey(messageContent, @"msgId"));
        if (isSoundOpen) {
             [SoundSong soundSong];
        }
        if (isVibrationopen) {
            [VibrationSong vibrationSong];
        }
        [DataStoreManager storeNewMsgs:messageContent senderType:COMMONUSER];//普通聊天消息
    }
    else if([type isEqualToString:@"payloadchat"])
    {
        if (isSoundOpen) {
            [SoundSong soundSong];
        }
        if (isVibrationopen) {
            [VibrationSong vibrationSong];
        }

        [DataStoreManager storeNewMsgs:messageContent senderType:PAYLOADMSG];//动态消息
    }
    else if ([type isEqualToString:@"sayHello"] || [type isEqualToString:@"deletePerson"])
    {
        if (isSoundOpen) {
            [SoundSong soundSong];
        }
        if (isVibrationopen) {
            [VibrationSong vibrationSong];
        }

        [DataStoreManager storeNewMsgs:messageContent senderType:SAYHELLOS];//关注和取消关注
    }
    else if([type isEqualToString:@"recommendfriend"])
    {
        if (isSoundOpen) {
            [SoundSong soundSong];
        }
        if (isVibrationopen) {
            [VibrationSong vibrationSong];
        }
        [DataStoreManager storeNewMsgs:messageContent senderType:RECOMMENDFRIEND];//好友推荐
    }
    else if([type isEqualToString:@"dailynews"])
    {
        NSLog(@"%@",KISDictionaryHaveKey(messageContent, @"msgId"));
        if ([DataStoreManager savedNewsMsgWithID:KISDictionaryHaveKey(messageContent, @"msgId")]) {
            NSLog(@"消息已存在");
            return;
        }
        if (isSoundOpen) {
            [SoundSong soundSong];
        }
        if (isVibrationopen) {
            [VibrationSong vibrationSong];
        }

        [DataStoreManager storeNewMsgs:messageContent senderType:DAILYNEWS];
    }
}
#pragma mark 收到新闻消息
-(void)dailynewsReceived:(NSDictionary * )messageContent
{
    [messageContent setValue:@"1" forKey:@"sayHiType"];
    [self storeNewMessage:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsMessage object:nil userInfo:messageContent];
}
#pragma mark --收到与我相关动态消息代理回调
-(void)newdynamicAboutMe:(NSDictionary *)messageContent;
{
    NSLog(@"messageContent%@",messageContent);
    [DataStoreManager saveDynamicAboutMe:messageContent];
}

#pragma mark 收到聊天消息代理回调
-(void)newMessageReceived:(NSDictionary *)messageContent
{
    NSRange range = [[messageContent objectForKey:@"sender"] rangeOfString:@"@"];
    NSString * sender = [[messageContent objectForKey:@"sender"] substringToIndex:range.location];
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    
//    if ([DataStoreManager savedMsgWithID:msgId]) {
//        NSLog(@"消息已存在");
//        return;
//    }
    if ([DataStoreManager isHaveMsgOnDb:msgId]) {
        NSLog(@"消息已存在");
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
    if (![DataStoreManager ifHaveThisUserInUserManager:sender]) {
        [[UserManager singleton]requestUserFromNet:sender];
    }else{//更新消息表
        NSDictionary* user=[[UserManager singleton] getUser:sender];
        [DataStoreManager storeThumbMsgUser:sender nickName:KISDictionaryHaveKey(user, @"nickname") andImg:KISDictionaryHaveKey(user,@"img")];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
}



#pragma mark 收到验证好友请求代理回调
-(void)newAddReq:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSRange range = [fromUser rangeOfString:@"@"];
    fromUser = [fromUser substringToIndex:range.location];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
  //  NSString * msg = KISDictionaryHaveKey(userInfo, @"msg");
    [self storeNewMessage:userInfo];
   // NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [DataStoreManager changshiptypeWithUserId:fromUser type:shiptype];

    if ([shiptype isEqualToString:@"1"]) {//成为好友
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
    }
   else if([shiptype isEqualToString:@"2"])//粉丝
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"1"];
    }
   else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendHelloReceived object:nil userInfo:userInfo];
}

#pragma mark 收到取消关注 删除好友请求代理回调
-(void)deletePersonReceived:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSRange range = [fromUser rangeOfString:@"@"];
    fromUser = [fromUser substringToIndex:range.location];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
  //  NSString * msg = KISDictionaryHaveKey(userInfo, @"msg");
    
    [self storeNewMessage:userInfo];
   // NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:1];
    [DataStoreManager changshiptypeWithUserId:fromUser type:shiptype];
    
    
    DSuser *dUser = [DataStoreManager getInfoWithUserId:fromUser];
    [DataStoreManager cleanIndexWithNameIndex:dUser.nameIndex withType:@"1"];


    if ([shiptype isEqualToString:@"2"]) {//移到关注表
//            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
    }
    else if ([shiptype isEqualToString:@"unkown"])
    {

            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteAttention object:nil userInfo:userInfo];
}

#pragma mark - 其他消息 头衔、角色等代理回调
-(void)otherMessageReceived:(NSDictionary *)info
{
//    BOOL isVibrationopen;
//    BOOL isSoundOpen;
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"])
//    {
//        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_sound_tixing_count"]intValue]==1) {
//            isSoundOpen =YES;
//        }else{
//            isSoundOpen =NO;
//        }
//    }else{
//        isSoundOpen =YES;
//    }
//    
//    if ([[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"])
//    {
//        if ([[[NSUserDefaults standardUserDefaults]objectForKey:@"wx_Vibration_tixing_count"]intValue]==1) {
//            isVibrationopen =YES;
//        }else{
//            isVibrationopen =NO;
//        }
//    }else{
//        isVibrationopen =YES;
//    }
    BOOL isVibrationopen=[self isVibrationopen];;
    BOOL isSoundOpen = [self isSoundOpen];

    if ([DataStoreManager savedOtherMsgWithID:info[@"msgId"]]) {
        return;
    }
    NSLog(@"info%@",info);
     [info setValue:@"1" forKey:@"sayHiType"];
    [DataStoreManager storeNewMsgs:info senderType:OTHERMESSAGE];//其他消息
    [DataStoreManager saveOtherMsgsWithData:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOtherMessage object:nil userInfo:info];
    if (isSoundOpen) {
        [SoundSong soundSong];
    }
    if (isVibrationopen) {
        [VibrationSong vibrationSong];
    }

}

#pragma mark 收到推荐好友代理回调
-(void)recommendFriendReceived:(NSDictionary *)info
{
    [info setValue:@"1" forKey:@"sayHiType"];

    [DataStoreManager storeNewMsgs:info senderType:RECOMMENDFRIEND];//其他消息
    NSArray* recommendArr = [KISDictionaryHaveKey(info, @"msg") JSONValue];
    
    for (NSDictionary* tempDic in recommendArr) {
        [DataStoreManager saveRecommendWithData:tempDic];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecommendFriendReceived object:nil userInfo:info];
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
            NSRange range = [[info objectForKey:@"sender"] rangeOfString:@"@"];
            NSString * sender = [[info objectForKey:@"sender"] substringToIndex:range.location];
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
