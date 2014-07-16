//
//  MessageAckService.h
//  GameGroup
//
//  Created by apple on 14-7-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageAckService : NSObject
+ (MessageAckService*)singleton;
@property(nonatomic, strong) NSMutableArray* cacheMessages;
-(void)addMessage:(NSMutableDictionary*)message;
@end
