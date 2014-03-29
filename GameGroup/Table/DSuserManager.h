//
//  DSuserManager.h
//  GameGroup
//
//  Created by 魏星 on 14-3-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSuserManager : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * nickName;
@property (nonatomic, retain) NSString * shiptype;
@property (nonatomic, retain) NSString * age;
@property (nonatomic, retain) NSString * achievement;
@property (nonatomic, retain) NSString * achievementLevel;
@property (nonatomic, retain) NSNumber * action;
@property (nonatomic, retain) NSString * backgroundImg;
@property (nonatomic, retain) NSString * birthday;
@property (nonatomic, retain) NSString * createTime;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * headImgID;
@property (nonatomic, retain) NSString * hobby;
@property (nonatomic, retain) NSString * nameIndex;
@property (nonatomic, retain) NSString * nameKey;
@property (nonatomic, retain) NSString * phoneNumber;
@property (nonatomic, retain) NSString * refreshTime;
@property (nonatomic, retain) NSString * remarkName;
@property (nonatomic, retain) NSString * signature;
@property (nonatomic, retain) NSString * starSign;
@property (nonatomic, retain) NSString * superremark;
@property (nonatomic, retain) NSString * superstar;

@end
