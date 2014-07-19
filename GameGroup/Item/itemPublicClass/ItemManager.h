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

//获取类型列表
-(void)getTeamType:(NSString*)gameId;

//获取标签列表
-(void)getTeamLable:(NSString*)gameId TypeId:(NSString*)typeId;

//组队房间过滤
-(void)getFilterId:(NSString*)gameId;

//收藏组队偏好
-(void)collectionItem:(NSString*)gameid CharacterId:(NSString*)characterId TypeId:(NSString*)typeId Description:(NSString*)description FilterId:(NSString*)filterId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;
@end
