//
//  GroupManager.m
//  GameGroup
//
//  Created by Apple on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupManager.h"
static GroupManager *groupManager = NULL;
@implementation GroupManager

+ (GroupManager*)singleton
{
    @synchronized(self)
    {
		if (groupManager == nil)
		{
			groupManager = [[self alloc] init];
		}
	}
	return groupManager;
}
-(id)init
{  self = [super init];
    if (self) {
        self.groupCache = [NSMutableDictionary dictionaryWithCapacity:30];
        self.cacheGroupIds = [NSMutableArray array];
    }
    return self;
}

- (NSMutableDictionary*)getGroupInfo:(NSString* )groupId
{
    NSMutableDictionary * groupDic = [self.groupCache objectForKey:groupId];
    if (groupDic) {
        return groupDic;
    }
     NSMutableDictionary * groupInfo = [DataStoreManager queryGroupInfoByGroupId:groupId];
    if (groupInfo) {
        if ([GameCommon isEmtity:KISDictionaryHaveKey(groupInfo, @"groupName")]) {
            [self getGroupInfoWithNet:groupId];
        }else{
            [self.groupCache setObject:groupInfo forKey:groupId];
        }
        return groupInfo;
    }
    else{
        [self getGroupInfoWithNet:groupId];
        return nil;
    }
}
-(void)clearGroupCache:(NSString*)groupId
{
    [self.groupCache removeObjectForKey:groupId];
}
//type：0系统创建的群，1个人创建的群，2组队的群
-(void)getGroupInfoWithNet:(NSString*)groupId
{
    
    [self clearGroupCache:groupId];
    if ([self.cacheGroupIds containsObject:groupId]) {
        return;
    }
    [self.cacheGroupIds addObject:groupId];
    
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupId forKey:@"groupId"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"231" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]) {
        [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    }else{
        [postDict setObject:@"" forKey:@"token"];
    }
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self.cacheGroupIds removeObject:groupId];
            [DataStoreManager saveDSGroupList:responseObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:groupInfoUpload object:nil userInfo:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [self.cacheGroupIds removeObject:groupId];
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100067"])
            {
                [DataStoreManager updateGroupState:groupId GroupState:@"0" GroupUserShipType:@"3"];//更新本地该群的可用状态
            }
        }

        NSLog(@"faile");
    }];
}

//更新本地该群的可用状态
-(void)changGroupState:(NSString*)grouoId GroupState:(NSString*)state GroupShipType:(NSString*)groupShipType
{
    [DataStoreManager updateGroupState:grouoId GroupState:state GroupUserShipType:groupShipType];
    [[GroupManager singleton] clearGroupCache:grouoId];
}


-(void)deleteGrpuoInfo:(NSString*)groupId{
    [DataStoreManager deleteGroupInfoByGoupId:groupId];
    [[GroupManager singleton] clearGroupCache:groupId];
}

@end
