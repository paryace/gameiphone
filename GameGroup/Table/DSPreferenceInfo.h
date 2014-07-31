//
//  DSPreferenceInfo.h
//  GameGroup
//
//  Created by Apple on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSPreferenceInfo : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * isOpen;
@property (nonatomic, retain) NSString * keyword;
@property (nonatomic, retain) NSString * matchCount;
@property (nonatomic, retain) NSString * preferenceId;
@property (nonatomic, retain) NSString * teamUserId;
@property (nonatomic, retain) NSString * typeId;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * gameId;
@property (nonatomic, retain) NSString * characterId;

@end
