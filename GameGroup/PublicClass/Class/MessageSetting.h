//
//  MessageSetting.h
//  GameGroup
//
//  Created by Marss on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageSetting : NSObject
+ (MessageSetting*)singleton;
//设置声音或者震动
-(void)setSoundOrVibrationopen;
@end
