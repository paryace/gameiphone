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

#import "DSOfflineZan.h"
@interface DataStoreManager : NSObject
+ (void)reSetMyAction:(BOOL)action;//重置我的激活状态
+ (BOOL)savedOtherMsgWithID:(NSString *)msgID;//角色动态消息是否存在
+ (BOOL)savedMsgWithID:(NSString*)msgId;//消息是否已存
+ (BOOL)savedNewsMsgWithID:(NSString*)msgId;//消息是否已存
+ (void)setDefaultDataBase:(NSString *)dataBaseName AndDefaultModel:(NSString *)modelName;

//ThumbMsg
+ (void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName andImg:(NSString*)img;
+ (void)storeThumbMsgUser:(NSString*)userid type:(NSString*)type;
+ (void)storeThumbMsgUser:(NSString*)userid nickName:(NSString*)nickName;//修改别名
+ (void)deleteAllThumbMsg;
+ (void)deleteThumbMsgWithSender:(NSString *)sender;
+ (void)refreshThumbMsgsAfterDeleteCommonMsg:(NSDictionary *)message ForUser:(NSString *)userid ifDel:(BOOL)del;
+ (NSArray *)qureyAllThumbMessagesWithType:(NSString *)type;

//聊天消息
+ (void)storeNewMsgs:(NSDictionary *)msg senderType:(NSString *)sendertype;
+ (void)storeMyPayloadmsg:(NSDictionary *)message;//保存我的动态消息
+ (void)storeMyMessage:(NSDictionary *)message;//保存我的聊天消息
+ (void)deleteMsgInCommentWithUUid:(NSString *)uuid;   //删除指定uuid的消息
+ (NSMutableArray *)qureyCommonMessagesWithUserID:(NSString *)userid FetchOffset:(NSInteger)integer;//根据userid分页查询
+ (NSMutableArray *)qureyAllCommonMessages:(NSString *)userid;
+ (NSString*)queryMessageStatusWithId:(NSString*)msgUUID;
+ (void)deleteAllCommonMsg;

+ (NSString *)queryMsgRemarkNameForUser:(NSString *)userid;
+ (NSString *)queryMsgHeadImageForUser:(NSString *)userid;
+ (void)blankMsgUnreadCountForUser:(NSString *)userid;
+ (NSArray *)queryUnreadCountForCommonMsg;
+ (void)deleteAllNewsMsgs;
+ (void)deleteMsgsWithSender:(NSString *)sender Type:(NSString *)senderType;    //删除指定发送者的所有消息




+ (void)refreshMessageStatusWithId:(NSString*)messageuuid status:(NSString*)status;
+ (NSArray *)qureyAllNewsMessage;
+ (NSArray *)queryAllReceivedHellos;
+ (NSDictionary *)qureyLastReceivedHello;

+(void)saveAllUserWithUserManagerList:(NSDictionary *)userInfo withshiptype:(NSString *)shiptype;
+(NSString *)queryFirstHeadImageForUser_userManager:(NSString *)userid;
+(NSMutableArray*)queryAllUserManagerWithOtherSortType:(NSString*)sorttype ascend:(BOOL)ascend;
+(NSMutableDictionary*)queryAllUserManagerWithshipType:(NSString *)shiptype;//取出好友或者关注或者粉丝
+(BOOL)ifHaveThisUserInUserManager:(NSString *)userId;//储存的用户中是否有这个用户的信息
+(NSString *)queryRemarkNameForUserManager:(NSString *)userid;
+(void)deleteAllUserWithUserId:(NSString*)userid;//删除userid是这个的
+(NSMutableArray*)queryAllFansWithOtherSortType:(NSString*)sorttype ascend:(BOOL)ascend;//取出粉丝
+(void)changshiptypeWithUserId:(NSString *)userId type:(NSString *)type;//好友关系改变的时候改变他的shiptype值
+(void)deleteAllUserWithShipType:(NSString*)shiptype;
+(BOOL)ifIsShipTypeWithUserId:(NSString*)userId type:(NSString*)shiptype;//判断关系（好友 关注 粉丝 自己 陌生人）
+(DSuser *)getInfoWithUserId:(NSString *)userId;//用ID获得表中的某个人的信息
//存储“好友”的关注人列表
+(NSMutableArray *)queryAttentionSections;
+(void)cleanIndexWithNameIndex:(NSString*)nameIndex withType:(NSString *)type;



+(void)saveDynamicAboutMe:(NSDictionary *)info;//储存朋友圈 与我相关信息
+(NSArray *)queryallDynamicAboutMeWithUnRead:(NSString *)UnRead;
+(void)deletecommentWithMsgId:(NSString*)msgid;
+(void)deleteAllcomment;


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
+(NSMutableDictionary *)queryOneFriendInfoWithUserName:(NSString *)userName;
+(NSString *)qureyUnreadForReceivedHellos;
+(void)blankReceivedHellosUnreadCount;

+(void)deleteAllHello;//清除打招呼列表


+(void)saveMyNewsWithData:(NSDictionary*)dataDic;
+(void)cleanMyNewsList;
+(void)saveFriendsNewsWithData:(NSDictionary*)dataDic;
+(void)cleanFriendsNewsList;


+(void)saveRecommendWithData:(NSDictionary*)dataDic;
+(void)updateRecommendStatus:(NSString *)theStatus ForPerson:(NSString *)userName;


+(void)saveOtherMsgsWithData:(NSDictionary*)userInfoDict;
+(NSArray *)queryAllOtherMsg;
+(void)cleanOtherMsg;
+(void)deleteOtherMsgWithUUID:(NSString *)uuid;

@end
