//
//  TeamManager.h
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamManager : NSObject
@property(nonatomic, strong) NSMutableDictionary* teamCache;
@property(nonatomic, strong) NSMutableArray* cacheids;

+ (TeamManager*)singleton;

-(void)GETInfoWithNet:(NSString*)gameId RoomId:(NSString*)roomId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

-(NSMutableDictionary*)getTeamInfo:(NSString*)gameId RoomId:(NSString*)roomId;

-(void)addMemberCount:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId UserId:(NSString*)userId;

-(void)removeMemberCount:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId UserId:(NSString*)userId;

-(void)upDateTeamMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId MemberCount:(NSString*)memberCount;

-(void)saveTeamInfo:(id)responseObject GameId:(NSString*)gameId;

-(void)saveTeamInfo:(id)responseObject GameId:(NSString*)gameId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//组队添加成员
-(void)saveMemberUserInfo:(NSDictionary*)memberUserInfo GroupId:(NSString*)groupId;

//删除组队成员
-(void)deleteMenberUserInfo:(NSDictionary*)memberUserInfo GroupId:(NSString*)groupId;

//更新就位确认状态
-(void)updateTeamUserState:(NSDictionary*)memberUserInfo;


//收到发起就位确认消息，更新就位确认状态
-(void)updateTeamUserState:(NSString*)groupId UserId:(NSString*)userId MemberList:(NSArray*)memberList State:(NSString*)state;

//收到就位确认结果消息，初始化就位确认状态
-(void)resetTeamUserState:(NSString*)groupId;

-(void)clearTeamMessage:(NSString*)groupId;//删除该组队所有的消息

@end
