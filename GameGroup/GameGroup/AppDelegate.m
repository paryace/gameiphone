//
//  AppDelegate.m
//  GameGroup
//
//  Created by Shen Yanping on 13-12-3.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "AppDelegate.h"
#import "TempData.h"
#import "StartViewController.h"
#import "XMPPHelper.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "GetDataAfterManager.h"
#import "BaseViewController.h"
#import "ReconnectMessage.h"
#import "AddAddressBookViewController.h"
#import "XMPPping.h"
#import "OfflineComment.h"
@implementation AppDelegate
{
   
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSLog(@"%@",NSHomeDirectory());
    
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:NULL];
                for (int i = 0; i <contents.count; i++) {
                    NSError *error;
                    NSLog(@"%@",error);
                    [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:[contents objectAtIndex:i]] error:&error];
                }
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
    }else{
    }
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // Override point for customization after application launch.
    self.startViewController = [[StartViewController alloc] init];
    
    self.window.rootViewController = self.startViewController;
    
    //网络变化
    self.reach = [Reachability reachabilityForInternetConnection];
    [_reach startNotifier];
    GetDataAfterManager *getDataAfterManager=[GetDataAfterManager shareManageCommon];
    self.xmppHelper=[[XMPPHelper alloc] init];
    [self.xmppHelper setupStream];
    self.xmppHelper.chatDelegate = getDataAfterManager;
    self.xmppHelper.addReqDelegate = getDataAfterManager;
    self.xmppHelper.commentDelegate = getDataAfterManager;
    self.xmppHelper.deletePersonDelegate = getDataAfterManager;
    self.xmppHelper.otherMsgReceiveDelegate = getDataAfterManager;
    self.xmppHelper.recommendReceiveDelegate = getDataAfterManager;
    getDataAfterManager.xmppHelper=self.xmppHelper;

    
    if ([[TempData sharedInstance] isHaveLogin] ) {
        [DataStoreManager setDefaultDataBase:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID] AndDefaultModel:@"LocalStore"];//根据用户名创建数据库
        [self.xmppHelper connect];
        
        
    }
   
    //注册离线系统  里面监听重连事件 自动提交赞与评论 未来可以添加其他离线的内容
    [OfflineComment singleton];
    
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];//打印xmpp输出
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    [MobClick startWithAppkey:@"52caacec56240b18e2035237"];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"2195106285"];
    [WXApi registerApp:@"wx64c8dc2f82a0c8fd" withDescription:nil];
//    [MobClick startWithAppkey:@"xxxxxxxxxxxxxxx" reportPolicy:BATCH   channelId:@""];

    [self.window makeKeyAndVisible];

    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (!_bSinaWB) {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    else{
        return [WeiboSDK handleOpenURL:url delegate:self];
    }

}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (!_bSinaWB) {
        return  [WXApi handleOpenURL:url delegate:self];
    }
    else{
        return [WeiboSDK handleOpenURL:url delegate:self];
    }
}


#pragma mark 推送
- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSLog(@"嘻嘻嘻嘻 My token is: %@", deviceToken);
    NSString* tokenStr = [deviceToken description];
    //NSLog(@"%d", tokenStr.length);
    [GameCommon shareGameCommon].deviceToken = [tokenStr substringWithRange:NSMakeRange(1, tokenStr.length - 2)];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"呜呜呜呜 Failed to get token, error: %@", error);
    [GameCommon shareGameCommon].deviceToken = @"";
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    //它是类里自带的方法,这个方法得说下，很多人都不知道有什么用，它一般在整个应用程序加载时执行，挂起进入后也会执行，所以很多时候都会使用到，将小红圈清空
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Notification_BecomeActive" object:nil userInfo:nil];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    if([self.xmppHelper isConnected]){
        [self.xmppHelper.xmppPing sendPingToServerWithTimeout:2];
    }
    if([self.xmppHelper isDisconnected]){
        [self.xmppHelper connect];
    }
    
}


- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    if ([response isKindOfClass:WBSendMessageToWeiboResponse.class])
    {
        NSString *str;
        if ((int)response.statusCode==0) {
            str = @"分享成功";
        }else{
            str = @"分享失败";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str message:nil delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];
        
        [alert show];

    }
    else if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        NSString *str;

        if ((int)response.statusCode==0) {
            str = @"授权成功";
        }else{
            str = @"授权失败";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:str
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"确定"
                                              otherButtonTitles:nil];
        self.wbtoken = [(WBAuthorizeResponse *)response accessToken];
        
        [alert show];
    }
}

-(void) onResp:(BaseResp*)resp
{
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        NSString *strTitle;
        if (resp.errCode ==0) {
            strTitle = @"分享成功";
        }else{
            strTitle = @"分享失败";
        }
       // NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}




- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //推送消息处理
    // NSLog(@"&&&&&&& %@", userInfo);
    //{
    //aps =     {
    //    alert = "This is some fany message.";
    //    badge = 1;
    //    sound = "received5.caf";
    //};
    //     NSLog(@"%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [MagicalRecord cleanUp];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



@end
