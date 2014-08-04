//
//  PreferencesMsgManager.m
//  GameGroup
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PreferencesMsgManager.h"
static PreferencesMsgManager *preferencesMsgManager = NULL;
@implementation PreferencesMsgManager
+ (PreferencesMsgManager*)singleton
{
    @synchronized(self)
    {
		if (preferencesMsgManager == nil)
		{
			preferencesMsgManager = [[self alloc] init];
		}
	}
	return preferencesMsgManager;
}
//请求偏好列表
-(void)getPreferencesWithNet:(NSString*)userId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"276" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:[NSString stringWithFormat:@"item_preference_%@",userId]];
            if (resuccess) {
                resuccess(responseObject);
            }
            [DataStoreManager savePreferenceInfo:responseObject Successcompletion:^(BOOL success, NSError *error) {
            }];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

//删除偏好
-(void)deletePreferences:(NSString*)gameId PreferenceId:(NSString*)preferenceId Completion:(MRSaveCompletionHandler)completion{
    [DataStoreManager deletePreferenceInfo:[GameCommon getNewStringWithId:gameId] PreferenceId:[GameCommon getNewStringWithId:preferenceId] Successcompletion:^(BOOL success, NSError *error) {
        [self removePreferenceState:[GameCommon getNewStringWithId:gameId] PreferenceId:[GameCommon getNewStringWithId:preferenceId]];
        if (completion) {
            completion(success, error);
        }
    }];
}
//根据角色id删除偏好
-(void)deletePreferences:(NSString*)characterId{
    [self deletePreferences:characterId Completion:nil];
}
//根据角色id删除偏好
-(void)deletePreferences:(NSString*)characterId Completion:(MRSaveCompletionHandler)completion{
    [DataStoreManager deletePreferenceInfoByCharacterId:[GameCommon getNewStringWithId:characterId] Successcompletion:^(BOOL success, NSError *error) {
        NSDictionary * dic = @{@"characterId":characterId};
        [[NSNotificationCenter defaultCenter] postNotificationName:RoleRemoveNotify object:nil userInfo:dic];
        if (completion) {
            completion(success, error);
        }
    }];
}




-(NSInteger)getNoreadMsgCount:(NSMutableArray*)msgs
{
    int allUnread = 0;
    for (int i = 0; i<msgs.count; i++) {
        NSMutableDictionary * message = [msgs objectAtIndex:i];
        NSInteger state = [self getPreferenceState:KISDictionaryHaveKey(KISDictionaryHaveKey(message, @"createTeamUser"), @"gameid") PreferenceId:KISDictionaryHaveKey(message, @"preferenceId")];
        if (state==1||state==3) {
            allUnread = allUnread+[KISDictionaryHaveKey(message, @"msgCount") intValue];
        }
    }
    return allUnread;
}

-(NSInteger)getPreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId{
    NSString *str = [GameCommon getNewStringWithId:[[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",[GameCommon getNewStringWithId:preferenceId],[GameCommon getNewStringWithId:gameId]]]];
    if ([GameCommon isEmtity:str]) {
        [self setPreferenceState:gameId PreferenceId:preferenceId State:1];
        return 1;
    }
    return [str integerValue];
}

-(void)setPreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId State:(NSInteger)state{
     [[NSUserDefaults standardUserDefaults]setObject:[NSString stringWithFormat:@"%d",state] forKey:[NSString stringWithFormat:@"%@_%@",[GameCommon getNewStringWithId:preferenceId],[GameCommon getNewStringWithId:gameId]]];
}

-(void)removePreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId{
    if ([[NSUserDefaults standardUserDefaults]objectForKey:[NSString stringWithFormat:@"%@_%@",[GameCommon getNewStringWithId:preferenceId],[GameCommon getNewStringWithId:gameId]]]) {
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:[NSString stringWithFormat:@"%@_%@",[GameCommon getNewStringWithId:preferenceId],[GameCommon getNewStringWithId:gameId]]];
    }
}

@end
