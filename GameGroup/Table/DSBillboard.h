//
//  DSBillboard.h
//  GameGroup
//
//  Created by Apple on 14-6-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSBillboard : NSManagedObject

@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * applicationId;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * backgroundImg;
@property (nonatomic, retain) NSString * msg;
@property (nonatomic, retain) NSString * userImg;
@property (nonatomic, retain) NSString * msgId;
@property (nonatomic, retain) NSString * msgType;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * senTime;
@property (nonatomic, retain) NSString * receiveTime;
@property (nonatomic, retain) NSString * payload;
@property (nonatomic, retain) NSString * msgContent;
@property (nonatomic, retain) NSString * senderId;
@property (nonatomic, retain) NSString * billboard;
@property (nonatomic, retain) NSString * billboardId;
@property (nonatomic, retain) NSString * createDate;

@end
