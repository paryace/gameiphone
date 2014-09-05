//
//  DSGroupMsgs.h
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSGroupMsgs : NSManagedObject

@property (nonatomic, retain) NSString * messageuuid;
@property (nonatomic, retain) NSString * msgContent;
@property (nonatomic, retain) NSString * msgFilesID;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * receiver;
@property (nonatomic, retain) NSString * receiveTime;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * senderNickname;
@property (nonatomic, retain) NSDate * senTime;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * teamPosition;
@property (nonatomic, retain) NSString * audioType;
@end
