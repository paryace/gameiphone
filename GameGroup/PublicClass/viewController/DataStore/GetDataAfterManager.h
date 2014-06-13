//
//  GetDataAfterManager.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-17.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"

#define kNewMessageReceived @"newMessageReceived"
#define kFriendHelloReceived @"friendHelloReceived"
#define kNewsMessage @"newsMessage"
#define kDeleteAttention @"deleteAttentionReceived"
#define kOtherMessage    @"otherMessage"
#define kJoinGroupMessage    @"joinGroupMessage"

#define kDisbandGroup    @"disbandGroup"//解散群组

#define kMessageAck @"messageAck"

@interface GetDataAfterManager : NSObject

@property(nonatomic,strong)XMPPHelper* xmppHelper;

+ (GetDataAfterManager*)shareManageCommon;

@end
