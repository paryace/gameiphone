//
//  GameListManager.m
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GameListManager.h"

@implementation GameListManager
static GameListManager * gameListManager = NULL;
+ (GameListManager*)singleton
{
    @synchronized(self)
    {
		if (gameListManager == nil)
		{
			gameListManager = [[self alloc] init];
		}
	}
	return gameListManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

-(void)getGameListFromLocal:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure{
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    if (dict) {
        NSLog(@"取本地数据-->>%@",dict);
        [self analysisGameList:dict resuccess:resuccess];
    }else{
        [self GetGageListFromNet:^(id responseObject) {
            NSLog(@"取后台数据-->>%@",responseObject);
            [self analysisGameList:responseObject resuccess:resuccess];
        } reError:^(id error) {
            if (refailure) {
                refailure(error);
            }
        }];
    }
}

-(void)getGameListDicFromLocal:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure{
    NSString *path  =[RootDocPath stringByAppendingString:@"/openData.plist"];
    NSDictionary *dict= [[NSMutableDictionary dictionaryWithContentsOfFile:path]objectForKey:@"gamelist"];
    if (dict) {
        NSLog(@"取本地数据-->>%@",dict);
        if (resuccess) {
            resuccess(dict);
        }
    }else{
        [self GetGageListFromNet:^(id responseObject) {
            NSLog(@"取后台数据-->>%@",responseObject);
            if (resuccess) {
                resuccess(dict);
            }
        } reError:^(id error) {
            if (refailure) {
                refailure(error);
            }
        }];
    }
}

-(void)GetGageListFromNet:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"225" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]:@"" forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *newDic = KISDictionaryHaveKey(responseObject, @"gamelist");
        if (resuccess) {
            resuccess(newDic);
        }
        [[GameCommon shareGameCommon] openSuccessWithInfo:responseObject From:@"gameListOpen"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (refailure) {
            refailure(error);
        }
    }];
}

-(void)analysisGameList:(NSDictionary*)gameListDic resuccess:(void (^)(id responseObject))resuccess{
    NSMutableArray *newArray = [NSMutableArray array];
    NSArray *allk =[gameListDic allKeys];
    for (int i =0; i<allk.count; i++) {
        NSArray *array = [gameListDic objectForKey:allk[i] ];
        [newArray addObjectsFromArray:array];
    }
    if (resuccess) {
        resuccess(newArray);
    }
}

@end
