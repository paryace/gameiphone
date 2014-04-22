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
    
    [self.xmppStream setMyJID:[XMPPJID jidWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingFormat:@"%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]]]] ;
    NSString* host=[[NSUserDefaults standardUserDefaults] objectForKey:@"host"];
    
    NSArray* hostArray = [host componentsSeparatedByString:@":"];
    host = [hostArray objectAtIndex:0];
    
    [self.xmppStream setHostName:host];

    //连接服务器
    NSError *err = nil;
    
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
    NSLog(@"not authenticated %@",error);
    NSError *err=[[NSError alloc] initWithDomain:@"WeShare" code:-100 userInfo:@{@"detail": @"ot-authorized"}];
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


// 3.关于通信的
- (void)comeBackDelivered:(NSString*)sender msgId:(NSString*)msgId//发送送达消息
{
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:msgId,@"src_id",@"true",@"received",@"Delivered",@"msgStatus", nil];
    NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
    [body setStringValue:[dic JSONRepresentation]];
    
    //生成XML消息文档
    NSXMLElement *mes = [NSXMLElement elementWithName:@"message"];
//    [mes addAttributeWithName:@"id" stringValue:[[GameCommon shareGameCommon] uuid]];
    [mes addAttributeWithName:@"id" stringValue:msgId];

    [mes addAttributeWithName:@"msgtype" stringValue:@"msgStatus"];
    //消息类型
    [mes addAttributeWithName:@"type" stringValue:@"normal"];
    
    //发送给谁
    [mes addAttributeWithName:@"to" stringValue:sender];
    //由谁发送
    [mes addAttributeWithName:@"from" stringValue:[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]]];
    NSLog(@"to---%@",[[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] stringByAppendingString:[[NSUserDefaults standardUserDefaults] objectForKey:@"domain"]]);
    //    [mes addAttributeWithName:@"msgtype" stringValue:@"normalchat"];
    [mes addAttributeWithName:@"msgTime" stringValue:[GameCommon getCurrentTime]];
    //    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    //    [mes addAttributeWithName:@"id" stringValue:uuid];
    //    NSLog(@"消息uuid ~!~~ %@", uuid);
    //组合
    [mes addChild:body];
    
    if (![self sendMessage:mes]) {
        return;
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
    NSString * fromName = [from substringToIndex:(range.location == NSNotFound) ? 0 : range.location];
    
    NSString *type = [[message attributeForName:@"type"] stringValue];
    
    NSString *msgTime = [[message attributeForName:@"msgTime"] stringValue]?[[message attributeForName:@"msgTime"] stringValue]:[GameCommon getCurrentTime];
    
    
    
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"msg"];
    [dict setObject:from forKey:@"sender"];
    [dict setObject:msgId forKey:@"msgId"];
    
    //消息接收到的时间
    [dict setObject: msgTime forKey:@"time"];
    
    NSLog(@"theDict%@",dict);
    if ([type isEqualToString:@"chat"])
    {
        if ([msgtype isEqualToString:@"normalchat"]) {//聊天的 或动态聊天消息
            NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];//是否含payload标签
            if (payload.length > 0&&[payload JSONValue][@"title"]) {
                [dict setObject:payload forKey:@"payload"];
                
                [dict setObject:@"payloadchat" forKey:@"msgType"];
            }else if (payload.length > 0&&[payload JSONValue][@"active"]){
                //发送通知 判断账号是否激活
                [[NSNotificationCenter defaultCenter] postNotificationName:@"wxr_myActiveBeChanged" object:nil userInfo:[payload JSONValue]];
                [dict setObject:@"normalchat" forKey:@"msgType"];
            }else{
                [dict setObject:@"normalchat" forKey:@"msgType"];
            }
            
            [dict setObject:msgId?msgId:@"" forKey:@"msgId"];
            [[NSNotificationCenter defaultCenter]postNotificationName:receiveregularMsg object:nil userInfo:dict];

            [self.chatDelegate newMessageReceived:dict];
        }
        else if ([msgtype isEqualToString:@"sayHello"]){//打招呼的
            [dict setObject:@"sayHello" forKey:@"msgType"];
            
            NSString * shiptype = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (shiptype.length > 0) {
                [dict setObject:KISDictionaryHaveKey([shiptype JSONValue], @"shiptype") forKey:@"shiptype"];
            }
            else
                [dict setObject:@""  forKey:@"shiptype"];
             [self.deletePersonDelegate newAddReq:dict];
          ///  [self comeBackDelivered:from msgId:msgId];
        }
        else if([msgtype isEqualToString:@"deletePerson"])//取消关注
        {
            [dict setObject:@"deletePerson" forKey:@"msgType"];
            
            NSString * shiptype = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
            if (shiptype.length > 0) {
                [dict setObject:KISDictionaryHaveKey([shiptype JSONValue], @"shiptype") forKey:@"shiptype"];
            }
            else
                [dict setObject:@""  forKey:@"shiptype"];

            
            [self.deletePersonDelegate deletePersonReceived:dict];
         //   [self comeBackDelivered:from msgId:msgId];
        }
        else if ([msgtype isEqualToString:@"character"] || [msgtype isEqualToString:@"pveScore"] || [msgtype isEqualToString:@"title"])//角色信息改变
        {
            [dict setObject:msgtype forKey:@"msgType"];
            NSString *title = [[message elementForName:@"payload"] stringValue];
            title = KISDictionaryHaveKey([title JSONValue],@"title");
            [dict setObject:title?title:@"" forKey:@"title"];
            
             [[NSNotificationCenter defaultCenter]postNotificationName:receiverOtherChrarterMsg object:nil userInfo:dict];
            
            [self.otherMsgReceiveDelegate otherMessageReceived:dict];
            [self comeBackDelivered:from msgId:msgId];
        }
        else if ([msgtype isEqualToString:@"recommendfriend"])//好友推荐
        {
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
             [[NSNotificationCenter defaultCenter]postNotificationName:receiverFriendRecommended object:nil userInfo:dict];
            [self.recommendReceiveDelegate recommendFriendReceived:dict];
          //  [self comeBackDelivered:from msgId:msgId];
        }
        else if([msgtype isEqualToString:@"frienddynamicmsg"] || [msgtype isEqualToString:@"mydynamicmsg"])//动态
        {
            if ([msgtype isEqualToString:@"frienddynamicmsg"]) {
                NSString* payload = [GameCommon getNewStringWithId:[[message elementForName:@"payload"] stringValue]];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"frienddunamicmsgChange_WX" object:nil userInfo:[payload JSONValue]];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:haveMyNews];
                [[NSUserDefaults standardUserDefaults] synchronize];
                [[GameCommon shareGameCommon] displayTabbarNotification];
            }
        //    [self comeBackDelivered:from msgId:msgId];
        }
        else if([msgtype isEqualToString:@"dailynews"])//新闻
        {
            [dict setObject:msgtype forKey:@"msgType"];
            NSString *title = [[message elementForName:@"payload"] stringValue];
            [dict setObject:title?title:@"" forKey:@"title"];
            [self.chatDelegate dailynewsReceived:dict];
           // [self comeBackDelivered:from msgId:msgId];
             [[NSNotificationCenter defaultCenter]postNotificationName:receiverNewsMsg object:nil userInfo:dict];
        }
        [self comeBackDelivered:from msgId:msgId];
    }
    if ([type isEqualToString:@"normal"]&& [msgtype isEqualToString:@"msgStatus"])
    {
        NSDictionary* bodyDic = [msg JSONValue];
        if ([bodyDic isKindOfClass:[NSDictionary class]]) {
            NSString* src_id = KISDictionaryHaveKey(bodyDic, @"src_id");
            if (src_id.length <= 0) {
                return;
            }
            if ([KISDictionaryHaveKey(bodyDic, @"msgStatus") isEqualToString:@"Delivered"]) {//是否送达
                [DataStoreManager refreshMessageStatusWithId:src_id status:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"3" : @"0"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:bodyDic];
            }
            else if ([KISDictionaryHaveKey(bodyDic, @"msgStatus") isEqualToString:@"Displayed"]) {//是否已读
                [DataStoreManager refreshMessageStatusWithId:src_id status:[KISDictionaryHaveKey(bodyDic, @"received") boolValue] ? @"4" : @"0"];
                [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:bodyDic];
            }
        }
    }
    if ([type isEqualToString:@"normal"] && [fromName isEqualToString:@"messageack"])//消息发送服务器状态告知
    {
        msg = [msg stringByReplacingOccurrencesOfString:@"'" withString:@"\""];
        NSDictionary* msgData = [msg JSONValue];
        NSString* src_id = KISDictionaryHaveKey(msgData, @"src_id");
        if (src_id.length <= 0) {
            return;
        }
        [DataStoreManager refreshMessageStatusWithId:src_id status:[KISDictionaryHaveKey(msgData, @"received") boolValue] ? @"1" : @"0"];
        [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:msgData];
    }
    
}


- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //请求的用户
//    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
//    NSString *fromnickName = [presence fromName];
//    NSString *additionMsg = [presence additionMsg];
//    NSString *headID = [presence headID];
//    NSLog(@"presenceType:%@,fromNickName:%@,additionMsg:%@",presenceType,fromnickName,additionMsg);
//    NSDictionary * uDict = [NSDictionary dictionaryWithObjectsAndKeys:presenceFromUser,@"fromUser",fromnickName,@"fromNickname",additionMsg,@"addtionMsg",headID,@"headID", nil];
    NSLog(@"presence2:%@  sender2:%@",presence,sender);
    if ([presenceType isEqualToString:@"subscribe"]) {
//        [self.addReqDelegate newAddReq:uDict];
    }
    
   // [self.addReq newAddReq:@""];
//    XMPPJID *jid = [XMPPJID jidWithString:presenceFromUser];
//    [self.xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
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
