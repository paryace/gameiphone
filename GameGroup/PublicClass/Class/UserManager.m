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
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"userId==[c]%@",userId];
    DSuser * dUser = [DSuser MR_findFirstWithPredicate:predicate];
    if (dUser) {
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
- (void)requestUserFromNet:(NSString*)userId {
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:userId forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"201" forKey:@"method"];//新接口
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self saveUserInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedFail" object:nil];
    }];
}

//保存用户信息  新接口
-(void)saveUserInfo:(id)responseObject
{
    NSMutableDictionary * dicUser = KISDictionaryHaveKey(responseObject, @"user");
    if ([GameCommon isEmtity:KISDictionaryHaveKey(dicUser, @"userid")]) {
        [dicUser setObject:KISDictionaryHaveKey(dicUser, @"id") forKey:@"userid"];
    }
    
    NSMutableArray * titles = KISDictionaryHaveKey(responseObject, @"title");
    NSMutableArray * charachers = KISDictionaryHaveKey(responseObject, @"characters");
    
    [dicUser setObject:[responseObject objectForKey:@"gameids"]forKey:@"gameids"];
    
    if ([titles isKindOfClass:[NSArray class]] && [titles count] != 0) {//头衔
        NSDictionary *titleDictionary=[titles objectAtIndex:0];
        NSMutableDictionary * titleObjectDic = KISDictionaryHaveKey(titleDictionary, @"titleObj");
        NSString * titleObj = KISDictionaryHaveKey(titleObjectDic, @"title");
        NSString * titleObjLevel = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjectDic, @"rarenum")];
        [dicUser setObject:titleObj forKey:@"titleName"];
        [dicUser setObject:titleObjLevel forKey:@"rarenum"];
    }
    [DataStoreManager newSaveAllUserWithUserManagerList:dicUser withshiptype:KISDictionaryHaveKey(responseObject, @"shiptype")];

    for (NSMutableDictionary *characher in charachers) {
        [DataStoreManager saveDSCharacters:characher UserId:KISDictionaryHaveKey(dicUser, @"id")];
    }
    for (NSMutableDictionary *title in titles) {
        [DataStoreManager saveDSTitle:title];
    }
    [self updateMsgInfo:dicUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedSuccess" object:nil userInfo:responseObject];
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
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSUserDefaults standardUserDefaults]setObject:responseObject forKey:@"sayHello_wx_info_id"];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
        
    }];
}

+(void)getBlackListFromNet
{
    
        NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
        [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
        [postDict setObject:@"228" forKey:@"method"];
        [postDict setObject:paramDict forKey:@"params"];
        
        [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
        
        [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            dispatch_queue_t queue = dispatch_queue_create("com.living.game.NewFriendController", NULL);
            dispatch_async(queue, ^{
                if ([responseObject isKindOfClass:[NSArray class]]) {
                    NSArray *array = responseObject;
//                    [DataStoreManager deleteAllBlackList];
                    if (array.count>0) {
                        for (NSDictionary *dic in array) {
                            [DataStoreManager SaveBlackListWithDic:dic WithType:@"2"];
                        }
                    }
                }
            });

        } failure:^(AFHTTPRequestOperation *operation, id error) {
            NSLog(@"deviceToken fail");
            
        }];
}

//创建群
+(void)createGroup:(NSString*)groupName Info:(NSString*)info GroupIconImg:(NSString*)groupIconImg
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:groupName forKey:@"groupName"];
    [paramDict setObject:info forKey:@"info"];
    [paramDict setObject:groupIconImg forKey:@"groupIconImg"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"229" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSLog(@"success%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id error) {
         NSLog(@"fail");
    }];
}
//获取群列表
+(void)getGroupListFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"230" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"success%@",responseObject);
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}




-(void) onUserUpdate:(NSNotification*)notification{

}

@end
