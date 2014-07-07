//
//  UserManager.m
//  GameGroup
//
//  Created by 魏星 on 14-3-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "UserManager.h"
#import "LocationManager.h"

static UserManager *userManager = NULL;

@implementation UserManager{
    dispatch_queue_t queue;
}

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
        self.userCache = [NSMutableDictionary dictionaryWithCapacity:30];
        self.cacheUserids = [NSMutableArray array];
        queue = dispatch_queue_create("com.living.game.SavePersonInfo", NULL);
    }
    return self;
}

- (NSMutableDictionary*)getUser:(NSString* )userId
{
    NSMutableDictionary * userDic = [self.userCache objectForKey:userId];
    if (userDic) {
        return userDic;
    }
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
        [self.userCache setObject:dict forKey:userId];
    }
    else{
        [self requestUserFromNet:userId];
    }
    return dict;
}
- (void)requestUserFromNet:(NSString*)userId {
    if ([userId hasPrefix:@"sys"]) {
        return ;
    }
    [self.userCache removeObjectForKey:userId];
    if ([self.cacheUserids containsObject:userId]) {
        return;
    }
    [self.cacheUserids addObject:userId];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    
    [paramDict setObject:userId forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"201" forKey:@"method"];//新接口
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self.cacheUserids removeObject:userId];
        [self saveUserInfo:responseObject];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.cacheUserids removeObject:userId];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"userInfoUpdatedFail" object:nil];
    }];
}

//保存用户信息  新接口
-(void)saveUserInfo:(id)responseObject
{
    dispatch_sync(queue, ^{
        NSMutableDictionary * dicUser = KISDictionaryHaveKey(responseObject, @"user");
        if ([GameCommon isEmtity:KISDictionaryHaveKey(dicUser, @"userid")]) {
            [dicUser setObject:KISDictionaryHaveKey(dicUser, @"id") forKey:@"userid"];
        }
        
        NSMutableArray * titles = KISDictionaryHaveKey(responseObject, @"title");
        NSMutableArray * charachers = KISDictionaryHaveKey(responseObject, @"characters");
        NSMutableDictionary *  latestDynamicMsg = KISDictionaryHaveKey(responseObject, @"latestDynamicMsg");
        
        [dicUser setObject:[responseObject objectForKey:@"gameids"]forKey:@"gameids"];
        if ([titles isKindOfClass:[NSArray class]] && [titles count] != 0) {//头衔
            NSDictionary *titleDictionary=[titles objectAtIndex:0];
            NSMutableDictionary * titleObjectDic = KISDictionaryHaveKey(titleDictionary, @"titleObj");
            NSString * titleObj = KISDictionaryHaveKey(titleObjectDic, @"title");
            NSString * titleObjLevel = [GameCommon getNewStringWithId:KISDictionaryHaveKey(titleObjectDic, @"rarenum")];
            [dicUser setObject:titleObj forKey:@"titleName"];
            [dicUser setObject:titleObjLevel forKey:@"rarenum"];
        }
        [DataStoreManager deleteAllDSCharacters:KISDictionaryHaveKey(dicUser, @"userid")];
        [DataStoreManager deleteAllDSTitle:KISDictionaryHaveKey(dicUser, @"userid")];
        
        [DataStoreManager newSaveAllUserWithUserManagerList:dicUser withshiptype:KISDictionaryHaveKey(responseObject, @"shiptype")];
        
        [DataStoreManager saveDSCharacters2:charachers UserId:KISDictionaryHaveKey(dicUser, @"userid")];
        [DataStoreManager saveDSTitle2:titles];
//        for (NSMutableDictionary *characher in charachers) {
//            [DataStoreManager saveDSCharacters:characher UserId:KISDictionaryHaveKey(dicUser, @"userid")];
//        }
//        for (NSMutableDictionary *title in titles) {
//            [DataStoreManager saveDSTitle:title];
//        }
        if (latestDynamicMsg&&[latestDynamicMsg isKindOfClass:[NSDictionary class]]) {
            [DataStoreManager saveDSlatestDynamic:latestDynamicMsg];
        }
        [self updateMsgInfo:dicUser];
    });
    [[NSNotificationCenter defaultCenter] postNotificationName:userInfoUpload object:nil userInfo:responseObject];
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
            
            if ([responseObject isKindOfClass:[NSArray class]]) {
                NSArray *array = responseObject;
                //                    [DataStoreManager deleteAllBlackList];
                if (array.count>0) {
                    for (NSDictionary *dic in array) {
                        [DataStoreManager SaveBlackListWithDic:dic WithType:@"2"];
                    }
                }
            }

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
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"230" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [DataStoreManager deleteAllDSGroupList];
        NSLog(@"success%@",responseObject);
        if ([responseObject isKindOfClass:[NSMutableArray class]]) {
            for (NSMutableDictionary * groupInfo in responseObject) {
                [DataStoreManager saveDSGroupList:groupInfo];
            }
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"faile");
    }];
}


//请求群的消息设置状态
+(void)getGroupSettingState
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
     NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"254" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",responseObject);
        if (![responseObject isKindOfClass:[NSMutableArray class]]) {
            return;
        }
        for (NSMutableDictionary * info in responseObject) {
            [[NSUserDefaults standardUserDefaults]setObject:KISDictionaryHaveKey(info, @"messageState") forKey:[NSString stringWithFormat:@"id%@",KISDictionaryHaveKey(info, @"groupId")]];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}

#pragma mark 获取用户位置
-(void)getUserLocation
{
    [[LocationManager sharedInstance] startCheckLocationWithSuccess:^(double lat, double lon) {
        [[TempData sharedInstance] setLat:lat Lon:lon];
        if ([[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]) {//自动登录
            [self upLoadUserLocationWithLat:lat Lon:lon];
        }
    } Failure:^{
        NSLog(@"开机定位失败");
    }];
}
-(void)upLoadUserLocationWithLat:(double)userLatitude Lon:(double)userLongitude
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSDictionary * locationDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%f",userLongitude],@"longitude",[NSString stringWithFormat:@"%f",userLatitude],@"latitude", nil];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"108" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}
//请求开机图
-(void)getOpenImageFromNet
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setObject:@(kScreenWidth) forKey:@"width"];
    [paramDict setObject:@(kScreenHeigth) forKey:@"height"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"263" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]:@"" forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
     
                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                  NSString * openImageId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(responseObject, @"adImg")];
                                  NSString * imageId = [[NSUserDefaults standardUserDefaults] objectForKey:OpenImage];
                                  if ([GameCommon isEmtity:openImageId]) {
                                      [[NSUserDefaults standardUserDefaults]setObject:@"" forKey:OpenImage];
                                  }else{
                                      if (![openImageId isEqualToString:imageId]) {
                                          [self downloadImageWithID:openImageId];
                                      }
                                  }
                              }
                          } failure:^(AFHTTPRequestOperation *operation, id error) {
                          }];
}

-(void)downloadImageWithID:(NSString *)imageId
{
    [[DownloadImageService singleton] startDownload:imageId];
}


//获取开机图
-(UIImage*)getOpenImage
{
    NSString * imageId = [[NSUserDefaults standardUserDefaults] objectForKey:OpenImage];
    if ([GameCommon isEmtity:imageId]) {
        return [self getDefaultOpenImage];
    }
    return [self getOpemImageByImageId:imageId];
}
-(UIImage*)getOpemImageByImageId:(NSString*)imageId
{
    NSString *openImgPath = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",imageId]];
    UIImage *openImage = [[UIImage alloc]initWithContentsOfFile:openImgPath];
    if (openImage&&![openImage isEqual:@""]) {
        return openImage;
        //        return [NetManager image2:openImage centerInSize:CGSizeMake(self.view.bounds.size.width*2, self.view.bounds.size.height*2)];
    }
    return [self getDefaultOpenImage];
}
-(UIImage*)getDefaultOpenImage
{
    if (iPhone5) {
        return KUIImage(@"Default-568h@2x.png");
    }
    return KUIImage(@"Default.png");
}


@end
