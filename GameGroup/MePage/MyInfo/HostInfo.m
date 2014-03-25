//
//  HostInfo.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-11.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "HostInfo.h"
@implementation HostInfo
- (id)initWithHostInfo:(NSDictionary*)info
{
    self = [super init];
    if (self) {
        
        self.characters = KISDictionaryHaveKey(info, @"characters");//角色
        
        self.achievementArray = KISDictionaryHaveKey(info, @"title");//头衔
        
        self.state = KISDictionaryHaveKey(info, @"dynamicmsg");//动态

//获取游戏角色列表
        //NSDictionary *charaDic = KISDictionaryHaveKey(info, @"dynamicmsg");
        if (![self.state isKindOfClass:[NSDictionary class]]) {
            ;
        }else{
         NSDictionary *dic =KISDictionaryHaveKey(self.state, @"titleObj");
        if ([dic isKindOfClass:[NSDictionary class]]) {
           
            
            NSLog(@"charaDic%@",dic);
            
             self.gameid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"gameid")];
             self.characterid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(dic, @"characterid")];
            
            NSLog(@"各种ID%@--%@",self.gameid,self.characterid);

        }else{
            NSLog(@"字典为空");

        }
        }
        self.zanNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"zannum")];
        self.fanNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"fansnum")];

        NSDictionary* userInfo = KISDictionaryHaveKey(info, @"user");
        if (![userInfo isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        self.infoDic = userInfo;
        if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"active")] intValue] == 2) {
            self.active = YES;
        }else
        {
            self.active = NO;
        }
        self.superstar = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superstar")];
        self.superremark = KISDictionaryHaveKey(userInfo, @"superremark");
        self.updateTime = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"updateUserLocationDate")];
        self.distrance = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"distance")];
        
        
        self.relation = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(info, @"shiptype")];// 1 好友，2 关注 3 粉丝 4 陌生人
        
        self.createTime = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"createTime")];
        self.starSign = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"constellation")];
        
        self.birthdate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"birthdate")];
        self.alias = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"alias")];

        self.clazzId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"clazz")];
        
        self.userName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"username")];
        self.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"id")];
        self.nickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"nickname")];
        self.telNumber = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"phoneNumber")];
        self.gender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"gender")];
        self.age = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"age")];
        
        self.signature = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"signature")];
        self.hobby = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"remark")];//说明、标签
        self.latitude = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"latitude")];
        self.longitude = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"longitude")];
        self.region = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"city")];

        self.headImgStr = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"img")];
        [self getHead:[NSString stringWithFormat:@"%@",[userInfo objectForKey:@"img"]]];
    
        self.backgroundImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"backgroundImg")];
    }
    return self;
}

//- (void)getTitleObj//头衔
//{
//    NSArray* characterArray = KISDictionaryHaveKey(self.characters, @"1");//魔兽世界的角色
//    if (![characterArray isKindOfClass:[NSArray class]]) {
//        return;
//    }
//    NSMutableDictionary* allTitleDic = [NSMutableDictionary dictionaryWithCapacity:1];
//    for (NSDictionary* info in characterArray) {
//        NSArray* titleObj = KISDictionaryHaveKey(info, @"titlesObj");
//        if (![titleObj isKindOfClass:[NSArray class]]) {
//            return;
//        }
//        if ([titleObj count] > 0) {
//            for (NSDictionary* oneTitleObj in titleObj) {
////                NSString* key = [GameCommon getNewStringWithId: KISDictionaryHaveKey(oneTitleObj, @"sortnum")];//顺序
//                NSString* key = KISDictionaryHaveKey(oneTitleObj, @"sortnum");//顺序
//
//                NSMutableDictionary* infoDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:KISDictionaryHaveKey(oneTitleObj, @"hide"),@"hide",KISDictionaryHaveKey(oneTitleObj, @"hasDate"),@"hasDate",[GameCommon getNewStringWithId:KISDictionaryHaveKey(oneTitleObj, @"titleid")],@"titleid",[GameCommon getNewStringWithId:KISDictionaryHaveKey(oneTitleObj, @"sortnum")],@"sortnum", KISDictionaryHaveKey(KISDictionaryHaveKey(oneTitleObj, @"titleObj"), @"title"),@"title", KISDictionaryHaveKey(KISDictionaryHaveKey(oneTitleObj, @"titleObj"), @"img"),@"img",nil];
//               
//                [allTitleDic setObject:infoDic forKey:key];
//            }
//            
//        }
//    }
////    NSArray* keySort = [allTitleDic keysSortedByValueUsingSelector:@selector(compare:)];
//    NSArray* keySort = [[allTitleDic allKeys] sortedArrayUsingSelector:@selector(compare:)];
//    
//    self.achievementArray = [NSMutableArray arrayWithCapacity:1];
//    if ([keySort count] > 0) {
//        for (int i = 0; i < [keySort count]; i++) {
//            [self.achievementArray addObject:[allTitleDic objectForKey:[keySort objectAtIndex:i]]];
//        }
//    }
//    NSLog(@"头衔： %@", self.achievementArray);
//}

- (NSArray *)getHeadImgArray:(NSString *)headImgStr
{
    NSRange range=[headImgStr rangeOfString:@","];
    if (range.location!=NSNotFound) {
        NSArray *imageArray = [headImgStr componentsSeparatedByString:@","];
        return imageArray;
    }
    else if(headImgStr.length>0)
    {
        NSArray * imageArray = [NSArray arrayWithObject:headImgStr];
        return imageArray;
    }
    else
        return nil;
    
    
}
-(void)getHead:(NSString *)headImgStr
{
    NSMutableArray * littleHeadArray = [NSMutableArray array];
    NSArray* i = [headImgStr componentsSeparatedByString:@","];
    if (i.count>0) {
        for (NSString* a in i) {
            if (![a isEqualToString:@""]) {
                [littleHeadArray addObject:a];
            }
        }
    }//动态大图ID数组和小图ID数组
    self.headImgArray = littleHeadArray;
}

@end

