//
//  DSThumbMsgs.h
//  GameGroup
//
//  Created by 魏星 on 14-4-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSThumbMsgs : NSManagedObject

@property (nonatomic, retain) NSString * messageuuid;
@property (nonatomic, retain) NSString * msgContent;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSString * receiver;
@property (nonatomic, retain) NSString * sender;
@property (nonatomic, retain) NSString * senderimg;
@property (nonatomic, retain) NSString * senderNickname;
@property (nonatomic, retain) NSString * senderType;
@property (nonatomic, retain) NSDate * sendTime;
@property (nonatomic, retain) NSString * sendTimeStr;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * unRead;
@property (nonatomic, retain) NSString * sayHiType;
@property (nonatomic, retain) NSString * receiveTime;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * payLoad;

@end
