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

- (instancetype)initWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate
{
    return [self initWithURLString:urlStr delegate:delegate tag:0];
}

- (instancetype)initWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag
{
    self = [super init];
    if (self) {
        [self setUrlStr:urlStr];
        [self setDelegate:delegate];
        [self setTag:tag];
    }
    return self;
}

+ (instancetype)imageDownloaderWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag
{
    AudioDownLoader *downloader = [[AudioDownLoader alloc] initWithURLString:urlStr delegate:delegate tag:tag];
    [downloader startDownload];
    return [downloader autorelease];
}

+ (instancetype)imageDownloaderWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate
{
    return [self imageDownloaderWithURLString:urlStr delegate:delegate tag:0];
}

- (void)startDownload
{
    //如果未给URL，不启动网络连接
    if (_urlStr == nil) {
        return;
    }
    NSLog(@"%@",kCacheDirectory);
    //先查看 cache中 是否已经有这个图片了。
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *imageName = [self.urlStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *filePath = [kCacheDirectory stringByAppendingPathComponent:imageName];
    //如果有，我们直接用
    if ([fm fileExistsAtPath:filePath]) {
        if([_delegate respondsToSelector:@selector(imageDownLoader:downLoadSuccessWithImage:)]){
            UIImage *image = [UIImage imageWithData:_receivedData];
            [_delegate imageDownLoader:self downLoadSuccessWithImage:image];
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
    //progress = [_receivedData length]/totalLength;
    
    if([_delegate respondsToSelector:@selector(imageDownLoader:progress:)]){
        [_delegate imageDownLoader:self progress:progress];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSString *imageName = [self.urlStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString *filePath = [kCacheDirectory stringByAppendingPathComponent:imageName];
    
    [[AudioManager singleton]isHaveThisFolderWithFilePath:[NSString stringWithFormat:@"%@/voice",RootDocPath]];
    
    //把图像数据存入cache中
    [_receivedData writeToFile:filePath atomically:YES];
    
    if([_delegate respondsToSelector:@selector(imageDownLoader:downLoadSuccessWithImage:)]){
        UIImage *image = [UIImage imageWithData:_receivedData];
        [_delegate imageDownLoader:self downLoadSuccessWithImage:image];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    if([_delegate respondsToSelector:@selector(imageDownLoader:failedWithError:)]){
        [_delegate imageDownLoader:self failedWithError:error];
    }
}


- (void)cancelDownload
{
    [_connection cancel];
    [_connection release];
    _connection = nil;
}

@end
