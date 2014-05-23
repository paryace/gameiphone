//
//  AppDelegate.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-3.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Reachability.h"
#import "WeiboSDK.h"
#import"WXApi.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "TencentOpenAPI/QQApiInterface.h"
#import <TencentOpenAPI/TencentApiInterface.h>
@class StartViewController;
@class XMPPHelper;

@interface AppDelegate : UIResponder
<UIApplicationDelegate,
WeiboSDKDelegate
,WXApiDelegate
,TencentSessionDelegate
,TencentApiInterfaceDelegate
,QQApiInterfaceDelegate
>
{
    NSString* _wbtoken;
    
}
@property(nonatomic,assign)BOOL bSinaWB;
@property(nonatomic,assign)BOOL bQQ;

@property (strong, nonatomic) NSString *wbtoken;

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) StartViewController *startViewController;
@property (nonatomic,strong) XMPPHelper *xmppHelper;
@property(nonatomic,strong)Reachability * reach;

- (void)didReceiveWeiboResponse:(WBBaseResponse *)response;
- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message;
@end
