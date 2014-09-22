//
//  ShareDynamicMsgService.h
//  GameGroup
//
//  Created by Apple on 14-9-22.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareToOther.h"

@interface ShareDynamicMsgService : NSObject
+ (ShareDynamicMsgService*)singleton;

-(void)sendToFriend:(NSString*)nickName DynamicId:(NSString*)dynamicId MsgBody:(NSString*)msgBody DynamicImage:(NSString*)dynamicImage ToUserId:(NSString*)touserId ToNickName:(NSString*)toNickName ToImage:(NSString*)toImage success:(void (^)(void))success failure:(void (^)(NSString * error))failure;

-(void)broadcastToFans:(NSString*)dynamicId resuccess:(void (^)(id responseObject))resuccess refailure:(void (^)(id error))refailure;

-(void)shareToOther:(NSString*)msgid MsgTitle:(NSString*)msgtitle Description:(NSString*)description Image:(NSString*)image  UserNickName:(NSString*)userNickName index:(NSInteger)buttonIndex;
@end
