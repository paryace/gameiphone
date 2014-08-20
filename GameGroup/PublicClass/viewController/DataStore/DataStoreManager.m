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
#import "DSTeamList.h"
#import "DSTeamNotificationMsg.h"
#import "DSMemberUserInfo.h"
#import "DSTeamUserInfo.h"
#import "DSTeamUser.h"
#import "DSPreferenceInfo.h"
#import "DSCreateTeamUserInfo.h"
#import "DSPreferenceMsg.h"
#import "DSPrepared.h"


@implementation DataStoreManager

-(void)nothing
{}
- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

//激活
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

#pragma mark - 更新会话列表界面消息
+(void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            thumbMsgs.senderNickname = nickName;
            thumbMsgs.senderimg = img;
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
#pragma mark - 更新会话列表界面消息
+(void)storeThumbMsgUser:(NSString*)userid type:(NSString*)type
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",userid,@"normalchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            thumbMsgs.sayHiType = type;
        }
    }];
}
#pragma mark - 更新会话列表界面消息
+(void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            thumbMsgs.senderNickname = nickName;
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//删除所有的显示消息
+(void)deleteAllThumbMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * thumbMsgs = [DSThumbMsgs MR_findAllInContext:localContext];
        for (DSThumbMsgs* msg in thumbMsgs) {
            [msg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//-----
+(void)deleteThumbMsgWithSender:(NSString *)sender Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs) {
            [thumbMsgs MR_deleteInContext:localContext];
        }
    }];
    if (successcompletion) {
        successcompletion(nil,nil);
    }
}


+(void)deleteThumbMsgWithGroupId:(NSString *)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * thumbMsgs = [DSThumbMsgs MR_findAllWithPredicate:predicate];
        for (DSThumbMsgs * thumbMsg in thumbMsgs) {
            if (thumbMsgs) {
                [thumbMsg MR_deleteInContext:localContext];
            }
        }
    }];
    NSArray * m_applyArray = [DataStoreManager queryDSGroupApplyMsg];
    if (m_applyArray.count>0) {
        [self uploadStoreMsg:[m_applyArray objectAtIndex:0]];
    }
}
+(void)deleteSayHiMsgWithSenderAndSayType:(NSString *)senderType SayHiType:(NSString*)sayHiType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"senderType==[c]%@ and sayHiType==[c]%@",senderType,sayHiType];
        NSArray * thumbMsg = [DSThumbMsgs MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<thumbMsg.count; i++) {
            DSThumbMsgs * thumb = [thumbMsg objectAtIndex:i];
            [thumb MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//删除该群消息记录
+(void)deleteGroupMsgWithSenderAndSayType:(NSString *)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ ",groupId];
        NSArray * thumbMsg = [DSGroupMsgs MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<thumbMsg.count; i++) {
            DSGroupMsgs * thumb = [thumbMsg objectAtIndex:i];
            [thumb MR_deleteInContext:localContext];
        }
    }];
}
//删除群组通知的显示消息
+(void)deleteJoinGroupApplication
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",GROUPAPPLICATIONSTATE];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    } completion:^(BOOL success, NSError *error) {
        
    }];
}

//根据msgType删除通知表的消息
+(void)deleteJoinGroupApplicationByMsgType:(NSString*)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgType==[c]%@ ",msgType];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp inContext:localContext];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//根据msgId删除通知表的消息
+(void)deleteJoinGroupApplicationWithMsgId:(NSString *)msgId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgId==[c]%@ ",msgId];
        DSGroupApplyMsg * dGroup = [DSGroupApplyMsg MR_findFirstWithPredicate:predicateApp inContext:localContext];
        if (dGroup) {
            [dGroup MR_deleteInContext:localContext];
        }
    } completion:^(BOOL success, NSError *error) {
        
    }];
}
//清空群组通知
+(void)clearJoinGroupApplicationMsg:(void (^)(BOOL success))block
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgType!=[c]%@ ",@"groupBillboard"];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp inContext:localContext];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if(block)
         {
             block(success);
         }
     }];
}

//根据msgType和GroupId删除通知表的消息
+(void)deleteJoinGroupApplicationByMsgTypeAndGroupId:(NSString*)msgType GroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"msgType==[c]%@ and groupId=[c]%@",msgType,groupId];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp inContext:localContext];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    } completion:^(BOOL success, NSError *error) {
        
    }];
}

//根据GroupId删除通知表的消息
+(void)deleteJoinGroupApplicationByGroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicateApp = [NSPredicate predicateWithFormat:@"groupId=[c]%@",groupId];
        NSArray * msgs = [DSGroupApplyMsg MR_findAllWithPredicate:predicateApp inContext:localContext];
        for (int i = 0; i<msgs.count; i++) {
            DSGroupApplyMsg * msg = [msgs objectAtIndex:i];
            [msg MR_deleteInContext:localContext];
        }
    }];
}



#pragma mark - 保存聊天记录
+(void)saveDSCommonMsg:(NSDictionary *)msg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];//所有消息
        commonMsg.sender = [msg objectForKey:@"sender"];
        commonMsg.msgContent = KISDictionaryHaveKey(msg, @"msg")?KISDictionaryHaveKey(msg, @"msg"):@"";
        commonMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        commonMsg.msgType = KISDictionaryHaveKey(msg, @"msgType");
        commonMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        commonMsg.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        commonMsg.status = @"1";
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

#pragma mark - 保存群组聊天记录
+(void)saveDSGroupMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSGroupMsgs * groupMsg = [DSGroupMsgs MR_createInContext:localContext];
        groupMsg.sender = [msg objectForKey:@"sender"];
        groupMsg.msgContent = KISDictionaryHaveKey(msg, @"msg")?KISDictionaryHaveKey(msg, @"msg"):@"";
        groupMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        groupMsg.msgType = KISDictionaryHaveKey(msg, @"msgType");
        groupMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        groupMsg.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        groupMsg.status = @"1";
        groupMsg.groupId = KISDictionaryHaveKey(msg, @"groupId");
        groupMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        groupMsg.teamPosition = KISDictionaryHaveKey(msg, @"teamPosition");
    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(msg);
//         }
//     }
     ];
    
    if (block) {
        block(msg);
    }
}



#pragma mark - 保存就位确认历史消息
+(void)saveDSGroupMsgOKCancel:(NSDictionary *)msg SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    NSDictionary * payloadDic = [KISDictionaryHaveKey(msg, @"payload") JSONValue];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSGroupMsgs * groupMsg = [DSGroupMsgs MR_createInContext:localContext];
        groupMsg.sender = KISDictionaryHaveKey(payloadDic, @"userid");
        groupMsg.msgContent = KISDictionaryHaveKey(msg, @"msg")?KISDictionaryHaveKey(msg, @"msg"):@"";
        groupMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        groupMsg.msgType = KISDictionaryHaveKey(msg, @"msgType");
        groupMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        groupMsg.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        groupMsg.status = @"1";
        groupMsg.groupId = KISDictionaryHaveKey(msg, @"groupId");
        groupMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        groupMsg.teamPosition = KISDictionaryHaveKey(msg, @"teamPosition");
        }
     ];
    
    if (block) {
        block(msg);
    }
}

//保存正常聊天的消息
+(void)storeNewNormalChatMsgs:(NSDictionary *)msg SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [self saveNewNormalChatMsgs:msg LoCon:localContext];
        }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(msg);
//         }
//     }
    ];
    if (block) {
        block(msg);
    }
}

//保存正常聊天的消息
+(void)saveNewNormalChatMsg:(NSArray *)msgs SaveSuccess:(void (^)(NSDictionary *msgDic))block{
    [MagicalRecord 	saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        for (NSDictionary * msg in msgs) {
            [self saveNewNormalChatMsgs:msg LoCon:localContext];
        }
    }
//     completion:^(BOOL success, NSError *error) {
//         for (NSDictionary * msg in msgs) {
//             if (block) {
//                 block(msg);
//             }
//         }
//     }
     ];
    for (NSDictionary * msg in msgs) {
        if (block) {
            block(msg);
        }
    }
}

//保存正常聊天的消息
+(void)saveNewNormalChatMsgs:(NSDictionary *)msg LoCon:(NSManagedObjectContext *)localContext
{
    NSString * sender = [msg objectForKey:@"sender"];
    NSString *sayhiType = KISDictionaryHaveKey(msg, @"sayHiType")?KISDictionaryHaveKey(msg, @"sayHiType"):@"1";
    NSPredicate * hasedpredicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",KISDictionaryHaveKey(msg, @"msgId")];
    DSCommonMsgs * commonMsg = [DSCommonMsgs MR_findFirstWithPredicate:hasedpredicate inContext:localContext];
    if (!commonMsg) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",sender,KISDictionaryHaveKey(msg, @"msgType")];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        int unread;
        if (!thumbMsgs){
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [thumbMsgs.unRead intValue];
        }
        thumbMsgs.sender = sender;
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = KISDictionaryHaveKey(msg, @"msg");
        thumbMsgs.sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        thumbMsgs.senderType = COMMONUSER;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.msgType = KISDictionaryHaveKey(msg, @"msgType");
        thumbMsgs.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        thumbMsgs.status = @"1";//已发送
        thumbMsgs.sayHiType = sayhiType;
        thumbMsgs.senderimg = @"";
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
        //
        if ([sayhiType isEqualToString:@"2"]){//自定义一条用于显示打招呼的消息
            NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234567wxxxxxxxxx"];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate1 inContext:localContext];
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.msgContent = KISDictionaryHaveKey(msg, @"msg");//打招呼内容
            thumbMsgs.sender = @"1234567wxxxxxxxxx";
            thumbMsgs.senderNickname = @"";
            thumbMsgs.senderType = COMMONUSER;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.msgType = @"sayHi";
            thumbMsgs.messageuuid = @"wx123";
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = @"1";
            thumbMsgs.sendTime=[NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
            thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        }
        //
        commonMsg = [DSCommonMsgs MR_createInContext:localContext];//所有消息
        commonMsg.sender = [msg objectForKey:@"sender"];
        commonMsg.msgContent = KISDictionaryHaveKey(msg, @"msg")?KISDictionaryHaveKey(msg, @"msg"):@"";
        commonMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        commonMsg.msgType = KISDictionaryHaveKey(msg, @"msgType");
        commonMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        commonMsg.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        commonMsg.status = @"1";
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }
}


//保存接收到群组的消息
+(void)storeNewGroupMsgs:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        [self saveGroupChatMsgs:msg LoCon:localContext];
    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(msg);
//         }
//     }
     ];
    if (block) {
        block(msg);
    }
}
//保存群组的消息
+(void)saveNewGroupChatMsg:(NSArray *)msgs SaveSuccess:(void (^)(NSDictionary *msgDic))block{
    [MagicalRecord 	saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSDictionary * msg in msgs) {
            [self saveGroupChatMsgs:msg LoCon:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         for (NSDictionary * msg in msgs) {
             if (block) {
                 block(msg);
             }
         }
     }];
}
+(void)saveGroupChatMsgs:(NSDictionary *)msg LoCon:(NSManagedObjectContext *)localContext
{
    NSString * senderNickname = [[[UserManager singleton] getUser:[msg objectForKey:@"sender"]] objectForKey:@"nickname"];
    NSPredicate * predicateMsg = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",KISDictionaryHaveKey(msg, @"msgId")];
    DSGroupMsgs * hasedmsg = [DSGroupMsgs MR_findFirstWithPredicate:predicateMsg inContext:localContext];
    if (!hasedmsg) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",KISDictionaryHaveKey(msg, @"groupId"), KISDictionaryHaveKey(msg, @"msgType"),@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        int unread;
        if (!thumbMsgs){
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [thumbMsgs.unRead intValue];
        }
        thumbMsgs.sender = [msg objectForKey:@"sender"];
        thumbMsgs.senderNickname = senderNickname;
        thumbMsgs.msgContent = KISDictionaryHaveKey(msg, @"msg");
        thumbMsgs.groupId = KISDictionaryHaveKey(msg, @"groupId");
        thumbMsgs.sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.msgType = KISDictionaryHaveKey(msg, @"msgType");
        thumbMsgs.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        thumbMsgs.status = @"1";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.payLoad = KISDictionaryHaveKey(msg, @"payload");
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
        
        //
        DSGroupMsgs * groupMsg = [DSGroupMsgs MR_createInContext:localContext];
        groupMsg.sender = [msg objectForKey:@"sender"];
        groupMsg.msgContent = KISDictionaryHaveKey(msg, @"msg")?KISDictionaryHaveKey(msg, @"msg"):@"";
        groupMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
        groupMsg.msgType = KISDictionaryHaveKey(msg, @"msgType");
        groupMsg.payload = KISDictionaryHaveKey(msg, @"payload");
        groupMsg.messageuuid = KISDictionaryHaveKey(msg, @"msgId");
        groupMsg.status = @"1";
        groupMsg.groupId = KISDictionaryHaveKey(msg, @"groupId");
        groupMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        groupMsg.teamPosition = KISDictionaryHaveKey(msg, @"teamPosition");
    }
}


+(void)uploadStoreMsg:(NSDictionary *)msg
{
    NSString * sender = [msg objectForKey:@"senderId"];
    NSString * msgContent = KISDictionaryHaveKey(msg, @"msgContent");
    NSString * msgId = KISDictionaryHaveKey(msg, @"msgId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"senTime"] doubleValue]];
    NSString* payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",GROUPAPPLICATIONSTATE];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = sender;
        thumbMsgs.senderNickname = KISDictionaryHaveKey(msg, @"msgTitle");
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = JOINGROUPMSG;
        thumbMsgs.msgType = GROUPAPPLICATIONSTATE;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",0];
        thumbMsgs.messageuuid = msgId;
        thumbMsgs.status = @"1";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.groupId = groupId;
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }
     completion:^(BOOL success, NSError *error) {
         
     }];

}
+(void)storeMyPayloadmsg:(NSDictionary *)message
{
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",receicer,msgType];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
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
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"2";
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
+(void)storeMyMessage:(NSDictionary *)message
{
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {

        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",receicer ,@"normalchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = receicer;
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = KISDictionaryHaveKey(message, @"msg");
        thumbMsgs.sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
        thumbMsgs.senderType = COMMONUSER;
        thumbMsgs.msgType = KISDictionaryHaveKey(message, @"msgType");
        thumbMsgs.senderimg = @"";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",0];
        thumbMsgs.messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
        thumbMsgs.status = @"2";
        thumbMsgs.groupId = KISDictionaryHaveKey(message, @"groupId");
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        
        //
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];
        commonMsg.sender = KISDictionaryHaveKey(message, @"sender");
        commonMsg.senderNickname = @"";
        commonMsg.msgContent = KISDictionaryHaveKey(message, @"msg")?KISDictionaryHaveKey(message, @"msg"):@"";
        commonMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
        commonMsg.receiver = receicer;
        commonMsg.msgType = KISDictionaryHaveKey(message, @"msgType");
        commonMsg.payload = KISDictionaryHaveKey(message, @"payload");
        commonMsg.messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
        commonMsg.status = @"2";
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}


+(void)storeMyGroupThumbMessage:(NSDictionary *)message
{
    NSString* groupId = KISDictionaryHaveKey(message, @"groupId");
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId,@"groupchat",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = KISDictionaryHaveKey(message, @"msg");
        thumbMsgs.sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.msgType = KISDictionaryHaveKey(message, @"msgType");
        thumbMsgs.senderimg = @"";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",0];
        thumbMsgs.messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
        thumbMsgs.status = @"2";//发送中
        thumbMsgs.groupId = groupId;
        thumbMsgs.payLoad = KISDictionaryHaveKey(message, @"payload");
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        
        //
        DSGroupMsgs * commonMsg = [DSGroupMsgs MR_createInContext:localContext];
        commonMsg.sender = KISDictionaryHaveKey(message, @"sender");
        commonMsg.senderNickname = @"";
        commonMsg.msgContent = KISDictionaryHaveKey(message, @"msg")?KISDictionaryHaveKey(message, @"msg"):@"";
        commonMsg.senTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
        commonMsg.receiver = KISDictionaryHaveKey(message, @"receiver");
        commonMsg.msgType = KISDictionaryHaveKey(message, @"msgType");
        commonMsg.payload = KISDictionaryHaveKey(message, @"payload");
        commonMsg.messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
        commonMsg.status = KISDictionaryHaveKey(message, @"status");
        commonMsg.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        commonMsg.groupId = groupId;
        commonMsg.teamPosition = KISDictionaryHaveKey(message, @"teamPosition");
    }
     completion:^(BOOL success, NSError *error) {
         
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
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
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
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)storeMyGroupMessage:(NSDictionary *)message Successcompletion:(MRSaveCompletionHandler)successcompletion
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
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId, @"groupchat",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicates inContext:localContext];
        int unread;
        if (!thumbMsgs){
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [thumbMsgs.unRead intValue];
        }
        thumbMsgs.sender = sender;
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.groupId = groupId;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.msgType = @"groupchat";
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"1";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.payLoad = payloadStr;
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
        
        
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
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}



+(void)changeMyMessage:(NSString *)messageuuid PayLoad:(NSString*)payload
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",messageuuid];
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        commonMsg.payload = payload;//动态 消息json
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)changeMyGroupMessage:(NSString *)messageuuid PayLoad:(NSString*)payload
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",messageuuid];
        DSGroupMsgs * commonMsg = [DSGroupMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        commonMsg.payload = payload;
    }
     completion:^(BOOL success, NSError *error) {
         
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
+(void)blankMsgUnreadCountForUser:(NSString *)userid  Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and msgType==[c]%@",userid,@"normalchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }
     
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}
//把群组聊天消息的未读消息设置为0
+(void)blankGroupMsgUnreadCountForUser:(NSString *)groupId  Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId,@"groupchat",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}


//把群组聊天消息的未读消息设置为0
+(void)blankGroupMsgUnreadCountForUser:(NSString *)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@",groupId,@"groupchat"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }];
}





+(void)blankMsgUnreadCountFormsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs) {
            thumbMsgs.unRead = @"0";
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        if ([senderType isEqualToString:COMMONUSER]) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            [thumbMsgs MR_deleteInContext:localContext];
            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"sender==[c]%@ OR receiver==[c]%@",sender,sender];
            NSArray * commonMsgs = [DSCommonMsgs MR_findAllWithPredicate:predicate2 inContext:localContext];
            for (int i = 0; i<commonMsgs.count; i++) {
                DSCommonMsgs * rH = [commonMsgs objectAtIndex:i];
                [rH MR_deleteInContext:localContext];
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
     }];
}
//-----删除所有的normalchat显示消息消息
+(void)deleteThumbMsgsByMsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
            NSArray * thumbMsg = [DSThumbMsgs MR_findAllWithPredicate:predicate inContext:localContext];
            for (int i = 0; i<thumbMsg.count; i++) {
                DSThumbMsgs * thumb = [thumbMsg objectAtIndex:i];
                [thumb MR_deleteInContext:localContext];
            }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//清除所有的聊天消息
+(void)clearAllChatMessage:(void (^)(BOOL success))block
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        //显示消息
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@ or msgType==[c]%@ or msgType==[c]%@ or msgType==[c]%@",@"payloadchat",@"sayHi",@"normalchat",@"groupchat"];
        NSArray * thumbMsg = [DSThumbMsgs MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<thumbMsg.count; i++) {
            DSThumbMsgs * thumb = [thumbMsg objectAtIndex:i];
            [thumb MR_deleteInContext:localContext];
        }
        
        //正常聊天消息
        NSPredicate * predicateNormalChat = [NSPredicate predicateWithFormat:@"msgType==[c]%@",@"normalchat"];
        NSArray * commonMsgs = [DSCommonMsgs MR_findAllWithPredicate:predicateNormalChat inContext:localContext];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSCommonMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
        
        //群组消息
        NSArray * commonGroupMsg = [DSGroupMsgs MR_findAll];
        for (int i = 0; i<commonGroupMsg.count; i++) {
            DSGroupMsgs * common = [commonGroupMsg objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
        //组队消息
        NSArray * commTeamMsg = [DSTeamNotificationMsg findAll];
        for (DSTeamNotificationMsg * commonMsg in commTeamMsg) {
            [commonMsg deleteInContext:localContext];
        }
        
        //就位确认消息
        NSArray * commPreparedMsgs = [DSPrepared findAll];
        for (DSPrepared * commPreparedMsg in commPreparedMsgs) {
            [commPreparedMsg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (block) {
             block(success);
         }
     }];

}


//-----删除所有的normalchat历史记录消息
+(void)deleteCommonMsgsByMsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
        NSArray * commonMsgs = [DSCommonMsgs MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSCommonMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}





+(void)deleteGroupMsgByMsgType:(NSString *)msgType
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@",msgType];
        NSArray * commonMsgs = [DSGroupMsgs MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSGroupMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//删除所有的群聊历史记录
+(void)clearGroupChatHistroyMsg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * commonMsgs = [DSGroupMsgs MR_findAll];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSGroupMsgs * common = [commonMsgs objectAtIndex:i];
            [common MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)changGroupMsgLocation:(NSString*)groupId UserId:(NSString*)userid TeamPosition:(NSString*)teamPosition  Successcompletion:(MRSaveCompletionHandler)successcompletion

{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and sender==[c]%@",groupId,userid];
        NSArray * commonMsgs = [DSGroupMsgs MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSGroupMsgs * common = [commonMsgs objectAtIndex:i];
            common.teamPosition = teamPosition;
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}

//-----

+(void)deleteMsgInCommentWithUUid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",uuid];
        DSCommonMsgs * commonMsgs = [DSCommonMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsgs) {
            [commonMsgs MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
+(void)deleteGroupMsgInCommentWithUUid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",uuid];
        DSGroupMsgs * commonMsgs = [DSGroupMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsgs) {
            [commonMsgs MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)deleteAllNewsMsgs
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * newsMsgs = [DSNewsMsgs MR_findAllInContext:localContext];
        for (DSNewsMsgs* msg in newsMsgs) {
            [msg deleteInContext:localContext];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000011"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
        [thumbMsgsDict setObject:[[DSArray objectAtIndex:i] teamPosition]?[[DSArray objectAtIndex:i] teamPosition] : @"" forKey:@"teamPosition"];
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * commonMsgs = [DSCommonMsgs MR_findAllInContext:localContext];
        for (DSCommonMsgs* msg in commonMsgs) {
            [msg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
    [DataStoreManager deleteAllThumbMsg];
}

+(void)refreshThumbMsgsAfterDeleteCommonMsg:(NSDictionary *)message ForUser:(NSString *)userid ifDel:(BOOL)del
{
    NSString * msgContent = [message objectForKey:@"msg"];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[message objectForKey:@"time"] doubleValue]];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate;
        predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
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
        
    }
     completion:^(BOOL success, NSError *error) {
         
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


+(NSArray * )qAllThumbMessagesWithType:(NSString *)type
{   NSMutableArray * msgList = [NSMutableArray array];
    NSPredicate * predicate= [NSPredicate predicateWithFormat:@"sayHiType==[c]%@",type];
    NSArray *array =[DSThumbMsgs MR_findAllSortedBy:@"sendTime" ascending:NO withPredicate:predicate];
    for (DSThumbMsgs * apm in array) {
        [msgList addObject:[self queryDSThumbMessage:apm]];
    }
    return msgList;
}

+(NSMutableDictionary*)queryDSThumbMessage:(DSThumbMsgs*)msgDS
{
    if (!msgDS) {
        return nil;
    }
    NSMutableDictionary * msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:msgDS.sender?msgDS.sender:@"" forKey:@"senderId"];
    [msgDic setObject:msgDS.senderNickname?msgDS.senderNickname:@"" forKey:@"senderNickname"];
    [msgDic setObject:msgDS.msgContent?msgDS.msgContent:@"" forKey:@"msgContent"];
    [msgDic setObject:msgDS.groupId?msgDS.groupId:@"" forKey:@"groupId"];
    [msgDic setObject:msgDS.senderType?msgDS.senderType:@"" forKey:@"senderType"];
    NSTimeInterval uu = [msgDS.sendTime timeIntervalSince1970];
    [msgDic setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"sendTime"];
    [msgDic setObject:msgDS.unRead?msgDS.unRead:@"" forKey:@"unRead"];
    [msgDic setObject:msgDS.msgType?msgDS.msgType:@"" forKey:@"msgType"];
    [msgDic setObject:msgDS.messageuuid?msgDS.messageuuid:@"" forKey:@"messageuuid"];
    [msgDic setObject:msgDS.status?msgDS.status:@"" forKey:@"status"];
    [msgDic setObject:msgDS.sayHiType?msgDS.sayHiType:@"" forKey:@"sayHiType"];
    [msgDic setObject:msgDS.receiveTime?msgDS.receiveTime:@"" forKey:@"receiveTime"];
    [msgDic setObject:msgDS.payLoad?msgDS.payLoad:@"" forKey:@"payload"];
    return msgDic;
}

+(NSMutableDictionary*)qSayHiMsg:(NSString *)type
{
    NSArray * sayHiList=[self qAllThumbMessagesWithType:type];
    if (sayHiList.count>0) {
        return [sayHiList objectAtIndex:0];
    }
    return nil;
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        if (messageuuid && messageuuid.length > 0) {//0失败 1发送到服务器 2发送中 3已送达 4已读
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@", messageuuid];
            DSCommonMsgs * commonMsgs = [DSCommonMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            if (commonMsgs) {
                commonMsgs.status = status;
            }
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            if (thumbMsgs){
                thumbMsgs.status = status;
            }
        }
    }];
    
    
//    if (messageuuid && messageuuid.length > 0) {//0失败 1发送到服务器 2发送中 3已送达 4已读
//        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@", messageuuid];
//        DSCommonMsgs * commonMsgs = [DSCommonMsgs MR_findFirstWithPredicate:predicate];
//        if (commonMsgs) {
//            commonMsgs.status = status;
//        }
//        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
//        if (thumbMsgs){
//            thumbMsgs.status = status;
//        }
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    }
}

+(void)refreshGroupMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status
{
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        if (messageuuid && messageuuid.length > 0) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@", messageuuid];
            DSGroupMsgs * commonMsgs = [DSGroupMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            if (commonMsgs) {
                commonMsgs.status = status;
            }
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
            if (thumbMsgs){
                thumbMsgs.status = status;
            }
        }
    }];
    
//    if (messageuuid && messageuuid.length > 0) {
//        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@", messageuuid];
//        DSGroupMsgs * commonMsgs = [DSGroupMsgs MR_findFirstWithPredicate:predicate];
//        if (commonMsgs) {
//            commonMsgs.status = status;
//        }
//        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
//        if (thumbMsgs){
//            thumbMsgs.status = status;
//        }
//        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreAndWait];
//    }
}

+(void)newSaveFriendList:(NSArray *)array withshiptype:(NSString *)nameindex
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSMutableDictionary * userInfo in array){
            [userInfo setObject:nameindex forKey:@"nameIndex"];
            [self saveUserInfo:userInfo withshiptype:KISDictionaryHaveKey(userInfo, @"shiptype") Loco:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
+(void)newSaveFriendInfo:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        [self saveUserInfo:userInfo withshiptype:shiptype Loco:localContext];
    }
    completion:^(BOOL success, NSError *error) {
         
     }];
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
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
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
            [self updateDSlatestDynamic:userId NickName:nickName Image:headImgID Alias:alias];
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
        }
        completion:^(BOOL success, NSError *error) {
            if (success&&[userId isEqualToString:[[NSUserDefaults standardUserDefaults]objectForKey:kMYUSERID]]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshMyInfomation" object:nil];
            }
        }];
    }
}

+(void)saveUserInfo:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype Loco:(NSManagedObjectContext*)localContext
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
    
    if ([GameCommon isEmtity:userId]) {
        return;
    }
   
    NSPredicate * predicated = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
    DSLatestDynamic * latestDynamic = [DSLatestDynamic MR_findFirstWithPredicate:predicated];
    latestDynamic.alias = alias?alias:@"";
    latestDynamic.nickname = nickName?nickName:@"";
    latestDynamic.userimg = headImgID?headImgID:@"";
    
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
    dUser.nameIndex = nameIndex?nameIndex:@"";
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
            dFname.index = nameIndex?nameIndex:@"";
            return ;
        }
        if([shiptype isEqualToString:@"3"])
        {
            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
            DSFansNameIndex * dFname = [DSFansNameIndex MR_findFirstWithPredicate:predicate2];
            if (!dFname)
                dFname = [DSFansNameIndex MR_createInContext:localContext];
            dFname.index = nameIndex?nameIndex:@"";
            return;
        }
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

+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dUser) {
            dUser.shiptype = [NSString stringWithFormat:@"%@",type];
        }
        NSLog(@"duser====%@----sht-%@",dUser.userId,dUser.shiptype);
    } completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}


+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type 
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dUser) {
            dUser.shiptype = [NSString stringWithFormat:@"%@",type];
        }
        NSLog(@"duser====%@----sht-%@",dUser.userId,dUser.shiptype);
        
    } completion:^(BOOL success, NSError *error) {
        if (success) {
            NSLog(@"成员修改成功。。。");
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];

        }else{
            NSLog(@"成员修改失败");
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
            [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
                if ([type isEqualToString:@"1"]) {
                    NSPredicate* predicateIndex = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSNameIndex* name = [DSNameIndex MR_findFirstWithPredicate:predicateIndex inContext:localContext];
                    [name MR_deleteInContext:localContext];
                }
                else  if ([type isEqualToString:@"2"]) {
                    NSPredicate* predicateIndex = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSAttentionNameIndex* name = [DSAttentionNameIndex MR_findFirstWithPredicate:predicateIndex inContext:localContext];
                    [name MR_deleteInContext:localContext];
                }
                
                else if ([type isEqualToString:@"3"]) {
                    NSPredicate* predicateIndex = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                    DSFansNameIndex* name = [DSFansNameIndex MR_findFirstWithPredicate:predicateIndex inContext:localContext];
                    [name MR_deleteInContext:localContext];
                }
                
            }
             completion:^(BOOL success, NSError *error) {
                 
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

+(void)saveDynamicAboutMe:(NSDictionary *)info SaveSuccess:(void (^)(NSDictionary *msgDic))block
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
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgid==[c]%@",msgid];
        DSCircleWithMe * dCircle= [DSCircleWithMe MR_findFirstWithPredicate:predicate inContext:localContext];
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

    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(info);
//         }
//     }
     ];
    
    if (block) {
        block(info);
    }
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgid==[c]%@",msgid];
        DSCircleWithMe * dUserManager = [DSCircleWithMe MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)deleteAllcomment
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * newsMsgs = [DSCircleWithMe MR_findAllInContext:localContext];
        for (DSNewsMsgs* msg in newsMsgs) {
            [msg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}




+(void)saveCommentsWithDic:(NSDictionary *)dic
{
    NSString *uuid = KISDictionaryHaveKey(dic, @"uuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineComments * offline= [DSOfflineComments MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!offline)
            offline = [DSOfflineComments MR_createInContext:localContext];
        offline.msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"msgId")];
        offline.comments = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"comments")];
        offline.destCommentId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"destCommentId")];
        offline.destUserid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"destUserid")];
        offline.uuid = uuid;
    }
     completion:^(BOOL success, NSError *error) {
         
     }];

}
+(NSArray *)queryallcomments
{
    NSArray *array= [DSOfflineComments MR_findAll];
    return array;

}
+(void)removeOfflineCommentsWithuuid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineComments * dUserManager = [DSOfflineComments MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];

}

+(void)saveOfflineZanWithDic:(NSDictionary *)dic
{
    NSString *uuid = KISDictionaryHaveKey(dic, @"uuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineZan * offline= [DSOfflineZan MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!offline)
            offline = [DSOfflineZan MR_createInContext:localContext];
        offline.msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"msgId")];
        offline.uuid = uuid;
    }
     completion:^(BOOL success, NSError *error) {
         
     }];

}
+(NSArray *)queryallOfflineZan
{
    NSArray *array= [DSOfflineZan MR_findAll];
    return array;
}
+(void)removeOfflineZanWithuuid:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"uuid==[c]%@",uuid];
        DSOfflineZan * dUserManager = [DSOfflineZan MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
            DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate inContext:localContext];
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
                DSNameIndex * dFname = [DSNameIndex MR_findFirstWithPredicate:predicate2 inContext:localContext];
                if (!dFname)
                    dFname = [DSNameIndex MR_createInContext:localContext];
                
                dFname.index = nameIndex;
            }
            [DataStoreManager cleanIndexWithNameIndex:oldNameIndex withType:dUser.shiptype];
        }
         completion:^(BOOL success, NSError *error) {
             
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

+(void)deleteMemberFromListWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (Recommend)
        {
            [Recommend MR_deleteInContext:localContext];
        }
    }];
     
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userName==[c]%@",username];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dUser) {
            dUser.userName = username;
            dUser.nickName = nickName;
            dUser.signature = [userInfoDict objectForKey:@"signature"];
        }

    }
     completion:^(BOOL success, NSError *error) {
         
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
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"newsId==[c]%@",newsId];
            DSMyNewsList * dMyNews = [DSMyNewsList MR_findFirstWithPredicate:predicate inContext:localContext];
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
        }
         completion:^(BOOL success, NSError *error) {
             
         }];
    }
}

+(void)cleanMyNewsList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dMyNews = [DSMyNewsList MR_findAllInContext:localContext];
        for (DSMyNewsList* news in dMyNews) {
            [news deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"newsId==[c]%@",newsId];
            DSFriendsNewsList * dUsersNews = [DSFriendsNewsList MR_findFirstWithPredicate:predicate inContext:localContext];
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
        }
         completion:^(BOOL success, NSError *error) {
             
         }];
    }
}

+(void)cleanFriendsNewsList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dUsersNews = [DSFriendsNewsList MR_findAllInContext:localContext];
        for (DSFriendsNewsList* news in dUsersNews) {
            [news deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

#pragma mark - 打招呼存储相关
+(void)deleteAllHello:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dReceived = [DSReceivedHellos MR_findAllInContext:localContext];
        for (DSReceivedHellos* received in dReceived) {
            [received deleteInContext:localContext];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}

+(void)deleteReceivedHelloWithUserId:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        NSArray * received = [DSReceivedHellos MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<received.count; i++) {
            DSReceivedHellos * rH = [received objectAtIndex:i];
            [rH MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];

}

+(void)deleteReceivedHelloWithUserId:(NSString *)userid withTime:(NSString *)times
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@ OR receiveTime==[c]%@",userid,times];
        NSArray * received = [DSReceivedHellos MR_findAllWithPredicate:predicate inContext:localContext];
        for (int i = 0; i<received.count; i++) {
            DSReceivedHellos * rH = [received objectAtIndex:i];
            [rH MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234"];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        thumbMsgs.unRead = @"0";
     }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)blankUnreadCountReceivedHellosForUser:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        DSReceivedHellos * dr = [DSReceivedHellos MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dr) {
            dr.unreadCount = @"0";
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        DSReceivedHellos * dReceivedHellos = [DSReceivedHellos MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dReceivedHellos)
        {
            dReceivedHellos.acceptStatus = theStatus;
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

#pragma mark 好友推荐
+(void)saveRecommendWithData:(NSArray*)recommendArr MsgInfo:(NSDictionary *)info SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        NSString * msgType = KISDictionaryHaveKey(info, @"msgType");
        NSString * msgId = KISDictionaryHaveKey(info, @"msgId");
        NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[info objectForKey:@"time"] doubleValue]];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ and sayHiType==[c]%@",@"12345",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = @"12345";
        thumbMsgs.senderNickname = @"推荐好友";
        thumbMsgs.msgContent = KISDictionaryHaveKey(info, @"disStr");
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = RECOMMENDFRIEND;
        thumbMsgs.msgType = msgType;
        thumbMsgs.unRead = @"1";
        thumbMsgs.messageuuid = msgId;
        thumbMsgs.status = @"1";//已发送
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        
        for (NSDictionary* userInfoDict in recommendArr) {
            NSString * userName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"username")];
            NSString * userNickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"nickname")];
            NSString * fromID = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"type")];
            NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"userid")];
            NSString * recommendReason = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"recommendReason")];
            NSArray* headArr = [[GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"img")] componentsSeparatedByString:@","];
            NSString * recommendMsg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"recommendMsg")];
            NSString * headImgID = [headArr count] != 0 ? [headArr objectAtIndex:0] : @"";
            NSString * fromStr = userInfoDict[@"recommendMsg"];//推荐理由
            
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userName==[c]%@",userName];
            DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate inContext:localContext];
            if (!Recommend)
                Recommend = [DSRecommendList MR_createInContext:localContext];
            Recommend.userName = userName;
            Recommend.nickName = userNickname;
            Recommend.state = @"0";
            Recommend.headImgID = headImgID;
            Recommend.fromStr = fromStr;
            Recommend.fromID = fromID;
            Recommend.userid = userid;
            Recommend.recommendReason=recommendReason;
            Recommend.recommendMsg = recommendMsg;

        }
    }
//     completion:^(BOOL success, NSError *error) {
//         if(block){
//             block(info);
//         }
//     }
     ];
    if(block){
        block(info);
    }

}

+(void)updateRecommendStatus:(NSString *)theStatus ForPerson:(NSString *)userId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
         DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (Recommend)
        {
            Recommend.state = theStatus;
        }
    }];
}

+(void)updateRecommendImgAndNickNameWithUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSRecommendList * Recommend = [DSRecommendList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (Recommend)
        {
            Recommend.nickName = nickName;
            Recommend.headImgID = img;
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
#pragma mark 头衔、角色、战斗力等消息

+(void)saveOtherMsgsWithData:(NSDictionary*)userInfoDict  SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    NSString* messageuuid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"msgId")];
    NSString* msgContent = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"msg")];
    NSString* msgType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"msgType")];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"time")] doubleValue]];
    NSString* myTitle = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfoDict, @"title")];

    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = @"1";
        thumbMsgs.senderNickname = [userInfoDict objectForKey:@"title"];
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = OTHERMESSAGE;
        thumbMsgs.msgType = msgType;
        thumbMsgs.sendTimeStr = [userInfoDict objectForKey:@"time"];
        int unread = [thumbMsgs.unRead intValue];
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"1";//已发送
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];

        DSOtherMsgs * otherMsgs = [DSOtherMsgs MR_createInContext:localContext];
        otherMsgs.messageuuid = messageuuid;
        otherMsgs.msgContent = msgContent;
        otherMsgs.msgType = msgType;
        otherMsgs.sendTime = sendTime;
        otherMsgs.myTitle = myTitle;
    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(userInfoDict);
//         }
//     }
     ];
    if (block) {
        block(userInfoDict);
    }
}
#pragma mark 保存每日一闻消息
+(void)saveDSNewsMsgs:(NSDictionary*)msgDict SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    NSString * msgContent = KISDictionaryHaveKey(msgDict, @"msg");
    NSString * msgType = KISDictionaryHaveKey(msgDict, @"msgType");
    NSString * msgId = KISDictionaryHaveKey(msgDict, @"msgId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msgDict objectForKey:@"time"] doubleValue]];
    NSString* title = KISDictionaryHaveKey(msgDict, @"title");
    NSDictionary *dic =[title JSONValue];
    NSString *gameid =[NSString stringWithFormat:@"%@",KISDictionaryHaveKey(dic, @"gameid")];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicateNews = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"sys00000011"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicateNews inContext:localContext];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = @"sys00000011";
        thumbMsgs.senderNickname = @"每日一闻";
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = DAILYNEWS;
        thumbMsgs.msgType = msgType;
        thumbMsgs.unRead = @"1";
        thumbMsgs.messageuuid = msgId;
        thumbMsgs.status = @"1";//已发送
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        
        DSNewsMsgs * newsMsg = [DSNewsMsgs MR_createInContext:localContext];//所有消息
        newsMsg.messageuuid = msgId;
        newsMsg.msgcontent = msgContent;
        newsMsg.msgtype = msgType;
        newsMsg.mytitle = title;
        newsMsg.gameid = gameid;
        newsMsg.sendtime = sendTime;
        
        NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"gameid=[c]%@",gameid];
        DSNewsGameList * dnews = [DSNewsGameList MR_findFirstWithPredicate:predicate1 inContext:localContext];
        if (!dnews)
            dnews = [DSNewsGameList MR_createInContext:localContext];
        dnews.gameid = gameid;
        dnews.mytitle = title;
        dnews.time =[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(msgDict);
//         }
//     }
     ];
    if (block) {
        block(msgDict);
    }
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * otherMsgs = [DSOtherMsgs MR_findAllInContext:localContext];
        for (DSOtherMsgs* other in otherMsgs) {
            [other deleteInContext:localContext];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (thumbMsgs)
        {
            [thumbMsgs deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)deleteOtherMsgWithUUID:(NSString *)uuid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"messageuuid==[c]%@",uuid];
        DSOtherMsgs * otherMsgs = [DSOtherMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (otherMsgs) {
            [otherMsgs MR_deleteInContext:localContext];
        }
        
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)changRecommendStateWithUserid:(NSString *)userid state:(NSString *)state
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {

    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
    DSRecommendList * dUser = [DSRecommendList MR_findFirstWithPredicate:predicate inContext:localContext];
    if (dUser) {
        dUser.state = state;
    }
    }
     completion:^(BOOL success, NSError *error) {
         if (!success) {
             NSLog(@"修改失败");
         }else{
             NSLog(@"修改成功");
         }
     }];
}

#pragma mark ---------黑名单操作


+(void)SaveBlackListWithDic:(NSDictionary *)dic WithType:(NSString *)type
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        NSString *userid = KISDictionaryHaveKey(dic, @"userid");
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSBlackList * blackList = [DSBlackList MR_findFirstWithPredicate:predicate inContext:localContext];
        
        if (!blackList)
            blackList = [DSBlackList MR_createInContext:localContext];
        
        blackList.userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"userid")];
        blackList.nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"nickname")];
        blackList.headimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"img")];
        blackList.time = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")];
        blackList.type = type;
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
    
}

+(void)deletePersonFromBlackListWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSBlackList * dblack = [DSBlackList MR_findFirstWithPredicate:predicate inContext:localContext];

        if (dblack) {
            [dblack MR_deleteInContext:localContext];
        }

    }];

}

+(void)changeBlackListTypeWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSBlackList * dblack = [DSBlackList MR_findFirstWithPredicate:predicate inContext:localContext];
        
        if (dblack) {
            dblack.type = @"2";
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}




+(void)deleteAllBlackList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dBlack = [DSBlackList MR_findAllInContext:localContext];
        for (DSBlackList* bl in dBlack) {
            [bl MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
        [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
            DSLatestDynamic * latestDynamic = [DSLatestDynamic MR_findFirstWithPredicate:predicate inContext:localContext];
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
        }
         completion:^(BOOL success, NSError *error) {
             
         }];
}

//删除最后一条动太
+(void)deleteDSlatestDynamic:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSLatestDynamic * latestDynamic = [DSLatestDynamic MR_findFirstWithPredicate:predicate inContext:localContext];
       [latestDynamic MR_deleteInContext:localContext];
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)updateDSlatestDynamic:(NSString*)userid NickName:(NSString*)nickname Image:(NSString*)userimg Alias:(NSString*)alias
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSLatestDynamic * latestDynamic = [DSLatestDynamic MR_findFirstWithPredicate:predicate inContext:localContext];
        latestDynamic.alias = alias?alias:@"";
        latestDynamic.nickname = nickname?nickname:@"";
        latestDynamic.userimg = userimg?userimg:@"";
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//删除所有角色
+(void)deleteAllDSCharacters:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        NSArray * dbCharacters = [DSCharacters MR_findAllWithPredicate:predicate inContext:localContext];
        for (DSCharacters* chara in dbCharacters) {
            [chara MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//删除单个角色
+(void)deleteDSCharactersByCharactersId:(NSString*)charactersId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"charactersId==[c]%@",charactersId];
        DSCharacters * dbCharacters = [DSCharacters MR_findFirstWithPredicate:predicate inContext:localContext];
        if (dbCharacters) {
            [dbCharacters MR_deleteInContext:localContext];
        }
    }];
}

//删除所有头衔
+(void)deleteAllDSTitle:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        NSArray * dbTitles = [DSTitle MR_findAllWithPredicate:predicate inContext:localContext];
        for (DSTitle* title in dbTitles) {
            [title MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//根据角色id删除头衔
+(void)deleteDSTitleByCharactersId:(NSString*)charactersId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"characterid==[c]%@",charactersId];
        NSArray * dbTitles = [DSTitle MR_findAllWithPredicate:predicate inContext:localContext];
        if (dbTitles.count>0) {
            for (DSTitle* title in dbTitles) {
                [title MR_deleteInContext:localContext];
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//根据Type删除头衔
+(void)deleteDSTitleByType:(NSString*)hide Userid:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"hide==[c]%@ and userid==[c]%@",hide,userid];
        NSArray * dbTitles = [DSTitle MR_findAllWithPredicate:predicate inContext:localContext];
        if (dbTitles.count>0) {
            for (DSTitle* title in dbTitles) {
                [title MR_deleteInContext:localContext];
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"simpleRealm")];
    NSString * value1 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value1")];
    NSString * value2 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value2")];
    NSString * value3 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value3")];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"charactersId==[c]%@ and userid==[c]%@",charactersId,userid];
        DSCharacters * dscharacters = [DSCharacters MR_findFirstWithPredicate:predicate inContext:localContext];
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
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
#pragma mark - 批量保存角色
+(void)saveDSCharacters2:(NSArray *)characters UserId:(NSString*)userid successCompletion:(MRSaveCompletionHandler)successCompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        NSArray * dbCharacters = [DSCharacters MR_findAllWithPredicate:predicate inContext:localContext];
        for (DSCharacters* chara in dbCharacters) {
            [chara MR_deleteInContext:localContext];
        }
        
        for (NSDictionary * character in characters) {
            [self saveCharacter:character UserId:userid Loco:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

+(void)saveCharacter:(NSDictionary *)characters UserId:(NSString*)userid Loco:(NSManagedObjectContext*)localContext
{
    NSString * auth = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"auth")];
    NSString * failedmsg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"failedmsg")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"gameid")];
    NSString * charactersId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"id")];
    NSString * img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"img")];
    NSString * name = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"name")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"simpleRealm")];
    NSString * value1 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value1")];
    NSString * value2 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value2")];
    NSString * value3 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"value3")];
//    NSString * simpleRealm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(characters, @"simpleRealm")];
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"charactersId==[c]%@ and userid==[c]%@",charactersId,userid];
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
//    dscharacters.simpleRealm=[NSString stringWithFormat:@"%@",simpleRealm] ;
}


#pragma mark - 保存头衔
+(void)saveDSTitle:(NSDictionary *)titless
{
    NSString * characterid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"characterid")];
    NSString * charactername = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"charactername")];
    NSString * clazz = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"clazz")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"gameid")];
    NSString * hasDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"hasDate")];
    NSString * hide = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"hide")];
    NSString * titleId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"titleid")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"realm")];
    NSString * sortnum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"sortnum")];
    NSString * ids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"id")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"userid")];
    NSString * userimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"userimg")];
    NSDictionary * titleObjects = KISDictionaryHaveKey(titless, @"titleObj");
    [self saveDSTitleObject:titleObjects];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ids==[c]%@ and userid==[c]%@",ids,userid];
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

    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
#pragma mark - 批量保存头衔
+(void)saveDSTitle2:(NSArray *)titles successCompletion:(MRSaveCompletionHandler)successCompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSDictionary * title in titles) {
            [self saveTitle:title Loco:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successCompletion)
         {
            successCompletion(success, error);
         }
     }];
}

+(void)saveTitle:(NSDictionary *)titless Loco:(NSManagedObjectContext*)localContext
{
    NSString * characterid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"characterid")];
    NSString * charactername = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"charactername")];
    NSString * clazz = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"clazz")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"gameid")];
    NSString * hasDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"hasDate")];
    NSString * hide = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"hide")];
    NSString * titleId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"titleid")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"realm")];
    NSString * sortnum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"sortnum")];
    NSString * ids = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"id")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"userid")];
    NSString * userimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titless, @"userimg")];
    NSDictionary * titleObjects = KISDictionaryHaveKey(titless, @"titleObj");
    
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"ids==[c]%@ and userid==[c]%@",ids,userid];
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
    [self saveTitleObject:titleObjects Loco:localContext];
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
    
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
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
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}


+(void)saveTitleObject:(NSDictionary *)titleObjects Loco:(NSManagedObjectContext*)localContext
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

}

//查找所有的角色
+(NSMutableArray *)queryCharacters:(NSString*)userId
{
    NSMutableArray *charactersArray = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
    NSArray *array = [DSCharacters MR_findAllWithPredicate:predicate];
    
//    NSArray *array222 = [array sortedArrayUsingComparator:^NSComparisonResult(DSCharacters * obj1, DSCharacters * obj2) {
//        if ([obj1.charactersId integerValue] > [obj2.charactersId integerValue]) {
//            return (NSComparisonResult)NSOrderedDescending;
//        }
//        if ([obj1.charactersId integerValue] < [obj2.charactersId integerValue]) {
//            return (NSComparisonResult)NSOrderedAscending;
//        }
//        return (NSComparisonResult)NSOrderedSame;
//    }];
    
    for (DSCharacters *character in array) {
        [charactersArray addObject:[self getCharacter:character]];
    }
    return charactersArray;
}

+(NSMutableArray *)queryCharacters:(NSString*)userId gameid:(NSString*)gameid
{
    NSMutableArray *charactersArray = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@ and gameid ==[c]%@",userId,gameid];
    NSArray *array = [DSCharacters MR_findAllWithPredicate:predicate];
    for (DSCharacters *character in array) {
        [charactersArray addObject:[self getCharacter:character]];
    }
    return charactersArray;
}



//查询单个角色信息
+(NSMutableDictionary*)queryCharacter:(NSString*)characterId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"charactersId==[c]%@",characterId];
    DSCharacters * character = [DSCharacters MR_findFirstWithPredicate:predicate];
    return [self getCharacter:character];
}


+(NSMutableDictionary*)getCharacter:(DSCharacters*)character
{
    if (!character) {
        return nil;
    }
    NSMutableDictionary * characterDic = [NSMutableDictionary dictionary];
    [characterDic setObject:character.auth forKey:@"auth"];
    [characterDic setObject:character.failedmsg forKey:@"failedmsg"];
    [characterDic setObject:character.gameid forKey:@"gameid"];
    [characterDic setObject:character.charactersId forKey:@"id"];
    [characterDic setObject:character.img forKey:@"img"];
    [characterDic setObject:character.name forKey:@"name"];
    [characterDic setObject:character.realm forKey:@"simpleRealm"];
    [characterDic setObject:character.value1 forKey:@"value1"];
    [characterDic setObject:character.value2 forKey:@"value2"];
    [characterDic setObject:character.value3 forKey:@"value3"];
    //[characterDic setObject:character.simpleRealm forKey:@"simpleRealm"];
    return characterDic;
}

//查找最后一条动态
+(NSMutableDictionary *)queryLatestDynamic:(NSString*)userId
{
    NSMutableDictionary * lasrDic = [NSMutableDictionary dictionary];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userid==[c]%@",userId];
    DSLatestDynamic *lastds = [DSLatestDynamic MR_findFirstWithPredicate:predicate];
    if (lastds) {
        [lasrDic setObject:lastds.alias?lastds.alias:@"" forKey:@"alias"];
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
    NSArray * array = [DSTitle MR_findAllWithPredicate:predicate];

     NSArray *array222 = [array sortedArrayUsingComparator:^NSComparisonResult(DSTitle * obj1, DSTitle * obj2) {
         if ([obj1.sortnum integerValue] > [obj2.sortnum integerValue]) {
             return (NSComparisonResult)NSOrderedDescending;
         }
         if ([obj1.sortnum integerValue] < [obj2.sortnum integerValue]) {
             return (NSComparisonResult)NSOrderedAscending;
         }
         return (NSComparisonResult)NSOrderedSame;
     }];
    for (DSTitle *title in array222) {
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
        [titleDic setObject:title.sortnum forKey:@"sortnum"];
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
    if (titleObject) {
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

    }
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
    NSString * type = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupList, @"type")];
    
    NSMutableArray * userList = KISDictionaryHaveKey(groupList, @"memberList");
    if ([userList isKindOfClass:[NSMutableArray class]] && userList.count>0) {
        for (NSMutableDictionary * user in userList) {
            [self saveDSGroupUser:user GroupId:groupId];
        }
    }
    
    [self upDataDSGroupApplyMsgByGroupId:groupId GroupName:groupName GroupBackgroundImg:backgroundImg];//更新群通知消息列表
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        DSGroupList * groupInfo = [DSGroupList MR_findFirstWithPredicate:predicate inContext:localContext];
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
        groupInfo.groupType = type;
        NSString * avb = groupInfo.available?groupInfo.available:@"0";
        groupInfo.available =[avb isEqualToString:@"0"]?@"0":avb;
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//删除所有群
+(void)deleteAllDSGroupList
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * dbTitles = [DSGroupList MR_findAll];
        for (DSGroupList* title in dbTitles) {
            [title MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
#pragma mark - 保存群组用户列表信息
+(void)saveDSGroupUser:(NSDictionary *)groupUser GroupId:(NSString*)groupId
{
    NSString * userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(groupUser, @"userid")];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userId==[c]%@",groupId,userId];
        DSGroupUser * groupUserInfo = [DSGroupUser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!groupUserInfo)
            groupUserInfo = [DSGroupUser MR_createInContext:localContext];
        groupUserInfo.groupId = groupId;
        groupUserInfo.userId = userId;
    }
     completion:^(BOOL success, NSError *error) {
         
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
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupUsershipType!=[c]%@ and groupType!=[c]%@",@"3",@"2"];
    NSArray *array = [DSGroupList MR_findAllWithPredicate:predicate];
    for (DSGroupList * group in array) {
        NSMutableDictionary * grouoDic = [self queryGroupInfo:group];
        [titlesArray addObject:grouoDic];
    }
    return titlesArray;
}


+(NSInteger)queryGroupCount
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupUsershipType!=[c]%@ and available==[c]%@ and groupType!=[c]%@",@"3",@"0",@"2"];
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
    [groupInfo setObject:group.backgroundImg?group.backgroundImg:@"" forKey:@"backgroundImg"];
    [groupInfo setObject:group.groupId forKey:@"groupId"];
    [groupInfo setObject:group.groupName?group.groupName:@"" forKey:@"groupName"];
    [groupInfo setObject:group.state?group.state:@"" forKey:@"state"];
    [groupInfo setObject:group.currentMemberNum?group.currentMemberNum:@"" forKey:@"currentMemberNum"];
    [groupInfo setObject:group.gameid?group.gameid:@"" forKey:@"gameid"];
    [groupInfo setObject:group.level?group.level:@"" forKey:@"level"];
    [groupInfo setObject:group.maxMemberNum?group.maxMemberNum:@"" forKey:@"maxMemberNum"];
    [groupInfo setObject:group.createDate?group.createDate:@"" forKey:@"createDate"];
    [groupInfo setObject:group.distance?group.distance:@"" forKey:@"distance"];
    [groupInfo setObject:group.experience?group.experience:@"" forKey:@"experience"];
    [groupInfo setObject:group.gameRealm?group.gameRealm:@"" forKey:@"gameRealm"];
    [groupInfo setObject:group.groupUsershipType?group.groupUsershipType:@"" forKey:@"groupUsershipType"];
    [groupInfo setObject:group.info?group.info:@"" forKey:@"info"];
    [groupInfo setObject:group.infoImg?group.infoImg:@"" forKey:@"infoImg"];
    [groupInfo setObject:group.location?group.location:@"" forKey:@"location"];
    [groupInfo setObject:group.available?group.available:@"" forKey:@"available"];
    [groupInfo setObject:group.groupType?group.groupType:@"" forKey:@"type"];
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
        DSGroupList * groupInfo = [DSGroupList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!groupInfo)
            groupInfo = [DSGroupList MR_createInContext:localContext];
        groupInfo.groupId = groupId;
        groupInfo.available = groupState;
        groupInfo.groupUsershipType = groupShipType;
    }];
}
//根据groupId 删除群信息
+(void)deleteGroupInfoByGoupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        DSGroupList * group = [DSGroupList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (group) {
            [group MR_deleteInContext:localContext];
        }
    }];
}

#pragma mark - 保存申请加入群的消息
+(void)saveDSGroupApplyMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block
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
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        if (![msgType isEqualToString:@"groupBillboard"]) {
            NSPredicate * predicateThumb = [NSPredicate predicateWithFormat:@"msgType==[c]%@",GROUPAPPLICATIONSTATE];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicateThumb inContext:localContext];
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = sender;
            thumbMsgs.senderNickname = KISDictionaryHaveKey(msg, @"msgTitle");
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = JOINGROUPMSG;
            thumbMsgs.msgType = GROUPAPPLICATIONSTATE;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";
            thumbMsgs.sayHiType = @"1";
            thumbMsgs.groupId = groupId;
            thumbMsgs.receiveTime=[NSString stringWithFormat:@"%@",[GameCommon getCurrentTime]];
        }
        
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgId==[c]%@",msgId];
        DSGroupApplyMsg * commonMsg = [DSGroupApplyMsg MR_findFirstWithPredicate:predicate inContext:localContext];
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
    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(msg);
//         }
//     }
     
     ];
    if (block) {
        block(msg);
    }
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * groupArrlyList = [DSGroupApplyMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate inContext:localContext];
        for (DSGroupApplyMsg * apm in groupArrlyList) {
            apm.nickname  = name;
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
+(void)changedDSGroupApplyMsgImgWithGroupId:(NSString *)groupId img:(NSString *)img
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * groupArrlyList = [DSGroupApplyMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate inContext:localContext];
        for (DSGroupApplyMsg * apm in groupArrlyList) {
            apm.backgroundImg  = img;
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}


//更新群通知表的信息
+(void)upDataDSGroupApplyMsgByGroupId:(NSString*)groupId GroupName:(NSString*)groupName GroupBackgroundImg:(NSString*)backgroundImg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * commonMsgs = [DSGroupApplyMsg findAllWithPredicate:predicate inContext:localContext];
        for (DSGroupApplyMsg * commonMsg in commonMsgs) {
            if (commonMsg) {
                commonMsg.groupName = groupName;
                commonMsg.backgroundImg = backgroundImg;
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
         
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
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"userid==[c]%@ and msgType==[c]%@ and state==[c]%@ and groupId==[c]%@",userid,msgType,@"0",groupId];
        NSArray * commMsgs = [DSGroupApplyMsg findAllWithPredicate:predicate inContext:localContext];
        for (DSGroupApplyMsg * commonMsg in commMsgs) {
            if (commonMsg) {
                commonMsg.state = state;
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}


//删除该群的所有消息
+(void)deleteMsgByGroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * commMsgs = [DSGroupApplyMsg findAllWithPredicate:predicate inContext:localContext];
        for (DSGroupApplyMsg * commonMsg in commMsgs) {
            if (commonMsg) {
                 [commonMsg MR_deleteInContext:localContext];
            }
        }
        
        NSArray * historyMsg = [DSGroupMsgs findAllWithPredicate:predicate inContext:localContext];
        for (DSGroupMsgs * commonMsg in historyMsg) {
            if (commonMsg) {
                [commonMsg MR_deleteInContext:localContext];
            }
        }
        DSGroupList * groupInfo = [DSGroupList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (groupInfo)
        {
            [groupInfo MR_deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}





#pragma mark - 
+(void)saveTeamThumbMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    NSString * msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgId")];
    NSString * body = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msg")];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    NSString * payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    [payloadDic setValue:@"teamchat" forKey:@"team"];
    NSString * nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"nickname")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"userid")];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId, @"groupchat",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicates inContext:localContext];
        int unread;
        if (!thumbMsgs){
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [thumbMsgs.unRead intValue];
        }
        thumbMsgs.sender = userid;
        thumbMsgs.senderNickname = nickname;
        thumbMsgs.msgContent = body;
        thumbMsgs.groupId = groupId;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.msgType = @"groupchat";
        thumbMsgs.messageuuid = msgId;
        thumbMsgs.status = @"1";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.payLoad = [payloadDic JSONFragment];
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
    }
//    completion:^(BOOL success, NSError *error) {
//        if (block) {
//            block(msg);
//        }
//    }
     
     ];
    
    if (block) {
        block(msg);
    }
}





#pragma mark - 保存申请加入群的消息
+(void)saveTeamNotifityMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    NSString * fromid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"sender")];
    NSString * toid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"toId")];
    NSString * msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgId")];
    NSString * msgType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgType")];
    NSString * body = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msg")];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    
    NSString * payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    [payloadDic setValue:@"teamchat" forKey:@"team"];
    NSString * characterName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"characterName")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"realm")];
    NSString * nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"nickname")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"userid")];
    NSString * gender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"gender")];
    NSString * roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"roomId")];
    NSString * characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"characterId")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"gameid")];
    NSString * value1 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"value1")];
    NSString * value2 = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"value2")];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    NSString * userimg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"img")];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId, @"groupchat",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicates inContext:localContext];
        int unread;
        if (!thumbMsgs){
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [thumbMsgs.unRead intValue];
        }
        thumbMsgs.sender = userid;
        thumbMsgs.senderNickname = nickname;
        thumbMsgs.msgContent = body;
        thumbMsgs.groupId = groupId;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.msgType = @"groupchat";
        thumbMsgs.messageuuid = msgId;
        thumbMsgs.status = @"1";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.payLoad = [payloadDic JSONFragment];
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
        
        
        
        NSPredicate * predicates2 = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId, @"groupchat",@"3"];
        DSThumbMsgs * thumbMsgs2 = [DSThumbMsgs MR_findFirstWithPredicate:predicates2 inContext:localContext];
        int unread2;
        if (!thumbMsgs2){
            thumbMsgs2 = [DSThumbMsgs MR_createInContext:localContext];
            unread2 =0;
        }else{
            unread2 = [thumbMsgs2.unRead intValue];
        }
        thumbMsgs2.sender = userid;
        thumbMsgs2.senderNickname = nickname;
        thumbMsgs2.msgContent = body;
        thumbMsgs2.groupId = groupId;
        thumbMsgs2.sendTime = sendTime;
        thumbMsgs2.senderType = GROUPMSG;
        thumbMsgs2.unRead = [NSString stringWithFormat:@"%d",unread2+1];
        thumbMsgs2.msgType = @"groupchat";
        thumbMsgs2.messageuuid = msgId;
        thumbMsgs2.status = @"1";
        thumbMsgs2.sayHiType = @"3";
        thumbMsgs2.payLoad = [payloadDic JSONFragment];
        thumbMsgs2.receiveTime=[GameCommon getCurrentTime];
        
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgId==[c]%@",msgId];
        DSTeamNotificationMsg * commonMsg = [DSTeamNotificationMsg MR_findFirstWithPredicate:predicate inContext:localContext];
        int unreadC;
        if (!commonMsg){
            commonMsg = [DSTeamNotificationMsg MR_createInContext:localContext];
            unreadC =0;
        }else{
            unreadC = [commonMsg.unreadMsgCount intValue];
        }
        commonMsg.state = @"0";
        commonMsg.fromId = fromid;
        commonMsg.toId = toid;
        commonMsg.msgId = msgId;
        commonMsg.msgType = msgType;
        commonMsg.body = body;
        commonMsg.msgTime = sendTime;
        commonMsg.payload = payloadStr;
        commonMsg.characterName = characterName;
        commonMsg.realm= realm;
        commonMsg.nickname = nickname;
        commonMsg.userid = userid;
        commonMsg.gender = gender;
        commonMsg.roomId = roomId;
        commonMsg.characterId = characterId;
        commonMsg.gameid = gameid;
        commonMsg.value1 = value1;
        commonMsg.value2 = value2;
        commonMsg.groupId = groupId;
        commonMsg.userImg = userimg;
        commonMsg.unreadMsgCount = [NSString stringWithFormat:@"%d",unreadC+1];
        commonMsg.receiveTime=[GameCommon getCurrentTime];
    }
//     completion:^(BOOL success, NSError *error) {
//         if (block) {
//             block(msg);
//         }
//     }
     ];
    
    if (block) {
        block(msg);
    }
}

+(NSInteger)getDSTeamNotificationMsgCount:(NSString*)groupId{
    return [self getDSTeamNotificationMsgCount:groupId SayHightType:@"3"]+[self getDSTeamNotificationMsgCount:groupId SayHightType:@"4"];
}


+(NSInteger)getDSTeamNotificationMsgCount:(NSString*)groupId SayHightType:(NSString*)sayHightType{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType=[c]%@",groupId,@"groupchat",sayHightType];
    DSThumbMsgs * commonMsg = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
    if (commonMsg) {
        return [commonMsg.unRead intValue];
    }
    return 0;
}

+(void)updateDSTeamNotificationMsgCount:(NSString*)groupId SayHightType:(NSString*)sayHightType{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType=[c]%@",groupId,@"groupchat",sayHightType];
        DSThumbMsgs * commonMsg = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            commonMsg.unRead= @"0";
        }
    }];
}

+(void)updateDSTeamNotificationMsgCount:(NSString*)groupId SayHightType:(NSString*)sayHightType  Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType=[c]%@",groupId,@"groupchat",sayHightType];
        DSThumbMsgs * commonMsg = [DSThumbMsgs MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            commonMsg.unRead= @"0";
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}


+(NSMutableArray*)queDSTeamNotificationMsgByMsgTypeAndGroupId:(NSString*)msgType GroupId:(NSString*)groupId
{
    NSMutableArray * msgList = [NSMutableArray array];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgType==[c]%@ and groupId==[c]%@",msgType,groupId];
    NSArray * groupArrlyList = [DSTeamNotificationMsg MR_findAllSortedBy:@"receiveTime" ascending:NO withPredicate:predicate];
    for (DSTeamNotificationMsg * apm in groupArrlyList) {
        [msgList addObject:[self queryDSTeamNotificationMsg:apm]];
    }
    return msgList;
}

+(NSMutableDictionary*)queryDSTeamNotificationMsg:(DSTeamNotificationMsg*)msgDS
{
    if (!msgDS) {
        return nil;
    }
    NSMutableDictionary * msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:msgDS.state forKey:@"state"];
    [msgDic setObject:msgDS.fromId forKey:@"fromId"];
    [msgDic setObject:msgDS.toId forKey:@"toId"];
    [msgDic setObject:msgDS.msgId forKey:@"msgId"];
    [msgDic setObject:msgDS.msgType forKey:@"msgType"];
    [msgDic setObject:msgDS.body forKey:@"body"];
    NSTimeInterval uu = [msgDS.msgTime timeIntervalSince1970];
    [msgDic setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"senTime"];
    [msgDic setObject:msgDS.payload forKey:@"payload"];
    [msgDic setObject:msgDS.characterName forKey:@"characterName"];
    [msgDic setObject:msgDS.realm forKey:@"realm"];
    [msgDic setObject:msgDS.nickname forKey:@"nickname"];
    [msgDic setObject:msgDS.userid forKey:@"userid"];
    [msgDic setObject:msgDS.gender forKey:@"gender"];
    [msgDic setObject:msgDS.roomId forKey:@"roomId"];
    [msgDic setObject:msgDS.characterId forKey:@"characterId"];
    [msgDic setObject:msgDS.gameid forKey:@"gameid"];
    [msgDic setObject:msgDS.value1 forKey:@"value1"];
    [msgDic setObject:msgDS.value2 forKey:@"value2"];
    [msgDic setObject:msgDS.groupId forKey:@"groupId"];
    [msgDic setObject:msgDS.userImg forKey:@"userImg"];
    [msgDic setObject:msgDS.receiveTime forKey:@"receiveTime"];
    return msgDic;
}

+(void)updateTeamNotifityMsgState:(NSString*)userid State:(NSString*)state GroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"userid==[c]%@ and state==[c]%@ and groupId==[c]%@",userid,@"0",groupId];
        NSArray * commMsgs = [DSTeamNotificationMsg findAllWithPredicate:predicate inContext:localContext];
        for (DSTeamNotificationMsg * commonMsg in commMsgs) {
            if (commonMsg) {
                commonMsg.state = state;
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//查询未处理的申请加入组队消息数量
+(NSInteger)getTeamNotifityMsgCount:(NSString*)state GroupId:(NSString*)groupId
{
    NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"state==[c]%@ and groupId==[c]%@",state,groupId];
    NSArray * commMsgs = [DSTeamNotificationMsg findAllWithPredicate:predicate];
    return commMsgs.count;
}

//删除组队通知消息
+(void)deleteTeamNotifityMsgState
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSArray * commMsgs = [DSTeamNotificationMsg findAll];
        for (DSTeamNotificationMsg * commonMsg in commMsgs) {
            [commonMsg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}
//根据groupId删除组队通知消息
+(void)deleteTeamNotifityMsgStateByGroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
         NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * commMsgs = [DSTeamNotificationMsg findAllWithPredicate:predicate inContext:localContext];
        for (DSTeamNotificationMsg * commonMsg in commMsgs) {
            [commonMsg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         
     }];
}

//根据groupId删除就位确认消息
+(void)deleteDSPreparedByGroupId:(NSString*)groupId
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * commMsgs = [DSPrepared findAllWithPredicate:predicate inContext:localContext];
        for (DSPrepared * commonMsg in commMsgs) {
            [commonMsg deleteInContext:localContext];
        }
    }
    completion:^(BOOL success, NSError *error) {
                                                   
    }];
}


//根据msgId删除组队通知消息
+(void)deleteTeamNotifityMsgStateByMsgId:(NSString*)msgId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate  predicateWithFormat:@"msgId==[c]%@",msgId];
        DSTeamNotificationMsg * commMsg = [DSTeamNotificationMsg findFirstWithPredicate:predicate inContext:localContext];
        if (commMsg) {
            [commMsg deleteInContext:localContext];
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}


#pragma mark - 保存就位确认消息
+(void)saveTeamPreparedMsg:(NSDictionary *)msg SaveSuccess:(void (^)(NSDictionary *msgDic))block
{
    NSString * fromid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"sender")];
    NSString * toid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"toId")];
    NSString * msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgId")];
    NSString * msgType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msgType")];
    NSString * body = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"msg")];
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    
    NSString * payloadStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(msg, @"payload")];
    NSDictionary *payloadDic = [payloadStr JSONValue];
    NSString * groupId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"groupId")];
    NSString * userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"userid")];
    NSString * roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"roomId")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"gameid")];
    NSString * result = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payloadDic, @"result")];
    
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId, @"groupchat",@"1"];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicates inContext:localContext];
        int unread;
        if (!thumbMsgs){
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [thumbMsgs.unRead intValue];
        }
        thumbMsgs.sender = @"";
        thumbMsgs.senderNickname = @"";
        thumbMsgs.msgContent = body;
        thumbMsgs.groupId = groupId;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = GROUPMSG;
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+([userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]?0:1)];
        thumbMsgs.msgType = @"groupchat";
        thumbMsgs.messageuuid = msgId;
        thumbMsgs.status = @"1";
        thumbMsgs.sayHiType = @"1";
        thumbMsgs.payLoad = [payloadDic JSONFragment];
        thumbMsgs.receiveTime=[GameCommon getCurrentTime];
        
        
        
        NSPredicate * predicates2 = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and msgType==[c]%@ and sayHiType==[c]%@",groupId, @"groupchat",@"4"];
        DSThumbMsgs * thumbMsgs2 = [DSThumbMsgs MR_findFirstWithPredicate:predicates2 inContext:localContext];
        int unread2;
        if (!thumbMsgs2){
            thumbMsgs2 = [DSThumbMsgs MR_createInContext:localContext];
//            unread2 =0;
        }else{
//            unread2 = [thumbMsgs.unRead intValue];
        }
        unread2 =0;
        thumbMsgs2.sender = @"";
        thumbMsgs2.senderNickname = @"";
        thumbMsgs2.msgContent = body;
        thumbMsgs2.groupId = groupId;
        thumbMsgs2.sendTime = sendTime;
        thumbMsgs2.senderType = GROUPMSG;
        thumbMsgs2.unRead = [NSString stringWithFormat:@"%d",unread2+([userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]?0:1)];
        thumbMsgs2.msgType = @"groupchat";
        thumbMsgs2.messageuuid = msgId;
        thumbMsgs2.status = @"1";
        thumbMsgs2.sayHiType = @"4";
        thumbMsgs2.payLoad = [payloadDic JSONFragment];
        thumbMsgs2.receiveTime=[GameCommon getCurrentTime];
        
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"msgId==[c]%@",msgId];
        DSPrepared * commonMsg = [DSPrepared MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!commonMsg)
            commonMsg = [DSPrepared MR_createInContext:localContext];
        commonMsg.fromId = fromid;
        commonMsg.toId = toid;
        commonMsg.msgId = msgId;
        commonMsg.msgType = msgType;
        commonMsg.body = body;
        commonMsg.msgTime = sendTime;
        commonMsg.payload = payloadStr;
        commonMsg.groupId = groupId;
        commonMsg.gameid = gameid;
        commonMsg.roomId = roomId;
        commonMsg.userId = userId;
        commonMsg.result = result;
        
    }
//        completion:^(BOOL success, NSError *error) {
//              if (block) {
//                  block(msg);
//              }
//          }
     ];
    
    if (block) {
        block(msg);
    }
}


#pragma mark  -----组队
+(void)saveTeamInfoWithDict:(NSDictionary *)dic GameId:(NSString*)gameId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    NSString * createDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"createDate")];
    NSString * crossServer  =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"crossServer")];
    NSString * descriptions =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"description")];
    NSString * dismissDate =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"dismissDate")];
    NSString * groupId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")];
    NSString * maxVol = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"maxVol")];
    NSString * memberCount  =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"memberCount")];
    NSString * minLevelId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"minLevelId")];
    NSString * minPower =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"minPower")];
    NSString * myMemberId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"myMemberId")];
    NSString * roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomId")];
    NSString * teamInfo  =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"teamInfo")];
    NSString * teamName =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"roomName")];
    NSString * teamUsershipType =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"teamUsershipType")];
    NSString * typeId =[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"typeId")];
    NSMutableDictionary * createTeamUserInfo = KISDictionaryHaveKey(dic, @"createTeamUser");
    NSMutableArray * userList = KISDictionaryHaveKey(dic, @"memberList");
    if ([userList isKindOfClass:[NSMutableArray class]] && userList.count>0) {
        
        [self detailList:userList RoomId:roomId GameId:gameId];
        
        for (NSMutableDictionary * user in userList) {
            [self saveMemberUserInfo:user GroupId:groupId Successcompletion:^(BOOL success, NSError *error) {
                
            }];
            [self saveTeamUser:[GameCommon getNewStringWithId:KISDictionaryHaveKey(user, @"userid")] groupId:groupId TeamUsershipType:[GameCommon getNewStringWithId:KISDictionaryHaveKey(user, @"teamUsershipType")] DefaultState:@"0"];
        }
    }
    [self saveCreateTeamUserInfo:createTeamUserInfo Successcompletion:^(BOOL success, NSError *error) {
        
    }];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and roomId==[c]%@",gameId,roomId];
        DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!commonMsg)
            commonMsg = [DSTeamList MR_createInContext:localContext];
        commonMsg.createDate = createDate;
        commonMsg.crossServer = crossServer;
        commonMsg.descriptions = descriptions;
        commonMsg.dismissDate = dismissDate;
        commonMsg.groupId = groupId;
        commonMsg.maxVol = maxVol;
        commonMsg.memberCount = memberCount;
        commonMsg.minLevelId = minLevelId;
        commonMsg.minPower = minPower;
        commonMsg.myMemberId = myMemberId;
        commonMsg.roomId = roomId;
        commonMsg.teamInfo = teamInfo;
        commonMsg.teamName = teamName;
        commonMsg.teamUsershipType = teamUsershipType;
        commonMsg.typeId = typeId;
        commonMsg.gameId = [GameCommon getNewStringWithId:gameId];
        commonMsg.characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterId")];
        commonMsg.characterImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterImg")];
        commonMsg.characterName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterName")];
        commonMsg.memberInfo = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"memberInfo")];
        commonMsg.realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"realm")];
        commonMsg.teamUserId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"teamUserId")];
        commonMsg.userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"userid")];
        commonMsg.gender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"gender")];
        commonMsg.img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"img")];
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}


+(void)detailList:(NSMutableArray*)userList RoomId:(NSString*)roomId GameId:(NSString*)gameId{
    NSMutableArray * array = [self getMemberList:roomId GameId:gameId];
    NSMutableArray * teamList = [array mutableCopy];
    for (NSMutableDictionary * user in userList) {
        for (NSMutableDictionary * user2 in array) {
            if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(user, @"userid")]
                 isEqualToString:[GameCommon getNewStringWithId:KISDictionaryHaveKey(user2, @"userid")]]) {
                [teamList removeObject:user2];
            }
        }
    }
    if (teamList && teamList.count>0) {
        for (NSMutableDictionary * dic in array) {
            [[TeamManager singleton] deleteMenberUserInfo:dic GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"groupId")]];
        }
    }
    
}


//保存组队成员列表信息
+(void)saveMemberUserInfo:(NSMutableDictionary*)memberUserInfo GroupId:(NSString*)groupId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"gameid")];
    NSString * gender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"gender")];
    NSString * img = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"img")];
    NSString * joinDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"joinDate")];
    NSString * leaveDate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"leaveDate")];
    NSString * memberId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"memberId")];
    NSString * memberTeamUserId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"memberTeamUserId")];
    NSString * nickname = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"nickname")];
    NSString * position = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"position")];
    NSString * roomId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"roomId")];
    NSString * teamUsershipType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"teamUsershipType")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")];
    
    NSString * constId = @"";
    NSString * mask = @"";
    NSString * positionType = @"";
    NSString * positionValue = @"";
    NSMutableDictionary * positionDic = KISDictionaryHaveKey(memberUserInfo, @"position");
    if ([positionDic isKindOfClass:[NSDictionary class]]) {
        constId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(positionDic, @"constId")];
        mask = [GameCommon getNewStringWithId:KISDictionaryHaveKey(positionDic, @"mask")];
        positionType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(positionDic, @"type")];
        positionValue = [GameCommon getNewStringWithId:KISDictionaryHaveKey(positionDic, @"value")];
    }
    NSMutableDictionary * teamUserDic = KISDictionaryHaveKey(memberUserInfo, @"teamUser");
    NSString * teamUsercharacterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"characterId")];
    NSString * teamUsercharacterName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"characterName")];
    NSString * teamUsergameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"gameid")];
    NSString * teamUsermemberInfo = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"memberInfo")];
    NSString * teamUserrealm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"realm")];
    NSString * teamUserteamUserId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"teamUserId")];
    NSString * teamUseruserid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamUserDic, @"userid")];
    
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"gameid==[c]%@ and memberId==[c]%@",gameid, memberId];
        //保存memberUser
        DSMemberUserInfo * commonMsg = [DSMemberUserInfo MR_findFirstWithPredicate:predicates inContext:localContext];
        if (!commonMsg)
            commonMsg = [DSMemberUserInfo MR_createInContext:localContext];
        commonMsg.gameid = gameid;
        commonMsg.gender = gender;
        commonMsg.img = img;
        commonMsg.joinDate = joinDate;
        commonMsg.leaveDate = leaveDate;
        commonMsg.memberId= memberId;
        commonMsg.memberTeamUserId = memberTeamUserId;
        commonMsg.nickname = nickname;
        commonMsg.position = position;
        commonMsg.roomId = roomId;
        commonMsg.teamUsershipType = teamUsershipType;
        commonMsg.userid = userid;
        commonMsg.groupId = groupId;
        commonMsg.constId = constId;
        commonMsg.mask = mask;
        commonMsg.positionType = positionType;
        commonMsg.positionValue = positionValue;
        
        //保存teamUser
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"teamUserId==[c]%@ and gameid==[c]%@",teamUserteamUserId,teamUsergameid];
         DSTeamUserInfo * commonMsgTeamUser = [DSTeamUserInfo MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        if (!commonMsgTeamUser)
            commonMsgTeamUser = [DSTeamUserInfo MR_createInContext:localContext];
        commonMsgTeamUser.characterId = teamUsercharacterId;
        commonMsgTeamUser.characterName = teamUsercharacterName;
        commonMsgTeamUser.gameid = teamUsergameid;
        commonMsgTeamUser.memberInfo = teamUsermemberInfo;
        commonMsgTeamUser.realm = teamUserrealm;
        commonMsgTeamUser.teamUserId = teamUserteamUserId;
        commonMsgTeamUser.userid = teamUseruserid;
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}


+(NSString*)getMemberPosition:(NSString*)groupId UserId:(NSString*)userId{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
    DSMemberUserInfo * commonMsgTeamUser = [DSMemberUserInfo MR_findFirstWithPredicate:predicate];
    if (commonMsgTeamUser) {
        if ([GameCommon isEmtity:commonMsgTeamUser.positionValue]) {
            return @"未选";
        }
        return commonMsgTeamUser.positionValue;
    }
    return @"未选";
}

//保存状态
+(void)saveTeamUser:(NSString*)userId groupId:(NSString*)groupId TeamUsershipType:(NSString*)teamUsershipType DefaultState:(NSString*)defaultState{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
        DSTeamUser * teamUserInfo = [DSTeamUser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!teamUserInfo){
            teamUserInfo = [DSTeamUser MR_createInContext:localContext];
            teamUserInfo.groupId = groupId;
            teamUserInfo.userid = userId;
            teamUserInfo.teamUsershipType = teamUsershipType?teamUsershipType:@"1";
            teamUserInfo.state = defaultState;
            teamUserInfo.onClickState = @"0";
        }else{
            teamUserInfo.groupId = groupId;
            teamUserInfo.userid = userId;
            teamUserInfo.teamUsershipType = teamUsershipType?teamUsershipType:@"1";
        }
    }
    completion:^(BOOL success, NSError *error) {
                                                   
    }];
}

//保存状态
+(void)saveTeamUser2:(NSString*)userId groupId:(NSString*)groupId TeamUsershipType:(NSString*)teamUsershipType State:(NSString*)state OnClickState:(NSString*)onClickState{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
        DSTeamUser * teamUserInfo = [DSTeamUser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (!teamUserInfo)
            teamUserInfo = [DSTeamUser MR_createInContext:localContext];
        teamUserInfo.groupId = groupId;
        teamUserInfo.userid = userId;
        teamUserInfo.teamUsershipType = teamUsershipType?teamUsershipType:@"1";
        teamUserInfo.state = state;
        teamUserInfo.onClickState = onClickState;

    }
    completion:^(BOOL success, NSError *error) {
                                                   
    }];
}



+(NSMutableDictionary*)getTeamUser:(NSString*)groupId TeamUsershipType:(NSString*)teamUsershipType{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and teamUsershipType==[c]%@",groupId,teamUsershipType];
    DSTeamUser * teamUserInfo2 = [DSTeamUser MR_findFirstWithPredicate:predicate2];
    if (teamUserInfo2){
        [dic setObject:teamUserInfo2.groupId forKey:@"groupId"];
        [dic setObject:teamUserInfo2.userid forKey:@"userid"];
        [dic setObject:teamUserInfo2.teamUsershipType forKey:@"teamUsershipType"];
        [dic setObject:teamUserInfo2.state forKey:@"state"];
        return dic;
    }
    return nil;
}


+(NSInteger)getTeamUser:(NSString*)groupId UserId:(NSString*)userId{
    NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
    DSTeamUser * teamUserInfo2 = [DSTeamUser MR_findFirstWithPredicate:predicate2];
    if (teamUserInfo2){
        return [teamUserInfo2.onClickState intValue];
    }
    return 0;
}



//更新状态
+(void)updateTeamUser:(NSString*)userId groupId:(NSString*)groupId State:(NSString*)state OnClickState:(NSString*)onClickState Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
        DSTeamUser * teamUserInfo = [DSTeamUser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (teamUserInfo){
            teamUserInfo.onClickState = onClickState;
            teamUserInfo.state = state;
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}

//更新状态
+(void)updateTeamUser:(NSString*)groupId State:(NSString*)state OnClickState:(NSString*)onClickState Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * teamUserInfos = [DSTeamUser MR_findAllWithPredicate:predicate inContext:localContext];
        for (DSTeamUser * teamUserInfo in teamUserInfos) {
            if (teamUserInfo){
                teamUserInfo.onClickState = onClickState;
                if ([teamUserInfo.teamUsershipType intValue]==0) {
                    teamUserInfo.state = @"2";
                }else{
                    teamUserInfo.state = state;
                }
            }
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}


//更新状态
+(void)resetTeamUser:(NSString*)groupId State:(NSString*)state OnClickState:(NSString*)onClickState Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        NSArray * teamUserInfos = [DSTeamUser MR_findAllWithPredicate:predicate inContext:localContext];
        for (DSTeamUser * teamUserInfo in teamUserInfos) {
            if (teamUserInfo){
//                teamUserInfo.state = state;
                teamUserInfo.onClickState = onClickState;
            }
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}

//删除状态
+(void)deleteTeamUser:(NSString*)userId groupId:(NSString*)groupId{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
        DSTeamUser * teamUserInfo = [DSTeamUser MR_findFirstWithPredicate:predicate inContext:localContext];
        if (teamUserInfo){
            [teamUserInfo MR_deleteInContext:localContext];
        }
    }];
}

//查询状态
+(NSString*)getTeamUserState:(NSString*)userId groupId:(NSString*)groupId{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
    DSTeamUser * teamUserInfo = [DSTeamUser MR_findFirstWithPredicate:predicate];
       return [GameCommon getNewStringWithId:teamUserInfo.state];
}


//删除某个组队的某个用户
+(void)deleteMenberUserInfo:(NSString*)groupId UserId:(NSString*)userId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesMemberUserInfo = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and userid==[c]%@",groupId,userId];
        //删除memberUser
        DSMemberUserInfo * commonMsg = [DSMemberUserInfo MR_findFirstWithPredicate:predicatesMemberUserInfo inContext:localContext];
        [commonMsg MR_deleteInContext:localContext];
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}

//删除某个组队的某个用户
+(void)deleteMenberUserInfo:(NSString*)memberTeamUserId GameId:(NSString*)gameId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesMemberUserInfo = [NSPredicate predicateWithFormat:@"memberTeamUserId==[c]%@ and gameid==[c]%@",memberTeamUserId,gameId];
        //删除memberUser
        DSMemberUserInfo * commonMsg = [DSMemberUserInfo MR_findFirstWithPredicate:predicatesMemberUserInfo inContext:localContext];
        if (commonMsg) {
            [commonMsg MR_deleteInContext:localContext];
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}

//查询MemberList
+(NSMutableArray*)getMemberList:(NSString*)roomId GameId:(NSString*)gameId{
    NSMutableArray * memberList = [NSMutableArray array];
    NSPredicate * predicates = [NSPredicate predicateWithFormat:@"roomId==[c]%@ and gameid==[c]%@",roomId, gameId];
    NSArray * commonMsgs = [DSMemberUserInfo MR_findAllWithPredicate:predicates];
    for (DSMemberUserInfo * commonMsg in commonMsgs) {
        [memberList addObject:[self getmemberInfo:commonMsg]];
    }
    return memberList;
}


//根据GroupId查询MemberList
+(NSMutableArray*)getMemberList:(NSString*)groupId{
    NSMutableArray * memberList = [NSMutableArray array];
    NSPredicate * predicates = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
    NSArray * commonMsgs = [DSMemberUserInfo MR_findAllWithPredicate:predicates];
    for (DSMemberUserInfo * commonMsg in commonMsgs) {
        [memberList addObject:[self getmemberInfo:commonMsg]];
    }
    return memberList;
}

+(NSMutableDictionary*)getmemberInfo:(DSMemberUserInfo*)commonMsg{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic setObject:commonMsg.gameid forKey:@"gameid"];
    [dic setObject:commonMsg.gender forKey:@"gender"];
    [dic setObject:commonMsg.img forKey:@"img"];
    [dic setObject:commonMsg.joinDate forKey:@"joinDate"];
    [dic setObject:commonMsg.leaveDate forKey:@"leaveDate"];
    [dic setObject:commonMsg.memberId forKey:@"memberId"];
    [dic setObject:commonMsg.memberTeamUserId forKey:@"memberTeamUserId"];
    [dic setObject:commonMsg.nickname forKey:@"nickname"];
    [dic setObject:commonMsg.position forKey:@"position"];
    [dic setObject:commonMsg.roomId forKey:@"roomId"];
    [dic setObject:commonMsg.teamUsershipType forKey:@"teamUsershipType"];
    [dic setObject:commonMsg.userid forKey:@"userid"];
    [dic setObject:commonMsg.groupId forKey:@"groupId"];
    [dic setObject:commonMsg.constId forKey:@"constId"];
    [dic setObject:commonMsg.mask forKey:@"mask"];
    [dic setObject:commonMsg.positionType forKey:@"type"];
    [dic setObject:commonMsg.positionValue forKey:@"value"];
    [dic setObject:[self getTeamUserState:[GameCommon getNewStringWithId:commonMsg.userid]  groupId:[GameCommon getNewStringWithId:commonMsg.groupId]]?[self getTeamUserState:[GameCommon getNewStringWithId:commonMsg.userid]  groupId:[GameCommon getNewStringWithId:commonMsg.groupId]]:@"0" forKey:@"state"];
   NSMutableDictionary * dicC = [self getTeamUserInfo:commonMsg.memberTeamUserId GameId:commonMsg.gameid];
    if (dicC) {
        [dic setObject:dicC forKey:@"teamUser"];
    }
    return dic;
}

//查询teamUserInfo
+(NSMutableDictionary*)getTeamUserInfo:(NSString*)teamUserId GameId:(NSString*)gameId{
    NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"teamUserId==[c]%@ and gameid==[c]%@",teamUserId,gameId];
    DSTeamUserInfo * commonMsgTeamUser = [DSTeamUserInfo MR_findFirstWithPredicate:predicatesTeamUser];
    return [self getTeamUserInfo:commonMsgTeamUser];
}

+(NSMutableDictionary*)getTeamUserInfo:(DSTeamUserInfo*)commonMsg{
    if (commonMsg) {
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        [dic setObject:commonMsg.characterId forKey:@"characterId"];
        [dic setObject:commonMsg.characterName forKey:@"characterName"];
        [dic setObject:commonMsg.gameid forKey:@"gameid"];
        [dic setObject:commonMsg.memberInfo forKey:@"memberInfo"];
        [dic setObject:commonMsg.realm forKey:@"realm"];
        [dic setObject:commonMsg.teamUserId forKey:@"teamUserId"];
        [dic setObject:commonMsg.userid forKey:@"userid"];
        return dic;
    }
    return nil;
}

//更新位置
+(void)updatePosition:(NSString*)roomId GameId:(NSString*)gameId GroupId:(NSString*)groupId UserId:(NSString*)userId TeamPosition:(NSDictionary*)teamPosition Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"groupId==[c]%@ and sender==[c]%@",groupId,userId];
        NSArray * commonMsgs = [DSGroupMsgs MR_findAllWithPredicate:predicate1 inContext:localContext];
        for (int i = 0; i<commonMsgs.count; i++) {
            DSGroupMsgs * common = [commonMsgs objectAtIndex:i];
            common.teamPosition = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition,@"value")];
        }
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"roomId==[c]%@ and gameid==[c]%@ and userid==[c]%@",roomId,gameId,userId];
        DSMemberUserInfo * commonMsg = [DSMemberUserInfo MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            commonMsg.positionValue = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition,@"value")];
            
            if (![GameCommon isEmtity:[GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition, @"type")]]) {
                commonMsg.positionType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition, @"type")];
            }
            if (![GameCommon isEmtity:[GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition, @"constId")]]) {
                commonMsg.constId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition, @"constId")];
            }
            if (![GameCommon isEmtity:[GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition, @"mask")]]) {
                commonMsg.mask = [GameCommon getNewStringWithId:KISDictionaryHaveKey(teamPosition, @"mask")];
            }
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}


//请求组队详情信息
+(NSMutableDictionary*)queryDSTeamInfo:(NSString*)gameId RoomId:(NSString*)roomId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and roomId==[c]%@",gameId,roomId];
    DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate];
    return [self getDSTeamInfo:commonMsg];
}

+(NSMutableDictionary*)getDSTeamInfo:(DSTeamList*)commonMsg
{
    if (!commonMsg) {
        return nil;
    }
    NSMutableDictionary * msgDic = [NSMutableDictionary dictionary];
    [msgDic setObject:commonMsg.createDate forKey:@"createDate"];
    [msgDic setObject:commonMsg.crossServer forKey:@"crossServer"];
    [msgDic setObject:commonMsg.descriptions forKey:@"description"];
    [msgDic setObject:commonMsg.dismissDate forKey:@"dismissDate"];
    [msgDic setObject:commonMsg.groupId forKey:@"groupId"];
    [msgDic setObject:commonMsg.maxVol forKey:@"maxVol"];
    [msgDic setObject:commonMsg.memberCount forKey:@"memberCount"];
    [msgDic setObject:commonMsg.minLevelId forKey:@"minLevelId"];
    [msgDic setObject:commonMsg.myMemberId forKey:@"myMemberId"];
    [msgDic setObject:commonMsg.roomId forKey:@"roomId"];
    [msgDic setObject:commonMsg.teamInfo forKey:@"teamInfo"];
    [msgDic setObject:commonMsg.teamName forKey:@"roomName"];
    [msgDic setObject:commonMsg.teamUsershipType forKey:@"teamUsershipType"];
    [msgDic setObject:commonMsg.typeId forKey:@"typeId"];
    [msgDic setObject:commonMsg.gameId forKey:@"gameId"];
    
    
    [msgDic setObject:commonMsg.characterId forKey:@"characterId"];
    [msgDic setObject:commonMsg.characterImg forKey:@"characterImg"];
    [msgDic setObject:commonMsg.characterName forKey:@"characterName"];
    [msgDic setObject:commonMsg.memberInfo forKey:@"memberInfo"];
    [msgDic setObject:commonMsg.realm forKey:@"realm"];
    [msgDic setObject:commonMsg.teamUserId forKey:@"teamUserId"];
    [msgDic setObject:commonMsg.userid forKey:@"userid"];
    [msgDic setObject:commonMsg.gender forKey:@"gender"];
    [msgDic setObject:commonMsg.img forKey:@"img"];
    
    
    return msgDic;
}

+(void)addMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and roomId==[c]%@",gameId,roomId];
        DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            int unread = [commonMsg.memberCount intValue];
            commonMsg.memberCount = [NSString stringWithFormat:@"%d",unread+1];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}



+(void)removeMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and roomId==[c]%@",gameId,roomId];
        DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            int unread = [commonMsg.memberCount intValue];
            commonMsg.memberCount = [NSString stringWithFormat:@"%d",unread>0?(unread-1):0];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}


+(void)addMemBerCount:(NSString*)groupId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            int unread = [commonMsg.memberCount intValue];
            commonMsg.memberCount = [NSString stringWithFormat:@"%d",unread+1];
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}

+(void)removeMemBerCount:(NSString*)groupId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"groupId==[c]%@",groupId];
        DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            int unread = [commonMsg.memberCount intValue];
            commonMsg.memberCount = [NSString stringWithFormat:@"%d",unread>0?(unread-1):0];
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}


+(void)updateMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId MemberCount:(NSString*)memberCount Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and roomId==[c]%@",gameId,roomId];
        DSTeamList * commonMsg = [DSTeamList MR_findFirstWithPredicate:predicate inContext:localContext];
        if (commonMsg) {
            commonMsg.memberCount = memberCount;
        }
        }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success,error);
         }
     }];
}





//保存偏好信息
+(void)savePreferenceInfo:(NSArray*)preferenceInfos Successcompletion:(MRSaveCompletionHandler)successcompletion
{

    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        for (NSMutableDictionary * preferenceInfo in preferenceInfos) {
            NSString * desc = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"desc")];
            NSString * isOpen = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"isOpen")];
            NSString * keyword = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"keyword")];
            NSString * matchCount = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"matchCount")];
            NSString * preferenceId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"preferenceId")];
            NSString * teamUserId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"teamUserId")];
            NSString * typeId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"typeId")];
            NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceInfo, @"userid")];
            NSMutableDictionary * createTeamUserInfo = KISDictionaryHaveKey(preferenceInfo, @"createTeamUser");
            NSString * gameId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"gameid")];
            NSString * characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterId")];
            [self saveCreateTeamUserInfo:createTeamUserInfo Successcompletion:^(BOOL success, NSError *error) {
                
            }];
            NSPredicate * predicates = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and preferenceId==[c]%@",gameId, preferenceId];
            DSPreferenceInfo * commonMsg = [DSPreferenceInfo MR_findFirstWithPredicate:predicates inContext:localContext];
            if (!commonMsg)
                commonMsg = [DSPreferenceInfo MR_createInContext:localContext];
            commonMsg.desc = desc;
            commonMsg.isOpen = isOpen;
            commonMsg.keyword = keyword;
            commonMsg.matchCount = matchCount;
            commonMsg.preferenceId = preferenceId;
            commonMsg.teamUserId = teamUserId;
            commonMsg.typeId = typeId;
            commonMsg.userid = userid;
            commonMsg.gameId = gameId;
            commonMsg.characterId = characterId;
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success ,error);
        }
    }];
}
//保存组队创建者的信息
+(void)saveCreateTeamUserInfo:(NSMutableDictionary*)createTeamUserInfo Successcompletion:(MRSaveCompletionHandler)successcompletion{
    NSString * characterId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterId")];
    NSString * characterImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterImg")];
    NSString * characterName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"characterName")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"gameid")];
    NSString * memberInfo = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"memberInfo")];
    NSString * realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"realm")];
    NSString * teamUserId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"teamUserId")];
    NSString * userid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(createTeamUserInfo, @"userid")];
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"gameid==[c]%@ and teamUserId==[c]%@",gameid,teamUserId];
        DSCreateTeamUserInfo * commonMsgTeamUser = [DSCreateTeamUserInfo MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        if (!commonMsgTeamUser)
            commonMsgTeamUser = [DSCreateTeamUserInfo MR_createInContext:localContext];
        commonMsgTeamUser.characterId = characterId;
        commonMsgTeamUser.characterName = characterName;
        commonMsgTeamUser.characterImg = characterImg;
        commonMsgTeamUser.gameid = gameid;
        commonMsgTeamUser.memberInfo = memberInfo;
        commonMsgTeamUser.realm = realm;
        commonMsgTeamUser.teamUserId = teamUserId;
        commonMsgTeamUser.userid = userid;
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success ,error);
         }
     }];
}

+(NSMutableArray*)queryPreferenceInfos{
    NSMutableArray * array = [NSMutableArray array];
    NSArray * commonMsgs = [DSPreferenceInfo MR_findAll];
    for (DSPreferenceInfo * commonMsg in commonMsgs) {
        [array addObject:[self queryPrefernce:commonMsg]];
    }
    return array;
}

+(NSMutableDictionary*)queryPreferenceInfo:(NSString*)gameId PreferenceId:(NSString*)preferenceId{
    NSPredicate * predicates = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and preferenceId==[c]%@",gameId, preferenceId];
    DSPreferenceInfo * commonMsg = [DSPreferenceInfo MR_findFirstWithPredicate:predicates];
    return [self queryPrefernce:commonMsg];
}

+(NSMutableDictionary*)queryPrefernce:(DSPreferenceInfo*)commmonMsg{
    NSMutableDictionary * preDic = [NSMutableDictionary dictionary];
    [preDic setObject:commmonMsg.desc forKey:@"desc"];
    [preDic setObject:commmonMsg.isOpen forKey:@"isOpen"];
    [preDic setObject:commmonMsg.keyword forKey:@"keyword"];
    [preDic setObject:commmonMsg.matchCount forKey:@"matchCount"];
    [preDic setObject:commmonMsg.preferenceId forKey:@"preferenceId"];
    [preDic setObject:commmonMsg.teamUserId forKey:@"teamUserId"];
    [preDic setObject:commmonMsg.typeId forKey:@"typeId"];
    [preDic setObject:commmonMsg.userid forKey:@"userid"];
    [preDic setObject:commmonMsg.gameId forKey:@"gameId"];
    [preDic setObject:commmonMsg.characterId forKey:@"characterId"];
    return preDic;
}

+(void)deletePreferenceInfo:(NSString*)gameId PreferenceId:(NSString*)preferenceId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and preferenceId==[c]%@",gameId, preferenceId];
        DSPreferenceInfo * commonMsg = [DSPreferenceInfo MR_findFirstWithPredicate:predicates inContext:localContext];
        if (!commonMsg){
            [commonMsg deleteInContext:localContext];
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success ,error);
         }
     }];
}
//根据characterId删除偏好
+(void)deletePreferenceInfoByCharacterId:(NSString*)characterId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"characterId==[c]%@",characterId];
        NSArray * commonMsgs = [DSPreferenceInfo MR_findAllWithPredicate:predicates inContext:localContext];
        for (DSPreferenceInfo * commonMsg in commonMsgs) {
            if (!commonMsg){
                [commonMsg deleteInContext:localContext];
            }
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success ,error);
        }
    }];
}
//

+(NSMutableDictionary*)queryCreateTeamUserInfo:(NSString*)gameId UserId:(NSString*)userId{
    NSPredicate * predicates = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and userid==[c]%@",gameId, userId];
    DSCreateTeamUserInfo * commonMsg = [DSCreateTeamUserInfo MR_findFirstWithPredicate:predicates];
    return [self queryCreateTeamUserInfo:commonMsg];
}

+(NSMutableDictionary*)queryCreateTeamUserInfo:(DSCreateTeamUserInfo*)commmonMsg{
    NSMutableDictionary * preDic = [NSMutableDictionary dictionary];
    [preDic setObject:commmonMsg.characterId forKey:@"characterId"];
    [preDic setObject:commmonMsg.characterName forKey:@"characterName"];
    [preDic setObject:commmonMsg.characterImg forKey:@"characterImg"];
    [preDic setObject:commmonMsg.gameid forKey:@"gameid"];
    [preDic setObject:commmonMsg.memberInfo forKey:@"memberInfo"];
    [preDic setObject:commmonMsg.realm forKey:@"realm"];
    [preDic setObject:commmonMsg.teamUserId forKey:@"teamUserId"];
    [preDic setObject:commmonMsg.userid forKey:@"userid"];
    return preDic;
}

+(void)deletePreferenceInfo:(NSString*)gameId TeamUserId:(NSString*)teamUserId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicates = [NSPredicate predicateWithFormat:@"gameId==[c]%@ and teamUserId==[c]%@",gameId, teamUserId];
        DSCreateTeamUserInfo * commonMsg = [DSCreateTeamUserInfo MR_findFirstWithPredicate:predicates inContext:localContext];
        if (!commonMsg){
            [commonMsg deleteInContext:localContext];
        }
    }
    completion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success ,error);
        }
    }];
}
//
//保存组队创建者的信息
+(void)savePreferenceMsg:(NSDictionary*)preferenceMsg SaveSuccess:(void (^)(NSDictionary *msgDic))block{
    NSString * msgId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceMsg, @"msgId")];
    NSString * msgType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceMsg, @"msgType")];
    NSString * fromId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceMsg, @"fromId")];
    NSString * toId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceMsg, @"toId")];
    NSDate * msgTime = [NSDate dateWithTimeIntervalSince1970:[[preferenceMsg objectForKey:@"time"] doubleValue]];
    NSString * payload = [GameCommon getNewStringWithId:KISDictionaryHaveKey(preferenceMsg, @"payload")];
    NSDictionary * payLoadDic = [payload JSONValue];
    NSString * userCount = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payLoadDic, @"userCount")];
    NSString * roomCount = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payLoadDic, @"roomCount")];
    NSString * characterName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payLoadDic, @"characterName")];
    NSString * descriptions = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payLoadDic, @"description")];
    NSString * preferenceId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payLoadDic, @"preferenceId")];
    NSString * gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(payLoadDic, @"gameid")];
    [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
         NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"gameid==[c]%@ and preferenceId==[c]%@",gameid,preferenceId];
        DSPreferenceMsg * commonMsg = [DSPreferenceMsg MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        int unread;
        if (!commonMsg){
           commonMsg = [DSPreferenceMsg MR_createInContext:localContext];
            unread =0;
        }else{
            unread = [commonMsg.msgCount intValue];
        }
        commonMsg.msgId = msgId;
        commonMsg.msgType = msgType;
        commonMsg.fromId = fromId;
        commonMsg.toId = toId;
        commonMsg.msgTime = msgTime;
        commonMsg.payload = payload;
        commonMsg.userCount = userCount;
        commonMsg.roomCount = roomCount;
        commonMsg.characterName = characterName;
        commonMsg.descriptions = descriptions;
        commonMsg.preferenceId = preferenceId;
        commonMsg.gameid = gameid;
        commonMsg.msgCount = [NSString stringWithFormat:@"%d",unread+1];
    }
//    completion:^(BOOL success, NSError *error) {
//        if (block) {
//            block(preferenceMsg);
//        }
//    }
     ];
    if (block) {
        block(preferenceMsg);
    }
}


+(NSMutableArray*)getPrefernceMsgs{
    NSMutableArray * array = [NSMutableArray array];
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * arrays = [DSPreferenceMsg MR_findAllInContext:localContext];
        for (DSPreferenceMsg * commonMsg in arrays) {
            [array addObject:[self getPreMsgDic:commonMsg]];
        }
    }];
   
    return  array;
}

+(NSMutableDictionary*)getPreferenceMsg:(NSString*)gameId PreferenceId:(NSString*)preferenceId{
    NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"gameid==[c]%@ and preferenceId==[c]%@",gameId,preferenceId];
    DSPreferenceMsg * commonMsg = [DSPreferenceMsg MR_findFirstWithPredicate:predicatesTeamUser];
    return [self getPreMsgDic:commonMsg];
}
+(NSMutableDictionary*)getPreMsgDic:(DSPreferenceMsg*)commonMsg{
    if (!commonMsg) {
        return nil;
    }
    NSMutableDictionary * preDic = [NSMutableDictionary dictionary];
    [preDic setObject:commonMsg.msgId forKey:@"msgId"];
    [preDic setObject:commonMsg.msgType forKey:@"msgType"];
    [preDic setObject:commonMsg.fromId forKey:@"fromId"];
    [preDic setObject:commonMsg.toId forKey:@"toId"];
    NSTimeInterval uu = [commonMsg.msgTime timeIntervalSince1970];
    [preDic setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"msgTime"];
    [preDic setObject:commonMsg.payload forKey:@"payload"];
    [preDic setObject:commonMsg.userCount forKey:@"userCount"];
    [preDic setObject:commonMsg.roomCount forKey:@"roomCount"];
    [preDic setObject:commonMsg.characterName forKey:@"characterName"];
    [preDic setObject:commonMsg.descriptions forKey:@"description"];
    [preDic setObject:commonMsg.preferenceId forKey:@"preferenceId"];
    [preDic setObject:commonMsg.gameid forKey:@"gameid"];
    [preDic setObject:commonMsg.msgCount forKey:@"msgCount"];
    return preDic;
}

+(void)deletePreferenceMsg:(NSString*)gameId PreferenceId:(NSString*)preferenceId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"gameid==[c]%@ and preferenceId==[c]%@",gameId,preferenceId];
        DSPreferenceMsg * commonMsg = [DSPreferenceMsg MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        [commonMsg deleteInContext:localContext];
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(success ,error);
         }

     }];
}
+(void)updatePreferenceMsg:(NSString*)gameId PreferenceId:(NSString*)preferenceId Successcompletion:(MRSaveCompletionHandler)successcompletion{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"gameid==[c]%@ and preferenceId==[c]%@",gameId,preferenceId];
        DSPreferenceMsg * commonMsg = [DSPreferenceMsg MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        if (commonMsg) {
            commonMsg.msgCount = @"0";
        }
    }
     completion:^(BOOL success, NSError *error) {
         if (successcompletion) {
             successcompletion(true,nil);
         }
     }];
}

+(void)saveCricleCountWithType:(NSInteger)type img:(NSString*)img userid:(NSString *)userid
{
    NSLog(@"消息过来了---%d",type);
    
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSCircleCount * circleCo = [DSCircleCount MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        if (!circleCo)
            circleCo = [DSCircleCount MR_createInContext:localContext];
        if (type==1) {
            circleCo.mineCount +=1;
            NSLog(@"与我相关（%d）",circleCo.mineCount);
        }else{
            circleCo.friendsCount+=1;
            NSLog(@"好友动态（%d）",circleCo.friendsCount);

        }
        circleCo.img = [GameCommon getHeardImgId:img];
        circleCo.userid = userid;
        NSLog(@"--%@",circleCo);
    }
    completion:^(BOOL success, NSError *error) {
        if (success) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshCircleCount" object:nil];
        }else{
//            [self saveCricleCountWithType:type img:img userid:userid];
            
            if (type ==1) {
                NSLog(@"与我相关保存失败");
            }else{
                 NSLog(@"好友动态保存失败");
            }
            
        }
    }];
}
+(DSCircleCount*)querymessageWithUserid:(NSString *)userid
{
    NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
    DSCircleCount * circleCo = [DSCircleCount MR_findFirstWithPredicate:predicatesTeamUser];
    if (circleCo) {
        return circleCo;
    }else
        return NULL;
}
+(void)clearMeCircleCountWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSCircleCount * circleCo = [DSCircleCount MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        if (circleCo) {
            circleCo.mineCount = 0;
        }
    }
    completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshCircleCount" object:nil];
    }];
}

+(void)clearFriendCircleCountWithUserid:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlock:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicatesTeamUser = [NSPredicate predicateWithFormat:@"userid==[c]%@",userid];
        DSCircleCount * circleCo = [DSCircleCount MR_findFirstWithPredicate:predicatesTeamUser inContext:localContext];
        if (circleCo) {
            circleCo.friendsCount = 0;
        }
    }
    completion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshCircleCount" object:nil];
    }];
}

@end
