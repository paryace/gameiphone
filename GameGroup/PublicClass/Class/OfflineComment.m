//
//  OfflineComment.m
//  GameGroup
//
//  Created by 魏星 on 14-5-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "OfflineComment.h"
#import "DSOfflineComments.h"
static OfflineComment *my_gameCommon = NULL;

@implementation OfflineComment

+ (OfflineComment*)singleton
{
    @synchronized(self)
    {
		if (my_gameCommon == nil)
		{
			my_gameCommon = [[self alloc] init];
		}
	}
	return my_gameCommon;
}
-(id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appBecomeActiveWithNet:) name:kReachabilityChangedNotification object:nil];
    }
    return self;
}



//当网络变得可用
- (void)appBecomeActiveWithNet:(NSNotification*)notification
{
    Reachability* reach = notification.object;
    if ([reach currentReachabilityStatus] != NotReachable  && [[TempData sharedInstance] isHaveLogin]) {//有网
        
     NSArray *array = [DataStoreManager queryallcomments];
        if ([array isKindOfClass:[NSArray class]]&&array.count>0) {

        for (int i =0; i<array.count; i++) {
            DSOfflineComments *offline = [array objectAtIndex:i];
            [self postCommentWithOffLine:offline];
        }
        }
        NSArray *array1 = [DataStoreManager queryallOfflineZan];
        if ([array1 isKindOfClass:[NSArray class]]&&array1.count>0) {
            for (int i = 0; i <array.count; i++) {
                DSOfflineZan *offlineZan = [array1 objectAtIndex:i];
                [self postZanWithMsgId:offlineZan];
            }
        }
     }
}
-(void)postCommentWithOffLine:(DSOfflineComments *)offline
{

    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:offline.msgId forKey:@"messageId"];
    if (offline.destCommentId) {
        [paramDic setObject:offline.destCommentId forKey:@"destCommentId"];
    }
    if (offline.destUserid) {
        [paramDic setObject:offline.destUserid forKey:@"destUserid"];
    }
    if (!offline.comments)  //评论内容为空，不让发。
    {
        return ;
    }
    [paramDic setObject:offline.comments forKey:@"comment"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"186" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    
    
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DataStoreManager removeOfflineCommentsWithuuid:offline.uuid];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
    
}
-(void)postZanWithMsgId:(DSOfflineZan *)offlineZan
{
    
    NSMutableDictionary *paramDic = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [paramDic setObject:offlineZan.msgId forKey:@"messageId"];
    [dict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [dict setObject:paramDic forKey:@"params"];
    [dict setObject:@"185" forKey:@"method"];
    [dict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:dict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        [DataStoreManager removeOfflineZanWithuuid:offlineZan.uuid];
        
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if ([error isKindOfClass:[NSDictionary class]]) {
            if (![[GameCommon getNewStringWithId:KISDictionaryHaveKey(error, kFailErrorCodeKey)] isEqualToString:@"100001"])
            {
                UIAlertView* alert = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@", [error objectForKey:kFailMessageKey]] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                [alert show];
            }
        }
    }];
}


//NSString* uuid = [[GameCommon shareGameCommon] uuid];


@end
