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
    

    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyUserId"] forKey:@"userid"];
    [postDict setObject:@"116" forKey:@"method"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyToken"] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"服务器数据 %@", responseObject);
        
        [[NSUserDefaults standardUserDefaults] setObject:KISDictionaryHaveKey(responseObject, @"address") forKey:@"host"];
        [[NSUserDefaults standardUserDefaults] setObject:KISDictionaryHaveKey(responseObject, @"name") forKey:@"domain"];

    } failure:^(AFHTTPRequestOperation *operation, id error) {

        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectFail" object:nil];

    }];
    
    return [super connectWithTimeout:timeout error:errPtr];
    


}
@end
