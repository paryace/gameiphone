//
//  PreferencesMsgManager.h
//  GameGroup
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesMsgManager : NSObject
+ (PreferencesMsgManager*)singleton;

-(NSInteger)getNoreadMsgCount:(NSMutableArray*)msgs;

-(NSInteger)getPreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId;

-(void)setPreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId State:(NSInteger)state;

-(void)removePreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId;
@end
