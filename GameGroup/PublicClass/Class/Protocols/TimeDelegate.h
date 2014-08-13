//
//  TimeDelegate.h
//  GameGroup
//
//  Created by Apple on 14-8-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TimeDelegate <NSObject>

@optional
- (void)timingTime:(long long )time;
- (void)finishTiming;
@end
