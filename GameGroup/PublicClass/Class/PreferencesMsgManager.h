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

//请求偏好列表
-(void)getPreferencesWithNet:(NSString*)userId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

//删除偏好
-(void)deletePreferences:(NSString*)gameId PreferenceId:(NSString*)preferenceId Completion:(MRSaveCompletionHandler)completion;

//根据游戏id删除偏好
-(void)deletePreferences:(NSString*)characterId;

//根据游戏id删除偏好
-(void)deletePreferences:(NSString*)gameId Completion:(MRSaveCompletionHandler)completion;

-(NSInteger)getNoreadMsgCount:(NSMutableArray*)msgs;

-(NSInteger)getNoreadMsgCount2;

-(NSInteger)getPreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId;

-(void)setPreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId State:(NSInteger)state;

-(void)removePreferenceState:(NSString*)gameId PreferenceId:(NSString*)preferenceId;
@end
