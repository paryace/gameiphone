//
//  ReconnectMessage.m
//  GameGroup
//
//  Created by 魏星 on 14-3-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReconnectMessage.h"
#import "AppDelegate.h"
static ReconnectMessage *my_reconectMessage = NULL;
@implementation ReconnectMessage
{
}
- (id)init
{
    self = [super init];
    if (self) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
       // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logInToChatServer) name:@"Notification_BecomeActive" object:nil];
    }
    return self;
}

+ (ReconnectMessage*)singleton
{
    @synchronized(self)
    {
		if (my_reconectMessage == nil)
		{
			my_reconectMessage = [[self alloc] init];
		}
	}
	return my_reconectMessage;
}


#pragma mark 进入程序网络变化
- (void)appBecomeActiveWithNet:(NSNotification*)notification
{
    Reachability* reach = notification.object;
    if ([reach currentReachabilityStatus] != NotReachable  && [[TempData sharedInstance] isHaveLogin]) {//有网
        if (![self.xmpphelper ifXMPPConnected]) {
            [self getChatServer];
        }
    }
}

#pragma mark 登陆xmpp
- (void)getChatServer//自动登陆情况下获得服务器
{
    if (![[TempData sharedInstance] isHaveLogin]){
        return;
    }
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[DataStoreManager getMyUserID] forKey:@"userid"];
    [postDict setObject:@"116" forKey:@"method"];
    [postDict setObject:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"服务器数据 %@", responseObject);

        [[TempData sharedInstance] SetServer:KISDictionaryHaveKey(responseObject, @"address") TheDomain:KISDictionaryHaveKey(responseObject, @"name")];//得到域名
        [self logInToChatServer];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectFail" object:nil];
    }];
    
}
-(void)logInToChatServer
{
    NSLog(@"尝试登陆xmpp");
    NSLog(@"%@",[[DataStoreManager getMyUserID] stringByAppendingFormat:@"%@",[[TempData sharedInstance] getDomain]]);
    [self.xmpphelper connect:[[DataStoreManager getMyUserID] stringByAppendingFormat:@"%@",[[TempData sharedInstance] getDomain]] password:[SFHFKeychainUtils getPasswordForUsername:LOCALTOKEN andServiceName:LOCALACCOUNT error:nil] host:[[TempData sharedInstance] getServer] success:^(void){
        
        NSLog(@"登陆成功xmpp");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectSuccess" object:nil];
        
        
    }fail:^(NSError *result){
        NSLog(@" localizedDescription %@", result.localizedDescription);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectFail" object:nil];
    }];
}

@end
