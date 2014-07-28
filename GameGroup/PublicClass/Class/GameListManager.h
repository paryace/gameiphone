//
//  GameListManager.h
//  GameGroup
//
//  Created by Apple on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameListManager : NSObject
+ (GameListManager*)singleton;

-(void)getGameListFromLocal:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

-(void)getGameListDicFromLocal:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;

-(void)GetGageListFromNet:(void (^)(id responseObject))resuccess reError:(void(^)(id error))refailure;
@end
