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

@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * crossServer;
@property (nonatomic, retain) NSString * descriptions;
@property (nonatomic, retain) NSString * dismissDate;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * maxVol;
@property (nonatomic, retain) NSString * memberCount;
@property (nonatomic, retain) NSString * minLevelId;
@property (nonatomic, retain) NSString * minPower;
@property (nonatomic, retain) NSString * myMemberId;
@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * teamInfo;
@property (nonatomic, retain) NSString * teamName;
@property (nonatomic, retain) NSString * teamUsershipType;
@property (nonatomic, retain) NSString * typeId;
@property (nonatomic, retain) NSString * gameId;
@property (nonatomic, retain) NSString * characterId;
@property (nonatomic, retain) NSString * characterImg;
@property (nonatomic, retain) NSString * characterName;
@property (nonatomic, retain) NSString * memberInfo;
@property (nonatomic, retain) NSString * realm;
@property (nonatomic, retain) NSString * teamUserId;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * img;

@end
