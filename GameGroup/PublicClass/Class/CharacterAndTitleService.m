//
//  CharacterAndTitleService.m
//  GameGroup
//
//  Created by Marss on 14-7-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharacterAndTitleService.h"

static CharacterAndTitleService * characterAndTitleService = NULL;

@implementation CharacterAndTitleService

+ (CharacterAndTitleService*)singleton
{
    @synchronized(self)
    {
		if (characterAndTitleService == nil)
		{
			characterAndTitleService = [[self alloc] init];
		}
	}
	return characterAndTitleService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//请求角色信息
-(void)getCharacterInfo:(NSString*)userid
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userid forKey:@"userid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"202" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSArray class]]) {
            [self saveCharachers:responseObject Userid:userid];
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
    }];
}
// 保存角色信息
-(void)saveCharachers:(NSArray*)charachers Userid:(NSString*)userid
{
    [DataStoreManager deleteAllDSCharacters:userid];
    for (NSMutableDictionary *characher in charachers) {
        [DataStoreManager saveDSCharacters:characher UserId:userid];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateCharacterInfo object:charachers userInfo:nil];
}


//请求头衔信息－－type显示头衔，0是显示， 1是隐藏， 如果不传两种都返回
-(void)getTitleInfo:(NSString*)userid Type:(NSString*)type
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:userid forKey:@"userid"];
    if (![GameCommon isEmtity:type]) {
        [paramDict setObject:@"0" forKey:@"hide"];
    }
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:@"129" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self saveTitleInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] Titles:KISDictionaryHaveKey(responseObject, @"0") Type:@"0"];
        
        [self saveTitleInfo:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] Titles:KISDictionaryHaveKey(responseObject, @"1") Type:@"1"];
    } failure:^(AFHTTPRequestOperation *operation, id error) {

    }];
}
//保存头衔信息
-(void)saveTitleInfo:(NSString*)userId Titles:(NSArray*)titles Type:(NSString*)type
{
    if (!titles || ![titles isKindOfClass:[NSArray class]]) {
        return;
    }
    if ([GameCommon isEmtity:type]) {
        [DataStoreManager deleteAllDSTitle:userId];
    }else{
        [DataStoreManager deleteDSTitleByType:type Userid:userId];
    }
    if (titles.count==0) {
        return;
    }
    for (NSMutableDictionary *title in titles) {
        [DataStoreManager saveDSTitle:title];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTitleInfo object:titles userInfo:nil];
}
@end
