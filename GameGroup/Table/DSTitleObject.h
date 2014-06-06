//
//  DSTitleObject.h
//  GameGroup
//
//  Created by Marss on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSTitleObject : NSManagedObject

@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * evolution;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * icon;
@property (nonatomic, retain) NSString * titleId;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * rank;
@property (nonatomic, retain) NSString * ranktype;
@property (nonatomic, retain) NSString * rankvaltype;
@property (nonatomic, retain) NSString * rarememo;
@property (nonatomic, retain) NSString * rarenum;
@property (nonatomic, retain) NSString * remark;
@property (nonatomic, retain) NSString * remarkDetail;
@property (nonatomic, retain) NSString * simpletitle;
@property (nonatomic, retain) NSString * sortnum;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * titlekey;
@property (nonatomic, retain) NSString * titletype;

@end
