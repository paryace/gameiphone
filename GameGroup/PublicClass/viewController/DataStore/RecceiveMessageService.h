//
//  RecceiveMessageService.h
//  GameGroup
//
//  Created by Apple on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecceiveMessageService : NSObject

@property (nonatomic,assign)id addReqDelegate;
@property (nonatomic,assign)id commentDelegate;
@property (nonatomic,assign)id chatDelegate;
@property (nonatomic,assign)id xmpprosterDelegate;
@property (nonatomic,assign)id notConnect;
@property (nonatomic,assign)id deletePersonDelegate;
@property (nonatomic,assign)id otherMsgReceiveDelegate;
@property (nonatomic,assign)id recommendReceiveDelegate;

+ (RecceiveMessageService*)shareManageCommon;
@end
