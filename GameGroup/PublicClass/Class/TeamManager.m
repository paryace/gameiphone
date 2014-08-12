//
//  TeamManager.m
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//


#import "TeamManager.h"
static TeamManager *teamManager = NULL;
@implementation TeamManager
+ (TeamManager*)singleton
{
    @synchronized(self)
    {
		if (teamManager == nil)
		{
			teamManager = [[self alloc] init];
		}
	}
	return teamManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.teamCache = [NSMutableDictionary dictionaryWithCapacity:30];
        self.cacheids = [NSMutableArray array];
    }
    return self;
}

//提取组队信息（本地或者后台）
-(NSMutableDictionary*)getTeamInfo:(NSString*)gameId RoomId:(NSString*)roomId{
    NSMutableDictionary * teamDic = [self.teamCache objectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    if (teamDic) {
        return teamDic;
    }
    NSMutableDictionary * dict = [DataStoreManager queryDSTeamInfo:gameId RoomId:roomId];
    if (dict) {
        [self.teamCache setObject:dict forKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        return dict;
    }
    else{
        [self GETInfoWithNet:gameId RoomId:roomId reSuccess:^(id responseObject) {
            
        } reError:^(id error) {
            
        }];
    }
    return dict;
}

#pragma mark ---请求组队详情信息
-(void)GETInfoWithNet:(NSString*)gameId RoomId:(NSString*)roomId reSuccess:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure
{
    [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    if ([self.cacheids containsObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]]) {
        return;
    }
    [self.cacheids addObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    NSMutableDictionary *paramDict  = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:[GameCommon getNewStringWithId:roomId] forKey:@"roomId"];
    [paramDict setObject:[GameCommon getNewStringWithId:gameId] forKey:@"gameid"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"266" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults]objectForKey:kMyToken]:@"" forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict  success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (resuccess) {
            resuccess(responseObject);
        }
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [self saveTeamInfo:responseObject GameId:gameId Successcompletion:^(BOOL success, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:teamInfoUpload object:nil userInfo:responseObject];
        }];
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
        [self.cacheids removeObject:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
    }];
}
//保存组队信息
-(void)saveTeamInfo:(id)responseObject GameId:(NSString*)gameId{
    [self saveTeamInfo:responseObject GameId:gameId Successcompletion:nil];
}
//保存组队信息
-(void)saveTeamInfo:(id)responseObject GameId:(NSString*)gameId Successcompletion:(MRSaveCompletionHandler)successcompletion
{
    if (![responseObject isKindOfClass:[NSDictionary class]]) {
        return;
    }
    [DataStoreManager saveTeamInfoWithDict:responseObject GameId:gameId Successcompletion:^(BOOL success, NSError *error) {
        if (successcompletion) {
            successcompletion(success,error);
        }
    }];
}

//组队人数+1
-(void)addMemberCount:(NSString*)gameId RoomId:(NSString*)roomId
{
    [DataStoreManager addMemBerCount:gameId RoomId:roomId Successcompletion:^(BOOL success, NSError *error) {
        [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        NSDictionary * dic = @{@"gameId":gameId,@"roomId":roomId};
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:dic];
    }];
}


-(void)roomFull:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId UserId:(NSString*)userId{
    NSMutableDictionary * teamInfo = [[TeamManager singleton] getTeamInfo:[GameCommon getNewStringWithId:gameId] RoomId:[GameCommon getNewStringWithId:roomId]];
    if ([KISDictionaryHaveKey(teamInfo, @"memberCount") intValue]==[KISDictionaryHaveKey(teamInfo, @"maxVol") intValue]) {
        [MessageService groupNotAvailable:@"inTeamSystemMsg" Message:@"该房间已组满队员" GroupId:groupId gameid:gameId roomId:roomId team:@"teamchat" UserId:userId];
    }
}

//组队人数-1
-(void)removeMemberCount:(NSString*)gameId RoomId:(NSString*)roomId
{
    [DataStoreManager removeMemBerCount:gameId RoomId:roomId Successcompletion:^(BOOL success, NSError *error) {
        [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        NSDictionary * dic = @{@"gameId":gameId,@"roomId":roomId};
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:dic];
    }];
}
//更新组队人数(暂时没用到)
-(void)upDateTeamMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId MemberCount:(NSString*)memberCount
{
    [DataStoreManager updateMemBerCount:gameId RoomId:roomId MemberCount:memberCount Successcompletion:^(BOOL success, NSError *error) {
        NSDictionary * dic = @{@"gameid":gameId,@"roomId":roomId};
        [self.teamCache removeObjectForKey:[NSString stringWithFormat:@"%@%@",gameId,roomId]];
        [[NSNotificationCenter defaultCenter] postNotificationName:UpdateTeamMemberCount object:nil userInfo:dic];
    }];
}

//组队添加成员
-(void)saveMemberUserInfo:(NSDictionary*)memberUserInfo GroupId:(NSString*)groupId{
    //我加入组队成功
    if ([[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshTeamList_wx" object:nil userInfo:memberUserInfo];
    }
    [DataStoreManager saveMemberUserInfo:(NSMutableDictionary*)memberUserInfo GroupId:groupId Successcompletion:^(BOOL success, NSError *error) {
        [DataStoreManager saveTeamUser:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] groupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] TeamUsershipType:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"teamUsershipType")] DefaultState:@"0"];
        [self addMemberCount:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"gameid")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"roomId")]];
        [self roomFull:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"gameid")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"roomId")] GroupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] UserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")]];
        [[NSNotificationCenter defaultCenter]postNotificationName:kChangMemberList object:nil userInfo:memberUserInfo];
    }];
}

//删除组队成员
-(void)deleteMenberUserInfo:(NSDictionary*)memberUserInfo GroupId:(NSString*)groupId{
    [DataStoreManager deleteMenberUserInfo:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] UserId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] Successcompletion:^(BOOL success, NSError *error) {
        [DataStoreManager deleteTeamUser:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] groupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")]];
        [self removeMemberCount:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"gameid")] RoomId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"roomId")]];
        [[NSNotificationCenter defaultCenter]postNotificationName:kChangMemberList object:nil userInfo:memberUserInfo];
    }];
}
//收到确认或者取消消息，更新就位确认状态
-(void)updateTeamUserState:(NSDictionary*)memberUserInfo
{
    [DataStoreManager updateTeamUser:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"userid")] groupId:[GameCommon getNewStringWithId:KISDictionaryHaveKey(memberUserInfo, @"groupId")] State:[self getState:KISDictionaryHaveKey(memberUserInfo, @"type")] OnClickState:[self getOnClickState:KISDictionaryHaveKey(memberUserInfo, @"type")] Successcompletion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kChangInplaceState object:nil userInfo:memberUserInfo];
    }];
}

//收到发起就位确认消息，更新就位确认状态
-(void)updateTeamUserState:(NSString*)groupId UserId:(NSString*)userId MemberList:(NSArray*)memberList State:(NSString*)state
{
    if (![GameCommon isEmtity:userId]) {
        [DataStoreManager saveTeamUser2:[GameCommon getNewStringWithId:userId] groupId:groupId TeamUsershipType:@"0" State:state OnClickState:@"1"];
    }
    if ([memberList isKindOfClass:[NSArray class]]) {
        for (NSString * userid in memberList) {
            [DataStoreManager saveTeamUser2:[GameCommon getNewStringWithId:userid] groupId:groupId TeamUsershipType:@"1" State:state OnClickState:@"1"];
        }
    }
    [DataStoreManager updateTeamUser:groupId State:state OnClickState:@"1" Successcompletion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kSendChangInplaceState object:nil userInfo:nil];
    }];
}

//收到就位确认结果消息，初始化就位确认状态
-(void)resetTeamUserState:(NSString*)groupId
{
    [DataStoreManager resetTeamUser:groupId State:@"0" OnClickState:@"0" Successcompletion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter]postNotificationName:kResetChangInplaceState object:nil userInfo:nil];
    }];
}

-(NSString*)getState:(NSString*)result{
    if([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectOk"]){
        return @"2";
    }else if ([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectCancel"]) {
        return @"3";
    }
    return @"1";
}

-(NSString*)getOnClickState:(NSString*)result{
    if([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectOk"]){
        return @"2";
    }else if ([[GameCommon getNewStringWithId:result]isEqualToString:@"teamPreparedUserSelectCancel"]) {
        return @"3";
    }
    return @"1";
}

@end
