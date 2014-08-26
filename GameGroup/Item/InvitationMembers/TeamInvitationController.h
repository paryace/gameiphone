//
//  TeamInvitationController.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "InviationGroupViewController.h"
#import "ShareToOther.h"
#import "InviationMYFriendController.h"

@interface TeamInvitationController : BaseViewController

@property(nonatomic,copy)NSString     *     roomId;
@property(nonatomic,copy)NSString     *     gameId;
@property(nonatomic,copy)NSString     *     groupId;
@property (strong, nonatomic)  NSMutableDictionary *roomInfoDic;
@property(nonatomic,assign) BOOL createFinish;

@end
