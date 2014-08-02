//
//  DSMemberUserInfo.h
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSMemberUserInfo : NSManagedObject

@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * joinDate;
@property (nonatomic, retain) NSString * leaveDate;
@property (nonatomic, retain) NSString * memberId;
@property (nonatomic, retain) NSString * memberTeamUserId;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * teamUsershipType;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * groupId;

@property (nonatomic, retain) NSString * constId;
@property (nonatomic, retain) NSString * mask;
@property (nonatomic, retain) NSString * positionType;
@property (nonatomic, retain) NSString * positionValue;

@end
