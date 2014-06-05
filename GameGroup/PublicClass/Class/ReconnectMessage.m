//
//  ReconnectMessage.m
//  GameGroup
//
//  Created by 魏星 on 14-3-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReconnectMessage.h"
#import "AppDelegate.h"
#import "UserManager.h"
static ReconnectMessage *my_reconectMessage = NULL;
@implementation ReconnectMessage
{
    Reachability* reach;
    MBProgressHUD *hud;
}
- (id)init
{
    self = [super init];
    if (self) {
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



- (void)sendDeviceToken
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    NSMutableDictionary* locationDict = [NSMutableDictionary dictionaryWithCapacity:1];
    [locationDict setObject:[GameCommon shareGameCommon].deviceToken forKey:@"deviceToken"];
    [locationDict setObject:appType forKey:@"appType"];
    
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]? [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID]:@""forKey:@"userid"];
    [postDict setObject:@"140" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]?[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken]:@"" forKey:@"token"];
    [postDict setObject:locationDict forKey:@"params"];
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        NSLog(@"deviceToken fail");
    }];
}

@end
