//
//  XMPPHelper.m
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "XMPPHelper.h"
#import "XMPP.h"
#import "ChatDelegate.h"
#import "AddReqDelegate.h"
#import "CommentDelegate.h"
#import "NotConnectDelegate.h"
#import "DeletePersonDelegate.h"
#import "OtherMessageReceive.h"
#import "RecommendFriendDelegate.h"
#import "XMPPAutoPing.h"
#import "XMPPJID.h"
#import "TempData.h"
#import "XMPPReconnect.h"
#import "JSON.h"
#import "GameXmppStream.h"
#import "GameXmppReconnect.h"
@implementation XMPPHelper
//@synthesize xmppStream,xmppvCardStorage,xmppvCardTempModule,xmppvCardAvatarModule,xmppvCardTemp,account,password,buddyListDelegate,chatDelegate,xmpprosterDelegate,processFriendDelegate,xmpptype,success,fail,regsuccess,regfail,xmppRosterscallback,myVcardTemp,xmppRosterMemoryStorage,xmppRoster;
-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}


-(void)setupStream
{
    self.xmppStream = [[GameXmppStream alloc] init];
    [self.xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];

    self.xmppStream.enableBackgroundingOnSocket = YES;
    self.xmppReconnect = [[GameXmppReconnect alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppReconnect setAutoReconnect:YES];
    [self.xmppReconnect addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [self.xmppReconnect activate:self.xmppStream];
    XMPPAutoPing* ping=[[XMPPAutoPing alloc] init];
    [ping activate:self.xmppStream];
    ping.pingTimeout=2;
    [ping addDelegate:self delegateQueue:  dispatch_get_main_queue()];
    self.xmppPing=[[XMPPPing alloc] initWithDispatchQueue:dispatch_get_main_queue()];
    [self.xmppPing activate:self.xmppStream];
    [self.xmppPing addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
}
- (void)goOnline {
	XMPPPresence *presence = [XMPPPresence presence];
	[[self xmppStream] sendElement:presence];
}

- (void)goOffline {
	XMPPPresence *presence = [XMPPPresence presenceWithType:@"unavailable"];
	[[self xmppStream] sendElement:presence];
}
-(BOOL)connect{

//    host = @"192.168.0.133";
    
 //   host = @"221.122.114.216";
//    theaccount = @"15100000000@52pet.net";
//    thepassword = @"0AB89AC5C55D40198EF10B39257DA1C4";


    if (![self.xmppStream isDisconnected]) {
        return YES;
        NSLog(@"连接不成功");
    }
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN]]]] ;
    NSString* host=[[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    
    NSArray* hostArray = [host componentsSeparatedByString:@":"];
    host = [hostArray objectAtIndex:0];
    
    [self.xmppStream setHostName:host];

    //连接服务器
   // NSError *err = nil;
    
    [self.xmppReconnect manualStart];
    
    return YES;
}

-(void)disconnect{
    [self goOffline];
    [self.xmppStream disconnect];
}
-(BOOL)isDisconnected
{
    return [self.xmppStream isDisconnected];
}
-(BOOL)isConnecting
{
    return [self.xmppStream isConnecting];
}
-(BOOL)isConnected
{
    return [self.xmppStream isConnected];
}

#pragma mark 进入程序网络变化
- (void)appBecomeActiveWithNet:(NSNotification*)notification
{
    Reachability* reach = notification.object;
    if ([reach currentReachabilityStatus] == NotReachable ) {//有网
        if ([self isConnected]) {
            [self disconnect];
        }
    }
    if ([reach currentReachabilityStatus] != NotReachable  && [[TempData sharedInstance] isHaveLogin]) {//有网
        if (![self isConnected]) {
            [self connect];
        }
    }
}

//===========XMPP委托事件============

//此方法在stream开始连接服务器的时候调用
- (void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"connected");
    NSError *error = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectSuccess" object:nil userInfo:nil];
    //验证密码
    [[self xmppStream] authenticateWithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] error:&error];
    if(error!=nil)
    {
//        self.fail(error);
    }
}

//此方法在stream连接断开的时候调用
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_disconnect" object:nil userInfo:nil];
}

// 2.关于验证的
//验证失败后调用
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error{
//    NSLog(@"not authenticated %@",error);
//    NSError *err=[[NSError alloc] initWithDomain:@"WeShare" code:-100 userInfo:@{@"detail": @"ot-authorized"}];
//    self.fail(err);
 //   [self.notConnect notConnectted];
}


//验证成功后调用
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    
//    self.xmppvCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
//    self.xmppvCardTempModule=[[XMPPvCardTempModule alloc]initWithvCardStorage:self.xmppvCardStorage];
//    self.xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc]initWithvCardTempModule:self.xmppvCardTempModule];
//    [self.xmppvCardTempModule   activate:self.xmppStream];
//    [self.xmppvCardAvatarModule activate:self.xmppStream];
//    [self getmyvcard];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"connectSuccess" object:nil userInfo:nil];
    NSLog(@"authenticated");
    [self goOnline];
    
}

-(BOOL)sendMessage:(NSXMLElement *)message
{
    if (![self isConnected]) {
        return NO;
    }
    else
    {
        [self.xmppStream sendElement:message];
        
        return YES;
    }
}


- (void)xmppStreamWillConnect:(XMPPStream *)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"startConnect" object:nil];
}

#pragma mark 收到消息后调用
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    NSString *msg = [[message elementForName:@"body"] stringValue];
    NSLog(@"message =====%@",message);
    if(msg==nil){
        return;
    }
    NSString *msgtype = [[message attributeForName:@"msgtype"] stringValue];
    NSString *from = [[message attributeForName:@"from"] stringValue];
    NSString *msgId = [[message attributeForName:@"id"] stringValue];
    NSRange range = [from rangeOfString:@"@"];
    NSString * fromId = [from substringToIndex:(range.location == NSNotFound) ? 0 : range.location];
    NSString *type = [[message attributeForName:@"type"] stringValue];
    NSString * time = [[message attributeForName:@"msgTime"] stringValue];
    NSString *msgTime = time?time:[GameCommon getCurrentTime];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"msg"];//消息内容
    [dict setObject:fromId forKey:@"sender"];//发送者用户id
    [dict setObject:msgId forKey:@"msgId"];//消息id
    [dict setObject: msgTime forKey:@"time"];//消息接收到的时间
    
    NSLog(@"theDict%@",dict);
    if ([type isEqualToString:@"chat"])
    {
        if ([msgtype isEqualToString:@"normalchat"]) {//聊天的 或动态聊天消息
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];//是否含payload标签
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            if ([payload JSONValue][@"active"]){//发送通知 判断账号是否激活
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wxr_myActiveBeChanged" object:nil userInfo:[payload JSONValue]];
            }
            [dict setObject:msgtype forKey:@"msgType"];
            [dict setObject:msgId?msgId:@"" forKey:@"msgId"];
            [self.chatDelegate newMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"sayHello"]){//打招呼的
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            [dict setObject:@"sayHello" forKey:@"msgType"];
            NSString * shiptype = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (shiptype.length > 0) {
                [dict setObject:KISDictionaryHaveKey([shiptype JSONValue], @"shiptype") forKey:@"shiptype"];
            }
            else
                [dict setObject:@""  forKey:@"shiptype"];
            [self.deletePersonDelegate newAddReq:dict];
        }
        else if([msgtype isEqualToString:@"deletePerson"])//取消关注
        {
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            
            [dict setObject:@"deletePerson" forKey:@"msgType"];
            NSString * shiptype = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (shiptype.length > 0) {
                [dict setObject:KISDictionaryHaveKey([shiptype JSONValue], @"shiptype") forKey:@"shiptype"];
            }
            else
                [dict setObject:@""  forKey:@"shiptype"];
            
            [self.deletePersonDelegate deletePersonReceived:dict];
        }
        else if ([msgtype isEqualToString:@"character"] || [msgtype isEqualToString:@"pveScore"] || [msgtype isEqualToString:@"title"])//角色信息改变
        {
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            
            [dict setObject:msgtype forKey:@"msgType"];
            NSString *title = [[message elementForName:@"payload"] stringValue];
            title = KISDictionaryHaveKey([title JSONValue],@"title");
            [dict setObject:title?title:@"" forKey:@"title"];
            
            [self.otherMsgReceiveDelegate otherMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"recommendfriend"])//好友推荐
        {
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            
            [dict setObject:msgtype forKey:@"msgType"];
            NSArray* arr = [msg JSONValue];
            NSString* dis = @"";
            if ([arr isKindOfClass:[NSArray class]]) {
                if ([arr count] != 0) {
                    NSMutableDictionary* dic = [arr objectAtIndex:0];
                    dis = [NSString stringWithFormat:@"%@%@",KISDictionaryHaveKey(dic, @"recommendMsg") ,KISDictionaryHaveKey(dic, @"nickname")];
                }
            }
            [dict setObject:dis forKey:@"disStr"];
            [self.recommendReceiveDelegate recommendFriendReceived:dict];
        }
        else if([msgtype isEqualToString:@"frienddynamicmsg"]//好友动态
                || [msgtype isEqualToString:@"mydynamicmsg"]//与我相关
                || [msgtype isEqualToString:@"groupDynamicMsgChange"])//群动态
        {
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            
            if ([msgtype isEqualToString:@"frienddynamicmsg"]) {    //新的朋友圈动态
                if ([[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]) {
                    int i =[[[NSUserDefaults standardUserDefaults]objectForKey:@"dongtaicount_wx"]intValue];
                    i++;
                    [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:@"dongtaicount_wx"];
                }else{
                    int i = 0;
                    i++;
                    [[NSUserDefaults standardUserDefaults]setObject:@(i)forKey:@"dongtaicount_wx"];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"frienddunamicmsgChange_WX" object:nil userInfo:[payload JSONValue]];
                

            }
            else if ([msgtype isEqualToString:@"mydynamicmsg"])
            {
                [self.chatDelegate newdynamicAboutMe:[payload JSONValue]];
                [[NSNotificationCenter defaultCenter]postNotificationName:@"mydynamicmsg_wx" object:nil userInfo:[payload JSONValue]];
                NSMutableData *data= [[NSMutableData alloc]init];
                NSKeyedArchiver *archiver= [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
                [archiver encodeObject:[payload JSONValue] forKey: @"getDatat"];
                [archiver finishEncoding];
                if (![[NSUserDefaults standardUserDefaults]objectForKey: @"mydynamicmsg_huancunCount_wx"]) {
                   int i=1;
                    [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:@"mydynamicmsg_huancunCount_wx"];
                }else{
                    int i =[[[NSUserDefaults standardUserDefaults]objectForKey: @"mydynamicmsg_huancunCount_wx"]intValue];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:@(i+1) forKey:@"mydynamicmsg_huancunCount_wx"];
                }
                
                [[NSUserDefaults standardUserDefaults]setObject:data forKey:@"mydynamicmsg_huancun_wx"];
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:haveMyNews];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[GameCommon shareGameCommon] displayTabbarNotification];
            }
            else if([msgtype isEqualToString:@"groupDynamicMsgChange"]){//群组动态groupId
                NSDictionary* msgDic = [payload JSONValue];
                NSString * groupId  = KISDictionaryHaveKey(msgDic, @"groupId");
                if (![[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,groupId]]) {
                    int i=1;
                    [[NSUserDefaults standardUserDefaults]setObject:@(i) forKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,groupId]];
                }else{
                    int i =[[[NSUserDefaults standardUserDefaults]objectForKey: [NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,groupId]]intValue];
                    
                    [[NSUserDefaults standardUserDefaults]setObject:@(i+1) forKey:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg_count,groupId]];
                }
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter]postNotificationName:[NSString stringWithFormat:@"%@%@",GroupDynamic_msg,groupId] object:nil userInfo:msgDic];
            }
              //未知的动态
            else
            {
                
            }
        }
        else if([msgtype isEqualToString:@"dailynews"])//新闻
        {
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            
            [dict setObject:msgtype forKey:@"msgType"];
            NSString *title = [[message elementForName:@"payload"] stringValue];
            [dict setObject:title?title:@"" forKey:@"title"];
            [self.chatDelegate dailynewsReceived:dict];
        }
        
        else if([msgtype isEqualToString:@"groupchat"])//群组聊天消息
        {
            NSString* bodyPayload = [GameCommon getNewStringWithId:msg];
            [dict setObject:KISDictionaryHaveKey([bodyPayload JSONValue], @"content") forKey:@"msg"];
            
            NSString * groupid = [[message attributeForName:@"groupid"] stringValue];
            NSString * domain=[[from componentsSeparatedByString:@"@"] objectAtIndex:1];
            NSString * to=[NSString stringWithFormat:@"%@%@%@",groupid,@"@group.",domain];
            NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [dict setObject:msgtype forKey:@"msgType"];
            [dict setObject:msgId?msgId:@"" forKey:@"msgId"];
            [dict setObject:groupid forKey:@"groupId"];
            
            [self.chatDelegate newGroupMessageReceived:dict];
            [self comeBackDelivered:to msgId:msgId];//发送群组的反馈消息（注意此时的应该反馈的对象是聊天群的JID）
        }
        else if([msgtype isEqualToString:@"inGroupSystemMsgJoinGroup"]//好友加入群
                ||[msgtype isEqualToString:@"inGroupSystemMsgQuitGroup"])//好友退出群
        {
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            NSString* payloadStr = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (payloadStr.length>0) {
                [dict setObject:payloadStr forKey:@"payload"];
            }
            [dict setObject:msgtype forKey:@"msgType"];
            [dict setObject:msgId?msgId:@"" forKey:@"msgId"];
            
            [self.chatDelegate changGroupMessageReceived:dict];
        }
        else if([msgtype isEqualToString:@"joinGroupApplication"]//申请加入群
                ||[msgtype isEqualToString:@"joinGroupApplicationAccept"]//入群申请通过
                ||[msgtype isEqualToString:@"joinGroupApplicationReject"]//入群申请拒绝
                
                ||[msgtype isEqualToString:@"groupApplicationUnderReview"]//群审核已提交
                ||[msgtype isEqualToString:@"groupApplicationAccept"]///群审核通过
                ||[msgtype isEqualToString:@"groupApplicationReject"]//群审核被拒绝
                
                ||[msgtype isEqualToString:@"groupLevelUp"]//群等级提升disbandGroup
                ||[msgtype isEqualToString:@"disbandGroup"]//解散群
                ||[msgtype isEqualToString:@"groupUsershipTypeChange"]//群成员身份变化
                ||[msgtype isEqualToString:@"kickOffGroup"]//被踢出群的消息
                ||[msgtype isEqualToString:@"groupRecommend"]//群推荐
                ||[msgtype isEqualToString:@"friendJoinGroup"]){//好友加入了新的群组
            [self comeBackDelivered:from msgId:msgId];//反馈消息
            
            [dict setObject:msgtype forKey:@"msgType"];
            [dict setObject:msgId?msgId:@"" forKey:@"msgId"];
            [dict setObject:[self getMsgTitle:msgtype] forKey:@"msgTitle"];
            NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate JoinGroupMessageReceived:dict];
        }
        //群组公告消息
        else if ([msgtype isEqualToString:@"groupBillboard"])
        {
            [self comeBackDelivered:from msgId:msgId];
            [dict setObject:msgtype forKey:@"msgType"];
            [dict setObject:msgId?msgId:@"" forKey:@"msgId"];
            [dict setObject:[self getMsgTitle:msgtype] forKey:@"msgTitle"];
            NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (payload.length>0) {
                [dict setObject:payload forKey:@"payload"];
            }
            [self.chatDelegate groupBillBoardMessageReceived:dict];
        }
    }
    
    if ([type isEqualToString:@"normal"]&& [msgtype isEqualToString:@"msgStatus"])
    {
        NSDictionary* bodyDic = [msg JSONValue];
        if ([bodyDic isKindOfClass:[NSDictionary class]]) {
            NSString* src_id = KISDictionaryHaveKey(bodyDic, @"src_id");
            if (src_id.length <= 0) {
                return;
            }
            NSString * msgStatus = KISDictionaryHaveKey(bodyDic, @"msgStatus");
            if ([msgStatus isEqualToString:@"Delivered"]) {//是否送达
                [DataStoreManager refreshMessageStatusWithId:src_id status:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"3" : @"0"];
                [DataStoreManager refreshGroupMessageStatusWithId:src_id status:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"3" : @"0"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:bodyDic];
            }
            else if ([msgStatus isEqualToString:@"Displayed"]) {//是否已读
                
                [DataStoreManager refreshMessageStatusWithId:src_id status:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"4" : @"0"];
                [DataStoreManager refreshGroupMessageStatusWithId:src_id status:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"4" : @"0"];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:bodyDic];
            }
        }
    }
    if ([type isEqualToString:@"normal"] && [fromId isEqualToString:@"messageack"])//消息发送服务器状态告知
    {
        msg = [msg stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary* msgData = [msg JSONValue];
        NSString* src_id = KISDictionaryHaveKey(msgData, @"src_id");
        if (src_id.length <= 0) {
            return;
        }
        [DataStoreManager refreshMessageStatusWithId:src_id status:[KISDictionaryHaveKey(msgData, @"received") boolValue] ? @"1" : @"0"];
         [DataStoreManager refreshGroupMessageStatusWithId:src_id status:[KISDictionaryHaveKey(msgData, @"received") boolValue] ? @"1" : @"0"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:msgData];
    }
}

-(NSString*)getMsgTitle:(NSString*)msgtype
{
    if([msgtype isEqualToString:@"joinGroupApplication"]){
        return @"申请加入群";
    }else if ([msgtype isEqualToString:@"joinGroupApplicationAccept"]){
        return @"入群申请通过";
    }else if ([msgtype isEqualToString:@"joinGroupApplicationReject"]){
        return @"入群申请拒绝";
    }else if ([msgtype isEqualToString:@"groupApplicationUnderReview"]){
        return @"群审核已提交";
    }else if ([msgtype isEqualToString:@"groupApplicationAccept"]){
        return  @"群审核通过";
    }else if ([msgtype isEqualToString:@"groupApplicationReject"]){
        return  @"群审核被拒绝";
    }else if ([msgtype isEqualToString:@"groupLevelUp"]){
        return  @"群等级提升";
    }else if ([msgtype isEqualToString:@"groupBillboard"]){
        return  @"群公告";
    }else if ([msgtype isEqualToString:@"friendJoinGroup"]){
        return  @"好友加入了新的群组";
    }else if ([msgtype isEqualToString:@"disbandGroup"]){
        return @"解散群";
    }
    return @"新的群消息";
}
//sender:@"10000202@gamepro.com/862933025698753"
#pragma mark 发送反馈消息
- (void)comeBackDelivered:(NSString*)sender msgId:(NSString*)msgId//发送送达消息
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"src_id",@"true",@"received",@"Delivered",@"msgStatus", nil];
    NSString *to=[[sender componentsSeparatedByString:@"/"] objectAtIndex:0];
    NSString * nowTime=[GameCommon getCurrentTime];
    NSString * message=[dic JSONRepresentation];
    NSString * userid = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * domaim = [[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN];
    NSString * from =[NSString stringWithFormat:@"%@%@",userid,domaim];
    NSXMLElement *mes = [MessageService createMes:nowTime Message:message UUid:msgId From:from To:to FileType:@"text" MsgType:@"msgStatus" Type:@"normal"];
    if (![self sendMessage:mes]) {
        return;
    }
}

- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
}

//接受到好友状态更新
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence{
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(id)error
{
    NSLog(@"didReceiveError:%@",error);
    DDXMLNode *errorNode = (DDXMLNode *)error;
    //遍历错误节点
    for(DDXMLNode *node in [errorNode children])
    {
        //若错误节点有【冲突】
        if([[node name] isEqualToString:@"conflict"])
        {
            //停止轮训检查链接状态
            //[_timer invalidate];
            //弹出登陆冲突,点击OK后logout
            NSString *message = [NSString stringWithFormat:@"在其他地方登陆"];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            alert.tag = 9999;
            [alert show];
        }
    }
}

- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender{
    NSLog(@"ping did received");
}

- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender{
    [self disconnect];
}

- (void)xmppPing:(XMPPPing *)sender didNotReceivePong:(NSString *)pingID dueToTimeout:(NSTimeInterval)timeout{
    [self disconnect];
}

- (void)xmppPing:(XMPPPing *)sender didReceivePong:(XMPPIQ *)pong withRTT:(NSTimeInterval)rtt{
    NSLog(@"ping did received");
}

@end
