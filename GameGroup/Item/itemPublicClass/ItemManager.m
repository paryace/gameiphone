//
//  ItemManager.m
//  GameGroup
//
//  Created by Marss on 14-7-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ItemManager.h"


static ItemManager *itemManager = NULL;
@implementation ItemManager
+ (ItemManager*)singleton
{
    @synchronized(self)
    {
		if (itemManager == nil)
		{
			itemManager = [[self alloc] init];
		}
	}
	return itemManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(BOOL)getUpdate:(NSString*)fileName
{
    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:fileName];
    long long nowTime = [self getCurrentTime];
    long long oldTime = [time longLongValue];
    if ((nowTime-oldTime)>24*60*60*1000) {
        NSString *alltimeString=[NSString stringWithFormat:@"%lld",nowTime];
        [[NSUserDefaults standardUserDefaults] setValue:alltimeString forKey:fileName];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return YES;
    }
    return NO;
}


#pragma mark ----获取组队分类
-(void)getTeamType:(NSString*)gameId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSArray * arrayType = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",@"TeamType",gameId]];
    if (arrayType&&![self getUpdate:[NSString stringWithFormat:@"%@_updateTime_%@",@"TeamType",gameId]]) {
        if (resuccess) {
            resuccess(arrayType);
        }
        return;
    }
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:gameId forKey:@"gameid"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"277" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"getTeamType--%@",responseObject);
        if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:[NSString stringWithFormat:@"%@_%@",@"TeamType",gameId]];
            if (resuccess) {
                resuccess(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

#pragma mark ----获取组队偏好标签 gameid，typeId
-(void)getTeamLable:(NSString*)gameId TypeId:(NSString*)typeId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSArray * arrayTag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@%@",@"TeamLable",gameId,typeId]];
    if (arrayTag&&![self getUpdate:[NSString stringWithFormat:@"%@_updateTime_%@%@",@"TeamLable",gameId,typeId]]) {
        if (resuccess) {
            resuccess(arrayTag);
        }
        return;
    }    
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:gameId forKey:@"gameid"];
    [paramDict setObject:typeId forKey:@"typeId"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"278" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"getTeamLable--%@",responseObject);
        if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
           [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:[NSString stringWithFormat:@"%@_%@%@",@"TeamLable",gameId,typeId]];
            if (resuccess) {
                resuccess(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

#pragma mark ----组队房间过滤 gameid
-(void)getFilterId:(NSString*)gameId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSArray * arrayFilterId = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",@"FilterId",gameId]];
    if (arrayFilterId&&![self getUpdate:[NSString stringWithFormat:@"%@_updateTime_%@",@"FilterId",gameId]]) {
        if (resuccess) {
            resuccess(arrayFilterId);
        }
        return;
    }
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:gameId forKey:@"gameid"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"280" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"getFilterId--%@",responseObject);
        if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:[NSString stringWithFormat:@"%@_%@",@"FilterId",gameId]];
            if (resuccess) {
                resuccess(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

#pragma mark ----收藏组队偏好 gameid，characterId，typeId，description，filterId
-(void)collectionItem:(NSString*)gameid CharacterId:(NSString*)characterId TypeId:(NSString*)typeId Description:(NSString*)description FilterId:(NSString*)filterId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:characterId] forKey:@"characterId"];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:typeId] forKey:@"typeId"];
    if (![GameCommon isEmtity:description]) {
        [paramDict setObject:description forKey:@"description"];
    }
    if (![GameCommon isEmtity:[GameCommon getNewStringWithId:filterId]]) {
        [paramDict setObject:[GameCommon getNewStringWithId:filterId] forKey:@"filterId"];
    }
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"282" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

#pragma mark ---获取我的位置
-(void)getMyGameLocation:(NSString*)gameid reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSArray * arrayType = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",@"MyGameLocation",gameid]];
    if (arrayType&&![self getUpdate:[NSString stringWithFormat:@"%@_updateTime_%@",@"MyGameLocation",gameid]]) {
        if (resuccess) {
            resuccess(arrayType);
        }
        return;
    }
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"281" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"MyGameLocation--%@",responseObject);
        if (responseObject&&[responseObject isKindOfClass:[NSArray class]]) {
            [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:[NSString stringWithFormat:@"%@_%@",@"MyGameLocation",gameid]];
            if (resuccess) {
                resuccess(responseObject);
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}


#pragma mark ---同意加入组队
-(void)agreeJoinTeam:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:userid] forKey:@"userid"];
    [paramDict setObject:[GameCommon getNewStringWithId:roomId] forKey:@"roomId"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"288" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"agreeJoinTeam--%@",responseObject);
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

#pragma mark ---拒绝加入组队
-(void)disAgreeJoinTeam:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:userid] forKey:@"userid"];
    [paramDict setObject:[GameCommon getNewStringWithId:roomId] forKey:@"roomId"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"273" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"disAgreeJoinTeam--%@",responseObject);
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

#pragma mark ---设置组队位置
-(void)setTeamPosition:(NSString*)gameid UserId:(NSString*)userid RoomId:(NSString*)roomId PositionTagId:(NSString*)positionTagId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:gameid] forKey:@"gameid"];
    [paramDict setObject:[GameCommon getNewStringWithId:userid] forKey:@"userid"];
    [paramDict setObject:[GameCommon getNewStringWithId:roomId] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:positionTagId] forKey:@"positionTagId"];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"299" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"setTeamPosition--%@",responseObject);
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}


-(long long)getCurrentTime{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime*1000;
    return (long long)nowTime;
}
@end
