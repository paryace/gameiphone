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
