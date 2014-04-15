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

- (void) sendImageContentWithImage:(UIImage *)imageV
{
    if ([WXApi isWXAppInstalled]) {
        WXMediaMessage *message = [WXMediaMessage message];
        [message setThumbImage:[UIImage imageNamed:@"res5thumb.png"]];
        
        WXImageObject *ext = [WXImageObject object];
        
        
        UIImage* image = imageV;
        ext.imageData = UIImagePNGRepresentation(image);
        message.mediaObject = ext;
        
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


@end
