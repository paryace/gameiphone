//
//  DSCircleWithMe.h
//  GameGroup
//
//  Created by 魏星 on 14-5-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSCircleWithMe : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * createDate;
@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSString * headImg;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * superstar;
@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * msgid;
@property (nonatomic, retain) NSString * myMsgid;
@property (nonatomic, retain) NSString * myMsgImg;
@property (nonatomic, retain) NSString * myMsg;
@property (nonatomic, retain) NSString * myType;
@property (nonatomic, retain) NSString * myCreateDate;
@end
