//
//  DSTitle.h
//  GameGroup
//
//  Created by Marss on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSTitle : NSManagedObject

@property (nonatomic, retain) NSString * characterid;
@property (nonatomic, retain) NSString * charactername;
@property (nonatomic, retain) NSString * clazz;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * hasDate;
@property (nonatomic, retain) NSString * hide;
@property (nonatomic, retain) NSString * titleId;
@property (nonatomic, retain) NSString * realm;
@property (nonatomic, retain) NSString * sortnum;
@property (nonatomic, retain) NSString * ids;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * userimg;

@end
