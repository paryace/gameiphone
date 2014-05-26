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
            [dict setObject:dUser.gender?dUser.gender:@"" forKey:@"gender"];
            [dict setObject:dUser.signature?dUser.signature:@"" forKey:@"signature"];
            [dict setObject:@"0" forKey:@"latitude"];
            [dict setObject:@"0" forKey:@"longitude"];
            [dict setObject:dUser.age?dUser.age:@"" forKey:@"birthdate"];
            [dict setObject:dUser.headImgID?dUser.headImgID:@"" forKey:@"img"];
            NSString * alis =dUser.remarkName;
            if ([GameCommon isEmtity:alis]) {
                alis = dUser.nickName;
            }
            [dict setObject:alis?alis:@"" forKey:@"nickname"];
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
//    [postDict setObject:@"106" forKey:@"method"];//旧接口
    [postDict setObject:@"201" forKey:@"method"];//新接口
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self saveUserInfo:responseObject UserId:userId];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedFail" object:nil];
    }];
}

//保存用户信息  新接口
-(void)saveUserInfo:(id)responseObject UserId:(NSString*)userId
{
    dispatch_queue_t queue = dispatch_queue_create("com.living.game.UserManager", NULL);
    dispatch_async(queue, ^{
        NSMutableDictionary * recDict = KISDictionaryHaveKey(responseObject, @"user");
        
        [recDict setObject:[responseObject objectForKey:@"gameids"]forKey:@"gameids"];
        if ([KISDictionaryHaveKey(responseObject, @"title") isKindOfClass:[NSArray class]] && [KISDictionaryHaveKey(responseObject, @"title") count] != 0) {//头衔
            NSDictionary *titleDictionary=[KISDictionaryHaveKey(responseObject, @"title") objectAtIndex:0];
            
            NSString * titleObj = KISDictionaryHaveKey(KISDictionaryHaveKey(titleDictionary, @"titleObj"), @"title");
            NSString * titleObjLevel = [GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(titleDictionary, @"titleObj"), @"rarenum")];
            [recDict setObject:titleObj forKey:@"titleName"];
            [recDict setObject:titleObjLevel forKey:@"rarenum"];
        }
        [DataStoreManager newSaveAllUserWithUserManagerList:recDict withshiptype:KISDictionaryHaveKey(responseObject, @"shiptype")];
        
//        //保存用户信息  如果有就删除旧的 保存新的 如果没有就保存
//        if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(responseObject, @"userid")]) {
//            [DataStoreManager newSaveAllUserWithUserManagerList:recDict withshiptype:KISDictionaryHaveKey(responseObject, @"shiptype")];
//        }else{
//            [DataStoreManager deleteAllUserWithUserId:KISDictionaryHaveKey(responseObject, @"userid")];
//            [DataStoreManager newSaveAllUserWithUserManagerList:recDict withshiptype:KISDictionaryHaveKey(responseObject, @"shiptype")];
//        }
        [self updateMsgInfo:recDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedSuccess" object:nil userInfo:responseObject];
        });
    });
}


//更新消息表
-(void)updateMsgInfo:(NSMutableDictionary*) userDict
{
    NSString * nickName=KISDictionaryHaveKey(userDict,@"alias");
    if ([GameCommon isEmtity:nickName]) {
        nickName=KISDictionaryHaveKey(userDict,@"nickname");
    }
    NSString * userImg=KISDictionaryHaveKey(userDict,@"img");
    NSString * userId=KISDictionaryHaveKey(userDict,@"userid");
    [DataStoreManager updateRecommendImgAndNickNameWithUser:userId nickName:nickName andImg:userImg];
    [DataStoreManager storeThumbMsgUser:userId nickName:nickName andImg:userImg];
}




-(void)getSayHiUserId
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@"" forKey:@"touserid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"154" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        
        [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"sayHello_wx_info_id"];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
        
    }];
    
}

-(void) onUserUpdate:(NSNotification*)notification{

}

@end
