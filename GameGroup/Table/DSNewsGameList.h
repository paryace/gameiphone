//
//  DSNewsGameList.h
//  GameGroup
//
//  Created by 魏星 on 14-5-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSNewsGameList : NSManagedObject

@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * mytitle;
@property (nonatomic, retain) NSString * time;
@end
