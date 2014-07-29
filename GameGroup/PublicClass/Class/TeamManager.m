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

//提取组队信息（本地或者后台）
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

#pragma mark ---请求组队详情信息
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
        [self saveTeamInfo:responseObject GameId:gameId Successcompletion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:teamInfoUpload object:nil userInfo:responseObject];
        }];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    }];
}
//保存组队信息
-(void)saveTeamInfo:(id)responseObject GameId:(NSString*)gameId{
    [self saveTeamInfo:responseObject GameId:gameId Successcompletion:nil];
}
//保存组队信息
-(void)saveTeamInfo:(id)responseObject GameId:(NSString*)gameId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [DataStoreManager saveTeamInfoWithDict:responseObject GameId:gameId Successcompletion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}
//组队人数+1
-(void)addMemberCount:(NSString*)gameId RoomId:(NSString*)roomId
{
    [DataStoreManager addMemBerCount:gameId RoomId:roomId Successcompletion:^(BOOL success, NSError *error) {
        [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:nil];
    }];
}
//组队人数-1
-(void)removeMemberCount:(NSString*)gameId RoomId:(NSString*)roomId
{
    [DataStoreManager removeMemBerCount:gameId RoomId:roomId Successcompletion:^(BOOL success, NSError *error) {
        [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:nil];
    }];
}
//更新组队人数
-(void)upDateTeamMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId MemberCount:(NSString*)memberCount
{
    [DataStoreManager updateMemBerCount:gameId RoomId:roomId MemberCount:memberCount Successcompletion:^(BOOL success, NSError *error) {
        [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:nil];
    }];
}

@end
