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


-(void)dyMessageReceived:(NSDictionary *)payloadStr;//动态消息

-(void)TeamNotifityMessageReceived:(NSDictionary *)messageContent;//组队通知消息

@end
