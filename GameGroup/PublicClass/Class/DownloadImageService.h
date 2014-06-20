//
//  DownloadImageService.h
//  GameGroup
//
//  Created by Apple on 14-6-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadImageService : NSObject<NSURLSessionDownloadDelegate>
@property (atomic, strong) NSURLSessionDownloadTask *task;
@property (atomic, strong) NSData * partialData;
@property (atomic, strong) NSString * imageId;

+ (DownloadImageService*)singleton;

-(void)startDownload:(NSString*)imageId;
@end
