//
//  SendFileManager.h
//  GameGroup
//
//  Created by Apple on 14-9-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SendFileMessageDelegate.h"

@interface SendFileManager : NSObject<QiniuUploadDelegate>
+ (SendFileManager*)singleton;
@property (nonatomic,assign)id<SendFileMessageDelegate>uploaddelegate;
@property(nonatomic, strong) NSMutableDictionary* cacheMessages;
-(void)addUploadImage:(int)index FilePath:(NSString*)filePath SendFileDelegate:(id<SendFileMessageDelegate>) updeleGate;
@end
