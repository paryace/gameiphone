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

#import "DSReceivedHellos.h"
#import "DSUnreadCount.h"
#import "DSNameIndex.h"

#import "DSAttentionNameIndex.h"

#import "DSFansNameIndex.h"

#import "DSMyNewsList.h"
#import "DSFriendsNewsList.h"

#import "DSRecommendList.h"//好友推荐
#import "DSOtherMsgs.h"

#import "DSNewsMsgs.h"//新闻
#import "DSuser.h"

@interface DataStoreManager : NSObject
+ (void)reSetMyAction:(BOOL)action;//重置我的激活状态
+ (BOOL)savedOtherMsgWithID:(NSString *)msgID;//角色动态消息是否存在
+ (BOOL)savedMsgWithID:(NSString*)msgId;//消息是否已存
+ (BOOL)savedNewsMsgWithID:(NSString*)msgId;//消息是否已存
+(void)setDefaultDataBase:(NSString *)dataBaseName AndDefaultModel:(NSString *)modelName;
+(void)storeNewMsgs:(NSDictionary *)msg senderType:(NSString *)sendertype;
+(void)storeMyPayloadmsg:(NSDictionary *)message;//保存我的动态消息
+(void)storeMyMessage:(NSDictionary *)message;//保存我的聊天消息
+(void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img;
+(void)storeThumbMsgUser:(NSString*)userid type:(NSString*)type;
+(void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName;//修改别名
+(NSString *)queryMsgRemarkNameForUser:(NSString *)userid;
+(NSString *)queryMsgHeadImageForUser:(NSString *)userid;
+(void)blankMsgUnreadCountForUser:(NSString *)userid;
+(NSArray *)queryUnreadCountForCommonMsg;
+(void)deleteAllNewsMsgs;
+(void)deleteAllThumbMsg;
+(void)deleteThumbMsgWithSender:(NSString *)sender;
+(void)deleteMsgsWithSender:(NSString *)sender Type:(NSString *)senderType;
+ (NSMutableArray *)qureyCommonMessagesWithUserID:(NSString *)userid FetchOffset:(NSInteger)integer;//根据userid分页查询
+(NSMutableArray *)qureyAllCommonMessages:(NSString *)userid;
+(NSString*)queryMessageStatusWithId:(NSString*)msgUUID;
+(void)deleteCommonMsg:(NSString *)content Time:(NSString *)theTime;
+(void)deleteAllCommonMsg;
+(void)refreshThumbMsgsAfterDeleteCommonMsg:(NSDictionary *)message ForUser:(NSString *)userid ifDel:(BOOL)del;
+(NSArray *)qureyAllThumbMessagesWithType:(NSString *)type;
+(void)refreshMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status;
+(NSArray *)qureyAllNewsMessage;
+(NSArray *)queryAllReceivedHellos;
+(NSDictionary *)qureyLastReceivedHello;

//储存所有看到过的用户信息
+(void)saveAllUserWithUserManagerList:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype;
+(NSString *)queryFirstHeadImageForUser_userManager:(NSString *)userid;
+(NSMutableArray*)queryAllUserManagerWithOtherSortType:(NSString*)sorttype ascend:(BOOL)ascend;
+(NSMutableDictionary*)queryAllUserManagerWithshipType:(NSString *)shiptype;//取出好友或者关注或者粉丝
+(BOOL)ifHaveThisUserInUserManager:(NSString *)userId;//储存的用户中是否有这个用户的信息
+(NSString *)queryRemarkNameForUserManager:(NSString *)userid;
+(void)deleteAllUserWithUserId:(NSString*)userid;//删除userid是这个的
+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type;//更改关系
+(void)deleteAllUserWithShipType:(NSString*)shiptype;

//存储“好友”的关注人列表
+(NSMutableArray *)queryAttentionSections;
+(BOOL)ifIsAttentionWithUserId:(NSString*)userid;
+(void)cleanAttentionList;//清空


//好友
//是否存在这个联系人
+(BOOL)ifHaveThisUser:(NSString *)userId;
+(BOOL)ifFriendHaveNicknameAboutUser:(NSString *)userId;
+(NSMutableArray *)querySections;
+(void)saveFriendRemarkName:(NSString*)remarkName userid:(NSString*)userid;//存备注名
//+ (void)cleanFriendList;//清空
+(NSString*)getMyNameIndex;

+(NSString *)queryNickNameForUser:(NSString *)userName;
+(NSString *)querySelfUserName;
+(void)updateFriendInfo:(NSDictionary *)userInfoDict ForUser:(NSString *)username;
+(NSString *)getOtherMessageTitleWithUUID:(NSString*)uuid type:(NSString*)type;//获取角色等 nickName
+(NSString *)queryRemarkNameForUser:(NSString *)userid;//获得别名

+(NSDictionary *)queryMyInfo;
+(NSMutableDictionary *)queryOneFriendInfoWithUserName:(NSString *)userName;
+(NSString *)qureyUnreadForReceivedHellos;
+(void)blankReceivedHellosUnreadCount;

+(void)deleteAllHello;//清除打招呼列表

//动态
+(void)saveMyNewsWithData:(NSDictionary*)dataDic;
+(void)cleanMyNewsList;
+(void)saveFriendsNewsWithData:(NSDictionary*)dataDic;
+(void)cleanFriendsNewsList;

//好友推荐
+(void)saveRecommendWithData:(NSDictionary*)dataDic;
+(void)updateRecommendStatus:(NSString *)theStatus ForPerson:(NSString *)userName;

//角色、头衔、战斗力消息
+(void)saveOtherMsgsWithData:(NSDictionary*)userInfoDict;
+(NSArray *)queryAllOtherMsg;
+(void)cleanOtherMsg;
+(void)deleteOtherMsgWithUUID:(NSString *)uuid;

@end
