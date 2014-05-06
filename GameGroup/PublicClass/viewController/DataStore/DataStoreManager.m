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
+ (BOOL)savedMsgWithID:(NSString*)msgId//消息是否已存
{
    NSArray * array = [DSCommonMsgs MR_findByAttribute:@"messageuuid" withValue:msgId];
    if (array.count > 0) {
        return YES;
    }
    return NO;
}
+ (BOOL)savedOtherMsgWithID:(NSString *)msgID
{
    NSArray * array = [DSOtherMsgs MR_findByAttribute:@"messageuuid" withValue:msgID];
    if (array.count > 0) {
        return YES;
    }
    return NO;
}
+ (BOOL)savedNewsMsgWithID:(NSString*)msgId//消息是否已存
{
    NSArray * array = [DSNewsMsgs MR_findByAttribute:@"messageuuid" withValue:msgId];
    if (array.count > 0) {
        return YES;
    }
    return NO;
}
#pragma mark - 存储消息相关
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
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (thumbMsgs)
        {
            thumbMsgs.sayHiType = type;
            NSLog(@"thumbMsgs.sayHiType%@",thumbMsgs.sayHiType);
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

+(void)deleteThumbMsgWithSender:(NSString *)sender
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        [thumbMsgs MR_deleteInContext:localContext];
    }];
}

+(void)storeNewMsgs:(NSDictionary *)msg senderType:(NSString *)sendertype
{
    NSRange range = [[msg objectForKey:@"sender"] rangeOfString:@"@"];
    NSString * sender = [[msg objectForKey:@"sender"] substringToIndex:range.location];//userid
    NSDictionary* user= [[UserManager singleton] getUser:sender];
    NSString * senderNickname = [user objectForKey:@"nickname"];
    NSString * msgContent = KISDictionaryHaveKey(msg, @"msg");
    NSString * msgType = KISDictionaryHaveKey(msg, @"msgType");
    NSString * msgId = KISDictionaryHaveKey(msg, @"msgId");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[[msg objectForKey:@"time"] doubleValue]];
    NSString *sayhiType = KISDictionaryHaveKey(msg, @"sayHiType")?KISDictionaryHaveKey(msg, @"sayHiType"):@"1";
//    NSString * receiver;
//    if ([msg objectForKey:@"receicer"]) {
//        NSRange range2 = [[msg objectForKey:@"receicer"] rangeOfString:@"@"];
//        receiver = [[msg objectForKey:@"receicer"] substringToIndex:range2.location];
//    }
    
    //普通用户消息存储到DSCommonMsgs和DSThumbMsgs两个表里
    if ([sendertype isEqualToString:COMMONUSER]) {
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];//所有消息
            commonMsg.sender = sender;
            commonMsg.senderNickname = senderNickname?senderNickname:@"";
            commonMsg.msgContent = msgContent?msgContent:@"";
            commonMsg.senTime = sendTime;
            commonMsg.msgType = msgType;
            commonMsg.payload = KISDictionaryHaveKey(msg, @"payload");
            commonMsg.messageuuid = msgId;
            commonMsg.status = @"1";//已发送
            
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
            
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];//消息页展示的内容
            if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = sender;
            thumbMsgs.senderNickname = senderNickname?senderNickname:@"";
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.msgType = msgType;
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = sayhiType;
                
            if ([sayhiType isEqualToString:@"2"]){
                    NSPredicate * predicate1 = [NSPredicate predicateWithFormat:@"sender==[c]%@",@"1234567wxxxxxxxxx"];
                   DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate1];                    if (!thumbMsgs)
                    thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
                    thumbMsgs.sender = @"1234567wxxxxxxxxx";
                    thumbMsgs.senderNickname = @"有新的打招呼信息";
                    thumbMsgs.senderType = sendertype;
                    int unread = [thumbMsgs.unRead intValue];
                    thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
                    thumbMsgs.msgType = @"sayHi";
                    thumbMsgs.messageuuid = @"wx123";
                    thumbMsgs.status = @"1";//已发送
                    thumbMsgs.sayHiType = @"1";
                }
            
        }];
    }
    else if ([sendertype isEqualToString:PAYLOADMSG]) {//动态聊天消息
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];//所有消息
            commonMsg.sender = sender;
            commonMsg.senderNickname = senderNickname?senderNickname:@"";
            commonMsg.msgContent = msgContent?msgContent:@"";
            commonMsg.senTime = sendTime;
            commonMsg.msgType = msgType;
            commonMsg.payload = KISDictionaryHaveKey(msg, @"payload");
            commonMsg.messageuuid = msgId;
            commonMsg.status = @"1";//已发送
            
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",sender];
            DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];//消息页展示的内容
            if (!thumbMsgs)
                thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
            thumbMsgs.sender = sender;
            thumbMsgs.senderNickname = senderNickname?senderNickname:@"";
            thumbMsgs.msgContent = msgContent;
            thumbMsgs.sendTime = sendTime;
            thumbMsgs.senderType = sendertype;
            int unread = [thumbMsgs.unRead intValue];
            thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
            thumbMsgs.msgType = msgType;
            thumbMsgs.messageuuid = msgId;
            thumbMsgs.status = @"1";//已发送
            thumbMsgs.sayHiType = sayhiType;
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

        }];
    }
    else if([sendertype isEqualToString:DAILYNEWS])//新闻
    {
        NSString* title = KISDictionaryHaveKey(msg, @"title");
        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            DSNewsMsgs * newsMsg = [DSNewsMsgs MR_createInContext:localContext];//所有消息
            newsMsg.messageuuid = msgId;
            newsMsg.msgcontent = msgContent;
            newsMsg.msgtype = msgType;
            newsMsg.mytitle = title;
            newsMsg.sendtime = sendTime;
            
            
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

        }];
    }
}
+(void)storeMyPayloadmsg:(NSDictionary *)message
{
    NSLog(@"message==%@",message);
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * sender = KISDictionaryHaveKey(message, @"sender");
    NSString * receicerNickname = KISDictionaryHaveKey(message, @"nickname");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* heardimg = KISDictionaryHaveKey(message, @"img");
    
    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];//所有消息
        commonMsg.sender = sender;
        commonMsg.senderNickname = @"";
        commonMsg.msgContent = msgContent?msgContent:@"";
        commonMsg.senTime = sendTime;
        commonMsg.receiver = receicer;
        commonMsg.msgType = msgType;
        commonMsg.payload = KISDictionaryHaveKey(message, @"payload");//动态 消息json
        commonMsg.messageuuid = messageuuid;
        commonMsg.status = @"2";//发送中
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",receicer];
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = receicer;
        thumbMsgs.senderNickname = receicerNickname;
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = PAYLOADMSG;
        thumbMsgs.msgType = msgType;
        thumbMsgs.senderimg = heardimg;
        thumbMsgs.sayHiType = @"1";
        int unread = [thumbMsgs.unRead intValue];
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"2";//发送中
    }];
}
+(void)storeMyMessage:(NSDictionary *)message
{
    NSLog(@"message==%@",message);
    NSString * receicer = KISDictionaryHaveKey(message, @"receiver");
    NSString * sender = KISDictionaryHaveKey(message, @"sender");
    NSString * receicerNickname = KISDictionaryHaveKey(message, @"nickname");
    NSString * msgContent = KISDictionaryHaveKey(message, @"msg");
    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[KISDictionaryHaveKey(message, @"time") doubleValue]];
    
    NSString* msgType = KISDictionaryHaveKey(message, @"msgType");
    NSString* heardimg = KISDictionaryHaveKey(message, @"img");

    NSString* messageuuid = KISDictionaryHaveKey(message, @"messageuuid");

    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        DSCommonMsgs * commonMsg = [DSCommonMsgs MR_createInContext:localContext];
        commonMsg.sender = sender;
        commonMsg.senderNickname = @"";
        commonMsg.msgContent = msgContent?msgContent:@"";
        commonMsg.senTime = sendTime;
        commonMsg.receiver = receicer;
        commonMsg.msgType = msgType;
        commonMsg.payload = KISDictionaryHaveKey(message, @"payload");//动态 消息json
        commonMsg.messageuuid = messageuuid;
        commonMsg.status = @"2";//发送中

        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",receicer];
        
        DSThumbMsgs * thumbMsgs = [DSThumbMsgs MR_findFirstWithPredicate:predicate];
        if (!thumbMsgs)
            thumbMsgs = [DSThumbMsgs MR_createInContext:localContext];
        thumbMsgs.sender = receicer;
        thumbMsgs.senderNickname = receicerNickname;
        thumbMsgs.msgContent = msgContent;
        thumbMsgs.sendTime = sendTime;
        thumbMsgs.senderType = COMMONUSER;
        thumbMsgs.msgType = msgType;
        thumbMsgs.senderimg = heardimg;
        thumbMsgs.sayHiType = @"1";
        int unread = [thumbMsgs.unRead intValue];
        thumbMsgs.unRead = [NSString stringWithFormat:@"%d",unread+1];
        thumbMsgs.messageuuid = messageuuid;
        thumbMsgs.status = @"2";//发送中
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

+(void)blankMsgUnreadCountForUser:(NSString *)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@",userid];
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

+ (NSMutableArray *)qureyCommonMessagesWithUserID:(NSString *)userid FetchOffset:(NSInteger)integer
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ OR receiver==[c]%@",userid,userid];
    NSSortDescriptor * sortDescriptor = [[NSSortDescriptor alloc]initWithKey:@"senTime" ascending:NO];
    NSFetchRequest * fetchRequest = [DSCommonMsgs MR_requestAllWithPredicate:predicate];
    [fetchRequest setFetchOffset:integer];
    [fetchRequest setFetchLimit:20];
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
+(NSMutableArray *)qureyAllCommonMessages:(NSString *)userid
{
    NSMutableArray * allMsgArray = [[NSMutableArray alloc] initWithCapacity:1];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"sender==[c]%@ OR receiver==[c]%@",userid,userid];
    NSArray * commonMsgsArray = [DSCommonMsgs MR_findAllSortedBy:@"senTime" ascending:YES withPredicate:predicate];
//    //取前20条...
//    for (int i = (commonMsgsArray.count>20?(commonMsgsArray.count-20):0); i<commonMsgsArray.count; i++) {
//        NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
//        [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] sender] forKey:@"sender"];
//        [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] msgContent] forKey:@"msg"];
//        NSDate * tt = [[commonMsgsArray objectAtIndex:i] senTime];
//        NSTimeInterval uu = [tt timeIntervalSince1970];
//        [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
//        [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] msgType]?[[commonMsgsArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
//        [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] payload]?[[commonMsgsArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
//        [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] messageuuid]?[[commonMsgsArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
//        [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] status]?[[commonMsgsArray objectAtIndex:i] status] : @"" forKey:@"status"];
//
//        [allMsgArray addObject:thumbMsgsDict];
//        
//    }
    NSInteger allCount = [commonMsgsArray count];
    if (allCount == 0) {
        return allMsgArray;
    }
    NSInteger allPage = allCount/20 + (allCount%20 > 0 ? 1 : 0);//每页20条 总共几页 第一页下标为allPage－1 最后一页为0
    for (int p = 1; p <= allPage; p++) {
        NSMutableArray* pageDataArray = [[NSMutableArray alloc] initWithCapacity:1];
        if (p != allPage) {//不是最后一页
            for (int i = allCount - 20 * p; i < (allCount - 20 * p) + 20; i++) {
                NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] sender] forKey:@"sender"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] msgContent] forKey:@"msg"];
                NSDate * tt = [[commonMsgsArray objectAtIndex:i] senTime];
                NSTimeInterval uu = [tt timeIntervalSince1970];
                [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] msgType]?[[commonMsgsArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] payload]?[[commonMsgsArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] messageuuid]?[[commonMsgsArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] status]?[[commonMsgsArray objectAtIndex:i] status] : @"" forKey:@"status"];
                
                [pageDataArray addObject:thumbMsgsDict];
            }
        }
        else
        {
            for (int i = 0; i < allCount - (20 * (p - 1)); i++) {//最后一页
                NSMutableDictionary * thumbMsgsDict = [NSMutableDictionary dictionary];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] sender] forKey:@"sender"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] msgContent] forKey:@"msg"];
                NSDate * tt = [[commonMsgsArray objectAtIndex:i] senTime];
                NSTimeInterval uu = [tt timeIntervalSince1970];
                [thumbMsgsDict setObject:[NSString stringWithFormat:@"%f",uu] forKey:@"time"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] msgType]?[[commonMsgsArray objectAtIndex:i] msgType] : @"" forKey:@"msgType"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] payload]?[[commonMsgsArray objectAtIndex:i] payload] : @"" forKey:@"payload"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] messageuuid]?[[commonMsgsArray objectAtIndex:i] messageuuid] : @"" forKey:@"messageuuid"];
                [thumbMsgsDict setObject:[[commonMsgsArray objectAtIndex:i] status]?[[commonMsgsArray objectAtIndex:i] status] : @"" forKey:@"status"];
                
                [pageDataArray addObject:thumbMsgsDict];
            }
        }
        [allMsgArray addObject:pageDataArray];
    }
    return allMsgArray;
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
//                if ([msgType isEqualToString:@"payloadchat"]) {
//                    NSDictionary* dic = [msgContent JSONValue];
//                    thumbMsgs.msgContent = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"title")].length > 0 ? KISDictionaryHaveKey(dic, @"title") : KISDictionaryHaveKey(dic, @"msg");
//                }
//                else
//                {
                    thumbMsgs.msgContent = msgContent;
//                }
                thumbMsgs.sendTime = sendTime;
            }
        }
        
    }];
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
    NSArray *array =[DSThumbMsgs MR_findAllSortedBy:@"sendTime" ascending:NO];
    NSMutableArray *allMsgArray = [NSMutableArray array];
    for (int i = 0; i<array.count; i++) {
        if ([[[array objectAtIndex:i]sayHiType]isEqualToString:type]) {
            [allMsgArray addObject:[array objectAtIndex:i]];
        }
    }
    return allMsgArray;
}

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

#pragma mark -存储所有人的列表信息
+(void)saveAllUserWithUserManagerList:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype
{
        NSString * myUserName = [GameCommon getNewStringWithId:[userInfo objectForKey:@"username"]];
        NSString * background = [GameCommon getNewStringWithId:[userInfo objectForKey:@"backgroundImg"]];
        NSString * nickName = [GameCommon getNewStringWithId:[userInfo objectForKey:@"nickname"]];
        NSString * gender = [GameCommon getNewStringWithId:[userInfo objectForKey:@"gender"]];
        BOOL action;
        if ([[GameCommon getNewStringWithId:[userInfo objectForKey:@"active"]]intValue] == 2) {
            action =YES;
        }else{
            action =NO;
        }
        NSString * headImgID = [GameCommon getNewStringWithId:[userInfo objectForKey:@"img"]];
        NSString * signature = [GameCommon getNewStringWithId:[userInfo objectForKey:@"signature"]];
        
        NSString * age = [GameCommon getNewStringWithId:[userInfo objectForKey:@"age"]];
        NSString * userId = [GameCommon getNewStringWithId:[userInfo objectForKey:@"id"]];
        NSString * achievement = [GameCommon getNewStringWithId:[userInfo objectForKey:@"achievement"]];
        NSString * alias = [GameCommon getNewStringWithId:[userInfo objectForKey:@"alias"]];//别名
        
        NSString * starSign = [GameCommon getNewStringWithId:[userInfo objectForKey:@"constellation"]];
        NSString * hobby = [GameCommon getNewStringWithId:[userInfo objectForKey:@"remark"]];
        NSString * birthday = [GameCommon getNewStringWithId:[userInfo objectForKey:@"birthdate"]];
        NSString * createTime = [GameCommon getNewStringWithId:[userInfo objectForKey:@"createTime"]];
        //    NSString * nameIndex = [GameCommon getNewStringWithId:[myInfo objectForKey:@"nameindex"]];
        NSString * refreshTime = [GameCommon getNewStringWithId:[userInfo objectForKey:@"updateUserLocationDate"]];
        double distance = [KISDictionaryHaveKey(userInfo, @"distance") doubleValue];
        if (distance == -1) {//若没有距离赋最大值
            distance = 9999000;
        }
        NSString * titleObj = @"";
        NSString * titleObjLevel = @"";
        
        NSDictionary* titleDic = KISDictionaryHaveKey(userInfo, @"title");
        if ([titleDic isKindOfClass:[NSDictionary class]]) {
            titleObj = KISDictionaryHaveKey(KISDictionaryHaveKey(titleDic, @"titleObj"), @"title");
            titleObjLevel = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(titleDic, @"titleObj"), @"rarenum")];
        }
        else
        {
            titleObj = @"暂无头衔";
            titleObjLevel = @"6";
        }
        
        NSString * superstar = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superstar")];//是否为明星用户
        NSString * superremark = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superremark")];
        if (userId) {
            [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
                NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
                DSuser * dUser= [DSuser MR_findFirstWithPredicate:predicate];
                if (!dUser)
                    dUser = [DSuser MR_createInContext:localContext];
                dUser.userName = myUserName;
                dUser.nickName = nickName?(nickName.length>1?nickName:[nickName stringByAppendingString:@" "]):@"";
                dUser.action = [NSNumber numberWithBool:action];
                dUser.gender = gender?gender:@"";
                dUser.userId = userId?userId:@"";
                dUser.headImgID = headImgID?headImgID:@"";
                dUser.signature = signature?signature:@"";
                dUser.age = age?age:@"";
                dUser.backgroundImg = background;
                dUser.achievement = achievement?achievement:@"";
                
                dUser.starSign = starSign?starSign:@"";
                dUser.hobby = hobby?hobby:@"";
                dUser.birthday = birthday?birthday:@"";
                dUser.createTime = createTime?createTime:@"";
                dUser.remarkName = alias?alias:@"";
                
                dUser.superstar = superstar?superstar:@"";
                dUser.superremark = superremark?superremark:@"";
                dUser.shiptype = shiptype?shiptype:@"";
                dUser.achievement = titleObj;
                dUser.achievementLevel = titleObjLevel;
                dUser.refreshTime = refreshTime;
                dUser.distance = [NSNumber numberWithDouble:distance];
                
                NSString* pinYin = [alias isEqualToString:@""] ? nickName : alias;
                NSString * nameIndex;
                NSString * nameKey;
                if (nickName.length>=1) {
                    nameKey = [[DataStoreManager convertChineseToPinYin:pinYin] stringByAppendingFormat:@"+%@",pinYin];
                    nameKey = [nameKey stringByAppendingFormat:@"%@", userId];
                    dUser.nameKey = nameKey;
                    nameIndex = [[nameKey substringToIndex:1] uppercaseString];
                    dUser.nameIndex = nameIndex;
                }
                if (![userId isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]&&nickName.length>=1) {
                    
                        if ([dUser.shiptype isEqualToString:@"1"]) {
                            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                            DSNameIndex * dFname = [DSNameIndex MR_findFirstWithPredicate:predicate2];
                            if (!dFname)
                                dFname = [DSNameIndex MR_createInContext:localContext];
                            
                            dFname.index = nameIndex;
                            return ;
                        }
                        if([dUser.shiptype isEqualToString:@"2"])
                        {
                            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                            DSAttentionNameIndex * dFname = [DSAttentionNameIndex MR_findFirstWithPredicate:predicate2];
                            if (!dFname)
                                dFname = [DSAttentionNameIndex MR_createInContext:localContext];
                            
                            dFname.index = nameIndex;
                            return ;
                        }
                        if([dUser.shiptype isEqualToString:@"2"])
                        {
                            NSPredicate * predicate2 = [NSPredicate predicateWithFormat:@"index==[c]%@",nameIndex];
                            DSFansNameIndex * dFname = [DSFansNameIndex MR_findFirstWithPredicate:predicate2];
                            if (!dFname)
                                dFname = [DSFansNameIndex MR_createInContext:localContext];
                            
                            dFname.index = nameIndex;
                            return ;
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
     
+(NSMutableArray*)queryAllUserManagerWithOtherSortType:(NSString*)sorttype ascend:(BOOL)ascend
{
    NSArray * fri = [DSuser MR_findAllSortedBy:sorttype ascending:ascend];
    NSMutableArray * nameKeyArray = [NSMutableArray array];
    NSMutableArray * theArr = [NSMutableArray array];
    for (int i = 0; i<fri.count; i++) {
        NSString * nameK = [[fri objectAtIndex:i]nameKey];
        if (nameK)
            [nameKeyArray addObject:nameK];
        NSString * userName = [[fri objectAtIndex:i] userName];
        NSString * userid = [[fri objectAtIndex:i] userId];
        NSString * nickName = [[fri objectAtIndex:i] nickName];
        NSString * remarkName = [[fri objectAtIndex:i] remarkName];
        NSString * headImg = [DataStoreManager queryFirstHeadImageForUser_userManager:userid];
        NSString * age = [[fri objectAtIndex:i] age];
        NSString * gender = [[fri objectAtIndex:i] gender];//性别
        NSString * achievement = [[fri objectAtIndex:i] achievement];//头衔
        NSString * achievementLevel = [[fri objectAtIndex:i] achievementLevel];//头衔
        NSString * modTime = [[fri objectAtIndex:i] refreshTime];//
        double distance = [[[fri objectAtIndex:i] distance] doubleValue];//
        
        if (![userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
            NSMutableDictionary * theDict = [NSMutableDictionary dictionary];
            [theDict setObject:userName forKey:@"username"];
            [theDict setObject:userid forKey:@"userid"];
            [theDict setObject:nickName?nickName:@"" forKey:@"nickname"];
            if (![remarkName isEqualToString:@""]) {
                [theDict setObject:remarkName forKey:@"displayName"];
            }
            else if(![nickName isEqualToString:@""]){
                [theDict setObject:nickName forKey:@"displayName"];
            }
            else
            {
                [theDict setObject:userName forKey:@"displayName"];
            }
            [theDict setObject:headImg?headImg:@"" forKey:@"img"];
            [theDict setObject:age ? age:@"" forKey:@"age"];
            [theDict setObject:gender ? gender:@"" forKey:@"sex"];
            [theDict setObject:achievement ? achievement:@"" forKey:@"achievement"];
            [theDict setObject:achievementLevel ? achievementLevel:@"" forKey:@"achievementLevel"];
            [theDict setObject:modTime ? modTime:@"" forKey:@"updateUserLocationDate"];
            [theDict setObject:[NSString stringWithFormat:@"%.f", distance] forKey:@"distance"];
            
            [theArr addObject:theDict];
        }
    }
    return theArr;
}

+(NSMutableDictionary*)queryAllUserManagerWithshipType:(NSString *)shiptype
{
    
    NSArray * array = [DSuser MR_findAll];
    NSMutableArray *fri = [NSMutableArray array];
    for (int i =0;i<array.count;i++) {
        DSuser *dUser = [array objectAtIndex:i];
        if ([dUser.shiptype isEqualToString:shiptype]) {
            [fri addObject:dUser];
        }
    }
    {
        NSMutableArray * nameKeyArray = [NSMutableArray array];
        NSMutableDictionary * theDict = [NSMutableDictionary dictionary];
        
        
        
        for (int i = 0; i<fri.count; i++) {
            NSString * nameK = [[fri objectAtIndex:i]nameKey];
            if (nameK)
                [nameKeyArray addObject:nameK];
            NSString * userName = [[fri objectAtIndex:i] userName];
            NSString * userid = [[fri objectAtIndex:i] userId];
            NSString * nickName = [[fri objectAtIndex:i] nickName];
            NSString * remarkName = [[fri objectAtIndex:i] remarkName];
            NSString * headImg = [DataStoreManager queryFirstHeadImageForUser_userManager:userid];
            NSString * age = [[fri objectAtIndex:i] age];
            NSString * gender = [[fri objectAtIndex:i] gender];//性别
            NSString * achievement = [[fri objectAtIndex:i] achievement];//头衔
            NSString * achievementLevel = [[fri objectAtIndex:i] achievementLevel];//头衔
            NSString * modTime = [[fri objectAtIndex:i] refreshTime];//
            double distance = [[[fri objectAtIndex:i] distance] doubleValue];//
            if (![userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]&&nameK) {
                NSMutableDictionary * friendDict = [NSMutableDictionary dictionary];
                [friendDict setObject:userName forKey:@"username"];
                [friendDict setObject:userid forKey:@"userid"];
                [friendDict setObject:nickName?nickName:@"" forKey:@"nickname"];
                if (remarkName && ![remarkName isEqualToString:@""]) {
                    [friendDict setObject:remarkName?remarkName:@"" forKey:@"displayName"];
                }
                else if(nickName && ![nickName isEqualToString:@""]){
                    [friendDict setObject:nickName forKey:@"displayName"];
                }
                else
                {
                    [friendDict setObject:userName ? userName : @"" forKey:@"displayName"];
                }
                [friendDict setObject:headImg?headImg:@"" forKey:@"img"];
                [friendDict setObject:age ? age:@"" forKey:@"age"];
                [friendDict setObject:gender ? gender:@"" forKey:@"sex"];
                [friendDict setObject:achievement ? achievement:@"" forKey:@"achievement"];
                [friendDict setObject:achievementLevel ? achievementLevel:@"" forKey:@"achievementLevel"];
                [friendDict setObject:modTime ? modTime:@"" forKey:@"updateUserLocationDate"];
                [friendDict setObject:[NSString stringWithFormat:@"%.f", distance] forKey:@"distance"];
                
                [theDict setObject:friendDict forKey:nameK];
                NSLog(@"thedict---%@",nameK);
                
            }
        }
         NSLog(@"thedictallKeys---%@",[theDict allKeys]);
        return theDict;
        
    }
}





+(BOOL)ifHaveThisUserInUserManager:(NSString *)userId
{
    if (userId) {
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
+(NSString *)queryRemarkNameForUserManager:(NSString *)userid
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
    if (dUser) {
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

+(void)deleteAllUserWithUserId:(NSString*)userid
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userid];
        DSuser * dUserManager = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUserManager) {
            [dUserManager MR_deleteInContext:localContext];
        }
    }];
}
+(void)deleteAllUserWithShipType:(NSString*)shiptype
{
    NSArray *array = [DSuser MR_findAll];
        for (int i =0;i<array.count;i++) {
            DSuser * dUserManager = [array objectAtIndex:i];
            if ([dUserManager.shiptype isEqualToString:shiptype]) {
                [self deleteAllUserWithUserId:dUserManager.userId];
            [DataStoreManager cleanIndexWithNameIndex:dUserManager.nameIndex withType:shiptype];
            }
        }
}

+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {
        dUser.shiptype = type;
        }
    //[self cleanIndexWithNameIndex:dUser.nameIndex withType:type];
}

+(void)deleteAllUser
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * thumbMsgs = [DSThumbMsgs MR_findAllInContext:localContext];
        for (DSThumbMsgs* msg in thumbMsgs) {
            [msg MR_deleteInContext:localContext];
        }
    }];
}



+(NSMutableArray *)queryAttentionSections
{
    NSMutableArray * sectionArray = [NSMutableArray array];
    NSArray * nameIndexArray2 = [DSAttentionNameIndex MR_findAll];
    NSMutableArray * nameIndexArray = [NSMutableArray array];
    for (int i = 0; i<nameIndexArray2.count; i++) {
        DSAttentionNameIndex * di = [nameIndexArray2 objectAtIndex:i];
        [nameIndexArray addObject:di.index];
    }
    [nameIndexArray sortUsingSelector:@selector(compare:)];
    for (int i = 0; i<nameIndexArray.count; i++) {
        NSMutableArray * array = [NSMutableArray array];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"nameIndex==[c]%@",[nameIndexArray objectAtIndex:i]];
        NSArray * fri = [DSuser MR_findAllSortedBy:@"nameKey" ascending:YES withPredicate:predicate];
        NSMutableArray * nameKeyArray = [NSMutableArray array];
        for (int i = 0; i<fri.count; i++) {
            NSString *shiptype =[[fri objectAtIndex:i]shiptype];
            NSString * thename = [[fri objectAtIndex:i]userId];
            NSString * nameK = [[fri objectAtIndex:i]nameKey];
            if (![thename isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]&&[shiptype isEqualToString:@"2"]) {
                [nameKeyArray addObject:nameK];
            }
            
        }
        [array addObject:[nameIndexArray objectAtIndex:i]];
        [array addObject:nameKeyArray];
        [sectionArray addObject:array];
    }
    return sectionArray;
    
}
+(DSuser *)queryUserWithUserId:(NSString *)userId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUsers = [DSuser MR_findFirstWithPredicate:predicate];
    return dUsers;
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




+ (void)cleanAttentionList//清空
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSArray * dUser = [DSuser MR_findAllInContext:localContext];
        for (DSuser* friend in dUser) {
                [friend deleteInContext:localContext];
        }
        NSArray * dUser_index = [DSAttentionNameIndex MR_findAllInContext:localContext];
        for (DSAttentionNameIndex* friendIndex in dUser_index) {
            [friendIndex deleteInContext:localContext];
        }
    }];
}
+(NSMutableArray*)queryAllFansWithOtherSortType:(NSString*)sorttype ascend:(BOOL)ascend
{
    NSArray * array = [DSuser MR_findAll];
    NSMutableArray *fri = [NSMutableArray array];
    for (int i = 0; i <array.count; i++) {
        DSuser *dUser = [array objectAtIndex:i];
        if ([dUser.shiptype isEqualToString:@"3"]) {
            [fri addObject:dUser];
        }
    }
    NSMutableArray * theArr = [NSMutableArray array];
    for (int i = 0; i<fri.count; i++) {
        NSString * userName = [[fri objectAtIndex:i] userName];
        NSString * userid = [[fri objectAtIndex:i] userId];
        NSString * nickName = [[fri objectAtIndex:i] nickName];
        NSString * remarkName = [[fri objectAtIndex:i] remarkName];
        NSString * headImg = [DataStoreManager queryFirstHeadImageForUser_userManager:userid];
        NSString * age = [[fri objectAtIndex:i] age];
        NSString * sex = [[fri objectAtIndex:i] gender];//性别
        NSString * achievement = [[fri objectAtIndex:i] achievement];//头衔
        NSString * achievementLevel = [[fri objectAtIndex:i] achievementLevel];//头衔
        NSString * modTime = [[fri objectAtIndex:i] refreshTime];//
        double distance = [[[fri objectAtIndex:i] distance] doubleValue];//
        NSLog(@"昵称：%@ 距离：%.f",nickName, distance);
        if (![userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
            NSMutableDictionary * theDict = [NSMutableDictionary dictionary];
            [theDict setObject:userName forKey:@"username"];
            [theDict setObject:userid forKey:@"userid"];
            [theDict setObject:nickName?nickName:@"" forKey:@"nickname"];
            if (remarkName && ![remarkName isEqualToString:@""]) {
                [theDict setObject:remarkName forKey:@"displayName"];
            }
            else if(nickName && ![nickName isEqualToString:@""]){
                [theDict setObject:nickName forKey:@"displayName"];
            }
            else
            {
                [theDict setObject:userName forKey:@"displayName"];
            }
            [theDict setObject:headImg?headImg:@"" forKey:@"img"];
            [theDict setObject:age ? age:@"" forKey:@"age"];
            [theDict setObject:sex ? sex:@"" forKey:@"sex"];
            [theDict setObject:achievement ? achievement:@"" forKey:@"achievement"];
            [theDict setObject:achievementLevel ? achievementLevel:@"" forKey:@"achievementLevel"];
            [theDict setObject:modTime ? modTime:@"" forKey:@"updateUserLocationDate"];
            [theDict setObject:[NSString stringWithFormat:@"%.f",distance] forKey:@"distance"];
            
            [theArr addObject:theDict];
        }
    }
    return theArr;
}

+(DSuser *)getInfoWithUserId:(NSString *)userId
{
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
   return [DSuser MR_findFirstWithPredicate:predicate];
}


+(NSMutableArray *)queryFansSections
{
    NSMutableArray * sectionArray = [NSMutableArray array];
    NSArray * nameIndexArray2 = [DSFansNameIndex MR_findAll];
    NSMutableArray * nameIndexArray = [NSMutableArray array];
    for (int i = 0; i<nameIndexArray2.count; i++) {
        DSFansNameIndex * di = [nameIndexArray2 objectAtIndex:i];
        [nameIndexArray addObject:di.index];
    }
    [nameIndexArray sortUsingSelector:@selector(compare:)];
    for (int i = 0; i<nameIndexArray.count; i++) {
        NSMutableArray * array = [NSMutableArray array];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"nameIndex==[c]%@",[nameIndexArray objectAtIndex:i]];
        NSArray * fri = [DSuser MR_findAllSortedBy:@"nameKey" ascending:YES withPredicate:predicate];
        NSMutableArray * nameKeyArray = [NSMutableArray array];
        for (int i = 0; i<fri.count; i++) {
            NSString * thename = [[fri objectAtIndex:i]userName];
            NSString * nameK = [[fri objectAtIndex:i]nameKey];
            if (![thename isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
                [nameKeyArray addObject:nameK];
            }
            
        }
        [array addObject:[nameIndexArray objectAtIndex:i]];
        [array addObject:nameKeyArray];
        [sectionArray addObject:array];
    }
    return sectionArray;
    
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

+(NSMutableArray *)querySections
{
    NSMutableArray * sectionArray = [NSMutableArray array];
    NSArray * nameIndexArray2 = [DSNameIndex MR_findAll];
    NSMutableArray * nameIndexArray = [NSMutableArray array];
    for (int i = 0; i<nameIndexArray2.count; i++) {
        DSNameIndex * di = [nameIndexArray2 objectAtIndex:i];
        [nameIndexArray addObject:di.index];//+,M
    }
    [nameIndexArray sortUsingSelector:@selector(compare:)];
    for (int i = 0; i<nameIndexArray.count; i++) {
        NSMutableArray * array = [NSMutableArray array];
        
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"nameIndex==[c]%@",[nameIndexArray objectAtIndex:i]];
        NSArray * fri = [DSuser MR_findAllSortedBy:@"nameKey" ascending:YES withPredicate:predicate];
        
        
        
        NSMutableArray * nameKeyArray = [NSMutableArray array];
        
        for (int i = 0; i<fri.count; i++) {
            NSString * shipType = [[fri objectAtIndex:i]shiptype];
            NSString * thename = [[fri objectAtIndex:i]userId];
            NSString * nameK = [[fri objectAtIndex:i]nameKey];
            
            if (![thename isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]&&[shipType isEqualToString:@"1"]) {
                [nameKeyArray addObject:nameK];//
            }
        
        }
        [array addObject:[nameIndexArray objectAtIndex:i]];//M
        [array addObject:nameKeyArray];//数组（Marss+Marss）
        [sectionArray addObject:array];
    }
    return sectionArray;

}

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

+(NSMutableArray*)queryAllFriendsWithOtherSortType:(NSString*)sorttype ascend:(BOOL)ascend
{
    NSArray * fri = [DSuser MR_findAllSortedBy:sorttype ascending:ascend];
    NSMutableArray * nameKeyArray = [NSMutableArray array];
    NSMutableArray * theArr = [NSMutableArray array];
    for (int i = 0; i<fri.count; i++) {
        NSString * nameK = [[fri objectAtIndex:i]nameKey];
        if (nameK)
            [nameKeyArray addObject:nameK];
        NSString * userName = [[fri objectAtIndex:i] userName];
        NSString * userid = [[fri objectAtIndex:i] userId];
        NSString * nickName = [[fri objectAtIndex:i] nickName];
        NSString * remarkName = [[fri objectAtIndex:i] remarkName];
        NSString * headImg = [DataStoreManager queryFirstHeadImageForUser_userManager:userid];
        NSString * age = [[fri objectAtIndex:i] age];
        NSString * sex = [[fri objectAtIndex:i] gender];//性别
        NSString * achievement = [[fri objectAtIndex:i] achievement];//头衔
        NSString * achievementLevel = [[fri objectAtIndex:i] achievementLevel];//头衔
        NSString * modTime = [[fri objectAtIndex:i] refreshTime];//
        double distance = [[[fri objectAtIndex:i] distance] doubleValue];//

        if (![userid isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]])
        {
            NSMutableDictionary* theDict = [NSMutableDictionary dictionary];

            [theDict setObject:userName forKey:@"username"];
            [theDict setObject:userid forKey:@"userid"];
            [theDict setObject:nickName?nickName:@"" forKey:@"nickname"];
            if (![remarkName isEqualToString:@""]) {
                [theDict setObject:remarkName forKey:@"displayName"];
            }
            else if(![nickName isEqualToString:@""]){
                [theDict setObject:nickName forKey:@"displayName"];
            }
            else
            {
                [theDict setObject:userName forKey:@"displayName"];
            }
            [theDict setObject:headImg ? headImg:@"" forKey:@"img"];
            [theDict setObject:age ? age:@"" forKey:@"age"];
            [theDict setObject:sex ? sex:@"" forKey:@"sex"];
            [theDict setObject:achievement ? achievement:@"" forKey:@"achievement"];
            [theDict setObject:achievementLevel ? achievementLevel:@"" forKey:@"achievementLevel"];
            [theDict setObject:modTime ? modTime:@"" forKey:@"updateUserLocationDate"];
            [theDict setObject:[NSString stringWithFormat:@"%.f", distance] forKey:@"distance"];

            [theArr addObject:theDict];
        }
    }
    return theArr;
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
    if (dUser) {//不是好友 就去粉丝列表查
        if (dUser.nickName.length>1) {
            return dUser.nickName;
        }
        else
            return dUser.userName;
    }
    DSuser* dFans = [DSuser MR_findFirstWithPredicate:predicate];
    if (dFans)
    {
        if (dFans.nickName.length>1) {
            return dFans.nickName;
        }
        else
            return dFans.userName;
    }
    else
        return userId;
}

+(NSString *)getOtherMessageTitleWithUUID:(NSString*)uuid type:(NSString*)type
{
//    NSDate * sendTime = [NSDate dateWithTimeIntervalSince1970:[times doubleValue]];

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

#pragma mark - 存储个人信息

+(void)saveMyBackgroungImg:(NSString*)backgroundImg
{
    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
        if (!dUser)
            dUser = [DSuser MR_createInContext:localContext];
        dUser.backgroundImg = backgroundImg;
    }];
}

+(NSMutableDictionary *)queryOneFriendInfoWithUserName:(NSString *)userName
{
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userName==[c]%@",userName];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {
        [dict setObject:dUser.userName forKey:@"username"];
        [dict setObject:dUser.userId?dUser.userId:@"" forKey:@"userid"];
        [dict setObject:dUser.nickName?dUser.nickName:@"" forKey:@"nickname"];
        [dict setObject:dUser.gender?dUser.gender:@"" forKey:@"gender"];
        [dict setObject:dUser.signature?dUser.signature:@"" forKey:@"signature"];
        [dict setObject:@"0" forKey:@"latitude"];
        [dict setObject:@"0" forKey:@"longitude"];
        [dict setObject:dUser.age?dUser.age:@"" forKey:@"birthdate"];
        [dict setObject:dUser.headImgID?dUser.headImgID:@"" forKey:@"img"];
    }
    return dict;
    
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
        [dict setObject:dUser.backgroundImg forKey:@"backgroundImg"];
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

//+(void)saveCharacterWithData:(NSDictionary*)dataDic
//{
//    NSString * name = [GameCommon getNewStringWithId:[dataDic objectForKey:@"name"]];
//    NSString * characterId = [GameCommon getNewStringWithId:[dataDic objectForKey:@"id"]];
//    NSString * gameid = [GameCommon getNewStringWithId:[dataDic objectForKey:@"gameid"]];
//    NSString * realm = [GameCommon getNewStringWithId:[dataDic objectForKey:@"realm"]];
//    NSString * clazzid = [GameCommon getNewStringWithId:[dataDic objectForKey:@"clazz"]];
//    NSString * pveScore = [GameCommon getNewStringWithId:[dataDic objectForKey:@"pveScore"]];
//    NSString * auth = [GameCommon getNewStringWithId:[dataDic objectForKey:@"auth"]];
//    
//    if (characterId) {
//        [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"characterId==[c]%@",characterId];
//            DSCharacterList * dCharacter = [DSCharacterList MR_findFirstWithPredicate:predicate];
//            if (!dCharacter)
//                dCharacter = [DSCharacterList MR_createInContext:localContext];
//            dCharacter.name = name;
//            dCharacter.characterId = characterId;
//            dCharacter.gameid = gameid;
//            dCharacter.realm = realm;
//            dCharacter.clazzid = clazzid;
//            dCharacter.pveScore = pveScore;
//            dCharacter.auth = auth;//是否认证
//        }];
//    }
//}
//
//+(void)cleanCharacterList
//{
//    [MagicalRecord saveUsingCurrentThreadContextWithBlockAndWait:^(NSManagedObjectContext *localContext) {
//        NSArray * dCharacter = [DSCharacterList MR_findAllInContext:localContext];
//        for (DSCharacterList* character in dCharacter) {
//                [character deleteInContext:localContext];
//        }
//    }];
//}



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

#pragma mark 头衔、角色、战斗力等消息
//@dynamic messageuuid;
//@dynamic msgContent;
//@dynamic msgType;
//@dynamic sendTime;
//@dynamic myTitle;

+(void)saveOtherMsgsWithData:(NSDictionary*)userInfoDict
{
    
    
    NSLog(@"userinfoDict%@",userInfoDict);
  //  NSString* messageuuid = [[GameCommon shareGameCommon] uuid];
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

@end
