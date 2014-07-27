//
//  ChatDelegate.h
//  WeShare
//
//  Created by Elliott on 13-5-7.
//  Copyright (c) 2013年 Elliott. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ChatDelegate <NSObject>

-(void)newMessageReceived:(NSDictionary *)messageContent;

-(void)dailynewsReceived:(NSDictionary * )messageContent;

-(void)newdynamicAboutMe:(NSDictionary *)messageContent;

-(void)newGroupMessageReceived:(NSDictionary *)messageContent;//群聊天

-(void)JoinGroupMessageReceived:(NSDictionary *)messageContent;//创建群，审核群...

-(void)changGroupMessageReceived:(NSDictionary *)messageContent;//加入或者退出群

-(void)groupBillBoardMessageReceived:(NSDictionary *)messageContent;//群公告消息

-(void)dyMessageReceived:(NSDictionary *)payloadStr;//好友动态消息

-(void)dyMeMessageReceived:(NSDictionary *)payloadStr;//与我相关动态消息

-(void)dyGroupMessageReceived:(NSDictionary *)payloadStr;//群动态消息

-(void)TeamNotifityMessageReceived:(NSDictionary *)messageContent;//组队通知消息


-(void)teamMemberMessageReceived:(NSDictionary *)messageContent;//加入组队

-(void)teamQuitTypeMessageReceived:(NSDictionary *)messageContent;//退出组队

-(void)teamKickTypeMessageReceived:(NSDictionary *)messageContent;//踢出组队

-(void)teamTissolveTypeMessageReceived:(NSDictionary*)messageContent;//解散组队

-(void)teamClaimAddTypeMessageReceived:(NSDictionary *)messageContent;//占坑

-(void)teamOccupyTypeMessageReceived:(NSDictionary *)messageContent;//填坑

@end
