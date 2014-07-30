//
//  DSCreateTeamUserInfo.h
//  GameGroup
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSCreateTeamUserInfo : NSManagedObject

@property (nonatomic, retain) NSString * characterId;
@property (nonatomic, retain) NSString * characterImg;
@property (nonatomic, retain) NSString * characterName;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * memberInfo;
@property (nonatomic, retain) NSString * realm;
@property (nonatomic, retain) NSString * teamUserId;
@property (nonatomic, retain) NSString * userid;

@end
