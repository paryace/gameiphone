//
//  DSTeamNotificationMsg.h
//  GameGroup
//
//  Created by Apple on 14-7-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSTeamNotificationMsg : NSManagedObject

@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSString * toId;
@property (nonatomic, retain) NSString * msgId;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSDate * msgTime;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * characterName;
@property (nonatomic, retain) NSString * realm;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * characterId;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * value1;
@property (nonatomic, retain) NSString * value2;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * userImg;
@property (nonatomic, retain) NSString * receiveTime;

@end
