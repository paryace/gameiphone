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


-(void)disbandGroupMessageReceived:(NSDictionary *)messageContent;//解散群

-(void)kickOffGroupMessageReceived:(NSDictionary *)messageContent;//被踢出群

-(void)joinGroupApplicationAcceptMessageReceived:(NSDictionary *)messageContent;//入群申请被通过





-(void)changGroupMessageReceived:(NSDictionary *)messageContent;//加入或者退出群

-(void)groupBillBoardMessageReceived:(NSDictionary *)messageContent;//群公告消息

-(void)dyMessageReceived:(NSDictionary *)payloadStr;//好友动态消息

-(void)dyMeMessageReceived:(NSDictionary *)payloadStr;//与我相关动态消息

-(void)dyGroupMessageReceived:(NSDictionary *)payloadStr;//群动态消息

-(void)TeamNotifityMessageReceived:(NSDictionary *)messageContent;//组队通知消息

-(void)teamMemberMessageReceived:(NSDictionary *)messageContent;//加入组队

-(void)teamQuitTypeMessageReceived:(NSDictionary *)messageContent;//退出组队

-(void)teamKickTypeMessageReceived:(NSDictionary *)messageContent;//踢出组队//

-(void)teamTissolveTypeMessageReceived:(NSDictionary*)messageContent;//解散组队

-(void)teamClaimAddTypeMessageReceived:(NSDictionary *)messageContent;//占坑

-(void)teamClaimKickTypeMessageReceived:(NSDictionary *)messageContent;//预约的人被踢出

-(void)teamOccupyTypeMessageReceived:(NSDictionary *)messageContent;//填坑

-(void)teamInviteTypeMessageReceived:(NSDictionary *)messageContent;//邀请加入组队

-(void)teamInviteInGroupTypeMessageReceived:(NSDictionary *)messageContent;//邀请加入组队

-(void)teamRecommendMessageReceived:(NSDictionary *)messageContent;//组队偏好消息

-(void)startTeamPreparedConfirmMessageReceived:(NSDictionary *)messageContent;//就位确认消息

-(void)teamPreparedUserSelectMessageReceived:(NSDictionary *)messageContent;//确定或者取消就位确认

-(void)teamPreparedConfirmResultMessageReceived:(NSDictionary *)messageContent;//就位确认结果

-(void)otherAnyMessageReceived:(NSDictionary *)messageContent;//其他不知道的消息
@end
