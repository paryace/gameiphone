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
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *str;
        if ((int)response.statusCode==0) {
            str = @"授权成功";
        }else{
            str = @"授权失败";
        }
        //        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        
        [alert show];
        
        //        NSString *title = @"发送结果";
        //        NSString *message = [NSString stringWithFormat:@"响应状态: %d\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode, response.userInfo, response.requestUserInfo];
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
        //                                                        message:message
        //                                                       delegate:nil
        //                                              cancelButtonTitle:@"确定"
        //                                              otherButtonTitles:nil];
        //        [alert show];
    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *str;
        
        if ((int)response.statusCode==0) {
            str = @"授权成功";
        }else{
            str = @"授权失败";
        }
        NSString *message = [NSString stringWithFormat:@"响应状态: %d\nresponse.userId: %@\nresponse.accessToken: %@\n响应UserInfo数据: %@\n原请求UserInfo数据: %@",(int)response.statusCode,[(WBAuthorizeResponse *)response userID], [(WBAuthorizeResponse *)response accessToken], response.userInfo, response.requestUserInfo];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        
        [alert show];
    }
}


@end
