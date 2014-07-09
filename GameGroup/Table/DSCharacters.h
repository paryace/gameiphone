//
//  DSCharacters.h
//  GameGroup
//
//  Created by Marss on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DSCharacters : NSManagedObject

@property (nonatomic, retain) NSString * userid;
@property (nonatomic, retain) NSString * auth;
@property (nonatomic, retain) NSString * failedmsg;
@property (nonatomic, retain) NSString * gameid;
@property (nonatomic, retain) NSString * charactersId;
@property (nonatomic, retain) NSString * img;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * realm;
@property (nonatomic, retain) NSString * value1;
@property (nonatomic, retain) NSString * value2;
@property (nonatomic, retain) NSString * value3;
@property (nonatomic, retain) NSString * simpleRealm;

@end
