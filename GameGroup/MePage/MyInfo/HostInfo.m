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
        self.state = KISDictionaryHaveKey(info, @"latestDynamicMsg");//动态
        self.charactersArr=KISDictionaryHaveKey(info, @"characters");//新角色
        self.gameids=KISDictionaryHaveKey(info, @"gameids");//游戏
        self.groupList = KISDictionaryHaveKey(info, @"groupList");
        self.zanNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"zannum")];
        self.fanNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"fansnum")];
        self.groupNum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"groupNum")];
        self.relation = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(info, @"shiptype")];// 1 好友，2 关注 3 粉丝 4 陌生人
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
        [[NSUserDefaults standardUserDefaults]setObject:self.charactersArr forKey:@"CharacterArrayOfAllForYou"];
        NSDictionary* userInfo = KISDictionaryHaveKey(info, @"user");
        if (![userInfo isKindOfClass:[NSDictionary class]]) {
            return self;
        }
        self.infoDic = userInfo;
        [self iniUserInfo:userInfo];
    }
    return self;
}

-(void)iniUserInfo:(NSDictionary*)userInfo
{
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"active")] intValue] == 2) {
        self.active = YES;
    }else
    {
        self.active = NO;
    }
    self.superstar = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superstar")];
    self.superremark = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"superremark")];
    self.updateTime = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"updateUserLocationDate")];
    self.distrance = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"distance")];
    self.createTime = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"createTime")];
    self.starSign = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"constellation")];
    self.birthdate = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"birthdate")];
    self.alias = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"alias")];
    self.clazzId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"clazz")];
    self.userName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"username")];
    self.userId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"userid")];
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
    self.headImgArray = [ImageService getImageIds:self.headImgStr];
    self.backgroundImg = [GameCommon getNewStringWithId:KISDictionaryHaveKey(userInfo, @"backgroundImg")];
}

@end

