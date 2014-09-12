//
//  ImageDownLoader.h
//  ImageDownload
//
//  Created by neal on 14-1-18.
//  Copyright (c) 2014年 lanou3g.com 蓝鸥科技. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AudioDownLoader;

//ImageDownLoaderDelegate
@protocol AudioDownLoaderDelegate <NSObject>
@optional
//图片下载完成
- (void)imageDownLoader:(AudioDownLoader *)downloader downLoadSuccessWithImage:(UIImage *)image;
//图片下载进度
- (void)imageDownLoader:(AudioDownLoader *)downloader progress:(CGFloat)progress;
//下载失败
- (void)imageDownLoader:(AudioDownLoader *)downloader failedWithError:(NSError *)error;
@end

@interface AudioDownLoader : NSObject<NSURLConnectionDataDelegate>

//图片URL
@property (nonatomic, copy)NSString *urlStr;

//监控图片下载的代理
@property (nonatomic, assign)id <AudioDownLoaderDelegate>delegate;

//是否需要缓存
@property (nonatomic, assign)BOOL needCache;

//下载器的标识
@property (nonatomic, assign)NSUInteger tag;

- (instancetype)initWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate;

//指定初始化方法
- (instancetype)initWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag;

//工厂方法一
+ (instancetype)imageDownloaderWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate tag:(NSUInteger)tag;
//工厂方法二
+ (instancetype)imageDownloaderWithURLString:(NSString *)urlStr delegate:(id<AudioDownLoaderDelegate>)delegate;

- (void)startDownload;
- (void)cancelDownload;

@end


