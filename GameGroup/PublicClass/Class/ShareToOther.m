//
//  ShareToOther.m
//  GameGroup
//
//  Created by 魏星 on 14-4-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ShareToOther.h"
#import "WXApiObject.h"
static ShareToOther *userManager = NULL;
@implementation ShareToOther
{
    AppDelegate*app;
}

+ (ShareToOther*)singleton
{
    @synchronized(self)
    {
		if (userManager == nil)
		{
			userManager = [[self alloc] init];
		}
	}
	return userManager;
}
-(id)init
{
    self = [super init];
    if (self) {
        app = (AppDelegate *)[UIApplication sharedApplication] .delegate;
    }
    return self;
}
//微博，仅图片分享
-(void)shareTosina:(UIImage *)imageV
{
    
    WBMessageObject *message = [WBMessageObject message];
    WBImageObject *image = [WBImageObject object];
    image.imageData = UIImagePNGRepresentation(imageV);
    message.imageObject = image;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    
    [WeiboSDK sendRequest:request];
    app.bSinaWB = YES;
}
//微博，带链接分享
-(void)shareTosinass:(UIImage *)imageV Title:(NSString*)title Description:(NSString*)des Url:(NSString*)uri
{
//    WBWebpageObject *webpage = [WBWebpageObject object];
//    webpage.objectID = @"identifier1";
//    webpage.title = title;
//    webpage.description = [NSString stringWithFormat:@"%@%@",des,uri];
//   webpage.thumbnailData =  UIImageJPEGRepresentation([NetManager compressImage:imageV targetSizeX:200 targetSizeY:200], 0.7);
//    webpage.webpageUrl = uri;

    WBMessageObject *message = [WBMessageObject message];
    if (imageV) {
        WBImageObject *wbimage = [WBImageObject object];
        wbimage.imageData = UIImageJPEGRepresentation([NetManager compressImage:imageV targetSizeX:200 targetSizeY:200], 0.7);
        message.imageObject = wbimage;
    }
    message.text = [NSString stringWithFormat:@"%@%@",title,uri];
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message];
    request.userInfo = @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
    app.bSinaWB = YES;
}

//分享到微博
-(void)shareTosinaObject:(id)mediaObject
{

}
//微博sso认证
- (void)ssoButtonPressed
{
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://www.sina.com";
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"SendMessageToWeiboViewController",
                         @"Other_Info_1": [NSNumber numberWithInt:123],
                         @"Other_Info_2": @[@"obj1", @"obj2"],
                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    [WeiboSDK sendRequest:request];
}



-(void) changeScene:(NSInteger)scene
{
    _scene = scene;
}
//微信， 仅图片分享
- (void) sendImageContentWithImage:(UIImage *)imageV
{
    
    WXImageObject *ext = [WXImageObject object];
    UIImage* image = imageV;
    ext.imageData =UIImageJPEGRepresentation(image, 0.2);
    [self shareToWX:ext uiimage:imageV Title:@"" Description:@""];
}
//微信，带链接分分享
- (void)sendAppExtendContent_friend:(UIImage *)image Title:(NSString*)title Description:(NSString*)des Url:(NSString*)uri
{
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = uri;
    [self shareToWX:ext uiimage:image Title:title Description:des];
}
//微信分享
-(void)shareToWX:(id)mediaObject uiimage:(UIImage *)imageV Title:(NSString*)title Description:(NSString*)des
{
    if ([WXApi isWXAppInstalled]) {
        WXMediaMessage *message = [WXMediaMessage message];
        UIImage * imageVV=[NetManager compressImage:imageV targetSizeX:640/3 targetSizeY:1136/3];
        [message setThumbImage:imageVV];
        message.title = title;
        message.description = des;
        message.mediaObject = mediaObject;
        
        SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
        req.bText = NO;
        req.message = message;
        req.scene = _scene;
        [WXApi sendReq:req];
        app.bSinaWB = NO;
        
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:@"您还没有安装微信" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
    }

}
//QQ,带链接分享
- (void)onTShareImage:(NSString*)imageUrl Title:(NSString*)title Description:(NSString*)des Url:(NSString*)uri
{
    [self onShareToQQ:title Description:des Url:uri previewImageURL:imageUrl IsZone:NO];
}

-(void)onShareToQQ:(NSString*)title Description:(NSString*)des Url:(NSString*)uri previewImageURL:(NSString*)previewURL IsZone:(BOOL)isZone{
    QQApiNewsObject * newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:uri]title:title description:des previewImageURL:[NSURL URLWithString:previewURL]];
    [self onShareToQQ:newsObj IsZone:isZone];
}

-(void)onShareToQQ:(NSString*)title Description:(NSString*)des Url:(NSString*)uri previewImageData:(NSData*)data IsZone:(BOOL)isZone{
    QQApiNewsObject * newsObj = [QQApiNewsObject objectWithURL:[NSURL URLWithString:uri]title:title description:des previewImageData:data];
    [self onShareToQQ:newsObj IsZone:isZone];
}

-(void)onShareToQQ:(QQApiNewsObject*)newsObj IsZone:(BOOL)isZone{
    app.bSinaWB = YES;
    SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:newsObj];
    QQApiSendResultCode sent = 0;
    if (isZone){//分享到QZone
        sent = [QQApiInterface SendReqToQZone:req];
    }else{//分享到QQ
        sent = [QQApiInterface sendReq:req];
    }
    [self handleSendResult:sent];
}



- (void)handleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult)
    {
        case EQQAPIAPPNOTREGISTED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"App未注册" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIMESSAGECONTENTINVALID:
        case EQQAPIMESSAGECONTENTNULL:
        case EQQAPIMESSAGETYPEINVALID:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送参数错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTINSTALLED:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"未安装手Q" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQQNOTSUPPORTAPI:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"API接口不支持" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPISENDFAILD:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"发送失败" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTTEXT:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯文本分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        case EQQAPIQZONENOTSUPPORTIMAGE:
        {
            UIAlertView *msgbox = [[UIAlertView alloc] initWithTitle:@"Error" message:@"空间分享不支持纯图片分享，请使用图文分享" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil];
            [msgbox show];
            break;
        }
        default:
        {
            break;
        }
    }
}

@end
