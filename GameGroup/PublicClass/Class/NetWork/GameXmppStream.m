//
//  GameXmppStream.m
//  GameGroup
//
//  Created by admin on 14-4-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GameXmppStream.h"

@implementation GameXmppStream


- (BOOL)connectWithTimeout:(NSTimeInterval)timeout error:(NSError **)errPtr{
    
    __block BOOL result = NO;

    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyUserId"] forKey:@"userid"];
    [postDict setObject:@"116" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyToken"] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"服务器数据 %@", responseObject);
        
        [self setMyJID:[XMPPJID jidWithString:[[[NSUserDefaults standardUserDefaults] objectForKey:@"MyUserId"] stringByAppendingFormat:@"%@",[[TempData sharedInstance] getDomain]]]] ;
        
        
        
        [self setHostName:KISDictionaryHaveKey(responseObject, @"address")];

        result=YES;

    } failure:^(AFHTTPRequestOperation *operation, id error) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectFail" object:nil];

    }];
    
    return result;

}
@end
