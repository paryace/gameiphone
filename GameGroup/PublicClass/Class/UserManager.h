//
//  UserManager.h
//  GameGroup
//
//  Created by 魏星 on 14-3-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSuser.h"

@interface UserManager : NSObject
@property(nonatomic, strong) NSMutableDictionary* userCache;
@property(nonatomic, strong) NSMutableArray* cacheUserids;
@property (strong,nonatomic) dispatch_queue_t queueDb;

+ (UserManager*)singleton;

- (NSMutableDictionary*)getUser:(NSString* )userId;

- (void)requestUserFromNet:(NSString*)userId;

-(void)getSayHiUserId;

-(void)getBlackListFromNet;

+(void)createGroup:(NSString*)groupName Info:(NSString*)info GroupIconImg:(NSString*)groupIconImg;

-(void)getGroupListFromNet;

-(void)saveUserInfo:(id)responseObject;

+(void)getGroupSettingState;

-(void)getUserLocation; //  定位

-(void)getOpenImageFromNet; //请求开机图
-(UIImage*)getOpenImage;//获取开机图

-(void)saveUserInfoToDb:(NSDictionary*)dicUser ShipType:(NSString*)shipType;
@end
