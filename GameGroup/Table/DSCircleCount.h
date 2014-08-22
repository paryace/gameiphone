//
//  DSCircleCount.h
//  GameGroup
//
//  Created by 魏星 on 14-8-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSCircleCount : NSManagedObject

@property (nonatomic, assign) int  friendsCount;
@property (nonatomic, assign) int  mineCount;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * myImg;
@end
