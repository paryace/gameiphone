//
//  GameXmppReconnect.m
//  GameGroup
//
//  Created by admin on 14-4-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GameXmppReconnect.h"

@implementation GameXmppReconnect
- (BOOL)shouldReconnect
{
	NSAssert(dispatch_get_specific(moduleQueueTag), @"Invoked private method outside moduleQueue");
	
	return [[TempData sharedInstance] isHaveLogin];
}

- (BOOL)autoReconnect
{
	return YES;
}

@end
