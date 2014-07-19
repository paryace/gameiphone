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

#pragma mark ----获取组队分类
-(void)getTeamType:(NSString*)gameId
{
    NSArray * arrayType = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",@"TeamType",gameId]];
    if (arrayType) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamType object:arrayType];
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
             [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamType object:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {

    }];
}

#pragma mark ----获取组队偏好标签 gameid，typeId
-(void)getTeamLable:(NSString*)gameId TypeId:(NSString*)typeId
{
    NSArray * arrayTag = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@%@",@"TeamLable",gameId,typeId]];
    if (arrayTag) {
         [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamLable object:arrayTag];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamLable object:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

#pragma mark ----组队房间过滤 gameid
-(void)getFilterId:(NSString*)gameId
{
    NSArray * arrayFilterId = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_%@",@"FilterId",gameId]];
    if (arrayFilterId) {
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateFilterId object:arrayFilterId];
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
            [[NSNotificationCenter defaultCenter] postNotificationName:UpdateFilterId object:responseObject];
            
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
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
@end
