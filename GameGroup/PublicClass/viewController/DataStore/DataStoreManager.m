//
//  DataStoreManager.m
//  PetGroup
//
//  Created by Tolecen on 13-8-15.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "DataStoreManager.h"
#import "MagicalRecord.h"
#import "DSuser.h"
#import "UserManager.h"
#import "DSCircleWithMe.h"
#import "DSOfflineComments.h"
#import "DSCharacters.h"
#import "DSTitle.h"
#import "DSTitleObject.h"
#import "DSGroupMsgs.h"
#import "DSGroupList.h"
#import "DSGroupApplyMsg.h"
#import "DSGroupUser.h"
#import "DSLatestDynamic.h"

@implementation DataStoreManager
-(void)nothing
{}
+ (void)reSetMyAction:(BOOL)action
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    DSuser *dUser = [DSuser MR_findFirstWithPredicate:predicate];
    dUser.action = [NSNumber numberWithBool:action];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
}

+(void)setDefaultDataBase:(NSString *)dataBaseName AndDefaultModel:(NSString *)modelName
{
    [MagicalRecord cleanUp];
    [MagicalRecord setDefaultModelNamed:[NSString stringWithFormat:@"%@.momd",modelName]];
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:[NSString stringWithFormat:@"%@.sqlite",dataBaseName]];
}

+ (BOOL)savedMsgWithID:(NSString*)msgId//正常聊天消息是否已存
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",msgId];
    DSCommonMsgs * msg = [DSCommonMsgs MR_findFirstWithPredicate:predicate];
    if (msg)
    {
        return YES;
    }
    return NO;
}
+ (BOOL)isHasdGroMsg:(NSString*)msgId//群组聊天消息是否已存
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",msgId];
    DSGroupMsgs * msg = [DSGroupMsgs MR_findFirstWithPredicate:predicate];
    if (msg)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)savedOtherMsgWithID:(NSString *)msgID//其他消息是否存在
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",msgID];
    DSOtherMsgs * msg = [DSOtherMsgs MR_findFirstWithPredicate:predicate];
    if (msg)
    {
        return YES;
    }
    return NO;
}

+ (BOOL)savedNewsMsgWithID:(NSString*)msgId//每日一闻消息是否已存
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",msgId];
    DSNewsMsgs * msg = [DSNewsMsgs MR_findFirstWithPredicate:predicate];
    if (msg)
    {
        return YES;
    }
    return NO;
}
#pragma mark - 会话列表界面 - thumbMsg
+(void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            thumbMsgs.senderNickname = nickName;
            thumbMsgs.senderimg = img;
        }
    }];
}

+(void)storeThumbMsgUser:(NSString*)userid type:(NSString*)type
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType=[c]%@",userid,@"normalchat"];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            thumbMsgs.sayHiType = type;
        }
    }];
}




+(void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            thumbMsgs.senderNickname = nickName;
        }
    }];
}

+(void)deleteAllThumbMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * thumbMsgs = [DSThumbMsgs MR_findAllInContext:localContext];
        for (DSThumbMsgs* msg in thumbMsgs) {
            [msg deleteInContext:localContext];
        }
    }];
}
//------
+(void)deleteAllDSCommonMsgs
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * comonMsgs = [DSCommonMsgs MR_findAllInContext:localContext];
        for (DSCommonMsgs* msg in comonMsgs) {
            [msg deleteInContext:localContext];
        }
    }];
}
//-----
+(void)deleteThumbMsgWithSender:(NSString *)sender
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs) {
            [thumbMsgs MR_deleteInContext:localContext];
        }
    }];
}


+(void)deleteThumbMsgWithGroupId:(NSString *)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs) {
            [thumbMsgs MR_deleteInContext:localContext];
        }
    }];
}
+(void)deleteSayHiMsgWithSenderAndSayType:(NSString *)senderType SayHiType:(NSString*)sayHiType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"senderType==[c]%@ and sayHiType==[c]%@",senderType,sayHiType];
        NSArray * thumbMsg = [DSThumbMsgs MR_findAllWithPredicate:predicate];
        for (int i = 0; i<thumbMsg.count; i++) {
            DSThumbMsgs * thumb = [thumbMsg objectAtIndex:i];
            [thumb MR_deleteInContext:localContext];
        }
    }];
}
//删除该群消息记录
+(void)deleteGroupMsgWithSenderAndSayType:(NSString *)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ ",groupId];
        NSArray * thumbMsg = [DSGroupMsgs MR_findAllWithPredicate:predicate];
        for (int i = 0; i<thumbMsg.count; i++) {
            DSGroupMsgs * thumb = [thumbMsg objectAtIndex:i];
            [thumb MR_deleteInContext:localContext];
        }
    }];
}
//删除群组通知的显示消息
+(void)deleteJoinGroupApplication
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",GROUPAPPLICATIONSTATE];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }];
}

//根据msgType删除通知表的消息
+(void)deleteJoinGroupApplicationByMsgType:(NSString*)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgType==[c]%@ ",msgType];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }];
}
//根据msgId删除通知表的消息
+(void)deleteJoinGroupApplicationWithMsgId:(NSString *)msgId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgId==[c]%@ ",msgId];
        DSGroupApplyMsg * dGroup = [DSGroupApplyMsg MR_findFirstWithPredicate:predicateApp];
        if (dGroup) {
            [dGroup MR_deleteInContext:localContext];
        }
    }];
}
//清空群组通知
+(void)clearJoinGroupApplicationMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgType!=[c]%@ ",@"groupBillboard"];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }];
}

//根据msgType和GroupId删除通知表的消息
+(void)deleteJoinGroupApplicationByMsgTypeAndGroupId:(NSString*)msgType GroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgType==[c]%@ and groupId=[c]%@",msgType,groupId];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }];
}

//根据GroupId删除通知表的消息
+(void)deleteJoinGroupApplicationByGroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"groupId=[c]%@",groupId];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }];
}



#pragma mark - 保存聊天记录
+(void)saveDSCommonMsg:(NSDictionary *)msg
{
    NSString * sender = [msg objectForKey:@"sender"];
    NSString * msgContent = KISDictionaryHaveKey(msg, @"msg");
    NSString * msgType = KISDictionaryHaveKey(msg, @"msgType");
    NSString * msgId = KISDictionaryHaveKey(msg, @"msgId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];//所有消息
        commonMsg.sender = sender;
        commonMsg.msgContent = msgContent?msgContent:@"";
        commonMsg.senTime = sendTime;
        commonMsg.msgType = msgType;
        commonMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        commonMsg.messageuuid = msgId;
        commonMsg.status = @"1";
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }];
}

#pragma mark - 保存群组聊天记录
+(void)saveDSGroupMsg:(NSDictionary *)msg
{
    NSString * sender = [msg objectForKey:@"sender"];
    NSString * msgContent = KISDictionaryHaveKey(msg, @"msg");
    NSString * msgType = KISDictionaryHaveKey(msg, @"msgType");
    NSString * msgId = KISDictionaryHaveKey(msg, @"msgId");
    NSString * groupId = KISDictionaryHaveKey(msg, @"groupId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSGroupMsgs * groupMsg = [DSGroupMsgs MR_createInContext:localContext];
        groupMsg.sender = sender;
        groupMsg.msgContent = msgContent?msgContent:@"";
        groupMsg.senTime = sendTime;
        groupMsg.msgType = msgType;
        groupMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        groupMsg.messageuuid = msgId;
        groupMsg.status = @"1";//状态5表示未读吧
        groupMsg.groupId = groupId;
        groupMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }];
}
#pragma mark - 存储消息相关
+(void)storeNewMsgs:(NSDictionary *)msg senderType:(NSString *)sendertype
{
    NSString * sender = [msg objectForKey:@"sender"];
    NSString * msgContent = KISDictionaryHaveKey(msg, @"msg");
    NSString * msgType = KISDictionaryHaveKey(msg, @"msgType");
    NSString * msgId = KISDictionaryHaveKey(msg, @"msgId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    NSString *sayhiType = KISDictionaryHaveKey(msg, @"sayHiType")?KISDictionaryHaveKey(msg, @"sayHiType"):@"1";
    
    //普通用户消息存储到DSCommonMsgs和DSThumbMsgs两个表里
    if ([sendertype isEqualToString:COMMONUSER]) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",sender,msgType];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];//消息页展示的内容
            if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = sender;
            thumbMsgs.senderNickname = @"";
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.msgType = msgType;
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = sayhiType;
            thumbMsgs.senderimg = @"";
            thumbMsgs.receiveTime=[GameCommon getCurrentTime];
                
            if ([sayhiType isEqualToString:@"2"]){//自定义一条用于显示打招呼的消息
                    NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234567wxxxxxxxxx"];
                    DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate1];
                    if (!thumbMsgs)
                    thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
                    thumbMsgs.msgContent = msgContent;//打招呼内容
                    thumbMsgs.sender = @"1234567wxxxxxxxxx";
                    thumbMsgs.senderNickname = @"";
                    thumbMsgs.senderType = sendertype;
                    int unread = [thumbMsgs.unRead intValue];
                    thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
                    thumbMsgs.msgType = @"sayHi";
                    thumbMsgs.messageuuid = @"wx123";
                    thumbMsgs.status = @"1";//已发送
                    thumbMsgs.sayHiType = @"1";
                    thumbMsgs.sendTime=sendTime;
                    thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
            }
        }];
    }
    else if([sendertype isEqualToString:SAYHELLOS])//关注 或取消关注
    {
//        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//            
//            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
//            
//            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
//            if (!thumbMsgs)
//                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
//            thumbMsgs.sender = @"1234";
//            thumbMsgs.senderNickname = @"有新关注信息";
//            thumbMsgs.msgContent = msgContent;
//            thumbMsgs.sendTime = sendTime;
//            thumbMsgs.senderType = sendertype;
//            thumbMsgs.msgType = msgType;
//            thumbMsgs.unRead = @"1";
//            thumbMsgs.messageuuid = msgId;
//            thumbMsgs.status = @"1";//已发送
//        }];
    }
    else if([sendertype isEqualToString:OTHERMESSAGE])//头衔、角色、战斗力
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = @"1";
            thumbMsgs.senderNickname = [msg objectForKey:@"title"];
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            thumbMsgs.msgType = msgType;
            thumbMsgs.sendTimeStr = [msg objectForKey:@"time"];
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = sayhiType;
            thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        }];
    }
    else if([sendertype isEqualToString:RECOMMENDFRIEND])//推荐好友
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"12345"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = @"12345";
            thumbMsgs.senderNickname = @"推荐好友";
            thumbMsgs.msgContent = KISDictionaryHaveKey(msg, @"disStr");
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            thumbMsgs.msgType = msgType;
            thumbMsgs.unRead = @"1";
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = @"1";
            thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        }];
    }
    else if([sendertype isEqualToString:DAILYNEWS])//新闻
    {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {

            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000011"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = @"sys00000011";
            thumbMsgs.senderNickname = @"每日一闻";
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            thumbMsgs.msgType = msgType;
            thumbMsgs.unRead = @"1";
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = @"1";
            thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        }];
    }else if([sendertype isEqualToString:GROUPMSG])//群组消息
    {
        NSString * groupId = KISDictionaryHaveKey(msg, @"groupId");
        NSDictionary* user= [[UserManager singleton] getUser:sender];
        NSString * senderNickname = [user objectForKey:@"nickname"];
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@",groupId, msgType];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = sender;
            thumbMsgs.senderNickname = senderNickname;
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.groupId = groupId;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.msgType = msgType;
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";
            thumbMsgs.sayHiType = sayhiType;
            thumbMsgs.receiveTime=[GameCommon getCurrentTime];
        }];
    }else if([sendertype isEqualToString:JOINGROUPMSG])//加入群组消息
    {
        NSString* payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
        NSDictionary *payloadDic = [payloadStr JSONValue];
        NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
        
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",GROUPAPPLICATIONSTATE];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = sender;
            thumbMsgs.senderNickname = KISDictionaryHaveKey(msg, @"msgTitle");
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            thumbMsgs.msgType = GROUPAPPLICATIONSTATE;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";
            thumbMsgs.sayHiType = @"1";
            thumbMsgs.groupId = groupId;
            thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        }];
    }
}
+(void)storeMyPayloadmsg:(NSDictionary *)message
{
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",receicer,msgType];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = receicer;
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = COMMONUSER;
        thumbMsgs.msgType = msgType;
        thumbMsgs.senderimg = @"";
        thumbMsgs.sayHiType = @"1";
        int unread = [thumbMsgs.unRead intValue];
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"2";
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
    }];
}
+(void)storeMyMessage:(NSDictionary *)message
{
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    NSString* groupId = KISDictionaryHaveKey(message, @"groupId");
    

    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {

        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",receicer ,@"normalchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = receicer;
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = COMMONUSER;
        thumbMsgs.msgType = msgType;
        thumbMsgs.senderimg = @"";
        thumbMsgs.sayHiType = @"1";
        int unread = [thumbMsgs.unRead intValue];
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"2";
        thumbMsgs.groupId = groupId;
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }];
}


+(void)storeMyGroupThumbMessage:(NSDictionary *)message
{    NSString * fromUserid = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    NSString* groupId = KISDictionaryHaveKey(message, @"groupId");
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@",groupId,@"groupchat"];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = fromUserid;
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.msgType = msgType;
        thumbMsgs.senderimg = @"";
        thumbMsgs.sayHiType = @"1";
        int unread = [thumbMsgs.unRead intValue];
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"2";//发送中
        thumbMsgs.groupId = groupId;
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }];
}


+(void)storeMyNormalMessage:(NSDictionary *)message
{
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * sender = KISDictionaryHaveKey(message, @"sender");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    NSString * payloadStr = KISDictionaryHaveKey(message, @"payload");
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];
        commonMsg.sender = sender;
        commonMsg.senderNickname = @"";
        commonMsg.msgContent = msgContent?msgContent:@"";
        commonMsg.senTime = sendTime;
        commonMsg.receiver = receicer;
        commonMsg.msgType = msgType;
        commonMsg.payload = payloadStr;
        commonMsg.messageuuid = messageuuid;
        commonMsg.status = @"2";
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }];
}

+(void)storeMyGroupMessage:(NSDictionary *)message
{
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * sender = KISDictionaryHaveKey(message, @"sender");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    NSString * payloadStr = KISDictionaryHaveKey(message, @"payload");
    NSString * groupId = KISDictionaryHaveKey(message, @"groupId");
     NSString * msgState = KISDictionaryHaveKey(message, @"status");
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSGroupMsgs * commonMsg = [DSGroupMsgs MR_createInContext:localContext];
        commonMsg.sender = sender;
        commonMsg.senderNickname = @"";
        commonMsg.msgContent = msgContent?msgContent:@"";
        commonMsg.senTime = sendTime;
        commonMsg.receiver = receicer;
        commonMsg.msgType = msgType;
        commonMsg.payload = payloadStr;
        commonMsg.messageuuid = messageuuid;
        commonMsg.status = msgState;
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        commonMsg.groupId = groupId;
    }];
}



+(void)changeMyMessage:(NSString *)messageuuid PayLoad:(NSString*)payload
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",messageuuid];
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_findFirstWithPredicate:predicate];
        commonMsg.payload = payload;//动态 消息json
    }];
}

+(void)changeMyGroupMessage:(NSString *)messageuuid PayLoad:(NSString*)payload
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",messageuuid];
        DSGroupMsgs * commonMsg = [DSGroupMsgs MR_findFirstWithPredicate:predicate];
        commonMsg.payload = payload;
    }];
}

+(NSString *)queryMsgRemarkNameForUser:(NSString *)userid
{
    if ([userid isEqualToString:@"1234"]) {
        return @"有新的关注消息";
    }
    if ([userid isEqualToString:@"12345"]) {
        return @"好友推荐";
    }
    if ([userid isEqualToString:@"1"]) {
        return @"有新的角色动态";
    }
    if ([userid isEqualToString:@"1234567wxxxxxxxxx"]) {
        return @"有新的打招呼信息";
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
    DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
    if (thumbMsgs) {
        if (thumbMsgs.senderNickname) {
            return thumbMsgs.senderNickname;
        }
        else
            return @"";
    }
    return @"";
}

+(NSString *)queryMsgHeadImageForUser:(NSString *)userid
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
    DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
    if (thumbMsgs) {
        if (thumbMsgs.senderimg) {
            return thumbMsgs.senderimg;
        }
        else
            return @"";
    }
    return @"";
}
//把正常聊天消息的未读消息设置为0
+(void)blankMsgUnreadCountForUser:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",userid,@"normalchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }];
}
//把群组聊天消息的未读消息设置为0
+(void)blankGroupMsgUnreadCountForUser:(NSString *)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@",groupId,@"groupchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }];
}

+(void)blankMsgUnreadCountFormsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }];
}

+(NSArray *)queryUnreadCountForCommonMsg
{
    NSMutableArray * unreadArray = [NSMutableArray array];
    NSArray * allUnreadArray = [DSThumbMsgs MR_findAllSortedBy:@"sendTime" ascending:NO];
    for (int i = 0; i<allUnreadArray.count; i++) {
        [unreadArray addObject:[[allUnreadArray objectAtIndex:i]unRead]];
    }
    return unreadArray;
}



+(void)deleteMsgsWithSender:(NSString *)sender Type:(NSString *)senderType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        if ([senderType isEqualToString:COMMONUSER]) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
            [thumbMsgs MR_deleteInContext:localContext];
            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"sender==[c]%@ OR receiver==[c]%@",sender,sender];
            NSArray * commonMsgs = [DSCommonMsgs MR_findAllWithPredicate:predicate2];
            for (int i = 0; i<commonMsgs.count; i++) {
                DSCommonMsgs * rH = [commonMsgs objectAtIndex:i];
                [rH MR_deleteInContext:localContext];
            }
        }
    }];
}
//-----删除所有的normalchat显示消息消息
+(void)deleteThumbMsgsByMsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
            NSArray * thumbMsg = [DSThumbMsgs MR_findAllWithPredicate:predicate];
            for (int i = 0; i<thumbMsg.count; i++) {
                DSThumbMsgs * thumb = [thumbMsg objectAtIndex:i];
                [thumb MR_deleteInContext:localContext];
            }
    }];
}


//-----删除所有的normalchat历史记录消息
+(void)deleteCommonMsgsByMsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
        NSArray * commonMsgs = [DSCommonMsgs MR_findAllWithPredicate:predicate];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSCommonMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
    }];
}





+(void)deleteGroupMsgByMsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
        NSArray * commonMsgs = [DSGroupMsgs MR_findAllWithPredicate:predicate];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSGroupMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
    }];
}

//删除所有的群聊历史记录
+(void)clearGroupChatHistroyMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * commonMsgs = [DSGroupMsgs MR_findAll];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSGroupMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
    }];
}

//-----

+(void)deleteMsgInCommentWithUUid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",uuid];
        DSCommonMsgs * commonMsgs = [DSCommonMsgs MR_findFirstWithPredicate:predicate];
        if (commonMsgs) {
            [commonMsgs MR_deleteInContext:localContext];
        }
    }];
}
+(void)deleteGroupMsgInCommentWithUUid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",uuid];
        DSGroupMsgs * commonMsgs = [DSGroupMsgs MR_findFirstWithPredicate:predicate];
        if (commonMsgs) {
            [commonMsgs MR_deleteInContext:localContext];
        }
    }];
}

+(void)deleteAllNewsMsgs
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * newsMsgs = [DSNewsMsgs MR_findAllInContext:localContext];
        for (DSNewsMsgs* msg in newsMsgs) {
            [msg deleteInContext:localContext];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000011"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }];
}

+ (NSMutableArray *)qureyCommonMessagesWithUserID:(NSString *)userid FetchOffset:(NSInteger)integer PageSize:(NSInteger)pageSize
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ OR receiver==[c]%@",userid,userid];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"receiveTime" ascending:NO];
    NSFetchRequest * fetchRequest = [DSCommonMsgs MR_requestAllWithPredicate:predicate];
    [fetchRequest setFetchOffset:integer];
    [fetchRequest setFetchLimit:pageSize];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSArray * DSArray = [DSCommonMsgs MR_executeFetchRequest:fetchRequest];
    NSMutableArray * msgArray = [NSMutableArray array];
    NSInteger count = DSArray.count;
    for (int i = count-1; i>=0; i--) {
        NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] sender] forKey:@"sender"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgContent] forKey:@"msg"];
        NSDate * tt = [[DSArray objectAtIndex:i] senTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgType]?[[DSArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] payload]?[[DSArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] messageuuid]?[[DSArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] status]?[[DSArray objectAtIndex:i] status] : @"" forKey:@"status"];
        [msgArray addObject:thumbMsgsDict];
    }
    return msgArray;
}


//+ (NSMutableArray *)qureyGroupMessagesGroupID:(NSString *)groupid FetchOffset:(NSInteger)integer
//{
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ OR receiver==[c]%@",groupid,groupid];
//    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"receiveTime" ascending:NO];
//    NSFetchRequest * fetchRequest = [DSGroupMsgs MR_requestAllWithPredicate:predicate];
//    [fetchRequest setFetchOffset:integer];
//    [fetchRequest setFetchLimit:20];
//    fetchRequest.sortDescriptors = @[sortDescriptor];
//    NSArray * DSArray = [DSGroupMsgs MR_executeFetchRequest:fetchRequest];
//    NSMutableArray * msgArray = [NSMutableArray array];
//    NSInteger count = DSArray.count;
//    for (int i = count-1; i>=0; i--) {
//        NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
//        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] sender] forKey:@"sender"];
//        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgContent] forKey:@"msg"];
//        NSDate * tt = [[DSArray objectAtIndex:i] senTime];
//        NSTimeInterval uu = [tt timeIntervalSince1970];
//        [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
//        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgType]?[[DSArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
//        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] payload]?[[DSArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
//        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] messageuuid]?[[DSArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
//        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] status]?[[DSArray objectAtIndex:i] status] : @"" forKey:@"status"];
//        [msgArray addObject:thumbMsgsDict];
//    }
//    return msgArray;
//}

+ (NSMutableArray *)qureyGroupMessagesGroupID:(NSString *)groupid FetchOffset:(NSInteger)integer PageSize:(NSInteger)pageSize
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ OR receiver==[c]%@",groupid,groupid];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"receiveTime" ascending:NO];
    NSFetchRequest * fetchRequest = [DSGroupMsgs MR_requestAllWithPredicate:predicate];
    [fetchRequest setFetchOffset:integer];
    [fetchRequest setFetchLimit:pageSize];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSArray * DSArray = [DSGroupMsgs MR_executeFetchRequest:fetchRequest];
    NSMutableArray * msgArray = [NSMutableArray array];
    NSInteger count = DSArray.count;
    for (int i = count-1; i>=0; i--) {
        NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] sender] forKey:@"sender"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgContent] forKey:@"msg"];
        NSDate * tt = [[DSArray objectAtIndex:i] senTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgType]?[[DSArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] payload]?[[DSArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] messageuuid]?[[DSArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] status]?[[DSArray objectAtIndex:i] status] : @"" forKey:@"status"];
        [msgArray addObject:thumbMsgsDict];
    }
    return msgArray;
}


+ (NSMutableArray *)qureyCommonMessagesWithMsgType:(NSString *)msgType
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"receiveTime" ascending:NO];
    NSFetchRequest * fetchRequest = [DSCommonMsgs MR_requestAllWithPredicate:predicate];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    NSArray * DSArray = [DSCommonMsgs MR_executeFetchRequest:fetchRequest];
    NSMutableArray * msgArray = [NSMutableArray array];
    NSInteger count = DSArray.count;
    for (int i = 0; i<count; i++) {
        NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] sender] forKey:@"sender"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgContent] forKey:@"msg"];
        NSDate * tt = [[DSArray objectAtIndex:i] senTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] msgType]?[[DSArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] payload]?[[DSArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] messageuuid]?[[DSArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] status]?[[DSArray objectAtIndex:i] status] : @"" forKey:@"status"];
        [msgArray addObject:thumbMsgsDict];
    }
    return msgArray;
}


+(NSString*)queryMessageStatusWithId:(NSString*)msgUUID
{
    if (msgUUID && msgUUID.length > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",msgUUID];
        DSCommonMsgs * commonMsgs = [DSCommonMsgs MR_findFirstWithPredicate:predicate];
        if (commonMsgs) {
            return commonMsgs.status;
        }
        return @"";
    }
    return @"";
}

+(NSString*)queryGroupMessageStatusWithId:(NSString*)msgUUID
{
    if (msgUUID && msgUUID.length > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",msgUUID];
        DSGroupMsgs * commonMsgs = [DSGroupMsgs MR_findFirstWithPredicate:predicate];
        if (commonMsgs) {
            return commonMsgs.status;
        }
        return @"";
    }
    return @"";
}

+(void)deleteAllCommonMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * commonMsgs = [DSCommonMsgs MR_findAllInContext:localContext];
        for (DSCommonMsgs* msg in commonMsgs) {
            [msg deleteInContext:localContext];
        }
    }];
    [DataStoreManager deleteAllThumbMsg];
}

+(void)refreshThumbMsgsAfterDeleteCommonMsg:(NSDictionary *)message ForUser:(NSString *)userid ifDel:(BOOL)del
{
    NSString * msgContent = [message objectForKey:@"msg"];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[message objectForKey:@"time"] doubleValue]];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate;
        predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs){
            if (del) {
                [thumbMsgs MR_deleteInContext:localContext];
            }
            else
            {
                thumbMsgs.msgContent = msgContent;
                thumbMsgs.sendTime = sendTime;
            }
        }
        
    }];
}
+(NSArray *)qureyAllNewsMessageWithGameid:(NSString *)gameid
{
    NSPredicate * predicate= [NSPredicate predicateWithFormat:@"gameid==[c]%@",gameid];
    NSArray *arr =[DSNewsMsgs MR_findAllSortedBy:@"sendtime" ascending:YES withPredicate:predicate];
    NSMutableArray* array = [NSMutableArray array];
    for (DSNewsMsgs* news in arr) {
        NSString * str = news.mytitle;
        NSDictionary * dic = [str JSONValue];
        [array addObject:dic];
    }
    return array;
}

+(NSArray *)qureyFirstOfgame
{
    NSMutableArray *mutarr = [NSMutableArray array];
    NSArray *array = [DSNewsGameList MR_findAll];
    for (DSNewsGameList *news in array) {
        NSString *str = news.gameid;
        NSString *str1 = news.mytitle;
        NSString *dic =[str1 JSONValue];
        NSDictionary *momo =[NSDictionary dictionaryWithObjectsAndKeys:str,@"gameid",dic,@"content", nil];
        [mutarr addObject:momo];
    }
    return mutarr;
}


+(NSArray *)qureyAllNewsMessage
{
    NSArray * newsMessage = [DSNewsMsgs MR_findAllSortedBy:@"sendtime" ascending:YES];
    NSMutableArray* array = [NSMutableArray array];
    for (DSNewsMsgs* news in newsMessage) {
        NSString * str = news.mytitle;
        NSDictionary * dic = [str JSONValue];
        [array addObject:dic];
    }
    return array;
}
+(NSArray *)qureyAllThumbMessagesWithType:(NSString *)type
{
    NSPredicate * predicate= [NSPredicate predicateWithFormat:@"sayHiType==[c]%@",type];
    NSArray *array =[DSThumbMsgs MR_findAllSortedBy:@"sendTime" ascending:NO withPredicate:predicate];
    return array;
}
+(DSThumbMsgs*)qureySayHiMsg:(NSString *)type
{
    NSArray * sayHiList=[self qureyAllThumbMessagesWithType:type];
    if (sayHiList.count>0) {
        return [sayHiList objectAtIndex:0];
    }
    return nil;
}

//检查消息是否存在
+(BOOL)isHaveSayHiMsg:(NSString *)type
{
    NSPredicate * predicate= [NSPredicate predicateWithFormat:@"sayHiType==[c]%@",type];
    DSThumbMsgs * sayThumbMsg= [DSThumbMsgs MR_findFirstWithPredicate:predicate];
    if (sayThumbMsg){
        return YES;
    }
    return NO;
}
//----
+(void)refreshMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status
{
    if (messageuuid && messageuuid.length > 0) {//0失败 1发送到服务器 2发送中 3已送达 4已读
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@", messageuuid];
        DSCommonMsgs * commonMsgs = [DSCommonMsgs MR_findFirstWithPredicate:predicate];
        if (commonMsgs) {
            commonMsgs.status = status;
        }
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs){
            thumbMsgs.status = status;
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

+(void)refreshGroupMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status
{
    if (messageuuid && messageuuid.length > 0) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@", messageuuid];
        DSGroupMsgs * commonMsgs = [DSGroupMsgs MR_findFirstWithPredicate:predicate];
        if (commonMsgs) {
            commonMsgs.status = status;
        }
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs){
            thumbMsgs.status = status;
        }
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
    }
}

#pragma mark-存储所有人的列表信息 (新)
+(void)newSaveAllUserWithUserManagerList:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype
{
    NSString *title = [GameCommon getNewStringWithId:[userInfo objectForKey:@"titleName"]];//头衔名称
    NSString *rarenum = [GameCommon getNewStringWithId:[userInfo objectForKey:@"rarenum"]];//头衔等级
    NSString *actionStr=[GameCommon getNewStringWithId:[userInfo objectForKey:@"active"]];
    BOOL action;//是否激活
    if ([actionStr intValue] == 2) {
        action =YES;
    }else{
        action =NO;
    }
    NSString * age = [GameCommon getNewStringWithId:[userInfo objectForKey:@"age"]];//年龄
    NSString * background = [GameCommon getNewStringWithId:[userInfo objectForKey:@"backgroundImg"]];//动态页面背景图
    NSString * birthday = [GameCommon getNewStringWithId:[userInfo objectForKey:@"birthday"]];//生日
    NSString * createTime = [GameCommon getNewStringWithId:[userInfo objectForKey:@"createTime"]];//创建时间
    double distance = [KISDictionaryHaveKey(userInfo, @"distance") doubleValue];//距离
    if (distance == -1) {//若没有距离赋最大值
        distance = 9999000;
    }
    NSString * gameids = [GameCommon getNewStringWithId:[userInfo objectForKey:@"gameids"]];//游戏Id
    NSString * gender = [GameCommon getNewStringWithId:[userInfo objectForKey:@"gender"]];//性别
    NSString * headImgID = [GameCommon getNewStringWithId:[userInfo objectForKey:@"img"]];//头像
    NSString * hobby = [GameCommon getNewStringWithId:[userInfo objectForKey:@"remark"]];//个人标签
    NSString * myUserName = [GameCommon getNewStringWithId:[userInfo objectForKey:@"username"]];//用户名（手机号）
    NSString * refreshTime = [GameCommon getNewStringWithId:[userInfo objectForKey:@"updateUserLocationDate"]];//更新时间
    NSString * alias = [GameCommon getNewStringWithId:[userInfo objectForKey:@"alias"]];//备注
    NSString * signature = [GameCommon getNewStringWithId:[userInfo objectForKey:@"signature"]];//个性签名
    NSString * starSign = [GameCommon getNewStringWithId:[userInfo objectForKey:@"constellation"]];//星座
    NSString * superremark = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superremark")];//加V说明
    NSString * superstar = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superstar")];//是否为加V用户
    NSString * userId = [GameCommon getNewStringWithId:[userInfo objectForKey:@"userid"]];//用户Id
    NSString * nickName = [GameCommon getNewStringWithId:[userInfo objectForKey:@"nickname"]];//昵称
    NSString * nameIdx=[GameCommon getNewStringWithId:[userInfo objectForKey:@"nameIndex"]];
    NSString * nameIndex;
    
    NSString* pinYin =([GameCommon isEmtity:alias])? nickName : alias;
    NSString * nameKey;
    
    if (pinYin.length>=1) {
        NSString *nameK = [[DataStoreManager convertChineseToPinYin:pinYin] stringByAppendingFormat:@"+%@",pinYin];
        nameKey = [nameK stringByAppendingFormat:@"%@", userId];
    }
    
    if (![GameCommon isEmtity:nameIdx]) {
        nameIndex=nameIdx;
    }else{
        nameIndex = [[nameKey substringToIndex:1] uppercaseString];
    }
    //没有昵称和备注的情况nameindex标记为＃
    if ([GameCommon isEmtity:nameIndex]) {
        nameIndex=@"#";
    }
    if (![GameCommon isEmtity:userId]) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
            DSuser * dUser= [DSuser MR_findFirstWithPredicate:predicate];
            if (!dUser)
                dUser = [DSuser MR_createInContext:localContext];
            
            dUser.achievement = title?title:@"";
            dUser.achievementLevel = rarenum?rarenum:@"";
            dUser.action = [NSNumber numberWithBool:action];
            dUser.age = age?age:@"";
            dUser.backgroundImg = background;
            dUser.birthday = birthday?birthday:@"";
            dUser.createTime = createTime?createTime:@"";
            dUser.distance = [NSNumber numberWithDouble:distance];
            dUser.gameids =gameids?gameids:@"";
            dUser.gender = gender?gender:@"";
            dUser.headImgID = headImgID?headImgID:@"";
            dUser.hobby = hobby?hobby:@"";
            dUser.nameIndex = nameIndex;
            dUser.nameKey = nameKey?nameKey:@"";
            dUser.nickName = nickName?(nickName.length>1?nickName:[nickName stringByAppendingString:@" "]):@"";
            dUser.phoneNumber = myUserName?myUserName:@"";
            dUser.refreshTime = refreshTime;
            dUser.remarkName = alias?alias:@"";
            dUser.shiptype = shiptype?shiptype:@"";
            dUser.signature = signature?signature:@"";
            dUser.starSign = starSign?starSign:@"";
            dUser.superremark = superremark?superremark:@"";
            dUser.superstar = superstar?superstar:@"";
            dUser.userId = userId?userId:@"";
            dUser.userName = myUserName?myUserName:@"";
            
            
            if (![userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
                if ([shiptype isEqualToString:@"1"]||[shiptype isEqualToString:@"2"]) {
                    NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSNameIndex * dFname = [DSNameIndex MR_findFirstWithPredicate:predicate2];
                    if (!dFname)
                        dFname = [DSNameIndex MR_createInContext:localContext];
                    dFname.index = nameIndex;
                    return ;
                }
                if([shiptype isEqualToString:@"3"])
                {
                    NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSFansNameIndex * dFname = [DSFansNameIndex MR_findFirstWithPredicate:predicate2];
                    if (!dFname)
                        dFname = [DSFansNameIndex MR_createInContext:localContext];
                    dFname.index = nameIndex;
                    return;
                }
            }
        }];
    }
}

+(NSString *)queryFirstHeadImageForUser_userManager:(NSString *)userid
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
    DSuser *dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser.headImgID) {
        NSRange range=[dUser.headImgID rangeOfString:@","];
        if (range.location!=NSNotFound) {
            NSArray *imageArray = [dUser.headImgID componentsSeparatedByString:@","];
            return [imageArray objectAtIndex:0];
        }
        else
        {
            return dUser.headImgID;
        }
    }
    else
        return @"no";

}

+(void)delInfoWithType:(NSString *)shiptype
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"shiptype==[c]%@",shiptype];
    DSuser *user = [DSuser MR_findFirstWithPredicate:predicate];
    if (user) {
        [user MR_deleteInContext:localContext];
    }
    }];
}

+(BOOL)ifHaveThisUserInUserManager:(NSString *)userId
{
    if (![GameCommon isEmtity:userId]) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
        DSuser * dUserManager = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUserManager) {
            return YES;
        }else
            return NO;
    }
    else
        return NO;
}

+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {
        dUser.shiptype = type;
    }
    }];
}

+ (BOOL)ifIsAttentionWithUserId:(NSString*)userId
{
    if (userId) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
        DSuser * dUsers = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUsers) {
            return YES;
        }
        else
            return NO;
    }
    else
        return NO;

}
+ (void)cleanIndexWithNameIndex:(NSString*)nameIndex withType:(NSString *)type
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"nameIndex==[c]%@",nameIndex];
    NSArray * dUser = [DSuser MR_findAllWithPredicate:predicate];
    NSMutableArray *array = [NSMutableArray array];
    for (int i = 0; i<dUser.count; i++) {
        DSuser *user = [dUser objectAtIndex:i];
        if ([user.shiptype isEqualToString:type]) {
            [array addObject:user];
        }
    }
    if ([array count] == 0 || ([array count] == 1 && [nameIndex isEqualToString:[DataStoreManager getMyNameIndex]])) {
            
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            if ([type isEqualToString:@"1"]) {
                NSPredicate* predicateIndex = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSNameIndex* name = [DSNameIndex MR_findFirstWithPredicate:predicateIndex];
                    [name MR_deleteInContext:localContext];
                }
              else  if ([type isEqualToString:@"2"]) {
                    NSPredicate* predicateIndex = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSAttentionNameIndex* name = [DSAttentionNameIndex MR_findFirstWithPredicate:predicateIndex];
                    [name MR_deleteInContext:localContext];
                }

               else if ([type isEqualToString:@"3"]) {
                    NSPredicate* predicateIndex = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSFansNameIndex* name = [DSFansNameIndex MR_findFirstWithPredicate:predicateIndex];
                    [name MR_deleteInContext:localContext];
                }

            }];
        }
}

+(DSuser *)getInfoWithUserId:(NSString *)userId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
   return [DSuser MR_findFirstWithPredicate:predicate];
}

#pragma mark - 是否存在这个联系人
+(BOOL)ifHaveThisUser:(NSString *)userId
{
    if (userId) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
        DSuser * dUsers = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUsers) {
            return YES;
        }
        return NO;
    }
    else
        return NO;
}

+(void)saveDynamicAboutMe:(NSDictionary *)info
{
    NSString *type = KISDictionaryHaveKey(info, @"type");
    NSString *customObject;
    NSString *customUser;
    if ([type intValue]==5||[type intValue]==7) {
        customObject =@"commentObject";
        customUser = @"commentUser";
    }
    else if ([type intValue]==4)
    {
        customObject = @"zanObject";
        customUser = @"zanUser";
    }

    NSString *msgid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info,customObject), @"id")];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgid==[c]%@",msgid];
        DSCircleWithMe * dCircle= [DSCircleWithMe MR_findFirstWithPredicate:predicate];
        if (!dCircle)
            dCircle = [DSCircleWithMe MR_createInContext:localContext];
            dCircle.myType =[NSString stringWithFormat:@"%@",type];

            dCircle.msgid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info,customObject), @"id")];
            
            dCircle.username =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info, customObject),customUser) ,@"username")];
            
            dCircle.alias =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info, customObject),customUser), @"alias")];
            dCircle.nickname =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info, customObject),customUser), @"nickname")];
            
            dCircle.headImg =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info, customObject),customUser), @"img")];
            
            dCircle.userid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info, customObject),customUser), @"userid")];
            dCircle.superstar =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(KISDictionaryHaveKey(info, customObject),customUser), @"supserstar")];
            
            dCircle.createDate =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info,customObject), @"createDate")];
        
            if ([type intValue] ==5||[type intValue] ==7) {
                dCircle.comment =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info,customObject), @"comment")];
            }
            dCircle.myMsgid =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info, @"dynamicMsg"), @"id")];
            dCircle.myMsgImg =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info, @"dynamicMsg"), @"img")];
            dCircle.myCreateDate =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info, @"dynamicMsg"), @"createDate")];
            
            dCircle.myMsg =[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(info, @"dynamicMsg"), @"msg")];
        
           dCircle.unRead = @"0";//设置未读属性 0 未读 、1 已读

    }];
}

+(NSArray *)queryallDynamicAboutMeWithUnRead:(NSString *)unRead
{
    NSArray *array= [DSCircleWithMe MR_findAllSortedBy:@"createDate" ascending:NO];
    NSMutableArray *arr = [NSMutableArray array];
    for (int i =0; i<array.count; i++) {
        DSCircleWithMe *circleMe = [array objectAtIndex:i];
        if ([circleMe.unRead isEqualToString:unRead]) {
            [arr addObject:circleMe];
            circleMe.unRead = @"1";
        }
    }
    return arr;
}


+(void)deletecommentWithMsgId:(NSString*)msgid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgid==[c]%@",msgid];
        DSCircleWithMe * dUserManager = [DSCircleWithMe MR_findFirstWithPredicate:predicate];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }];
}

+(void)deleteAllcomment
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * newsMsgs = [DSCircleWithMe MR_findAllInContext:localContext];
        for (DSNewsMsgs* msg in newsMsgs) {
            [msg deleteInContext:localContext];
        }
    }];
}




+(void)saveCommentsWithDic:(NSDictionary *)dic
{
    NSString *uuid = KISDictionaryHaveKey(dic, @"uuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineComments * offline= [DSOfflineComments MR_findFirstWithPredicate:predicate];
        if (!offline)
            offline = [DSOfflineComments MR_createInContext:localContext];
        offline.msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"msgId")];
        offline.comments = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"comments")];
        offline.destCommentId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"destCommentId")];
        offline.destUserid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"destUserid")];
        offline.uuid = uuid;
    }];

}
+(NSArray *)queryallcomments
{
    NSArray *array= [DSOfflineComments MR_findAll];
    return array;

}
+(void)removeOfflineCommentsWithuuid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineComments * dUserManager = [DSOfflineComments MR_findFirstWithPredicate:predicate];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }];

}

+(void)saveOfflineZanWithDic:(NSDictionary *)dic
{
    NSString *uuid = KISDictionaryHaveKey(dic, @"uuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineZan * offline= [DSOfflineZan MR_findFirstWithPredicate:predicate];
        if (!offline)
            offline = [DSOfflineZan MR_createInContext:localContext];
        offline.msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"msgId")];
        offline.uuid = uuid;
    }];

}
+(NSArray *)queryallOfflineZan
{
    NSArray *array= [DSOfflineZan MR_findAll];
    return array;
}
+(void)removeOfflineZanWithuuid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineZan * dUserManager = [DSOfflineZan MR_findFirstWithPredicate:predicate];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }];

}





+(BOOL)ifFriendHaveNicknameAboutUser:(NSString *)userId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUsers = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUsers) {
        if (dUsers.nickName.length>1) {
            return YES;
        }
        else
            return NO;
    }
    else
        return NO;
}

//查询好友
+(NSMutableDictionary *)newQuerySections:(NSString*)shipType ShipType2:(NSString*)shipType2
{
    NSMutableDictionary *userInfo=[[NSMutableDictionary alloc]init];
    NSMutableDictionary *userList=[[NSMutableDictionary alloc]init];
    NSMutableArray * nameIndexArray = [NSMutableArray array];
    NSArray * nameIndexArray2 = [DSNameIndex MR_findAll];
    for (int i = 0; i<nameIndexArray2.count; i++) {
        DSNameIndex * di = [nameIndexArray2 objectAtIndex:i];
        NSString * nameIndex=di.index;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"nameIndex==[c]%@",nameIndex];
        NSArray * fri = [DSuser MR_findAllSortedBy:@"nameKey" ascending:YES withPredicate:predicate];
        NSMutableArray * usersarray= [NSMutableArray array];
        for (int i = 0; i<fri.count; i++) {
          NSString * shipT = [[fri objectAtIndex:i]shiptype];
            if ([shipT isEqualToString:shipType]||[shipT isEqualToString:shipType2]) {
                NSMutableDictionary *user= [self getUserDictionary:[fri objectAtIndex:i]];
                [usersarray addObject:user];
            }
        }
        if (usersarray&&[usersarray count]>0) {
            [nameIndexArray addObject:nameIndex];
            [userList setValue:usersarray forKey:nameIndex];
        }
    }
    [nameIndexArray sortUsingSelector:@selector(compare:)];
    [userInfo setObject:nameIndexArray forKey:@"nameKey"];
    [userInfo setObject:userList forKey:@"userList"];
    return userInfo;
}
//根据userid查用户信息
+(NSMutableDictionary *)getUserInfoFromDbByUserid:(NSString*)userid
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
    DSuser *dbUser = [ DSuser MR_findFirstWithPredicate:predicate];
    return [self getUserDictionary:dbUser];
}



+(NSMutableDictionary *)getUserDictionary:(DSuser*)dbUser
{
    NSMutableDictionary *user=[[NSMutableDictionary alloc]init];
    [user setObject:[dbUser gameids]?[dbUser gameids]:@"" forKey:@"gameids"];
    [user setObject:[dbUser userName]?[dbUser userName]:@"" forKey:@"username"];
    [user setObject:[dbUser userId]?[dbUser userId]:@"" forKey:@"userid"];
    [user setObject:[dbUser nickName]?[dbUser nickName]:@"" forKey:@"nickname"];
    [user setObject:[dbUser headImgID]?[dbUser headImgID]:@"" forKey:@"img"];
    [user setObject:[dbUser age]?[dbUser age]:@"" forKey:@"age"];
    [user setObject:[dbUser gender]?[dbUser gender]:@"" forKey:@"gender"];
    [user setObject:[dbUser achievement]?[dbUser achievement]:@"" forKey:@"titleName"];
    [user setObject:[dbUser achievementLevel]?[dbUser achievementLevel]:@"" forKey:@"rarenum"];
    [user setObject:[dbUser refreshTime]?[dbUser refreshTime]:@"" forKey:@"updateUserLocationDate"];
    [user setObject:[dbUser distance]?[dbUser distance]:@"" forKey:@"distance"];
    [user setObject:[dbUser nameIndex]?[dbUser nameIndex]:@"" forKey:@"nameIndex"];
    [user setObject:[dbUser shiptype]?[dbUser shiptype]:@"" forKey:@"shiptype"];
    [user setObject:[dbUser remarkName]?[dbUser remarkName]:@"" forKey:@"alias"];
    
    [user setObject:[dbUser backgroundImg]?[dbUser backgroundImg]:@""forKey:@"backgroundImg"];
    [user setObject:[dbUser birthday]?[dbUser birthday] :@"" forKey:@"birthdate"];
    [user setObject:[dbUser createTime]?[dbUser createTime] :@"" forKey:@"createTime"];
    [user setObject:[dbUser hobby]?[dbUser hobby] :@""forKey:@"remark"];
    [user setObject:[dbUser nameKey]?[dbUser nameKey]:@"" forKey:@"nameKey"];
    [user setObject:[dbUser phoneNumber]?[dbUser phoneNumber] :@""forKey:@"phoneNumber"];
    [user setObject:[dbUser signature]?[dbUser signature] :@""forKey:@"signature"];
    [user setObject:[dbUser starSign]?[dbUser starSign] :@""forKey:@"constellation"];
    [user setObject:[dbUser superremark]?[dbUser superremark]:@"" forKey:@"superremark"];
    [user setObject:[dbUser superstar]?[dbUser superstar] :@""forKey:@"superstar"];
    [user setObject:@"未知" forKey:@"city"];
    [user setObject:@"0" forKey:@"latitude"];
    [user setObject:@"0" forKey:@"longitude"];
    
    return user;
}

//根据用户id查询用户信息
+(id)queryDUser:(NSString*)userId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    return [DSuser MR_findFirstWithPredicate:predicate];
}

//----------------------------------------
+ (void)saveFriendRemarkName:(NSString*)remarkName userid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUser) {
            dUser.remarkName = remarkName;
        }
        
        NSString* oldNameIndex = dUser.nameIndex;
        
        NSString * nameIndex;
        NSString * nameKey;
        if (remarkName.length>=1) {
            nameKey = [[DataStoreManager convertChineseToPinYin:remarkName] stringByAppendingFormat:@"+%@",remarkName];
            dUser.nameKey = nameKey;
            nameIndex = [[nameKey substringToIndex:1] uppercaseString];
            dUser.nameIndex = nameIndex;
        }
        if (remarkName.length>=1) {
            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
            DSNameIndex * dFname = [DSNameIndex MR_findFirstWithPredicate:predicate2];
            if (!dFname)
                dFname = [DSNameIndex MR_createInContext:localContext];
            
            dFname.index = nameIndex;
        }
       [DataStoreManager cleanIndexWithNameIndex:oldNameIndex withType:dUser.shiptype];
    }];
}

+(NSMutableArray *)queryAllFriendsNickname
{
    NSMutableArray * array = [NSMutableArray array];
    NSArray * fri = [DSuser MR_findAll];
    for (DSuser * ggf in fri) {
        NSArray * arry = [NSArray arrayWithObjects:ggf.nickName?ggf.nickName:@"1",ggf.userName, nil];
        [array addObject:arry];
    }
    return array;
}

+(BOOL)ifIsShipTypeWithUserId:(NSString*)userId type:(NSString*)shiptype
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if ([dUser.shiptype isEqualToString:shiptype]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark -
+(NSString *)convertChineseToPinYin:(NSString *)chineseName
{
    if (chineseName==nil||[chineseName isEqualToString:@""]) {
        return  @"";
    }
    NSMutableString * theName = [NSMutableString stringWithString:chineseName];
    CFRange range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformToLatin, NO);
    range = CFRangeMake(0, theName.length);
    CFStringTransform((CFMutableStringRef)theName, &range, kCFStringTransformStripCombiningMarks, NO);
    NSString * dd = [theName stringByReplacingOccurrencesOfString:@" " withString:@""];
    return dd;
}

+(void)updateFriendInfo:(NSDictionary *)userInfoDict ForUser:(NSString *)username
{
    NSString * nickName = [userInfoDict objectForKey:@"nickname"];
 

    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userName==[c]%@",username];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUser) {
            dUser.userName = username;
            dUser.nickName = nickName;
            dUser.signature = [userInfoDict objectForKey:@"signature"];
        }

    }];
}

+(NSString *)queryNickNameForUser:(NSString *)userId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {
        if (dUser.nickName) {
            return dUser.nickName;
        }
        else{
            return dUser.userName;
        }
    }
    else{
        return userId;
    }
}

+(NSString *)getOtherMessageTitleWithUUID:(NSString*)uuid type:(NSString*)type
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@ AND msgType==[c]%@",uuid,type];
    DSThumbMsgs *msg = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
    if (msg) {
        return msg.senderNickname;
    }
    return @"";
}

+(NSString *)queryRemarkNameForUser:(NSString *)userid
{
    if ([userid isEqualToString:@"1234"]) {
        return @"有新的关注消息";
    }
    if ([userid isEqualToString:@"12345"]) {
        return @"好友推荐";
    }
    if ([userid isEqualToString:@"1"]) {
        return @"有新的角色动态";
    }
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {//不是好友 就去粉丝、关注列表查
        if (dUser.remarkName && ![dUser.remarkName isEqualToString:@""]) {
            return dUser.remarkName;
        }
        else if(dUser.nickName && ![dUser.nickName isEqualToString:@""])
            return dUser.nickName;
        else
            return userid;
    }
    return @"";
}

+(NSString *)querySelfUserName
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {//自己
        return  dUser.userName;
    }
    return @"";
}

+(NSDictionary *)queryMyInfo
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {
        [dict setObject:dUser.userName forKey:@"username"];
        [dict setObject:dUser.userId forKey:@"id"];
        [dict setObject:dUser.nickName forKey:@"nickname"];
        [dict setObject:dUser.gender forKey:@"gender"];
        [dict setObject:dUser.signature forKey:@"signature"];
        [dict setObject:@"0" forKey:@"latitude"];
        [dict setObject:@"0" forKey:@"longitude"];
        [dict setObject:dUser.age forKey:@"birthdate"];
        [dict setObject:dUser.headImgID forKey:@"img"];
        [dict setObject:dUser.backgroundImg?dUser.backgroundImg:@"" forKey:@"backgroundImg"];
        [dict setObject:dUser.superstar forKey:@"superstar"];
    }
    return dict;
}


+(NSString *)toString:(id)object
{
    return [NSString stringWithFormat:@"%@",object?object:@""];
}

#pragma mark -清理索引
+ (NSString*)getMyNameIndex
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
    NSArray * dUser = [DSuser MR_findAllWithPredicate:predicate];
    if ([dUser count] != 0) {
        return [[dUser objectAtIndex:0] nameIndex];
    }
    return @"";
}
#pragma mark - 动态
//@dynamic heardImgId;
//@dynamic newsId;
//@dynamic bigTitle;
//@dynamic msg;
//@dynamic imageStr;
//@dynamic detailPageId;
//@dynamic createDate;
//@dynamic nickName;
//@dynamic commentObj;
//@dynamic urlLink;
//@dynamic img userid
+(void)saveMyNewsWithData:(NSDictionary*)dataDic
{
    NSString * heardImgId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"userimg"]];
    NSString * newsId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"id"]];
    NSString * bigTitle = [GameCommon getNewStringWithId:[dataDic objectForKey:@"title"]];
    NSString * msg = [GameCommon getNewStringWithId:[dataDic objectForKey:@"msg"]];
//    NSString * imageStr = [GameCommon getNewStringWithId:[dataDic objectForKey:@"hide"]];
    NSString * detailPageId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"detailPageId"]];
    NSString * createDate = [GameCommon getNewStringWithId:[dataDic objectForKey:@"createDate"]];
   
    NSString * type = [GameCommon getNewStringWithId:[dataDic objectForKey:@"type"]];
    NSString * commentObj = @"";
    if ([KISDictionaryHaveKey(dataDic, @"commentObj") isKindOfClass:[NSDictionary class]]) {
        commentObj = KISDictionaryHaveKey(KISDictionaryHaveKey(dataDic, @"commentObj"), @"msg");
    }
    NSString * urlLink = [GameCommon getNewStringWithId:[dataDic objectForKey:@"urlLink"]];
    NSString * zannum = [GameCommon getNewStringWithId:[dataDic objectForKey:@"zannum"]];
    NSString * showTitle = [GameCommon getNewStringWithId:[dataDic objectForKey:@"showtitle"]];

    NSString * userid = [GameCommon getNewStringWithId:[dataDic objectForKey:@"userid"]];
    NSString * username = [GameCommon getNewStringWithId:[dataDic objectForKey:@"username"]];
    NSString * img = [GameCommon getNewStringWithId:[dataDic objectForKey:@"thumb"]];//缩略图
    NSString * superStar = [GameCommon getNewStringWithId:[dataDic objectForKey:@"superstar"]];
    
    NSString * nickName = [GameCommon getNewStringWithId:[dataDic objectForKey:@"alias"]];
    if ([nickName isEqualToString:@""]) {
        nickName = [GameCommon getNewStringWithId:[dataDic objectForKey:@"nickname"]];
    }
    if ([KISDictionaryHaveKey(dataDic, @"destUser") isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *destDic = [dataDic objectForKey:@"destUser"];
        userid = [GameCommon getNewStringWithId:[destDic objectForKey:@"userid"]];
        username = [GameCommon getNewStringWithId:[destDic objectForKey:@"username"]];
        heardImgId = [GameCommon getNewStringWithId:[destDic objectForKey:@"userimg"]];
        superStar = [GameCommon getNewStringWithId:[destDic objectForKey:@"superstar"]];
        nickName = [GameCommon getNewStringWithId:[destDic objectForKey:@"alias"]];

        if ([nickName isEqualToString:@""]) {
            nickName = [GameCommon getNewStringWithId:[destDic objectForKey:@"nickname"]];
        }
    }

    if (newsId) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"newsId==[c]%@",newsId];
            DSMyNewsList * dMyNews = [DSMyNewsList MR_findFirstWithPredicate:predicate];
            if (!dMyNews)
                dMyNews = [DSMyNewsList MR_createInContext:localContext];
            dMyNews.heardImgId = heardImgId;
            dMyNews.newsId = newsId;
            dMyNews.bigTitle = bigTitle;
            dMyNews.msg = msg;
            dMyNews.detailPageId = detailPageId;
            dMyNews.createDate = createDate;
            dMyNews.nickName = nickName;
            dMyNews.type = type;
            dMyNews.commentObj = commentObj;
            dMyNews.urlLink = urlLink;
            dMyNews.img = img;
            dMyNews.zannum = zannum;
            dMyNews.userid = userid;
            dMyNews.username = username;
            dMyNews.superstar = superStar;
            dMyNews.showTitle = showTitle;
        }];
    }
}

+(void)cleanMyNewsList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dMyNews = [DSMyNewsList MR_findAllInContext:localContext];
        for (DSMyNewsList* news in dMyNews) {
            [news deleteInContext:localContext];
        }
    }];
}

+(void)saveFriendsNewsWithData:(NSDictionary*)dataDic
{
    NSString * heardImgId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"userimg"]];
    NSString * newsId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"id"]];
    NSString * bigTitle = [GameCommon getNewStringWithId:[dataDic objectForKey:@"title"]];
    NSString * msg = [GameCommon getNewStringWithId:[dataDic objectForKey:@"msg"]];
    //    NSString * imageStr = [GameCommon getNewStringWithId:[dataDic objectForKey:@"hide"]];
    NSString * detailPageId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"detailPageId"]];
    NSString * createDate = [GameCommon getNewStringWithId:[dataDic objectForKey:@"createDate"]];
    NSString * type = [GameCommon getNewStringWithId:[dataDic objectForKey:@"type"]];
    NSString * commentObj = @"";
    if ([KISDictionaryHaveKey(dataDic, @"commentObj") isKindOfClass:[NSDictionary class]]) {
        commentObj = KISDictionaryHaveKey(KISDictionaryHaveKey(dataDic, @"commentObj"), @"msg");
    }
    NSString * urlLink = [GameCommon getNewStringWithId:[dataDic objectForKey:@"urlLink"]];
    NSString * zannum = [GameCommon getNewStringWithId:[dataDic objectForKey:@"zannum"]];
    NSString * showTitle = [GameCommon getNewStringWithId:[dataDic objectForKey:@"showtitle"]];

    NSString * userid = [GameCommon getNewStringWithId:[dataDic objectForKey:@"userid"]];
    NSString * username = [GameCommon getNewStringWithId:[dataDic objectForKey:@"username"]];
    NSString * img = [GameCommon getNewStringWithId:[dataDic objectForKey:@"thumb"]];
    NSString * superStar = [GameCommon getNewStringWithId:[dataDic objectForKey:@"superstar"]];
    NSString * nickName = [GameCommon getNewStringWithId:[dataDic objectForKey:@"alias"]];
    if ([nickName isEqualToString:@""]) {
        nickName = [GameCommon getNewStringWithId:[dataDic objectForKey:@"nickname"]];
    }
    if ([KISDictionaryHaveKey(dataDic, @"destUser") isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *destDic = [dataDic objectForKey:@"destUser"];
        userid = [GameCommon getNewStringWithId:[destDic objectForKey:@"userid"]];
        username = [GameCommon getNewStringWithId:[destDic objectForKey:@"username"]];
        heardImgId = [GameCommon getNewStringWithId:[destDic objectForKey:@"userimg"]];
        superStar = [GameCommon getNewStringWithId:[destDic objectForKey:@"superstar"]];
        nickName = [GameCommon getNewStringWithId:[destDic objectForKey:@"alias"]];
        if ([nickName isEqualToString:@""]) {
            nickName = [GameCommon getNewStringWithId:[destDic objectForKey:@"nickname"]];
        }
    }
    if (newsId) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"newsId==[c]%@",newsId];
            DSFriendsNewsList * dUsersNews = [DSFriendsNewsList MR_findFirstWithPredicate:predicate];
            if (!dUsersNews)
                dUsersNews = [DSFriendsNewsList MR_createInContext:localContext];
            dUsersNews.heardImgId = heardImgId;
            dUsersNews.newsId = newsId;
            dUsersNews.bigTitle = bigTitle;
            dUsersNews.msg = msg;
            //            dMyNews.imageStr = sortnum;
            dUsersNews.detailPageId = detailPageId;
            dUsersNews.createDate = createDate;
            dUsersNews.nickName = nickName;
            dUsersNews.type = type;
            dUsersNews.commentObj = commentObj;
            dUsersNews.urlLink = urlLink;
            dUsersNews.img = img;
            dUsersNews.zannum = zannum;
            dUsersNews.userid = userid;
            dUsersNews.username = username;
            dUsersNews.showTitle = showTitle;
        }];
    }
}

+(void)cleanFriendsNewsList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dUsersNews = [DSFriendsNewsList MR_findAllInContext:localContext];
        for (DSFriendsNewsList* news in dUsersNews) {
            [news deleteInContext:localContext];
        }
    }];
}

#pragma mark - 打招呼存储相关
+(void)deleteAllHello
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dReceived = [DSReceivedHellos MR_findAllInContext:localContext];
        for (DSReceivedHellos* received in dReceived) {
            [received deleteInContext:localContext];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }];
}

+(void)deleteReceivedHelloWithUserId:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        NSArray * received = [DSReceivedHellos MR_findAllWithPredicate:predicate];
        for (int i = 0; i<received.count; i++) {
            DSReceivedHellos * rH = [received objectAtIndex:i];
            [rH MR_deleteInContext:localContext];
        }
    }];

}

+(void)deleteReceivedHelloWithUserId:(NSString *)userid withTime:(NSString *)times
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@ OR receiveTime==[c]%@",userid,times];
        NSArray * received = [DSReceivedHellos MR_findAllWithPredicate:predicate];
        for (int i = 0; i<received.count; i++) {
            DSReceivedHellos * rH = [received objectAtIndex:i];
            [rH MR_deleteInContext:localContext];
        }
    }];

}

+(NSString *)qureyUnreadForReceivedHellos
{
//    DSUnreadCount * unread = [DSUnreadCount MR_findFirst];
//    int theUnread = [unread.receivedHellosUnread intValue];
    NSArray * allReceived = [DSReceivedHellos MR_findAll];
    int theUnread = 0;
    for (int i = 0; i<allReceived.count; i++) {
        theUnread = theUnread + [[[allReceived objectAtIndex:i] unreadCount] intValue];
    }
    return [NSString stringWithFormat:@"%d",theUnread];
}

+(void)blankReceivedHellosUnreadCount
{
//    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//        DSUnreadCount * unread = [DSUnreadCount MR_findFirst];
//        unread.receivedHellosUnread = @"0";
//    }];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        thumbMsgs.unRead = @"0";
     }];
}

+(void)blankUnreadCountReceivedHellosForUser:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        DSReceivedHellos * dr = [DSReceivedHellos MR_findFirstWithPredicate:predicate];
        if (dr) {
            dr.unreadCount = @"0";
        }
    }];
}

+(NSArray *)queryAllReceivedHellos
{
    NSArray * rechellos = [DSReceivedHellos MR_findAllSortedBy:@"receiveTime" ascending:NO];
    NSMutableArray * hellosArray = [NSMutableArray array];
    for (int i = 0; i<rechellos.count; i++) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject:[[rechellos objectAtIndex:i] userId] forKey:@"userid"];
        [dict setObject:[[rechellos objectAtIndex:i] nickName] forKey:@"nickName"];
        NSLog(@"---------------%@",dict);
        //        NSRange range=[[[rechellos objectAtIndex:i] headImgID] rangeOfString:@","];
        //        if (range.location!=NSNotFound) {
        ////            NSArray *imageArray = [[[rechellos objectAtIndex:i] headImgID] componentsSeparatedByString:@","];
        //            [dict setObject:[[rechellos objectAtIndex:i] headImgID] forKey:@"headImgID"];
        //        }
        //        else
        [dict setObject:[[rechellos objectAtIndex:i] headImgID] forKey:@"headImgID"];
        [dict setObject:[[rechellos objectAtIndex:i] addtionMsg] forKey:@"addtionMsg"];
//        [dict setObject:[[rechellos objectAtIndex:i] acceptStatus] forKey:@"acceptStatus"];
        [dict setObject:[[rechellos objectAtIndex:i] receiveTime] forKey:@"receiveTime"];
        [dict setObject:[[rechellos objectAtIndex:i] unreadCount] forKey:@"unread"];
        
        [hellosArray addObject:dict];
    }
    return hellosArray;
}

+(NSDictionary *)qureyLastReceivedHello
{
    NSArray * rechellos = [DSReceivedHellos MR_findAllSortedBy:@"receiveTime" ascending:YES];
    NSMutableDictionary * lastHelloDict = [NSMutableDictionary dictionary];
    [lastHelloDict setObject:ZhaoHuLan forKey:@"sender"];
    if (rechellos.count>0) {
        DSReceivedHellos * lastRecHello = [rechellos lastObject];
        NSDate * tt = [lastRecHello receiveTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [lastHelloDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
        [lastHelloDict setObject:[NSString stringWithFormat:@"%@:%@",[lastRecHello nickName],[lastRecHello addtionMsg]] forKey:@"msg"];
    }
    //    else
    //    {
    //        NSTimeInterval uu = [[NSDate date] timeIntervalSince1970];
    //        [lastHelloDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
    //        [lastHelloDict setObject:@"暂时还没有新朋友" forKey:@"msg"];
    //    }
    return lastHelloDict;
}


+(void)updateReceivedHellosStatus:(NSString *)theStatus ForPerson:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        DSReceivedHellos * dReceivedHellos = [DSReceivedHellos MR_findFirstWithPredicate:predicate];
        if (dReceivedHellos)
        {
            dReceivedHellos.acceptStatus = theStatus;
        }
    }];
}

#pragma mark 好友推荐
//{"regtime":1387173496000,"username":"13371669965","remark":null,"nickname":"Fan","userid":"00000006","type":3,"guild":"黎明之翼"}
+(void)saveRecommendWithData:(NSDictionary*)userInfoDict
{
    NSString * userName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"username")];
    NSString * userNickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"nickname")];
    NSString * fromID = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"type")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"userid")];
     NSString * recommendReason = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"recommendReason")];
    NSArray* headArr = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"img")] componentsSeparatedByString:@","];
    NSString * headImgID = [headArr count] != 0 ? [headArr objectAtIndex:0] : @"";
    NSString * fromStr = userInfoDict[@"recommendMsg"];//推荐理由
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userName==[c]%@",userName];
        DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate];
        if (!Recommend)
        {
            Recommend = [DSRecommendList MR_createInContext:localContext];
        }
        Recommend.userName = userName;
        Recommend.nickName = userNickname;
        if ([DataStoreManager ifHaveThisUserInUserManager:fromID] || [DataStoreManager ifIsAttentionWithUserId:userid]) {
            Recommend.state = @"1";
        }
        else{
            Recommend.state = @"0";
        }
        Recommend.headImgID = headImgID;
        Recommend.fromStr = fromStr;
        Recommend.fromID = fromID;
        Recommend.userid = userid;
        Recommend.recommendReason=recommendReason;

    }];

}

+(void)updateRecommendStatus:(NSString *)theStatus ForPerson:(NSString *)userId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
         DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate];
        if (Recommend)
        {
            Recommend.state = theStatus;
        }
    }];
}

+(void)updateRecommendImgAndNickNameWithUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate];
        if (Recommend)
        {
            Recommend.nickName = nickName;
            Recommend.headImgID = img;
        }
    }];
}
#pragma mark 头衔、角色、战斗力等消息
//@dynamic messageuuid;
//@dynamic msgContent;
//@dynamic msgType;
//@dynamic sendTime;
//@dynamic myTitle;

+(void)saveOtherMsgsWithData:(NSDictionary*)userInfoDict
{
    NSString* messageuuid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"msgId")];
    NSString* msgContent = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"msg")];
    NSString* msgType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"msgType")];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"time")] doubleValue]];
    NSString* myTitle = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"title")];

    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSOtherMsgs * otherMsgs = [DSOtherMsgs MR_createInContext:localContext];
        otherMsgs.messageuuid = messageuuid;
        otherMsgs.msgContent = msgContent;
        otherMsgs.msgType = msgType;
        otherMsgs.sendTime = sendTime;
        otherMsgs.myTitle = myTitle;
    }];
}
#pragma mark 保存每日一闻消息
+(void)saveDSNewsMsgs:(NSDictionary*)msgDict
{
    NSString * msgContent = KISDictionaryHaveKey(msgDict, @"msg");
    NSString * msgType = KISDictionaryHaveKey(msgDict, @"msgType");
    NSString * msgId = KISDictionaryHaveKey(msgDict, @"msgId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msgDict objectForKey:@"time"] doubleValue]];
    NSString* title = KISDictionaryHaveKey(msgDict, @"title");
    NSDictionary *dic =[title JSONValue];
    NSString *gameid =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"gameid")];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSNewsMsgs * newsMsg = [DSNewsMsgs MR_createInContext:localContext];//所有消息
        newsMsg.messageuuid = msgId;
        newsMsg.msgcontent = msgContent;
        newsMsg.msgtype = msgType;
        newsMsg.mytitle = title;
        newsMsg.gameid = gameid;
        newsMsg.sendtime = sendTime;
        
        NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"gameid=[c]%@",gameid];
        DSNewsGameList * dnews = [DSNewsGameList MR_findFirstWithPredicate:predicate1];
        if (!dnews)
            dnews = [DSNewsGameList MR_createInContext:localContext];
        dnews.gameid = gameid;
        dnews.mytitle = title;
        dnews.time =[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }];
}

+(NSArray *)queryAllOtherMsg
{
    NSArray * otherMsgArr = [DSOtherMsgs MR_findAllSortedBy:@"sendTime" ascending:NO];
    NSMutableArray * resultArr = [NSMutableArray array];
    for (int i = 0; i<otherMsgArr.count; i++) {
        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        [dict setObject:[[otherMsgArr objectAtIndex:i] messageuuid] forKey:@"messageuuid"];
        [dict setObject:[[otherMsgArr objectAtIndex:i] msgContent] forKey:@"msgContent"];
        [dict setObject:[[otherMsgArr objectAtIndex:i] msgType] forKey:@"msgType"];
        
        NSDate * tt = [[otherMsgArr objectAtIndex:i] sendTime];
        NSTimeInterval uu = [tt timeIntervalSince1970];
        [dict setObject:[NSString stringWithFormat:@"%.f", uu] forKey:@"sendTime"];
//        [dict setObject:[[otherMsgArr objectAtIndex:i] sendTime] forKey:@"sendTime"];
        [dict setObject:[[otherMsgArr objectAtIndex:i] myTitle] forKey:@"myTitle"];
        
        [resultArr addObject:dict];
    }
    
    return resultArr;
}


+(void)cleanOtherMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * otherMsgs = [DSOtherMsgs MR_findAllInContext:localContext];
        for (DSOtherMsgs* other in otherMsgs) {
            [other deleteInContext:localContext];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }];
}

+(void)deleteOtherMsgWithUUID:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",uuid];
        DSOtherMsgs * otherMsgs = [DSOtherMsgs MR_findFirstWithPredicate:predicate];
        if (otherMsgs) {
            [otherMsgs MR_deleteInContext:localContext];
        }
        
    }];
}

+(void)changRecommendStateWithUserid:(NSString *)userid state:(NSString *)state
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
    DSRecommendList * dUser = [DSRecommendList MR_findFirstWithPredicate:predicate];
    if (dUser) {
        dUser.state = state;
    }
    }];
}

#pragma mark ---------黑名单操作


+(void)SaveBlackListWithDic:(NSDictionary *)dic WithType:(NSString *)type
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        NSString *userid = KISDictionaryHaveKey(dic, @"userid");
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSBlackList * blackList = [DSBlackList MR_findFirstWithPredicate:predicate];
        
        if (!blackList)
            blackList = [DSBlackList MR_createInContext:localContext];
        
        blackList.userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
        blackList.nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")];
        blackList.headimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")];
        blackList.time = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")];
        blackList.type = type;
    }];
    
}

+(void)deletePersonFromBlackListWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSBlackList * dblack = [DSBlackList MR_findFirstWithPredicate:predicate];

        if (dblack) {
            [dblack MR_deleteInContext:localContext];
        }

    }];

}

+(void)changeBlackListTypeWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSBlackList * dblack = [DSBlackList MR_findFirstWithPredicate:predicate];
        
        if (dblack) {
            dblack.type = @"2";
        }
    }];
}




+(void)deleteAllBlackList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dBlack = [DSBlackList MR_findAllInContext:localContext];
        for (DSBlackList* bl in dBlack) {
            [bl MR_deleteInContext:localContext];
        }
    }];

}

+(NSMutableArray *)queryAllBlackListInfo
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:[DSBlackList MR_findAll]];
    return array;
}


+(NSArray *)queryAllBlackListUserid
{
    NSMutableArray *arr = [NSMutableArray array];
    
    NSArray *array = [DSBlackList MR_findAll];
    for (DSBlackList *bl in array) {
        [arr addObject:bl.userid];
    }
    return arr;
}

+ (BOOL)isBlack:(NSString*)userId//是否存在黑名单里
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
    DSBlackList * user = [DSBlackList MR_findFirstWithPredicate:predicate];
    if (user)
    {
        return YES;
    }
    return NO;
}


#pragma mark - 保存最后一条动态
+(void)saveDSlatestDynamic:(NSDictionary *)characters
{
    NSString * alias = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"alias")];
    NSString * commentnum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"commentnum")];
    NSString * createDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"createDate")];
    NSString * msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"id")];
    NSString * img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"img")];
    NSString * msg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"msg")];
    NSString * nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"nickname")];
    NSString * rarenum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"rarenum")];
    NSString * superstar = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"superstar")];
    NSString * thumb = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"thumb")];
    NSString * title = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"title")];
    NSString * type = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"type")];
    NSString * urlLink = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"urlLink")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"userid")];
    NSString * userimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"userimg")];
    NSString * username = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"username")];
    NSString * zannum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"zannum")];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSLatestDynamic * latestDynamic = [DSLatestDynamic MR_findFirstWithPredicate:predicate];
        if (!latestDynamic)
            latestDynamic = [DSLatestDynamic MR_createInContext:localContext];
        latestDynamic.alias = alias;
        latestDynamic.commentnum= commentnum;
        latestDynamic.createDate = createDate;
        latestDynamic.msgId = msgId;
        latestDynamic.img = img;
        latestDynamic.msg = msg;
        latestDynamic.nickname = nickname;
        latestDynamic.rarenum = rarenum;
        latestDynamic.superstar = superstar;
        latestDynamic.thumb = thumb;
        latestDynamic.title = title;
        latestDynamic.type = type;
        latestDynamic.urlLink = urlLink;
        latestDynamic.userid = userid;
        latestDynamic.userimg = userimg;
        latestDynamic.username = username;
        latestDynamic.zannum = zannum;
    }];
}

//删除所有角色
+(void)deleteAllDSCharacters:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        NSArray * dbCharacters = [DSCharacters MR_findAllWithPredicate:predicate];
        for (DSCharacters* chara in dbCharacters) {
            [chara MR_deleteInContext:localContext];
        }
    }];
}
//删除所有头衔
+(void)deleteAllDSTitle:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        NSArray * dbTitles = [DSTitle MR_findAllWithPredicate:predicate];
        for (DSTitle* title in dbTitles) {
            [title MR_deleteInContext:localContext];
        }
    }];
}

#pragma mark - 保存角色
+(void)saveDSCharacters:(NSDictionary *)characters UserId:(NSString*)userid
{
    NSString * auth = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"auth")];
    NSString * failedmsg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"failedmsg")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"gameid")];
    NSString * charactersId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"id")];
    NSString * img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"img")];
    NSString * name = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"name")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"realm")];
    NSString * value1 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value1")];
    NSString * value2 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value2")];
    NSString * value3 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value3")];

    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"charactersId==[c]%@",charactersId];
        DSCharacters * dscharacters = [DSCharacters MR_findFirstWithPredicate:predicate];
        if (!dscharacters)
            dscharacters = [DSCharacters MR_createInContext:localContext];
        dscharacters.userid=userid;
        dscharacters.auth=auth;
        dscharacters.failedmsg=failedmsg;
        dscharacters.gameid=gameid;
        dscharacters.charactersId=charactersId;
        dscharacters.img=img;
        dscharacters.name=name;
        dscharacters.realm=realm;
        dscharacters.value1=value1;
        dscharacters.value2=value2;
        dscharacters.value3=value3;
    }];
}

#pragma mark - 保存头衔
+(void)saveDSTitle:(NSDictionary *)titles
{
    NSString * characterid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"characterid")];
    NSString * charactername = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"charactername")];
    NSString * clazz = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"clazz")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"gameid")];
    NSString * hasDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"hasDate")];
    NSString * hide = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"hide")];
    NSString * titleId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"titleid")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"realm")];
    NSString * sortnum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"sortnum")];
    NSString * ids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"id")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"userid")];
    NSString * userimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titles, @"userimg")];
    NSDictionary * titleObjects = KISDictionaryHaveKey(titles, @"titleObj");
    [self saveDSTitleObject:titleObjects];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ids==[c]%@",ids];
        DSTitle * titles = [DSTitle MR_findFirstWithPredicate:predicate];
        if (!titles)
            titles = [DSTitle MR_createInContext:localContext];
        titles.characterid=characterid;
        titles.charactername=charactername;
        titles.clazz=clazz;
        titles.gameid=gameid;
        titles.hasDate=hasDate;
        titles.hide=hide;
        titles.titleId=titleId;
        titles.realm=realm;
        titles.sortnum=sortnum;
        titles.ids=ids;
        titles.userid=userid;
        titles.userimg=userimg;
    }];
}

#pragma mark - 保存TitleObject
+(void)saveDSTitleObject:(NSDictionary *)titleObjects
{
    NSString * createDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"createDate")];
    NSString * evolution = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"evolution")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"gameid")];
    NSString * icon = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"icon")];
    NSString * titleId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"id")];
    NSString * img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"img")];
    NSString * rank = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"rank")];
    NSString * ranktype = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"ranktype")];
    NSString * rankvaltype = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"rankvaltype")];
    NSString * rarememo = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"rarememo")];
    NSString * rarenum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"rarenum")];
    NSString * remark = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"remark")];
    NSString * remarkDetail = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"remarkDetail")];
    NSString * simpletitle = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"simpletitle")];
    NSString * sortnum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"sortnum")];
    NSString * title = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"title")];
    NSString * titlekey = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"titlekey")];
    NSString * titletype = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjects, @"titletype")];

    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"titleId==[c]%@",titleId];
        DSTitleObject * titleObject = [DSTitleObject MR_findFirstWithPredicate:predicate];
        if (!titleObject)
            titleObject = [DSTitleObject MR_createInContext:localContext];
        titleObject.createDate=createDate;
        titleObject.evolution=evolution;
        titleObject.gameid=gameid;
        titleObject.icon=icon;
        titleObject.titleId=titleId;
        titleObject.img=img;
        titleObject.rank=rank;
        titleObject.ranktype=ranktype;
        titleObject.rankvaltype=rankvaltype;
        titleObject.rarememo=rarememo;
        titleObject.rarenum=rarenum;
        titleObject.remark=remark;
        titleObject.remarkDetail=remarkDetail;
        titleObject.simpletitle=simpletitle;
        titleObject.sortnum=sortnum;
        titleObject.title=title;
        titleObject.titlekey=titlekey;
        titleObject.titletype=titletype;
    }];
}
//查找所有的角色
+(NSMutableArray *)queryCharacters:(NSString*)userId
{
    NSMutableArray *charactersArray = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
    NSArray *array = [DSCharacters MR_findAllWithPredicate:predicate];
    for (DSCharacters *character in array) {
        NSMutableDictionary * characterDic = [NSMutableDictionary dictionary];
        [characterDic setObject:character.auth forKey:@"auth"];
         [characterDic setObject:character.failedmsg forKey:@"failedmsg"];
         [characterDic setObject:character.gameid forKey:@"gameid"];
         [characterDic setObject:character.charactersId forKey:@"id"];
         [characterDic setObject:character.img forKey:@"img"];
         [characterDic setObject:character.name forKey:@"name"];
         [characterDic setObject:character.realm forKey:@"realm"];
         [characterDic setObject:character.value1 forKey:@"value1"];
         [characterDic setObject:character.value2 forKey:@"value2"];
         [characterDic setObject:character.value3 forKey:@"value3"];
        [charactersArray addObject:characterDic];
    }
    return charactersArray;
}


//查找最后一条动态
+(NSMutableDictionary *)queryLatestDynamic:(NSString*)userId
{
    NSMutableDictionary * lasrDic = [NSMutableDictionary dictionary];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
    DSLatestDynamic *lastds = [DSLatestDynamic MR_findFirstWithPredicate:predicate];
    if (lastds) {
        [lasrDic setObject:lastds.alias forKey:@"alias"];
        [lasrDic setObject:lastds.commentnum forKey:@"commentnum"];
        [lasrDic setObject:lastds.createDate forKey:@"createDate"];
        [lasrDic setObject:lastds.msgId forKey:@"msgId"];
        [lasrDic setObject:lastds.img forKey:@"img"];
        [lasrDic setObject:lastds.msg forKey:@"msg"];
        [lasrDic setObject:lastds.nickname forKey:@"nickname"];
        [lasrDic setObject:lastds.rarenum forKey:@"rarenum"];
        [lasrDic setObject:lastds.superstar forKey:@"superstar"];
        [lasrDic setObject:lastds.thumb forKey:@"thumb"];
        [lasrDic setObject:lastds.title forKey:@"title"];
        //    [lasrDic setObject:lastds.titleObj forKey:@"titleObj"];
        [lasrDic setObject:lastds.type forKey:@"type"];
        [lasrDic setObject:lastds.urlLink forKey:@"urlLink"];
        [lasrDic setObject:lastds.userid forKey:@"userid"];
        [lasrDic setObject:lastds.userimg forKey:@"userimg"];
        [lasrDic setObject:lastds.username forKey:@"username"];
        [lasrDic setObject:lastds.zannum forKey:@"zannum"];
    }
    return lasrDic;
}


//查找所有的角色
+(NSMutableArray *)queryTitle:(NSString*)userId Hide:(NSString*)hide
{
    
    NSMutableArray *titlesArray = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@ and hide==[c]%@",userId,hide];
    NSArray *array = [DSTitle MR_findAllWithPredicate:predicate];
    for (DSTitle *title in array) {
        NSMutableDictionary * titleDic = [NSMutableDictionary dictionary];
        NSMutableDictionary * titleObjectDic = [self queryDSTitleObject:title.titleId];
        [titleDic setObject:title.characterid forKey:@"characterid"];
        [titleDic setObject:title.charactername forKey:@"charactername"];
        [titleDic setObject:title.clazz forKey:@"clazz"];
        [titleDic setObject:title.gameid forKey:@"gameid"];
        [titleDic setObject:title.hasDate forKey:@"hasDate"];
        [titleDic setObject:title.hide forKey:@"hide"];
        [titleDic setObject:title.titleId forKey:@"titleId"];
        [titleDic setObject:title.realm forKey:@"realm"];
        [titleDic setObject:title.ids forKey:@"id"];
        [titleDic setObject:title.userid forKey:@"userid"];
        [titleDic setObject:title.userimg forKey:@"userimg"];
        [titleDic setObject:titleObjectDic forKey:@"titleObj"];
        [titlesArray addObject:titleDic];
    }
    return titlesArray;
}

+(NSMutableDictionary*)queryDSTitleObject:(NSString*)titleId
{
    NSMutableDictionary * titleObjectDic = [NSMutableDictionary dictionary];
    NSPredicate * predicateObject = [NSPredicate predicateWithFormat:@"titleId==[c]%@",titleId];
    DSTitleObject * titleObject = [DSTitleObject MR_findFirstWithPredicate:predicateObject];
    [titleObjectDic setObject:titleObject.createDate forKey:@"createDate"];
    [titleObjectDic setObject:titleObject.evolution forKey:@"evolution"];
    [titleObjectDic setObject:titleObject.gameid forKey:@"gameid"];
    [titleObjectDic setObject:titleObject.icon forKey:@"icon"];
    [titleObjectDic setObject:titleObject.titleId forKey:@"id"];
    [titleObjectDic setObject:titleObject.img forKey:@"img"];
    [titleObjectDic setObject:titleObject.rank forKey:@"rank"];
    [titleObjectDic setObject:titleObject.ranktype forKey:@"ranktype"];
    [titleObjectDic setObject:titleObject.rankvaltype forKey:@"rankvaltype"];
    [titleObjectDic setObject:titleObject.rarememo forKey:@"rarememo"];
    [titleObjectDic setObject:titleObject.rarenum forKey:@"rarenum"];
    [titleObjectDic setObject:titleObject.remark forKey:@"remark"];
    [titleObjectDic setObject:titleObject.remarkDetail forKey:@"remarkDetail"];
    [titleObjectDic setObject:titleObject.simpletitle forKey:@"simpletitle"];
    [titleObjectDic setObject:titleObject.sortnum forKey:@"sortnum"];
    [titleObjectDic setObject:titleObject.title forKey:@"title"];
    [titleObjectDic setObject:titleObject.titlekey forKey:@"titlekey"];
    [titleObjectDic setObject:titleObject.titletype forKey:@"titletype"];
    return titleObjectDic;
}



#pragma mark - 保存群组列表信息
+(void)saveDSGroupList:(NSDictionary *)groupList
{
    NSString * backgroundImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"backgroundImg")];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"groupId")];
    NSString * groupName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"groupName")];
    NSString * state = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"state")];
    
    NSString * currentMemberNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"currentMemberNum")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"gameid")];
    NSString * level = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"level")];
    NSString * maxMemberNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"maxMemberNum")];
    NSString * createDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"createDate")];
    NSString * distance = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"distance")];
    NSString * experience = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"experience")];
    NSString * gameRealm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"gameRealm")];
    NSString * groupUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"groupUsershipType")];
    NSString * info = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"info")];
    NSString * infoImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"infoImg")];
    NSString * location = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"location")];
    
    NSMutableArray * userList = KISDictionaryHaveKey(groupList, @"memberList");
    if ([userList isKindOfClass:[NSMutableArray class]] && userList.count>0) {
        for (NSMutableDictionary * user in userList) {
            [self saveDSGroupUser:user GroupId:groupId];
        }
    }
    
    [self upDataDSGroupApplyMsgByGroupId:groupId GroupName:groupName GroupBackgroundImg:backgroundImg];//更新群通知消息列表
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        DSGroupList * groupInfo = [DSGroupList MR_findFirstWithPredicate:predicate];
        if (!groupInfo)
            groupInfo = [DSGroupList MR_createInContext:localContext];
        groupInfo.backgroundImg = backgroundImg;
        groupInfo.groupId = groupId;
        groupInfo.groupName = groupName;
        groupInfo.state = state;
        groupInfo.currentMemberNum = currentMemberNum;
        groupInfo.gameid = gameid;
        groupInfo.level = level;
        groupInfo.maxMemberNum = maxMemberNum;
        groupInfo.createDate = createDate;
        groupInfo.distance = distance;
        groupInfo.experience = experience;
        groupInfo.gameRealm = gameRealm;
        groupInfo.groupUsershipType = groupUsershipType;
        groupInfo.info = info;
        groupInfo.infoImg = infoImg;
        groupInfo.location = location;
        NSString * avb = groupInfo.available?groupInfo.available:@"0";
        groupInfo.available =[avb isEqualToString:@"0"]?@"0":avb;
    }];
}
#pragma mark - 保存群组用户列表信息
+(void)saveDSGroupUser:(NSDictionary *)groupUser GroupId:(NSString*)groupId
{
    NSString * userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupUser, @"userid")];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userId==[c]%@",groupId,userId];
        DSGroupUser * groupUserInfo = [DSGroupUser MR_findFirstWithPredicate:predicate];
        if (!groupUserInfo)
            groupUserInfo = [DSGroupUser MR_createInContext:localContext];
        groupUserInfo.groupId = groupId;
        groupUserInfo.userId = userId;
    }];
}
//查询群用户列表
+(NSMutableArray *)queryGroupUserList:(NSString*)groupId
{
    
    NSMutableArray *userList = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
    NSArray *array = [DSGroupUser MR_findAllWithPredicate:predicate];
    
    for (DSGroupUser * groupUser in array) {
        NSMutableDictionary * grouoDic = [self queryGroupUser:groupUser];
        [userList addObject:grouoDic];
    }
    return userList;
}
+(NSMutableDictionary*)queryGroupUser:(DSGroupUser*)groupuser
{
    if (!groupuser) {
        return nil;
    }
    NSMutableDictionary * groupUserInfo = [NSMutableDictionary dictionary];
    [groupUserInfo setObject:groupuser.groupId forKey:@"groupId"];
    [groupUserInfo setObject:groupuser.userId forKey:@"userId"];
    return groupUserInfo;
}
//查询群组列表
+(NSMutableArray *)queryGroupInfoList
{
    
    NSMutableArray *titlesArray = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupUsershipType!=[c]%@",@"3"];
    NSArray *array = [DSGroupList MR_findAllWithPredicate:predicate];
    for (DSGroupList * group in array) {
        NSMutableDictionary * grouoDic = [self queryGroupInfo:group];
        [titlesArray addObject:grouoDic];
    }
    return titlesArray;
}


+(NSInteger)queryGroupCount
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupUsershipType!=[c]%@",@"3"];
    NSArray *array = [DSGroupList MR_findAllWithPredicate:predicate];
    if (array>0) {
        return array.count;
    }
    return 0;
}

+(NSMutableDictionary*)queryGroupInfo:(DSGroupList*)group
{
    if (!group) {
        return nil;
    }
    NSMutableDictionary * groupInfo = [NSMutableDictionary dictionary];
    [groupInfo setObject:group.backgroundImg forKey:@"backgroundImg"];
    [groupInfo setObject:group.groupId forKey:@"groupId"];
    [groupInfo setObject:group.groupName forKey:@"groupName"];
    [groupInfo setObject:group.state forKey:@"state"];
    [groupInfo setObject:group.currentMemberNum forKey:@"currentMemberNum"];
    [groupInfo setObject:group.gameid forKey:@"gameid"];
    [groupInfo setObject:group.level forKey:@"level"];
    [groupInfo setObject:group.maxMemberNum forKey:@"maxMemberNum"];
    [groupInfo setObject:group.createDate forKey:@"createDate"];
    [groupInfo setObject:group.distance forKey:@"distance"];
    [groupInfo setObject:group.experience forKey:@"experience"];
    [groupInfo setObject:group.gameRealm forKey:@"gameRealm"];
    [groupInfo setObject:group.groupUsershipType forKey:@"groupUsershipType"];
    [groupInfo setObject:group.info forKey:@"info"];
    [groupInfo setObject:group.infoImg forKey:@"infoImg"];
    [groupInfo setObject:group.location forKey:@"location"];
    [groupInfo setObject:group.available forKey:@"available"];
    return groupInfo;
}

+(NSMutableDictionary*)queryGroupInfoByGroupId:(NSString*)groupId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
    DSGroupList * group = [DSGroupList MR_findFirstWithPredicate:predicate];
    NSMutableDictionary * groupInfo = [self queryGroupInfo:group];
    return groupInfo;
}
//更新群的可用状态
+(void)updateGroupState:(NSString*)groupId GroupState:(NSString*)groupState GroupUserShipType:(NSString*)groupShipType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        DSGroupList * group = [DSGroupList MR_findFirstWithPredicate:predicate];
        if (group) {
            group.available = groupState;
            group.groupUsershipType = groupShipType;
        }
    }];
}
//根据groupId 删除群信息
+(void)deleteGroupInfoByGoupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        DSGroupList * group = [DSGroupList MR_findFirstWithPredicate:predicate];
        if (group) {
            [group MR_deleteInContext:localContext];
        }
    }];
}

#pragma mark - 保存申请加入群的消息
+(void)saveDSGroupApplyMsg:(NSDictionary *)msg
{
    NSString * sender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"sender")];
    NSString * msgContent = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msg")];
    NSString * msgType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgType")];
    NSString * msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgId")];
    NSString * payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    NSString * applicationId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"applicationId")];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    NSString * groupName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupName")];
    NSString * nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"nickname")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"userid")];
    NSString * backgroundImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"backgroundImg")];
    NSString * userImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"userImg")];
    NSString * msgText = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"msg")];
    
    NSString * billboard = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"billboard")];
    NSString * billboardId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"billboardId")];
    NSString * createDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"createDate")];
    
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    
//    if([msgType isEqualToString:@"disbandGroup"]){
//        [self deleteMsgByGroupId:groupId];
//    }
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgId==[c]%@",msgId];
        DSGroupApplyMsg * commonMsg = [DSGroupApplyMsg MR_findFirstWithPredicate:predicate];
        if (!commonMsg)
            commonMsg = [DSGroupApplyMsg MR_createInContext:localContext];
        commonMsg.state = @"0";
        commonMsg.msgId = msgId;
        commonMsg.msgType = msgType;
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        commonMsg.senTime = sendTime;
        commonMsg.payload = payloadStr;
        commonMsg.msgContent = msgContent;
        commonMsg.senderId = sender;
        commonMsg.applicationId = applicationId;
        commonMsg.groupId= groupId;
        commonMsg.groupName = groupName;
        commonMsg.nickname = nickname;
        commonMsg.userid= userid;
        commonMsg.userImg = userImg;
        commonMsg.backgroundImg = backgroundImg;
        commonMsg.msg = msgText;
        commonMsg.billboard=billboard;
        commonMsg.billboardId= billboardId;
        commonMsg.createDate= createDate;
    }];
}
#pragma mark - 查询群通知消息
+(NSMutableArray*)queryDSGroupApplyMsg
{
    NSMutableArray * msgList = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType!=[c]%@",@"groupBillboard"];//剔除群公告通知
    NSArray * groupArrlyList = [DSGroupApplyMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate];
    for (DSGroupApplyMsg * apm in groupArrlyList) {
        [msgList addObject:[self queryDSGroupApplyMsg:apm]];
    }
    return msgList;
}

#pragma mark - 根据msgType查询群通知消息
+(NSMutableArray*)queryDSGroupApplyMsgByMsgType:(NSString*)msgType
{
    NSMutableArray * msgList = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
    NSArray * groupArrlyList = [DSGroupApplyMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate];
    for (DSGroupApplyMsg * apm in groupArrlyList) {
        [msgList addObject:[self queryDSGroupApplyMsg:apm]];
    }
    return msgList;
}

+(void)changedDSGroupApplyMsgWithGroupId:(NSString *)groupId name:(NSString *)name
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * groupArrlyList = [DSGroupApplyMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate];
        for (DSGroupApplyMsg * apm in groupArrlyList) {
            apm.nickname  = name;
        }
    }];
}
+(void)changedDSGroupApplyMsgImgWithGroupId:(NSString *)groupId img:(NSString *)img
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * groupArrlyList = [DSGroupApplyMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate];
        for (DSGroupApplyMsg * apm in groupArrlyList) {
            apm.backgroundImg  = img;
        }
    }];
}


//更新群通知表的信息
+(void)upDataDSGroupApplyMsgByGroupId:(NSString*)groupId GroupName:(NSString*)groupName GroupBackgroundImg:(NSString*)backgroundImg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * commonMsgs = [DSGroupApplyMsg findAllWithPredicate:predicate];
        for (DSGroupApplyMsg * commonMsg in commonMsgs) {
            if (commonMsg) {
                commonMsg.groupName = groupName;
                commonMsg.backgroundImg = backgroundImg;
            }
        }
    }];
}

+(NSMutableDictionary*)queryDSGroupApplyMsg:(DSGroupApplyMsg*)msgDS
{
    if (!msgDS) {
        return nil;
    }
    NSMutableDictionary * msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:msgDS.state forKey:@"state"];
    [msgDic setObject:msgDS.msgId forKey:@"msgId"];
    [msgDic setObject:msgDS.msgType forKey:@"msgType"];
    [msgDic setObject:msgDS.receiveTime forKey:@"receiveTime"];
    NSTimeInterval uu = [msgDS.senTime timeIntervalSince1970];
    [msgDic setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"senTime"];
    [msgDic setObject:msgDS.payload forKey:@"payload"];
    [msgDic setObject:msgDS.msgContent forKey:@"msgContent"];
    [msgDic setObject:msgDS.senderId forKey:@"senderId"];
    [msgDic setObject:msgDS.applicationId forKey:@"applicationId"];
    [msgDic setObject:msgDS.groupId forKey:@"groupId"];
    [msgDic setObject:msgDS.groupName forKey:@"groupName"];
    [msgDic setObject:msgDS.nickname forKey:@"nickname"];
    [msgDic setObject:msgDS.userid forKey:@"userid"];
    [msgDic setObject:msgDS.userImg forKey:@"userImg"];
    [msgDic setObject:msgDS.backgroundImg forKey:@"backgroundImg"];
    [msgDic setObject:msgDS.msg forKey:@"msg"];
    [msgDic setObject:msgDS.billboard forKey:@"billboard"];
    [msgDic setObject:msgDS.billboardId forKey:@"billboardId"];
    [msgDic setObject:msgDS.createDate forKey:@"createDate"];
    return msgDic;
}

+(void)updateMsgState:(NSString*)userid State:(NSString*)state MsgType:(NSString*)msgType GroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"userid==[c]%@ and msgType==[c]%@ and state==[c]%@ and groupId==[c]%@",userid,msgType,@"0",groupId];
        NSArray * commMsgs = [DSGroupApplyMsg findAllWithPredicate:predicate];
        for (DSGroupApplyMsg * commonMsg in commMsgs) {
            if (commonMsg) {
                commonMsg.state = state;
            }
        }
    }];
}


//删除该群的所有消息
+(void)deleteMsgByGroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * commMsgs = [DSGroupApplyMsg findAllWithPredicate:predicate];
        for (DSGroupApplyMsg * commonMsg in commMsgs) {
            if (commonMsg) {
                 [commonMsg MR_deleteInContext:localContext];
            }
        }
        
        NSArray * historyMsg = [DSGroupMsgs findAllWithPredicate:predicate];
        for (DSGroupMsgs * commonMsg in historyMsg) {
            if (commonMsg) {
                [commonMsg MR_deleteInContext:localContext];
            }
        }
        DSGroupList * groupInfo = [DSGroupList MR_findFirstWithPredicate:predicate];
        if (groupInfo)
        {
            [groupInfo MR_deleteInContext:localContext];
        }
    }];
}
@end
