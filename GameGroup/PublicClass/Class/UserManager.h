//
//  UserManager.h
//  GameGroup
//
//  Created by 魏星 on 14-3-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DSuser.h"

@interface UserManager : NSObject
+ (UserManager*)singleton;
- (NSMutableDictionary*)getUser:(NSString* )userId;
- (void)requestUserFromNet:(NSString*)userId;
@end
