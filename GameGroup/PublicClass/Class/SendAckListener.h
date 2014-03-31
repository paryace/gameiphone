//
//  SendAckListener.h
//  GameGroup
//
//  Created by 魏星 on 14-3-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SendAckListener : NSObject
+ (SendAckListener*)singleton;
@property(nonatomic,strong) XMPPHelper*xmpphelper;
@end
