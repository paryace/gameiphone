//
//  DSTeamUser.h
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSTeamUser : NSManagedObject

@property (nonatomic, retain) NSString * roomId;
@property (nonatomic, retain) NSString * userid;

@end
