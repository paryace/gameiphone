//
//  DSPreferenceMsg.h
//  GameGroup
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSPreferenceMsg : NSManagedObject

@property (nonatomic, retain) NSString * msgId;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSString * toId;
@property (nonatomic, retain) NSDate * msgTime;
@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * userCount;
@property (nonatomic, retain) NSString * roomCount;
@property (nonatomic, retain) NSString * characterName;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * preferenceId;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * msgCount;

@end
