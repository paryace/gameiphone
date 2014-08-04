//
//  ItemManager.h
//  GameGroup
//
//  Created by Marss on 14-7-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemManager : NSObject
+ (ItemManager*)singleton;

-(NSMutableDictionary*)createType;

-(NSMutableDictionary*)createMaxVols;

//获取类型列表
-(void)getTeamType:(NSString*)gameId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//获取标签列表
-(void)getTeamLable:(NSString*)gameId TypeId:(NSString*)typeId CharacterId:(NSString*)characterId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//获取房间偏好标签
-(void)getTeamLableRoom:(NSString*)gameId TypeId:(NSString*)typeId CharacterId:(NSString*)characterId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//组队房间过滤
-(void)getFilterId:(NSString*)gameId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//收藏组队偏好
-(void)collectionItem:(NSString*)gameid CharacterId:(NSString*)characterId TypeId:(NSString*)typeId Description:(NSString*)description FilterId:(NSString*)filterId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//获取我的位置
-(void)getMyGameLocation:(NSString*)gameid reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//同意加入组队
-(void)agreeJoinTeam:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//拒绝加入组队
-(void)disAgreeJoinTeam:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//设置组队位置
-(void)setTeamPosition:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId PositionTag:(NSDictionary*)selectType GroupId:(NSString*)groupId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//获取偏好数量
-(void)getPersonCountFromNetWithGameId:(NSString *)gameid typeId:(NSString *)typeId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//解散队伍
-(void)dissoTeam:(NSString*)roomId GameId:(NSString*)gameId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//退出队伍
-(void)exitTeam:(NSString*)roomId GameId:(NSString*)gameId MemberId:(NSString*)memberId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//发起就位确认
-(void)sendTeamPreparedUserSelect:(NSString*)roomId GameId:(NSString*)gameId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

#pragma mark --- 组队就位确认
-(void)teamPreparedUserSelect:(NSString*)roomId GameId:(NSString*)gameId ConfirmationId:(NSString*)confirmationId Value:(NSString*)value reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;
@end
