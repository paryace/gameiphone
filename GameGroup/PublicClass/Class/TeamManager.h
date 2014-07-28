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

-(NSMutableDictionary*)getTeamInfo:(NSString*)gameId RoomId:(NSString*)roomId;
@end
