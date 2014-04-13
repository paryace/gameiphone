//
//  DSuser.h
//  GameGroup
//
//  Created by 魏星 on 14-3-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSuser : NSManagedObject

@property (nonatomic, retain) NSString * userId;//id
@property (nonatomic, retain) NSString * userName;//手机号
@property (nonatomic, retain) NSString * nickName;//昵称
@property (nonatomic, retain) NSString * shiptype;//关系
@property (nonatomic, retain) NSString * age;//年龄
@property (nonatomic, retain) NSString * achievement;
@property (nonatomic, retain) NSString * achievementLevel;
@property (nonatomic, retain) NSNumber * action;//是否激活
@property (nonatomic, retain) NSString * backgroundImg;//背景图片
@property (nonatomic, retain) NSString * birthday;//生日
@property (nonatomic, retain) NSString * createTime;//创建时间
@property (nonatomic, retain) NSNumber * distance;//
@property (nonatomic, retain) NSString * gender;//性别
@property (nonatomic, retain) NSString * headImgID;//头像
@property (nonatomic, retain) NSString * hobby;//--
@property (nonatomic, retain) NSString * nameIndex;//
@property (nonatomic, retain) NSString * nameKey;//
@property (nonatomic, retain) NSString * phoneNumber;//手机号
@property (nonatomic, retain) NSString * refreshTime;//刷新时间
@property (nonatomic, retain) NSString * remarkName;//备注名
@property (nonatomic, retain) NSString * signature;//签名
@property (nonatomic, retain) NSString * starSign;//星座
@property (nonatomic, retain) NSString * superremark;//V认证描述
@property (nonatomic, retain) NSString * superstar;//V认证
@end




/*
 
 {
 1 =             (
 {
 achievementPoints = 5330;
 auth = 0;
 battlegroup = " ";
 classObj =                     {
 id = 1;
 mask = 1;
 name = "\U6218\U58eb";
 powerType = rage;
 };
 clazz = 1;
 content = " ";
 failedmsg = "";
 failednum = 0;
 filepath = "/home/appusr/characters/\U6851\U5fb7\U5170/\U5b89\U5ff5.zip";
 gender = 1;
 guild = "\U4e07\U5343";
 guildRealm = "\U6851\U5fb7\U5170";
 id = 232690;
 iscatch = 1;
 itemlevel = 527;
 itemlevelequipped = 527;
 lastModified = 1395996690000;
 level = 90;
 mountsnum = 34;
 name = "\U5b89\U5ff5";
 pveScore = 1373;
 pvpScore = 0;
 race = 22;
 raceObj =                     {
 id = 22;
 mask = 2097152;
 name = "\U72fc\U4eba";
 side = alliance;
 sidename = "\U8054\U76df";
 };
 rank = 4;
 realm = "\U6851\U5fb7\U5170";
 thumbnail = 174698;
 totalHonorableKills = 965;
 },
 {
 achievementPoints = 15010;
 auth = 0;
 battlegroup = " ";
 classObj =                     {
 id = 6;
 mask = 32;
 name = "\U6b7b\U4ea1\U9a91\U58eb";
 powerType = "runic-power";
 };
 clazz = 6;
 content = " ";
 failedmsg = "";
 failednum = 1;
 filepath = "/home/appusr/characters/\U7ea2\U9f99\U5973\U738b/\U6267\U91d1\U543e.zip";
 gender = 0;
 guild = Forever;
 guildRealm = "\U7ea2\U9f99\U5973\U738b";
 id = 4452574;
 iscatch = 1;
 itemlevel = 513;
 itemlevelequipped = 513;
 lastModified = 1397363365000;
 level = 90;
 mountsnum = 129;
 name = "\U6267\U91d1\U543e";
 pveScore = 0;
 pvpScore = 0;
 race = 10;
 raceObj =                     {
 id = 10;
 mask = 512;
 name = "\U8840\U7cbe\U7075";
 side = horde;
 sidename = "\U90e8\U843d";
 };
 rank = 8;
 realm = "\U7ea2\U9f99\U5973\U738b";
 thumbnail = 2213951;
 totalHonorableKills = 1391;
 }
 );
 };
 dynamicmsg =         {
 alias = " ";
 commentnum = 0;
 createDate = 1397367230000;
 id = 159619;
 img = "2561132,";
 msg = "\U5206\U4eab\U6267\U91d1\U543e\U7684\U5934\U8854\Uff1a\U96f7\U9706\U4e4b\U6012\Uff0c\U9010\U98ce\U8005\U7684\U795d\U798f\U4e4b\U5251";
 nickname = "\U8d25\U7c7b\U9a91\U58eb";
 rarenum = 0;
 superstar = 0;
 thumb = 2561133;
 title = " ";
 titleObj =             {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954267000;
 hide = 0;
 id = 4973074;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 2;
 titleObj =                 {
 createDate = 1389340897000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 111;
 img = 501;
 rank = 1;
 ranktype = "1,2,3";
 rankvaltype = itemlevel;
 rarememo = "48.89%";
 rarenum = 6;
 remark = "\U867d\U7136\U6c38\U6052\U5c9b\U5904\U5904\U5145\U6ee1\U5371\U9669\Uff0c\U4f46\U4e5f\U6709\U5f88\U591a\U4e0d\U9519\U7684\U673a\U9047\Uff0c\U5bcc\U8d35\U9669\U4e2d\U6c42\U554a\Uff01";
 remarkDetail = "\U83b7\U53d6\U6761\U4ef6\Uff1a
 \n\U83b7\U53d6\U88c5\U5907\U5230\U8fbe496\U7ea7\U522b
 \n
 \n\U4e0b\U4e00\U5934\U8854\Uff1a
 \n\U88c5\U5907\U7b49\U7ea7\U5230\U8fbe561";
 simpletitle = "\U7d2b\U88c5\U5f00\U59cb!";
 sortnum = 1;
 title = "\U7d2b\U88c5\U5f00\U59cb!";
 titlekey = "wow_itemlevel_496";
 titletype = "\U88c5\U5907\U7b49\U7ea7";
 };
 titleid = 111;
 userid = 10000203;
 userimg = " ";
 };
 type = 3;
 urlLink = " ";
 userid = 10000203;
 userimg = "198834,195642,";
 username = 15210536307;
 zan = 0;
 zannum = 1;
 };
 fansnum = 250;
 shiptype = 1;
 title =         (
 {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954267000;
 hide = 0;
 id = 4973074;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 2;
 titleObj =                 {
 createDate = 1389340897000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 111;
 img = 501;
 rank = 1;
 ranktype = "1,2,3";
 rankvaltype = itemlevel;
 rarememo = "48.89%";
 rarenum = 6;
 remark = "\U867d\U7136\U6c38\U6052\U5c9b\U5904\U5904\U5145\U6ee1\U5371\U9669\Uff0c\U4f46\U4e5f\U6709\U5f88\U591a\U4e0d\U9519\U7684\U673a\U9047\Uff0c\U5bcc\U8d35\U9669\U4e2d\U6c42\U554a\Uff01";
 remarkDetail = "\U83b7\U53d6\U6761\U4ef6\Uff1a
 \n\U83b7\U53d6\U88c5\U5907\U5230\U8fbe496\U7ea7\U522b
 \n
 \n\U4e0b\U4e00\U5934\U8854\Uff1a
 \n\U88c5\U5907\U7b49\U7ea7\U5230\U8fbe561";
 simpletitle = "\U7d2b\U88c5\U5f00\U59cb!";
 sortnum = 1;
 title = "\U7d2b\U88c5\U5f00\U59cb!";
 titlekey = "wow_itemlevel_496";
 titletype = "\U88c5\U5907\U7b49\U7ea7";
 };
 titleid = 111;
 userid = 10000203;
 userimg = " ";
 },
 {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954268000;
 hide = 0;
 id = 4973076;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 3;
 titleObj =                 {
 createDate = 1387853793000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 2;
 img = 157;
 rank = 0;
 ranktype = " ";
 rankvaltype = " ";
 rarememo = "23.32%";
 rarenum = 5;
 remark = "\U966a\U4f34\U7740\U9b54\U517d\U4e16\U754c\U4e00\U8d77\U8d70\U8fc7\U591a\U5e74\U8f89\U714c\U5386\U53f2\U7684\U4f60, \U53ef\U4ee5\U81ea\U8c6a\U7684\U5927\U558a\U51fa\U53e3:\"\U6211\U662f\U9b54\U517d\U73a9\U5bb6!\"";
 remarkDetail = "\U57282008\U5e7412-10\U65e5\Uff08\U6210\U5c31\U7cfb\U7edf\U4e0a\U7ebf\U7b2c\U4e00\U5929\Uff09\U83b7\U53d670\U7ea7\U6210\U5c31\U7684\U73a9\U5bb6,\U53ef\U4ee5\U83b7\U5f97\U6b64\U5934\U8854";
 simpletitle = "\U9b54\U517d\U4e16\U754c\U8001\U73a9\U5bb6";
 sortnum = 1;
 title = "\U9b54\U517d\U4e16\U754c\U8001\U73a9\U5bb6";
 titlekey = "wow_oldplayer";
 titletype = "\U9b54\U517d\U4e16\U754c\U8001\U73a9\U5bb6";
 };
 titleid = 2;
 userid = 10000203;
 userimg = " ";
 },
 {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954268000;
 hide = 0;
 id = 4973075;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 4;
 titleObj =                 {
 createDate = 1357288980000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 50;
 img = 152;
 rank = 1;
 ranktype = "1,2,3";
 rankvaltype = mountsnum;
 rarememo = "31.73%";
 rarenum = 6;
 remark = "\U83b7\U5f97100\U79cd\U5750\U9a91";
 remarkDetail = "\U83b7\U53d6\U6761\U4ef6:\U83b7\U5f97100\U79cd\U5750\U9a91
 \n
 \n\U4e0b\U4e00\U5934\U8854:\U83b7\U5f97200\U79cd\U5750\U9a91";
 simpletitle = "\U5750\U9a91\U6210\U5806";
 sortnum = 1;
 title = "\U5750\U9a91\U6210\U5806";
 titlekey = "wow_mounts_100";
 titletype = "\U5750\U9a91\U6570\U91cf";
 };
 titleid = 50;
 userid = 10000203;
 userimg = " ";
 },
 {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954268000;
 hide = 0;
 id = 4973077;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 5;
 titleObj =                 {
 createDate = 1388826466000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 73;
 img = 454;
 rank = 0;
 ranktype = " ";
 rankvaltype = " ";
 rarememo = "13.07%";
 rarenum = 6;
 remark = "5.4\U7248\U672c\U5b8c\U6210\U5ea6[10%]
 \n\U2611\U91ce\U5916\U9996\U9886";
 remarkDetail = "\U83b7\U53d6\U6761\U4ef6:
 \n\U51fb\U8d25\U6c38\U6052\U5c9b\U7684\U91ce\U725b\U4eba\U706b\U795e\U65a1\U8033\U6735\U65af
 \n
 \n\U4e0b\U4e00\U5934\U8854:
 \n\U5b8c\U6210\U573a\U666f\U6218\U5f79:\U6f58\U8fbe\U5229\U4e9a\U7684\U9ed1\U6697\U4e4b\U5fc3,\U5e76\U51fb\U8d25\U51b3\U6218\U5965\U683c\U745e\U739b\U7684\U52a0\U5c14\U9c81\U4ec0\U00b7\U5730\U72f1\U5486\U54ee\Uff08\U666e\U901a\U96be\U5ea6)";
 simpletitle = "\U6f58\U8fbe\U5229\U4e9a\U7684\U65c5\U4eba";
 sortnum = 1;
 title = "\U6f58\U8fbe\U5229\U4e9a\U7684\U65c5\U4eba";
 titlekey = "wow_pandaliya_lr";
 titletype = " ";
 };
 titleid = 73;
 userid = 10000203;
 userimg = " ";
 },
 {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954284000;
 hide = 0;
 id = 4973078;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 6;
 titleObj =                 {
 createDate = 1388826466000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 57;
 img = 437;
 rank = 1;
 ranktype = "1,2,3";
 rankvaltype = qunxinzhinu;
 
 rarememo = "4.63%";
 rarenum = 3;
 remark = "\U592a\U9633\U4e4b\U4e95\U7684\U80fd\U91cf\U6d41\U904d\U7d22\U5229\U8fbe\U5c14\U7684\U5f13\U8eab, \U800c\U5c04\U51fa\U7684\U661f\U5149\U4eff\U4f5b\U5728\U8ffd\U5fc6\U90a3\U4e2a\U9065\U8fdc\U7684\U5e74\U4ee3.";
 remarkDetail = "\U57282010-8-31(\U5deb\U5996\U738b\U5f00\U653e)\U4e4b\U524d\U83b7\U5f97\U7d22\U5229\U8fbe\U5c14\Uff0c\U7fa4\U661f\U4e4b\U6012";
 simpletitle = "\U771f\U00b7\U7d22\U5229\U8fbe\U5c14\Uff0c\U7fa4\U661f\U4e4b\U6012";
 sortnum = 1;
 title = "\U771f\U00b7\U7d22\U5229\U8fbe\U5c14\Uff0c\U7fa4\U661f\U4e4b\U6012";
 titlekey = " ";
 titletype = "\U83b7\U53d6\U65f6\U95f4";
 };
 titleid = 57;
 userid = 10000203;
 userimg = " ";
 },
 {
 characterid = 4452574;
 charactername = "\U6267\U91d1\U543e";
 clazz = 6;
 gameid = 1;
 hasDate = 1396954284000;
 hide = 0;
 id = 4973079;
 realm = "\U7ea2\U9f99\U5973\U738b";
 sortnum = 7;
 titleObj =                 {
 createDate = 1388826466000;
 evolution = 0;
 gameid = 1;
 icon = " ";
 id = 66;
 img = 446;
 rank = 1;
 ranktype = "1,2,3";
 rankvaltype = fengjian;
 rarememo = "21.23%";
 rarenum = 4;
 remark = "\U4ee3\U8868\U7740\U8363\U8000\U4e0e\U8d23\U4efb\U4f20\U8bf4\U6b66\U5668 - \"\U82f1\U96c4, \U613f\U4f60\U62e5\U6709\U4e00\U4efd\U65e0\U6094\U7684\U7231\U60c5!\"";
 remarkDetail = "\U83b7\U5f97\U6761\U4ef6:
 \n\U96f7\U9706\U4e4b\U6012\Uff0c\U9010\U98ce\U8005\U7684\U795d\U798f\U4e4b\U5251";
 simpletitle = "\U96f7\U9706\U4e4b\U6012\Uff0c\U9010\U98ce\U8005\U7684\U795d\U798f\U4e4b\U5251";
 sortnum = 1;
 title = "\U96f7\U9706\U4e4b\U6012\Uff0c\U9010\U98ce\U8005\U7684\U795d\U798f\U4e4b\U5251";
 titlekey = " ";
 titletype = "\U83b7\U53d6\U65f6\U95f4";
 };
 titleid = 66;
 userid = 10000203;
 userimg = " ";
 }
 );
 user =         {
 active = 2;
 age = 23;
 alias = " ";
 appType = " ";
 backgroundImg = " ";
 birthdate = 19900929;
 city = " ";
 constellation = "\U5929\U79e4\U5ea7";
 createTime = 1393748067000;
 deviceToken = " ";
 distance = "25.982621273733216";
 email = "1819253992@qq.com";
 fan = 250;
 gender = 1;
 hobby = " ";
 id = 10000203;
 ifFraudulent = " ";
 img = "198834,195642,";
 lastForbiddenTime = " ";
 latitude = "39.982903";
 longitude = "116.304222";
 modTime = 1397367665378;
 nickname = "\U8d25\U7c7b\U9a91\U58eb";
 password = "lueSGJZetyySpUndWjMBEg==";
 phoneNumber = " ";
 rarenum = 0;
 realname = " ";
 remark = "\U6211\U5728\U8fd9\U7b49\U4f60";
 signature = "........................................";
 state = 0;
 superremark = " ";
 superstar = 0;
 title = " ";
 updateUserLocationDate = 1397375967288;
 username = 15210536307;
 };
 zannum = 16;
 };

 
 */