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
        [self.groupCache setObject:groupInfo forKey:groupId];
        return groupInfo;
    }
    else{
        [self getGroupInfoWithNet:groupId];
        return nil;
    }
}

-(void)getGroupInfoWithNet:(NSString*)groupId
{
    
    [self.groupCache removeObjectForKey:groupId];
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
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            [self.cacheGroupIds removeObject:groupId];
            [DataStoreManager saveDSGroupList:responseObject];
            [[NSNotificationCenter defaultCenter] postNotificationName:groupInfoUpload object:nil userInfo:responseObject];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
    
}

@end
