//
//  GameCommon.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameCommon : NSObject

@property(nonatomic, assign) BOOL haveNet;//是否有网
@property(nonatomic, strong) NSArray* emoji_array; //用到de表情
@property(nonatomic, strong) NSMutableDictionary* emoji_dict; //用到de表情字典
@property(nonatomic, strong) NSMutableDictionary* wow_realms;//英雄联盟服务器 注册、搜索时用
@property(nonatomic, strong) NSMutableArray* wow_clazzs;//职业

@property(nonatomic, strong) NSString* deviceToken;

+ (NSString*)getNewStringWithId:(id)oldString;//剔除json里的空格字段

//+(NSString *)isNewOrOldWithImage:(NSString *)imgStr width:(int)width hieght:(int)hieght a:(NSString *)a;//测试 用于切图


+ (GameCommon*)shareGameCommon;
+ (float)diffHeight:(UIViewController *)controller;
//+(NSString *)isNewOrOldWithImage:(NSString *)imgStr;
-(NSString *)convertChineseToPinYin:(NSString *)chineseName;
-(NSUInteger) unicodeLengthOfString: (NSString *) text;
-(NSUInteger) asciiLengthOfString: (NSString *) text;
- (BOOL)isValidateEmail:(NSString *)email;

-(NSString*) uuid;
- (NSMutableDictionary*)getNetCommomDic;

+(NSString *)getCurrentTime;
+(NSString *)getWeakDay:(NSDate *)datetime;
+(NSString *)CurrentTime:(NSString *)currentTime AndMessageTime:(NSString *)messageTime;
//获取各种时间格式
+(NSString *)getTimeWithChatStyle:(NSString *)currentTime AndMessageTime:(NSString *)messageTime; //聊天界面 Label上显示的格式
+(NSString *)getTimeWithMessageTime:(NSString*)messageTime;

- (NSString*)getDataWithTimeInterval:(NSString*)timeInterval;
+ (NSString*)getTimeAndDistWithTime:(NSString*)time Dis:(NSString*)distrance;

+(UIColor*)getAchievementColorWithLevel:(NSUInteger)level;

+(NSString *)dynamicListCurrentTime:(NSString *)currentTime AndMessageTime:(NSString *)messageTime;
+(NSString *)DynamicCurrentTime:(NSString *)currentTime AndMessageTime:(NSString *)messageTime;

+ (NSString*)getHeardImgId:(NSString*)img;

//根据gameid 返回open接口的游戏信息
+(NSString *)putoutgameIconWithGameId:(NSString *)gameid;

//是否有网
//+ (BOOL)testConnection;

-(void)displayTabbarNotification;

- (void)fansCountChanged:(BOOL)addOne;

+ (void)loginOut;
+ (void)cleanLastData;

+(BOOL)isEmtity:(NSString*)str;
+(NSArray*)getGameids:(NSString*)gameids;
+(NSURL*)getImageUrl:(NSString*)imageid;
@end
