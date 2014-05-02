//
//  DSOfflineComments.h
//  GameGroup
//
//  Created by 魏星 on 14-5-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSOfflineComments : NSManagedObject

@property (nonatomic, retain) NSString * msgId;
@property (nonatomic, retain) NSString * destCommentId;
@property (nonatomic, retain) NSString * comments;
@property (nonatomic, retain) NSString * destUserid;
@property (nonatomic, retain) NSString *uuid;
@end
