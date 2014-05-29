//
//  UpLoadFileService.h
//  GameGroup
//
//  Created by Apple on 14-5-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QiniuSimpleUploader.h"
#import "QiniuResumableUploader.h"

@interface UpLoadFileService : NSObject
- (void)simpleUpload:(NSString*)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate;
@end
