//
//  DataStoreManager.h
//  PetGroup
//
//  Created by Tolecen on 13-8-15.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DSThumbMsgs.h"
#import "DSCommonMsgs.h"
#import "DSNewsGameList.h"
#import "DSReceivedHellos.h"
#import "DSUnreadCount.h"
#import "DSNameIndex.h"
#import "DSBlackList.h"

#import "DSAttentionNameIndex.h"
#import "DSFansNameIndex.h"

#import "DSMyNewsList.h"
#import "DSFriendsNewsList.h"

#import "DSRecommendList.h"//好友推荐
#import "DSOtherMsgs.h"

#import "DSNewsMsgs.h"//新闻
#import "DSuser.h"
#import "DSThumbMsgs.h"
#import "DSTeamList.h"
#import "DSOfflineZan.h"
@interface DataStoreManager : NSObject

+ (void)reSetMyAction:(BOOL)action;//重置我的激活状态
+ (void)setDefaultDataBase:(NSString *)dataBaseName AndDefaultModel:(NSString *)modelName;
+(void)saveDSNewsMsgs:(NSDictionary*)msgDict SaveSuccess:(void (^)(NSDictionary *msgDic))block;//保存每日一闻消息
+(void)saveDSCommonMsg:(NSDictionary *)msg;
//ThumbMsg
+ (void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img;
+ (void)storeThumbMsgUser:(NSString*)userid type:(NSString*)type;
+ (void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName;//修改别名
+ (void)deleteAllThumbMsg;
+(void)deleteThumbMsgWithSender:(NSString *)sender Successcompletion:(MRSaveCompletionHandler)successcompletion;
+ (void)refreshThumbMsgsAfterDeleteCommonMsg:(NSDictionary *)message ForUser:(NSString *)userid ifDel:(BOOL)del;
+ (NSArray *)qureyAllThumbMessagesWithType:(NSString *)type;

//聊天消息
+ (void)storeNewMsgs:(NSDictionary *)msg senderType:(NSString *)sendertype;
+ (void)storeMyPayloadmsg:(NSDictionary *)message;//保存我的动态消息
+ (void)storeMyMessage:(NSDictionary *)message;//保存我的聊天消息
+ (void)deleteMsgInCommentWithUUid:(NSString *)uuid;   //删除指定uuid的消息
+ (NSMutableArray *)qureyCommonMessagesWithUserID:(NSString *)userid FetchOffset:(NSInteger)integer PageSize:(NSInteger)pageSize;//根据userid分页查询
+ (NSString*)queryMessageStatusWithId:(NSString*)msgUUID;
+ (void)deleteAllCommonMsg;

+ (NSString *)queryMsgRemarkNameForUser:(NSString *)userid;
+ (NSString *)queryMsgHeadImageForUser:(NSString *)userid;
+(void)blankMsgUnreadCountForUser:(NSString *)userid  Successcompletion:(MRSaveCompletionHandler)successcompletion;
+ (NSArray *)queryUnreadCountForCommonMsg;
+ (void)deleteAllNewsMsgs;
+ (void)deleteMsgsWithSender:(NSString *)sender Type:(NSString *)senderType;    //删除指定发送者的所有消息




+ (void)refreshMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status;
+ (NSArray *)qureyAllNewsMessage;
+(NSArray *)qureyAllNewsMessageWithGameid:(NSString *)gameid;
+(NSArray *)qureyFirstOfgame;
+(NSArray *)qureyAllFirstNewsMessage;

+ (NSArray *)queryAllReceivedHellos;
+ (NSDictionary *)qureyLastReceivedHello;

+(NSString *)queryFirstHeadImageForUser_userManager:(NSString *)userid;

+(BOOL)ifHaveThisUserInUserManager:(NSString *)userId;//储存的用户中是否有这个用户的信息


+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type;//好友关系改变的时候改变他的shiptype值

+(BOOL)ifIsShipTypeWithUserId:(NSString*)userId type:(NSString*)shiptype;//判断关系（好友 关注 粉丝 自己 陌生人）
+(DSuser *)getInfoWithUserId:(NSString *)userId;//用ID获得表中的某个人的信息
//存储“好友”的关注人列表

+(void)cleanIndexWithNameIndex:(NSString*)nameIndex withType:(NSString *)type;
+(void)deleteMemberFromListWithUserid:(NSString *)userid;


+(void)saveDynamicAboutMe:(NSDictionary *)info SaveSuccess:(void (^)(NSDictionary *msgDic))block;//储存朋友圈 与我相关信息
+(NSArray *)queryallDynamicAboutMeWithUnRead:(NSString *)UnRead;
+(void)deletecommentWithMsgId:(NSString*)msgid;
+(void)deleteAllcomment;
+(NSArray *)qureyAllNewsMessage;

//离线评论和赞
+(void)saveCommentsWithDic:(NSDictionary *)dic;
+(NSArray *)queryallcomments;
+(void)removeOfflineCommentsWithuuid:(NSString *)uuid;


+(void)saveOfflineZanWithDic:(NSDictionary *)dic;
+(NSArray *)queryallOfflineZan;
+(void)removeOfflineZanWithuuid:(NSString *)uuid;



//是否存在这个联系人
+(BOOL)ifHaveThisUser:(NSString *)userId;
+(BOOL)ifFriendHaveNicknameAboutUser:(NSString *)userId;
+(NSMutableArray *)querySections;
+(void)saveFriendRemarkName:(NSString*)remarkName userid:(NSString*)userid;//存备注名
//+ (void)cleanFriendList;//清空
+(NSString*)getMyNameIndex;

+(NSString *)queryNickNameForUser:(NSString *)userId;
+(NSString *)querySelfUserName;
+(void)updateFriendInfo:(NSDictionary *)userInfoDict ForUser:(NSString *)username;
+(NSString *)getOtherMessageTitleWithUUID:(NSString*)uuid type:(NSString*)type;//获取角色等 nickName
+(NSString *)queryRemarkNameForUser:(NSString *)userid;//获得别名
+(NSDictionary *)queryMyInfo;
+(NSString *)qureyUnreadForReceivedHellos;
+(void)blankReceivedHellosUnreadCount;

+(void)clearAllChatMessage:(void (^)(BOOL success))block;//清空消息
+(void)deleteAllHello:(MRSaveCompletionHandler)successcompletion;//清除打招呼列表


+(void)saveMyNewsWithData:(NSDictionary*)dataDic;
+(void)cleanMyNewsList;
+(void)saveFriendsNewsWithData:(NSDictionary*)dataDic;
+(void)cleanFriendsNewsList;


+(void)saveRecommendWithData:(NSArray*)recommendArr MsgInfo:(NSDictionary *)info SaveSuccess:(void (^)(NSDictionary *msgDic))block;
+(void)updateRecommendStatus:(NSString *)theStatus ForPerson:(NSString *)userName;


+(void)saveOtherMsgsWithData:(NSDictionary*)userInfoDict  SaveSuccess:(void (^)(NSDictionary *msgDic))block;
+(NSArray *)queryAllOtherMsg;
+(void)cleanOtherMsg;
+(void)deleteOtherMsgWithUUID:(NSString *)uuid;

+(NSMutableDictionary *)newQuerySections:(NSString*)shipType ShipType2:(NSString*)shipType2;//取出好友和关注的字母

+(void)newSaveAllUserWithUserManagerList:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype;

+(void)deleteSayHiMsgWithSenderAndSayType:(NSString *)senderType SayHiType:(NSString*)sayHiType;//根据senderType和sayHiType删除消息

+(BOOL)isHaveSayHiMsg:(NSString *)type;//是否有打招呼的消息


+(void)updateRecommendImgAndNickNameWithUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img;

+(void)changRecommendStateWithUserid:(NSString *)userid state:(NSString *)state;

+(id)queryDUser:(NSString*)userId;


//-----删除所有的normalchat显示消息消息
+(void)deleteThumbMsgsByMsgType:(NSString *)msgType;

//-----删除所有的normalchat历史记录消息
+(void)deleteCommonMsgsByMsgType:(NSString *)msgType;

+(DSThumbMsgs*)qureySayHiMsg:(NSString *)type;


+(void)changeMyMessage:(NSString *)messageuuid PayLoad:(NSString*)payload;

//黑名单操作

/*
 *-* 1. 保存拉入黑名单的用户
 *-* 2. 从黑名单中删除用户
 *-* 3. 删除黑名单中的所有用户
 *-* 4. 改变黑名单中的type值
 *-* 5. 取出所有的黑名单信息
 *-* 6. 取出所有黑名单用户的userid
 */


+(void)SaveBlackListWithDic:(NSDictionary *)dic WithType:(NSString *)type;
+(void)deletePersonFromBlackListWithUserid:(NSString *)userid;

+(void)deleteAllBlackList;
+(void)changeBlackListTypeWithUserid:(NSString *)userid;

+(NSMutableArray *)queryAllBlackListInfo;

+(NSArray *)queryAllBlackListUserid;

+ (BOOL)isBlack:(NSString*)userId;



//
+(void)saveDSCharacters:(NSDictionary *)characters UserId:(NSString*)userid;//保存角色列表

+(void)saveDSCharacters2:(NSArray *)characters UserId:(NSString*)userid successCompletion:(MRSaveCompletionHandler)successCompletion;

+(void)saveDSTitle:(NSDictionary *)titles;//保存头衔列表

+(void)saveDSTitle2:(NSArray *)titles successCompletion:(MRSaveCompletionHandler)successCompletion;

+(NSMutableArray *)queryCharacters:(NSString*)userId;//查找角色列表

+(NSMutableDictionary*)queryCharacter:(NSString*)characterId;//查询单个角色信息

+(NSMutableArray *)queryTitle:(NSString*)userId Hide:(NSString*)hide;//查找头衔列表

+(NSMutableDictionary *)getUserInfoFromDbByUserid:(NSString*)userid;//查询用户信息

+ (NSMutableArray *)qureyGroupMessagesGroupID:(NSString *)groupid FetchOffset:(NSInteger)integer PageSize:(NSInteger)pageSize;//查询群组历史消息

+(void)saveDSGroupMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block;//保存群组消息

+(void)deleteGroupMsgByMsgType:(NSString *)msgType;//删除所有的群组消息

+(void)storeMyNormalMessage:(NSDictionary *)message;//保存我发送的正常消息

+(void)storeMyGroupMessage:(NSDictionary *)message;//保存我发送的群消息

+(void)refreshGroupMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status;//刷新群组消息

+(void)changeMyGroupMessage:(NSString *)messageuuid PayLoad:(NSString*)payload;//更改群组发送图片的payload

+(void)deleteGroupMsgInCommentWithUUid:(NSString *)uuid;//删除某条群组消息

+(void)saveDSGroupList:(NSDictionary *)groupList;//保存群列表

+(void)updateGroupState:(NSString*)groupId GroupState:(NSString*)groupState GroupUserShipType:(NSString*)groupShipType;//更改群的可用状态

+(void)saveDSGroupUser:(NSDictionary *)groupUser GroupId:(NSString*)groupId;//保存群组的用户列表

+(NSMutableArray *)queryGroupUserList:(NSString*)groupId;//查找群用户列表

+(NSMutableArray *)queryGroupInfoList;//查找群列表

+(NSInteger)queryGroupCount;//查找我的群数量

+(NSMutableDictionary*)queryGroupInfoByGroupId:(NSString*)groupId;//查找单个群信息

+(void)deleteGroupMsgWithSenderAndSayType:(NSString *)groupId;//删除群消息记录

+(void)storeMyGroupThumbMessage:(NSDictionary *)message;//保存我发送的群组消息

+(void)blankGroupMsgUnreadCountForUser:(NSString *)groupId  Successcompletion:(MRSaveCompletionHandler)successcompletion;//清除群组的未读消息

+(void)blankGroupMsgUnreadCountForUser:(NSString *)groupId;

+ (NSMutableArray *)qureyCommonMessagesWithMsgType:(NSString *)msgType;//根据msgType查询消息

+(void)saveDSGroupApplyMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block;//保存申请假如群的消息

+(NSMutableArray*)queryDSGroupApplyMsg;//查询群通知消息

+(NSMutableArray*)queryDSGroupApplyMsgByMsgType:(NSString*)msgType;//根据msgType查询群通知消息

+(void)changedDSGroupApplyMsgWithGroupId:(NSString *)groupId name:(NSString *)name;//改变群名

+(void)changedDSGroupApplyMsgImgWithGroupId:(NSString *)groupId img:(NSString *)img;//改变群头像
+(void)updateMsgState:(NSString*)userid State:(NSString*)state MsgType:(NSString*)msgType GroupId:(NSString*)groupId;//改变消息状态

+(void)deleteJoinGroupApplication;//删除所有的群组消息

+(void)deleteMsgByGroupId:(NSString*)groupId;//删除该群的所有消息

+(void)blankMsgUnreadCountFormsgType:(NSString *)msgType;//根据msgType将未读的消息数量变为0

+(void)deleteJoinGroupApplicationByMsgType:(NSString*)msgType;//根据msgType删除群通知的消息

+(void)deleteThumbMsgWithGroupId:(NSString *)groupId;//根据groupId删除ThumbMsg消息表得记录

+(void)deleteJoinGroupApplicationWithMsgId:(NSString *)msgId;//根据msgid 删除单条记录(滑动删除)

//删除所有角色
+(void)deleteAllDSCharacters:(NSString*)userid;

//删除所有头衔
+(void)deleteAllDSTitle:(NSString*)userid;

//根据msgType和GroupId删除通知表的消息
+(void)deleteJoinGroupApplicationByMsgTypeAndGroupId:(NSString*)msgType GroupId:(NSString*)groupId;

//根据GroupId删除通知表的消息
+(void)deleteJoinGroupApplicationByGroupId:(NSString*)groupId;

//根据groupId 删除群信息
+(void)deleteGroupInfoByGoupId:(NSString*)groupId;

//删除所有的群聊历史记录
+(void)clearGroupChatHistroyMsg;
//更新群通知表的信息
-(void)upDataDSGroupApplyMsgByGroupId:(NSString*)groupId GroupName:(NSString*)groupName GroupBackgroundImg:(NSString*)backgroundImg;

//保存最后一条动态
+(void)saveDSlatestDynamic:(NSDictionary *)characters;

//查询最有一条动态消息
+(NSMutableDictionary *)queryLatestDynamic:(NSString*)userId;

//清空群组通知
+(void)clearJoinGroupApplicationMsg:(void (^)(BOOL success))block;

+(void)uploadStoreMsg:(NSDictionary *)msg;

//删除所有的群
+(void)deleteAllDSGroupList;

+(NSArray * )qAllThumbMessagesWithType:(NSString *)type;

+(NSMutableDictionary*)qSayHiMsg:(NSString *)type;

//保存群组聊天消息
+(void)storeNewGroupMsgs:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block;

//保存正常聊天的消息
+(void)storeNewNormalChatMsgs:(NSDictionary *)msg SaveSuccess:(void (^)(NSDictionary *msgDic))block;

+(void)saveNewNormalChatMsg:(NSArray *)msgs SaveSuccess:(void (^)(NSDictionary *msgDic))block;

+(void)saveNewGroupChatMsg:(NSArray *)msgs SaveSuccess:(void (^)(NSDictionary *msgDic))block;

+(void)deleteDSlatestDynamic:(NSString*)userid;

+(void)updateDSlatestDynamic:(NSString*)userid NickName:(NSString*)nickname Image:(NSString*)userimg Alias:(NSString*)alias;

//删除单个角色
+(void)deleteDSCharactersByCharactersId:(NSString*)charactersId;

//根据角色id删除头衔
+(void)deleteDSTitleByCharactersId:(NSString*)charactersId;

//根据Type删除头衔
+(void)deleteDSTitleByType:(NSString*)hide Userid:(NSString*)userid;

+(void)newSaveFriendList:(NSArray *)array withshiptype:(NSString *)nameindex;

+(void)newSaveFriendInfo:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype;


//更改位置
+(void)changGroupMsgLocation:(NSString*)groupId UserId:(NSString*)userid TeamPosition:(NSString*)teamPosition;

//保存组队通知消息
+(void)saveTeamNotifityMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block;

//请求组队申请消息数
+(NSInteger)getDSTeamNotificationMsgCount:(NSString*)groupId;

//更新组队申请消息数
+(void)updateDSTeamNotificationMsgCount:(NSString*)groupId;

//查询组队通知列表
+(NSMutableArray*)queDSTeamNotificationMsgByMsgTypeAndGroupId:(NSString*)msgType GroupId:(NSString*)groupId;

//更新组队通知状态
+(void)updateTeamNotifityMsgState:(NSString*)userid State:(NSString*)state GroupId:(NSString*)groupId;

//删除组队通知消息
+(void)deleteTeamNotifityMsgState;

//根据groupId删除组队通知消息
+(void)deleteTeamNotifityMsgStateByGroupId:(NSString*)groupId;

+(void)saveTeamThumbMsg:(NSDictionary *)msg  SaveSuccess:(void (^)(NSDictionary *msgDic))block;

//保存组队信息
+(void)saveTeamInfoWithDict:(NSDictionary *)dic GameId:(NSString*)gameId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//查询组队信息
+(NSMutableDictionary*)queryDSTeamInfo:(NSString*)gameId RoomId:(NSString*)roomId;

//组队人数+1
+(void)addMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//组队人数-1
+(void)removeMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//更新组队人数
+(void)updateMemBerCount:(NSString*)gameId RoomId:(NSString*)roomId MemberCount:(NSString*)memberCount Successcompletion:(MRSaveCompletionHandler)successcompletion;

//保存偏好信息
+(void)savePreferenceInfo:(NSArray*)preferenceInfo Successcompletion:(MRSaveCompletionHandler)successcompletion;

//保存组队创建者的信息
+(void)saveCreateTeamUserInfo:(NSMutableDictionary*)createTeamUserInfo Successcompletion:(MRSaveCompletionHandler)successcompletion;

//查询偏好列表
+(NSMutableArray*)queryPreferenceInfos;

//查新单个偏好信息（gameid，偏好id）
+(NSMutableDictionary*)queryPreferenceInfo:(NSString*)gameId PreferenceId:(NSString*)preferenceId;

//删除偏好
+(void)deletePreferenceInfo:(NSString*)gameId PreferenceId:(NSString*)preferenceId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//根据游戏id删除组队偏好
+(void)deletePreferenceInfoByCharacterId:(NSString*)characterId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//查询创建组队者的信息
+(NSMutableDictionary*)queryCreateTeamUserInfo:(NSString*)gameId TeamUserId:(NSString*)teamUserId;

//删除创建组队者的信息
+(void)deletePreferenceInfo:(NSString*)gameId TeamUserId:(NSString*)teamUserId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//保存组队偏好
+(void)savePreferenceMsg:(NSDictionary*)preferenceMsg SaveSuccess:(void (^)(NSDictionary *msgDic))block;

//获取组队偏好消息
+(NSMutableDictionary*)getPreferenceMsg:(NSString*)gameId PreferenceId:(NSString*)preferenceId;

//删除组队偏好消息
+(void)deletePreferenceMsg:(NSString*)gameId PreferenceId:(NSString*)preferenceId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//更新组队偏好消息
+(void)updatePreferenceMsg:(NSString*)gameId PreferenceId:(NSString*)preferenceId Successcompletion:(MRSaveCompletionHandler)successcompletion;

//查询未处理的申请加入组队消息数量
+(NSInteger)getTeamNotifityMsgCount:(NSString*)state GroupId:(NSString*)groupId;
@end
