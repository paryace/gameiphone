//
//  UserManager.m
//  GameGroup
//
//  Created by 魏星 on 14-3-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "UserManager.h"
static UserManager *userManager = NULL;

@implementation UserManager

+ (UserManager*)singleton
{
    @synchronized(self)
    {
		if (userManager == nil)
		{
			userManager = [[self alloc] init];
		}
	}
	return userManager;
}
-(id)init
{  self = [super init];
    if (self) {

    }
    return self;
}

- (NSMutableDictionary*)getUser:(NSString* )userId
{
    
//    DSuser* user=[DataStoreManager queryFirstHeadImageForUser_userManager:userId];
//    if(!user){
//        [self requestUserFromNet:userId];
//        return [self getDefaultUser:userId];
//    }else{
//        return user;
//    }

        NSMutableDictionary * dict = [NSMutableDictionary dictionary];
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
        DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
        if (dUser) {
            [dict setObject:dUser.userName forKey:@"username"];
            [dict setObject:dUser.userId?dUser.userId:@"" forKey:@"userid"];
            [dict setObject:dUser.nickName?dUser.nickName:@"" forKey:@"nickname"];
            [dict setObject:dUser.gender?dUser.gender:@"" forKey:@"gender"];
            [dict setObject:dUser.signature?dUser.signature:@"" forKey:@"signature"];
            [dict setObject:@"0" forKey:@"latitude"];
            [dict setObject:@"0" forKey:@"longitude"];
            [dict setObject:dUser.age?dUser.age:@"" forKey:@"birthdate"];
            [dict setObject:dUser.headImgID?dUser.headImgID:@"" forKey:@"img"];
        }
        else{
            [self requestUserFromNet:userId];
        }
    

    return dict;
}

//- (DSuser*)getDefaultUser:(NSString*) userId{
//    DSuser* user=[[DSuser alloc] init];
//    user.userId=userId;
//    return user;
//
//}

- (void)requestUserFromNet:(NSString*)userId {
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:userId forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"106" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSMutableDictionary * recDict = KISDictionaryHaveKey(responseObject, @"user");
        if ([KISDictionaryHaveKey(responseObject, @"title") isKindOfClass:[NSArray class]] && [KISDictionaryHaveKey(responseObject, @"title") count] != 0) {//头衔
            [recDict setObject:[KISDictionaryHaveKey(responseObject, @"title") objectAtIndex:0] forKey:@"title"];
        }
        //保存用户信息  如果有就删除旧的 保存新的 如果没有就保存
        if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(responseObject, @"userid")]) {
            [DataStoreManager saveAllUserWithUserManagerList:recDict];
        }else{
            [DataStoreManager deleteAllUserWithUserName:KISDictionaryHaveKey(responseObject, @"userid")];
            [DataStoreManager saveAllUserWithUserManagerList:recDict];
        }

            [DataStoreManager storeThumbMsgUser:userId nickName:KISDictionaryHaveKey(recDict, @"nickname") andImg:KISDictionaryHaveKey(recDict,@"img")];


        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedSuccess" object:nil userInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
     [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedFail" object:nil];
    }];
}

-(void) onUserUpdate:(NSNotification*)notification{

}

@end
