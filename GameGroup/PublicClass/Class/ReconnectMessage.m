//
//  ReconnectMessage.m
//  GameGroup
//
//  Created by 魏星 on 14-3-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReconnectMessage.h"
#import "AppDelegate.h"
#import "UserManager.h"
static ReconnectMessage *my_reconectMessage = NULL;
@implementation ReconnectMessage
{
    Reachability* reach;
}
- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}

+ (ReconnectMessage*)singleton
{
    @synchronized(self)
    {
		if (my_reconectMessage == nil)
		{
			my_reconectMessage = [[self alloc] init];
		}
	}
	return my_reconectMessage;
}


#pragma mark - 获得好友、关注、粉丝列表
-(void)getFriendByHttp
{
    [[NSNotificationCenter defaultCenter]postNotificationName:@"StartGetFriendListForNet" object:nil];
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    //    [paramDict setObject:@"1" forKey:@"shiptype"];// 1：好友   2：关注  3：粉丝
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sorttype_1]) {
        [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:sorttype_1] forKey:@"sorttype_1"];
    }
    else
    {
        [paramDict setObject:@"1" forKey:@"sorttype_1"];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:sorttype_2]) {
        [paramDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:sorttype_2] forKey:@"sorttype_2"];
    }
    else
    {
        [paramDict setObject:@"1" forKey:@"sorttype_2"];
    }
    [paramDict setObject:@"2" forKey:@"sorttype_3"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"111" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    // [hud show:YES];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getFriendListForNet_wx" object:nil];
        [self parseContentListWithData:responseObject ];
        
        [[NSUserDefaults standardUserDefaults] setObject:[GameCommon getNewStringWithId:KISDictionaryHaveKey(KISDictionaryHaveKey(responseObject, @"3"), @"totalResults")] forKey:FansCount];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //不再请求好友列表
        [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:isFirstOpen];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"getFriendListForNet_wx" object:nil];

    }];
}

- (void)parseContentListWithData:(NSDictionary*)dataDic
{
    [DataStoreManager deleteAllUserWithShipType:@"1"];//先清 再存
    [DataStoreManager deleteAllUserWithShipType:@"2"];
    [DataStoreManager deleteAllUserWithShipType:@"3"];
    
    id friendsList = KISDictionaryHaveKey(dataDic, @"1");
    id attentionList = KISDictionaryHaveKey(dataDic, @"2");
    id fansList = KISDictionaryHaveKey(KISDictionaryHaveKey(dataDic, @"3"), @"users");
    dispatch_queue_t queue = dispatch_queue_create("com.living.game", NULL);
    dispatch_async(queue, ^{
        //   [hud show:YES];
        
        if ([friendsList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [friendsList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [friendsList objectForKey:key]) {
                    [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"1"];
                    if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                        [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"1"];
                    }
                    
                }
            }
        }
        else if([friendsList isKindOfClass:[NSArray class]]){
            for (NSDictionary * dict in friendsList) {
                [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"1"];
                if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                    [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"1"];
                }
            }
        }
        //关注
        if ([attentionList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [attentionList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [attentionList objectForKey:key]) {
                    //                    [dict setObject:key forKey:@"nameindex"];
                    [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"2"];
                    if (![DataStoreManager ifHaveThisUserInUserManager:KISDictionaryHaveKey(dict, @"userid")]) {
                        [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"2"];
                    }
                    
                }
            }
        }
        else if([attentionList isKindOfClass:[NSArray class]])
        {
            for (NSDictionary * dict in attentionList) {
                [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"2"];
            }
        }
        //粉丝
        if ([fansList isKindOfClass:[NSDictionary class]]) {
            NSArray* keyArr = [fansList allKeys];
            for (NSString* key in keyArr) {
                for (NSMutableDictionary * dict in [fansList objectForKey:key]) {
                    [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"2"];
                }
            }
        }
        else if ([fansList isKindOfClass:[NSArray class]]) {
            for (NSDictionary * dict in fansList) {
                [DataStoreManager saveAllUserWithUserManagerList:dict withshiptype:@"3"];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"0"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"1"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kReloadContentKey object:@"2"];
            
        });
    });
}

- (void)sendDeviceToken
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* locationDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [locationDict setObject:[GameCommon shareGameCommon].deviceToken forKey:@"deviceToken"];
    [locationDict setObject:appType forKey:@"appType"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] forKey:@"userid"];
    [postDict setObject:@"140" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStrNoController:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
}



#pragma mark 进入程序网络变化
- (void)appBecomeActiveWithNet:(NSNotification*)notification
{
    reach = notification.object;
    if ([reach currentReachabilityStatus] != NotReachable  && [[TempData sharedInstance] isHaveLogin]) {//有网
        if (![self.xmpphelper isConnected]) {
            [self getChatServer];
        }
    }
}

@end
