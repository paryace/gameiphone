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
@implementation GetDataAfterManager

static GetDataAfterManager *my_getDataAfterManager = NULL;

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeMyActive:) name:@"wxr_myActiveBeChanged" object:nil];
    }
    return self;
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

-(void)storeNewMessage:(NSDictionary *)messageContent
{
    NSLog(@"messageContent==%@",messageContent);
    NSString * type = KISDictionaryHaveKey(messageContent, @"msgType");
    type = type?type:@"notype";
    NSLog(@"%@",type);
    if([type isEqualToString:@"normalchat"])
    {
        NSLog(@"%@",KISDictionaryHaveKey(messageContent, @"msgId"));
        [SoundSong soundSong];
        [DataStoreManager storeNewMsgs:messageContent senderType:COMMONUSER];//普通聊天消息
    }
    else if([type isEqualToString:@"payloadchat"])
    {
        [SoundSong soundSong];
        [DataStoreManager storeNewMsgs:messageContent senderType:PAYLOADMSG];//动态消息
    }
    else if ([type isEqualToString:@"sayHello"] || [type isEqualToString:@"deletePerson"])//关注和取消关注
    {
        [SoundSong soundSong];;
        
        [DataStoreManager storeNewMsgs:messageContent senderType:SAYHELLOS];//打招呼消息
    }
    else if([type isEqualToString:@"recommendfriend"])
    {
        [DataStoreManager storeNewMsgs:messageContent senderType:RECOMMENDFRIEND];
    }
    else if([type isEqualToString:@"dailynews"])
    {
        NSLog(@"%@",KISDictionaryHaveKey(messageContent, @"msgId"));
        if ([DataStoreManager savedNewsMsgWithID:KISDictionaryHaveKey(messageContent, @"msgId")]) {
            NSLog(@"消息已存在");
            return;
        }
        [SoundSong soundSong];
        [DataStoreManager storeNewMsgs:messageContent senderType:DAILYNEWS];
    }
}
#pragma mark 收到新闻消息
-(void)dailynewsReceived:(NSDictionary * )messageContent
{
    [self storeNewMessage:messageContent];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNewsMessage object:nil userInfo:messageContent];
}
#pragma mark 收到聊天消息
-(void)newMessageReceived:(NSDictionary *)messageContent
{
    NSRange range = [[messageContent objectForKey:@"sender"] rangeOfString:@"@"];
    NSString * sender = [[messageContent objectForKey:@"sender"] substringToIndex:range.location];
    NSString* msgId = KISDictionaryHaveKey(messageContent, @"msgId");
    
    
    if ([DataStoreManager savedMsgWithID:KISDictionaryHaveKey(messageContent, @"msgId")]) {
        NSLog(@"消息已存在");
        return;
    }
    [self storeNewMessage:messageContent];
    [self.xmppHelper comeBackDelivered:sender msgId:msgId];
    
    
    if (![DataStoreManager ifHaveThisUserInUserManager:sender]) {
        [self requestPeopleInfoWithName:sender ForType:1 Msg:nil userInfo:messageContent];
    }
    else
    {
        [DataStoreManager storeThumbMsgUser:sender nickName:[DataStoreManager queryRemarkNameForUserManager:sender] andImg:[DataStoreManager queryFirstHeadImageForUser_userManager:sender]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];
    }
}



#pragma mark 收到验证好友请求
-(void)newAddReq:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSRange range = [fromUser rangeOfString:@"@"];
    fromUser = [fromUser substringToIndex:range.location];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
    NSString * msg = KISDictionaryHaveKey(userInfo, @"msg");
    
    [self storeNewMessage:userInfo];
    NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:1];
    
    if ([shiptype isEqualToString:@"1"]) {//成为好友

            [tempDic addEntriesFromDictionary:[DataStoreManager addPersonToReceivedHellosWithAttention:fromUser]];
            [tempDic setObject:fromUser forKey:@"fromUser"];
            [tempDic setObject:msg forKey:@"addtionMsg"];
            [DataStoreManager addPersonToReceivedHellos:tempDic];
            [DataStoreManager saveUserFriendWithAttentionList:fromUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];

            [DataStoreManager deleteAttentionWithUserName:fromUser];//从关注表删除
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];

    }
    else if([shiptype isEqualToString:@"3"])//粉丝
    {
        
    }
    else
    {
        
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kFriendHelloReceived object:nil userInfo:userInfo];
}

#pragma mark 收到取消关注 删除好友请求
-(void)deletePersonReceived:(NSDictionary *)userInfo
{
    NSString * fromUser = [userInfo objectForKey:@"sender"];
    NSRange range = [fromUser rangeOfString:@"@"];
    fromUser = [fromUser substringToIndex:range.location];
    NSString * shiptype = KISDictionaryHaveKey(userInfo, @"shiptype");
    NSString * msg = KISDictionaryHaveKey(userInfo, @"msg");
    
    [self storeNewMessage:userInfo];
    NSMutableDictionary* tempDic = [NSMutableDictionary dictionaryWithCapacity:1];
    if ([shiptype isEqualToString:@"2"]) {//移到关注表
            [tempDic addEntriesFromDictionary:[DataStoreManager addPersonToReceivedHellosWithFriend:fromUser]];
            [tempDic setObject:fromUser forKey:@"fromUser"];
            [tempDic setObject:msg forKey:@"addtionMsg"];
            [DataStoreManager addPersonToReceivedHellos:tempDic];
            [DataStoreManager saveUserAttentionWithFriendList:fromUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"1"];
            [DataStoreManager deleteFriendWithUserId:fromUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
    }
    else if ([shiptype isEqualToString:@"unkown"])
    {

            [tempDic addEntriesFromDictionary:[DataStoreManager addPersonToReceivedHellosWithFans:fromUser]];
            [tempDic setObject:fromUser forKey:@"fromUser"];
            [tempDic setObject:msg forKey:@"addtionMsg"];
            [DataStoreManager addPersonToReceivedHellos:tempDic];
            
            [[GameCommon shareGameCommon] fansCountChanged:NO];
            [DataStoreManager deleteFansWithUserid:fromUser];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];
//            [self displayMsgsForDefaultView];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kDeleteAttention object:nil userInfo:userInfo];
}

#pragma mark - 其他消息 头衔、角色等
-(void)otherMessageReceived:(NSDictionary *)info
{
    if ([DataStoreManager savedOtherMsgWithID:info[@"msgId"]]) {
        return;
    }
    NSLog(@"info%@",info);
    [DataStoreManager storeNewMsgs:info senderType:OTHERMESSAGE];//其他消息
    [DataStoreManager saveOtherMsgsWithData:info];
    [[NSNotificationCenter defaultCenter] postNotificationName:kOtherMessage object:nil userInfo:info];
    [SoundSong soundSong];
}

#pragma mark 收到推荐好友
-(void)recommendFriendReceived:(NSDictionary *)info
{
    [DataStoreManager storeNewMsgs:info senderType:RECOMMENDFRIEND];//其他消息
    NSArray* recommendArr = [KISDictionaryHaveKey(info, @"msg") JSONValue];
    
    for (NSDictionary* tempDic in recommendArr) {
        [DataStoreManager saveRecommendWithData:tempDic];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kRecommendFriendReceived object:nil userInfo:info];
}

-(void)requestPeopleInfoWithName:(NSString *)userid ForType:(int)type Msg:(NSString *)msg userInfo:(NSDictionary*)messageContent
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userid forKey:@"userid"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"106" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary * recDict = KISDictionaryHaveKey(responseObject, @"user");
        if ([KISDictionaryHaveKey(responseObject, @"title") isKindOfClass:[NSArray class]] && [KISDictionaryHaveKey(responseObject, @"title") count] != 0) {//头衔
            [recDict setObject:[KISDictionaryHaveKey(responseObject, @"title") objectAtIndex:0] forKey:@"title"];
        }
                [DataStoreManager saveAllUserWithUserManagerList:recDict];
        
        
        NSString* nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"alias")];
        if ([nickName isEqualToString:@""]) {
            nickName = KISDictionaryHaveKey(recDict, @"nickname");
        }
        [DataStoreManager storeThumbMsgUser:userid nickName:nickName andImg:[GameCommon getHeardImgId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(recDict, @"img")]]];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNewMessageReceived object:nil userInfo:messageContent];

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}



#pragma mark --获取你和谁说过话
-(void)getSayHiUserIdWithNetGetArray:(NSMutableArray *)array
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"" forKey:@"touserid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"154" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"sayHello_wx_info_id"];
        
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [array addObjectsFromArray:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
        
    }];
    
}

@end
