//
//  SendAckListener.m
//  GameGroup
//
//  Created by 魏星 on 14-3-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SendAckListener.h"
#import "NSObject+SBJSON.h"
static SendAckListener *my_SendAckListener = NULL;

@implementation SendAckListener

+ (SendAckListener*)singleton
{
    @synchronized(self)
    {
		if (my_SendAckListener == nil)
		{
			my_SendAckListener = [[self alloc] init];
		}
	}
	return my_SendAckListener;
}
-(id)init
{  self = [super init];
    if (self) {
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(comeBackDelivered:) name:kNewMessageReceived object:nil];
    }
    return self;
}

@end
