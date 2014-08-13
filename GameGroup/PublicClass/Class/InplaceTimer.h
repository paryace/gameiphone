//
//  InplaceTimer.h
//  GameGroup
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeDelegate.h"

@interface InplaceTimer : NSObject

@property (nonatomic, assign) id<TimeDelegate> delegate;

+ (InplaceTimer*)singleton;

//显示重新计时
-(void)reStartTimer:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId timeDeleGate:(id<TimeDelegate>) timedeleGate;
//开始计时
-(void)startTimer:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId timeDeleGate:(id<TimeDelegate>) timedeleGate;
//结束计时
-(void)stopTimer:(NSString*)gameId RoomId:(NSString*)roomId GroupId:(NSString*)groupId;
//时间清零
-(void)resetTimer:(NSString*)gameId RoomId:(NSString*)roomId;
@end
