//
//  DSGroupList.h
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSGroupList : NSManagedObject

@property (nonatomic, retain) NSString * backgroundImg;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * groupName;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * currentMemberNum;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSString * maxMemberNum;

@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * distance;
@property (nonatomic, retain) NSString * experience;
@property (nonatomic, retain) NSString * gameRealm;
@property (nonatomic, retain) NSString * groupUsershipType;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) NSString * infoImg;
@property (nonatomic, retain) NSString * location;



@end
