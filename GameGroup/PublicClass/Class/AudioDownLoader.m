//
//  ImageDownLoader.m
//  ImageDownload
//
//  Created by neal on 14-1-18.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import "AudioDownLoader.h"

#define kCacheDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)objectAtIndex:0]

@interface AudioDownLoader()
{
    NSMutableData *_receivedData;
    NSURLConnection *_connection;
    
}
@property(nonatomic, retain)NSMutableData *receivedData;
@end

@implementation AudioDownLoader

- (void)dealloc
{
    [_receivedData release];
    [self cancelDownload];
    [super dealloc];
}

- (instancetype)initWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId MessageUuid:(NSString*)messageuuid delegate:(id<AudioDownLoaderDelegate>)delegate
{
    return [self initWithURLString:urlStr MessageId:messageId MessageUuid:messageId delegate:delegate tag:0];
}

- (instancetype)initWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId MessageUuid:(NSString*)messageuuid delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag
{
    self = [super init];
    if (self) {
        [self setUrlStr:urlStr];
        [self setDelegate:delegate];
        [self setTag:tag];
        [self setMessageId:messageId];
        [self setMessageuuid:messageuuid];
    }
    return self;
}

+ (instancetype)fileDownloaderWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId MessageUuid:(NSString*)messageuuid delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag
{
    AudioDownLoader *downloader = [[AudioDownLoader alloc] initWithURLString:urlStr MessageId:messageId MessageUuid:messageId delegate:delegate tag:tag];
    [downloader startDownload];
    return [downloader autorelease];
}

+ (instancetype)fileDownloaderWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId MessageUuid:(NSString*)messageuuid delegate:(id<AudioDownLoaderDelegate>)delegate
{
    return [self fileDownloaderWithURLString:urlStr MessageId:messageId MessageUuid:messageId delegate:delegate tag:0];
}

- (void)startDownload
{
    //如果未给URL，不启动网络连接
    if (_urlStr == nil) {
        return;
    }
    NSString * filePath = [self getVoideFilePath:_messageId];
    //如果有，我们直接用
    if ([self isFileExist:filePath]) {
        _receivedData = [NSData dataWithContentsOfURL:[NSURL URLWithString:filePath]];
        if([_delegate respondsToSelector:@selector(fileDownLoader:downLoadSuccessWithImage:)]){
            [_delegate fileDownLoader:self downLoadSuccessWithImage:_receivedData];
        }
    }else{    //如果没有，我们就去下载
        self.receivedData = [NSMutableData data];
        NSURL *url = [NSURL URLWithString:_urlStr];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
        //在创建新的连接之前，取消旧的连接
        [self cancelDownload];
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        [request release];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"%lld",[httpResponse expectedContentLength]);
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_receivedData appendData:data];
    CGFloat progress = 0;
    if([_delegate respondsToSelector:@selector(fileDownLoader:progress:)]){
        [_delegate fileDownLoader:self progress:progress];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    //把数据存入cache中
    NSString *ps = [self getVoideFilePath:_messageId];
    [[AudioManager singleton]isHaveThisFolderWithFilePath:[NSString stringWithFormat:@"%@/voice",RootDocPath]];
    [_receivedData writeToFile:ps atomically:YES];
    if([_delegate respondsToSelector:@selector(fileDownLoader:downLoadSuccessWithImage:)]){
        [_delegate fileDownLoader:self downLoadSuccessWithImage:_receivedData];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([_delegate respondsToSelector:@selector(fileDownLoader:failedWithError:)]){
        [_delegate fileDownLoader:self failedWithError:error];
    }
}

-(NSString*)getVoideFilePath:(NSString*)messageId{
    return [NSString stringWithFormat:@"%@/voice/%@",RootDocPath,[[AudioManager singleton]changeStringWithString:[GameCommon getNewStringWithId:messageId]]];
}

#pragma mark ---判断文件是否存在于沙盒
- (BOOL)isFileExist:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:fileName];
    return result;
}

- (void)cancelDownload
{
    [_connection cancel];
    [_connection release];
    _connection = nil;
}

@end
