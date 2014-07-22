//
//  ReceiveMessageDelegate.h
//  GameGroup
//
//  Created by Apple on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ReceiveMessageDelegate <NSObject>
@optional
-(void)onMessage:(XMPPMessage *)message;
@end
