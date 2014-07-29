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
-(void)setTeamPosition:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId PositionTagId:(NSString*)positionTagId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

-(void)getPersonCountFromNetWithGameId:(NSString *)gameid typeId:(NSString *)typeId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;
@end
