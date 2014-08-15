//
//  ShareToOther.h
//  GameGroup
//
//  Created by 魏星 on 14-4-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShareToOther : NSObject
{
    enum WXScene _scene;
}
@property(nonatomic,copy)NSString *wbtoken;
+ (ShareToOther*)singleton;
-(void)shareTosina:(UIImage *)imageV;//分享到新浪微博
- (void) sendImageContentWithImage:(UIImage *)imageV;//分享到微信
-(void) changeScene:(NSInteger)scene;
- (void)ssoButtonPressed;//授权
- (void)onTShareImage:(NSString*)imageUrl Title:(NSString*)title Description:(NSString*)des Url:(NSString*)uri;
-(void)onShareToQQ:(NSString*)title Description:(NSString*)des Url:(NSString*)uri previewImageURL:(NSString*)previewURL IsZone:(BOOL)isZone;
-(void)onShareToQQ:(NSString*)title Description:(NSString*)des Url:(NSString*)uri previewImageData:(NSData*)data IsZone:(BOOL)isZone;
- (void)sendAppExtendContent_friend:(UIImage*)image Title:(NSString*)title Description:(NSString*)des Url:(NSString*)uri;


-(void)shareTosinass:(UIImage *)imageV Title:(NSString*)title Description:(NSString*)des Url:(NSString*)uri;
@end
