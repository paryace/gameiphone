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

@end
