//
//  DSTeamList.h
//  GameGroup
//
//  Created by 魏星 on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSTeamList : NSManagedObject

@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * teamInfo;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * characterName;
@property (nonatomic, retain) NSString * characterId;
@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSString * memberInfo;
@property (nonatomic, retain) NSString * realm;
@property (nonatomic, retain) NSString * teamUserId;
@property (nonatomic, retain) NSString * tdescription;
@property (nonatomic, retain) NSString * constId;
@property (nonatomic, retain) NSString * mask;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * typeValue;
@property (nonatomic, retain) NSString * teamUsershipType;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * typeId;

@end
