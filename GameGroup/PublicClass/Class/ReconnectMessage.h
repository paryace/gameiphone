//
//  ReconnectMessage.h
//  GameGroup
//
//  Created by 魏星 on 14-3-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReconnectMessage : NSObject
+ (ReconnectMessage*)singleton;
-(void)getChatServer;
-(void)getLonInToChatServer;
@property (strong,nonatomic) XMPPHelper * xmpphelper;

@end
