//
//  TeamManager.m
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamManager.h"
static TeamManager *teamManager = NULL;
@implementation TeamManager
+ (TeamManager*)singleton
{
    @synchronized(self)
    {
		if (teamManager == nil)
		{
			teamManager = [[self alloc] init];
		}
	}
	return teamManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.teamCache = [NSMutableDictionary dictionaryWithCapacity:30];
        self.cacheids = [NSMutableArray array];
    }
    return self;
}


-(NSMutableDictionary*)getTeamInfo:(NSString*)gameId RoomId:(NSString*)roomId{
    NSMutableDictionary * teamDic = [self.teamCache objectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    if (teamDic) {
        return teamDic;
    }
    NSMutableDictionary * dict = [DataStoreManager queryDSTeamInfo:gameId RoomId:roomId];
    if (dict) {
        [self.teamCache setObject:dict forKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        return dict;
    }
    else{
        [self GETInfoWithNet:gameId RoomId:roomId];
    }
    return dict;
    
}

#pragma mark ---NET
-(void)GETInfoWithNet:(NSString*)gameId RoomId:(NSString*)roomId
{
    [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    if ([self.cacheids containsObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]]) {
        return;
    }
    [self.cacheids addObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:roomId] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:gameId] forKey:@"gameid"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"266" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [DataStoreManager saveTeamInfoWithDict:responseObject GameId:gameId];
            [[NSNotificationCenter defaultCenter] postNotificationName:teamInfoUpload object:nil userInfo:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    }];
}


-(void)addMemberCount:(NSString*)gameId RoomId:(NSString*)roomId
{
    [DataStoreManager addMemBerCount:gameId RoomId:roomId Successcompletion:^(BOOL success, NSError *error) {
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:nil];
    }];
    
}
-(void)removeMemberCount:(NSString*)gameId RoomId:(NSString*)roomId
{
    [DataStoreManager removeMemBerCount:gameId RoomId:roomId Successcompletion:^(BOOL success, NSError *error) {
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:nil];
    }];
}

-(void)upDateTeamMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId MemberCount:(NSString*)memberCount
{
    [DataStoreManager updateMemBerCount:gameId RoomId:roomId MemberCount:memberCount Successcompletion:^(BOOL success, NSError *error) {
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:nil];
    }];
}

@end
