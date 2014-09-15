//
//  ImageDownLoader.h
//  ImageDownload
//
//  Created by neal on 14-1-18.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AudioDownLoader;

@protocol AudioDownLoaderDelegate <NSObject>
@optional
//下载完成
- (void)fileDownLoader:(AudioDownLoader *)downloader downLoadSuccessWithImage:(NSData *)data;
//下载进度
- (void)fileDownLoader:(AudioDownLoader *)downloader progress:(CGFloat)progress;
//下载失败
- (void)fileDownLoader:(AudioDownLoader *)downloader failedWithError:(NSError *)error;
@end

@interface AudioDownLoader : NSObject<NSURLConnectionDataDelegate>

//URL
@property (nonatomic, copy)NSString *urlStr;

//MessageId
@property (nonatomic, copy)NSString *messageId;

//监控下载的代理
@property (nonatomic, assign)id <AudioDownLoaderDelegate>delegate;

//是否需要缓存
@property (nonatomic, assign)BOOL needCache;

//下载器的标识
@property (nonatomic, assign)NSUInteger tag;

//指定初始化方法
- (instancetype)initWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId delegate:(id<AudioDownLoaderDelegate>)delegate;
//指定初始化方法
- (instancetype)initWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag;
//工厂方法一
+ (instancetype)fileDownloaderWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag;
//工厂方法二
+ (instancetype)fileDownloaderWithURLString:(NSString *)urlStr MessageId:(NSString*)messageId delegate:(id<AudioDownLoaderDelegate>)delegate;




- (void)startDownload;
- (void)cancelDownload;

@end


