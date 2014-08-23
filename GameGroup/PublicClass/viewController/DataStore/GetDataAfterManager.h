//
//  GetDataAfterManager.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-17.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"



@interface GetDataAfterManager : NSObject

@property(nonatomic,strong)XMPPHelper* xmppHelper;
@property (strong,nonatomic) AppDelegate * appDel;
@property (nonatomic, retain) NSTimer* cellTimerDyGroup;

+ (GetDataAfterManager*)shareManageCommon;

@end
