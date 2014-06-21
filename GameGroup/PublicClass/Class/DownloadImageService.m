//
//  DownloadImageService.m
//  GameGroup
//
//  Created by Apple on 14-6-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "DownloadImageService.h"
#import "AFURLSessionManager.h"
static DownloadImageService *downService = NULL;
@implementation DownloadImageService

+ (DownloadImageService*)singleton
{
    @synchronized(self)
    {
		if (downService == nil)
		{
			downService = [[self alloc] init];
		}
	}
	return downService;
}

- (NSURLSession *)session
{
    //创建NSURLSession
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession  *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:self delegateQueue:nil];
    return session;
}

- (NSURLRequest *)request:(NSString*)imageId
{
    NSString * urlStr= [ImageService getImgUrl:imageId];
    NSString * downLoadUrl = [NSString stringWithFormat:@"%@",urlStr];
    NSURL *url = [NSURL URLWithString:downLoadUrl];
    //创建请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    return request;
}

-(void)startDownload:(NSString*)imageId
{
    //用NSURLSession和NSURLRequest创建网络任务
    self.imageId = imageId;
    self.task = [[self session] downloadTaskWithRequest:[self request:imageId]];
    [self.task resume];
}

//创建文件本地保存目录
-(NSURL *)createDirectoryForDownloadItemFromURL
{
    
    NSString *path = [RootDocPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",self.imageId]];
    return [[NSURL alloc]initFileURLWithPath:path];
}
//把文件拷贝到指定路径
-(BOOL) copyTempFileAtURL:(NSURL *)location toDestination:(NSURL *)destination
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtURL:destination error:NULL];
    [fileManager copyItemAtURL:location toURL:destination error:&error];
    if (error == nil) {
        return true;
    }else{
        NSLog(@"%@",error);
        return false;
    }
}

#pragma mark NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    //下载成功后，文件是保存在一个临时目录的，需要开发者自己考到放置该文件的目录
    NSURL *destination = [self createDirectoryForDownloadItemFromURL];
    BOOL success = [self copyTempFileAtURL:location toDestination:destination];
    if (success) {
        [[NSUserDefaults standardUserDefaults]setObject:self.imageId forKey:OpenImage];
    }
    self.task = nil;
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
}
@end
