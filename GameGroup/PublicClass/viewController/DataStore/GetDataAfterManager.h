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
#define kRecommendMessage    @"recommend"
#define kDisbandGroup    @"disbandGroup"//解散群组
#define kKickOffGroupGroup    @"kickOffGroupGroup"//解散群组
#define kMessageAck @"messageAck"
#define kteamMessage    @"teamMessage"
#define kteamRecommend    @"teamRecommend"
#define kUpdateMsgCount    @"updateMsgCount"

@interface GetDataAfterManager : NSObject

@property(nonatomic,strong)XMPPHelper* xmppHelper;
@property (strong,nonatomic) AppDelegate * appDel;
@property(nonatomic, strong) NSMutableArray* cacheMsg;
@property (nonatomic, retain) NSTimer* cellTimer;
@property (nonatomic, retain) NSTimer* mTimer;
@property (nonatomic, retain) NSTimer* cellTimerGroup;
@property (nonatomic, retain) NSTimer* cellTimerDy;
@property (nonatomic, retain) NSTimer* cellTimerDyMe;
@property (nonatomic, retain) NSTimer* cellTimerDyGroup;
@property(nonatomic, strong) NSMutableArray* cacheMsgGroup;

+ (GetDataAfterManager*)shareManageCommon;

@end
