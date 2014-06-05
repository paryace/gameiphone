//
//  DSBlackList.h
//  GameGroup
//
//  Created by 魏星 on 14-6-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSBlackList : NSManagedObject

@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * headimg;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) NSString * type;

@end
