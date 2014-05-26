//
//  CharaInfo.m
//  GameGroup
//
//  Created by admin on 14-2-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharaInfo.h"

@implementation CharaInfo
- (id)initWithCharaInfo:(NSDictionary*)info
{
    self = [super init];
    if (self) {
        //info = KISDictionaryHaveKey(info, @"entity");//角色数据
        
        self.classObj = KISDictionaryHaveKey(info, @"classObj");//职业
        
        self.raceObj = KISDictionaryHaveKey(info, @"raceObj");//种族

        self.titleDic = KISDictionaryHaveKey(info,@"title");
        NSLog(@"titleDic%@",self.titleDic);
        self.auth = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"auth")];//是否认证
        
        if ([self.classObj isKindOfClass:[NSDictionary class]]) {
            self.professionalId = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.classObj, @"id")];
            self.professionalName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.classObj, @"name")];

        }
        
        self.characterid = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"id")];
        
        
        self.powerType = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.classObj, @"powerType")];
        self.roleNickName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"name")];

        
        self.clazz = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"clazz")];//职业
        
        self.gender = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"gender")];//性别
        
        self.guild = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"guild")];//公会
        
        self.itemlevel = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"itemlevel")];//装等
        
        self.itemlevelequipped = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"itemlevelequipped")];//当前装等
        
        self.level = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"level")];//等级
        
        self.pveScore = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"pveScore")];//pve战斗力
        self.race = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"race")];//种族
        
        self.raceName = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.raceObj, @"name")];//种族名字
        
        self.side = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.raceObj, @"side")];//阵营
        
        self.sidename = [GameCommon getNewStringWithId:KISDictionaryHaveKey(self.raceObj, @"sidename")];//阵营名称
        
        self.realm = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"realm")];//服务器
        
        self.thumbnail = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"thumbnail")];//获取头像
        
        self.mountsnum = [GameCommon getNewStringWithId:KISDictionaryHaveKey(info, @"mountsnum")];//坐骑数量
        
        NSLog(@"ranvaltype---%@",self.rankvaltype);
        
        
        self.listContentDic = KISDictionaryHaveKey(info, @"ranking");//表格中的数据
        /*好友 全国 服务器  */
        self.friendOfRanking = KISDictionaryHaveKey(self.listContentDic, @"1");
        self.nationaOfRanking = KISDictionaryHaveKey(self.listContentDic, @"3");
        self.serverOfRanking = KISDictionaryHaveKey(self.listContentDic, @"2");
        
        /*成就 好友  PVE 荣誉击杀  装备等级 成就点数 PVE */
        self.achievementDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"achievementPoints");
        self.itemlevelDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"itemlevel");
        self.pveScoreDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"pveScore");
        self.pvpscoreDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"pvpScore");
        self.KillsDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"totalHonorableKills");

        /*成就 全国  PVE 荣誉击杀  装备等级 成就点数 PVE */
        self.achievementDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"achievementPoints");
        self.itemlevelDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"itemlevel");
        self.pveScoreDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"pveScore");
        self.pvpscoreDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"pvpScore");
        self.KillsDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"totalHonorableKills");
    /*成就 服务器  PVE 荣誉击杀  装备等级 成就点数 PVE */
        self.achievementDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"achievementPoints");
        self.itemlevelDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"itemlevel");
        self.pveScoreDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"pveScore");
        self.pvpscoreDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"pvpScore");
        self.KillsDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"totalHonorableKills");
        [self getListContentForUrl];
        
        
}
    return self;
}

- (id)initWithReLoadingInfo:(NSDictionary *)info
{
    /*好友 全国 服务器  */
    self.friendOfRanking = KISDictionaryHaveKey(info, @"1");
    self.nationaOfRanking = KISDictionaryHaveKey(info, @"3");
    self.serverOfRanking = KISDictionaryHaveKey(info, @"2");
    
    /*成就 好友  PVE 荣誉击杀  装备等级 成就点数 PVE */
    self.achievementDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"achievementPoints");
    self.itemlevelDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"itemlevel");
    self.pveScoreDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"pveScore");
    self.pvpscoreDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"pvpScore");
    self.KillsDic1 = KISDictionaryHaveKey(self.friendOfRanking, @"totalHonorableKills");
    
    /*成就 全国  PVE 荣誉击杀  装备等级 成就点数 PVE */
    self.achievementDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"achievementPoints");
    self.itemlevelDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"itemlevel");
    self.pveScoreDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"pveScore");
    self.pvpscoreDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"pvpScore");
    self.KillsDic2 = KISDictionaryHaveKey(self.nationaOfRanking, @"totalHonorableKills");
    /*成就 服务器  PVE 荣誉击杀  装备等级 成就点数 PVE */
    self.achievementDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"achievementPoints");
    self.itemlevelDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"itemlevel");
    self.pveScoreDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"pveScore");
    self.pvpscoreDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"pvpScore");
    self.KillsDic3 = KISDictionaryHaveKey(self.serverOfRanking, @"totalHonorableKills");
    
    [self getListContentForUrl];
    return self;
}
-(void) getListContentForUrl
{
    /*  第一界面*/
    //获取所有的Value
    self.firstValueArray  = [[NSMutableArray alloc]init];
    self.firstRankArray   = [[NSMutableArray alloc]init];
    self.firstCompArray   = [[NSMutableArray alloc]init];
    
    self.secondValueArray = [[NSMutableArray alloc]init];
    self.secondRankArray  = [[NSMutableArray alloc]init];
    self.secondCompArray  = [[NSMutableArray alloc]init];
    
    self.thirdValueArray  = [[NSMutableArray alloc]init];
    self.thirdRankArray   = [[NSMutableArray alloc]init];
    self.thirdCompArray   = [[NSMutableArray alloc]init];

    [self addNSMutableArray:self.firstValueArray getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic1, @"value")
                        str:KISDictionaryHaveKey(self.KillsDic1, @"value")
                        str:KISDictionaryHaveKey(self.itemlevelDic1, @"value")
                        str:KISDictionaryHaveKey(self.achievementDic1, @"value")
                        str:KISDictionaryHaveKey(self.pvpscoreDic1, @"value")];
    //获取所有的排名
    [self addNSMutableArray:self.firstRankArray getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic1, @"rank")
                        str:KISDictionaryHaveKey(self.KillsDic1, @"rank")
                        str:KISDictionaryHaveKey(self.itemlevelDic1, @"rank")
                        str:KISDictionaryHaveKey(self.achievementDic1, @"rank")
                        str:KISDictionaryHaveKey(self.pvpscoreDic1, @"rank")];
    //所有的浮动
    [self addNSMutableArray:self.firstCompArray getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic1, @"compare")
                        str:KISDictionaryHaveKey(self.KillsDic1, @"compare")
                        str:KISDictionaryHaveKey(self.itemlevelDic1, @"compare")
                        str:KISDictionaryHaveKey(self.achievementDic1, @"compare")
                        str:KISDictionaryHaveKey(self.pvpscoreDic1, @"compare")];
    /*  第2界面*/
    
    //获取所有的Value
    [self addNSMutableArray:self.secondValueArray
            getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic2, @"value")
                        str:KISDictionaryHaveKey(self.KillsDic2, @"value")
                        str:KISDictionaryHaveKey(self.itemlevelDic2, @"value")
                        str:KISDictionaryHaveKey(self.achievementDic2, @"value")
                        str:KISDictionaryHaveKey(self.pvpscoreDic2, @"value")];
    //获取所有的排名
    [self addNSMutableArray:self.secondRankArray
            getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic2, @"rank")
                        str:KISDictionaryHaveKey(self.KillsDic2, @"rank")
                        str:KISDictionaryHaveKey(self.itemlevelDic2, @"rank")
                        str:KISDictionaryHaveKey(self.achievementDic2, @"rank")
                        str:KISDictionaryHaveKey(self.pvpscoreDic2, @"rank")];
    //所有的浮动
    [self addNSMutableArray:self.secondCompArray
            getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic2, @"compare")
                        str:KISDictionaryHaveKey(self.KillsDic2, @"compare")
                        str:KISDictionaryHaveKey(self.itemlevelDic2, @"compare")
                        str:KISDictionaryHaveKey(self.achievementDic2, @"compare")
                        str:KISDictionaryHaveKey(self.pvpscoreDic2, @"compare")];

    
    /*  第3界面*/
    
    //获取所有的Value
    [self addNSMutableArray:self.thirdValueArray getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic3, @"value")
                        str:KISDictionaryHaveKey(self.KillsDic3, @"value")
                        str:KISDictionaryHaveKey(self.itemlevelDic3, @"value")
                        str:KISDictionaryHaveKey(self.achievementDic3, @"value")
                        str:KISDictionaryHaveKey(self.pvpscoreDic3, @"value")];
    //获取所有的排名
    [self addNSMutableArray:self.thirdRankArray getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic3, @"rank")
                        str:KISDictionaryHaveKey(self.KillsDic3, @"rank")
                        str:KISDictionaryHaveKey(self.itemlevelDic3, @"rank")
                        str:KISDictionaryHaveKey(self.achievementDic3, @"rank")
                        str:KISDictionaryHaveKey(self.pvpscoreDic3, @"rank")];
    //所有的浮动
    [self addNSMutableArray:self.thirdCompArray getContentOfDic:KISDictionaryHaveKey(self.pveScoreDic3, @"compare")
                        str:KISDictionaryHaveKey(self.KillsDic3, @"compare")
                        str:KISDictionaryHaveKey(self.itemlevelDic3, @"compare")
                        str:KISDictionaryHaveKey(self.achievementDic3, @"compare")
                        str:KISDictionaryHaveKey(self.pvpscoreDic3, @"compare")];
}

-(id)addNSMutableArray:(NSMutableArray *)array getContentOfDic:(NSString *)str1 str:(NSString *)str2 str:(NSString *)str3 str:(NSString *)str4 str:(NSString *)str5
{
    [array addObject:str1];
    [array addObject:str2];
    [array addObject:str3];
    [array addObject:str4];
    [array addObject:str5];
    return array;
    
}


@end
