//
//  DSPrepared.h
//  GameGroup
//
//  Created by Apple on 14-8-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSPrepared : NSManagedObject

@property (nonatomic, retain) NSString * fromId;
@property (nonatomic, retain) NSString * toId;
@property (nonatomic, retain) NSString * msgId;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * msgTime;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSString * payload;

@end
