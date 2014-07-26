//
//  GroupManager.h
//  GameGroup
//
//  Created by Apple on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GroupManager : NSObject

@property(nonatomic, strong) NSMutableDictionary* groupCache;

@property(nonatomic, strong) NSMutableArray* cacheGroupIds;

+ (GroupManager*)singleton;

- (NSMutableDictionary*)getGroupInfo:(NSString* )groupId;//本地拿取群信息

-(void)getGroupInfoWithNet:(NSString*)groupId;//网络请求群信息

-(void)clearGroupCache:(NSString*)groupId;//清除缓存

-(void)changGroupState:(NSString*)grouoId GroupState:(NSString*)state GroupShipType:(NSString*)groupShipType;//更新该群的本地可用状态

-(void)deleteGrpuoInfo:(NSString*)groupId;//删除群组信息
@end
