//
//  DSThumbMsgs.h
//  GameGroup
//
//  Created by Shen Yanping on 14-2-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSThumbMsgs : NSManagedObject

@property (nonatomic, copy) NSString * messageuuid;
@property (nonatomic, copy) NSString * msgContent;
@property (nonatomic, copy) NSString * msgType;
@property (nonatomic, copy) NSString * receiver;
@property (nonatomic, copy) NSString * sender;
@property (nonatomic, copy) NSString * senderimg;
@property (nonatomic, copy) NSString * senderNickname;
@property (nonatomic, copy) NSString * senderType;
@property (nonatomic, retain) NSDate * sendTime;
@property (nonatomic, copy) NSString * sendTimeStr;
@property (nonatomic, copy) NSString * unRead;
@property (nonatomic, copy) NSString * status;
@property (nonatomic, copy) NSString * sayHiType;
@end
