//
//  ShareDynamicMsgService.m
//  GameGroup
//
//  Created by Apple on 14-9-22.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ShareDynamicMsgService.h"
static ShareDynamicMsgService *shareDynamicMsgService = NULL;
@implementation ShareDynamicMsgService
+ (ShareDynamicMsgService*)singleton
{
    @synchronized(self)
    {
		if (shareDynamicMsgService == nil)
		{
			shareDynamicMsgService = [[self alloc] init];
		}
	}
	return shareDynamicMsgService;
}
//分享给好友
-(void)sendToFriend:(NSString*)nickName DynamicId:(NSString*)dynamicId MsgBody:(NSString*)msgBody DynamicImage:(NSString*)dynamicImage ToUserId:(NSString*)touserId ToNickName:(NSString*)toNickName ToImage:(NSString*)toImage success:(void (^)(void))success failure:(void (^)(NSString * error))failure
{
    NSString *title = [NSString stringWithFormat:@"分享了%@的动态",nickName];
    NSXMLElement * payload = [NSXMLElement elementWithName:@"payload"];
    NSString *payloadStr = [MessageService createPayLoadStr:dynamicImage title:title shiptype:@"1" messageid:dynamicId msg:msgBody type:@"3"];
    [payload setStringValue:payloadStr];
    NSString * nowTime = [GameCommon getCurrentTime];
    NSString * message = [NSString stringWithFormat:@"分享:%@的动态",nickName];
    NSString * fromUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kMYUSERID];
    NSString * domain = [[NSUserDefaults standardUserDefaults] objectForKey:kDOMAIN];
    NSString * from = [fromUserId stringByAppendingString:domain];
    NSString * toUserid = touserId;
    NSString * to = [toUserid stringByAppendingString:domain];
    NSString* uuid = [[GameCommon shareGameCommon] uuid];
    NSXMLElement *mes =[MessageService createMes:nowTime Message:message UUid:uuid From:from To:to FileType:@"text" MsgType:@"normalchat" Type:@"chat"];
    [mes addChild:payload];
    if ([((AppDelegate*)[[UIApplication sharedApplication] delegate]).xmppHelper sendMessage:mes]) {
        if (success) {
            success();
        }
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:title forKey:@"msg"];
        [dictionary setObject:@"you" forKey:@"sender"];
        [dictionary setObject:nowTime forKey:@"time"];
        [dictionary setObject:toUserid forKey:@"receiver"];
        [dictionary setObject:toNickName forKey:@"nickname"];
        [dictionary setObject:toImage forKey:@"img"];
        [dictionary setObject:payloadStr forKey:@"payload"];
        [dictionary setObject:@"normalchat" forKey:@"msgType"];
        [dictionary setObject:uuid forKey:@"messageuuid"];
        [dictionary setObject:@"2" forKey:@"status"];
        [DataStoreManager storeMyPayloadmsg:dictionary];
        [DataStoreManager storeMyNormalMessage:dictionary];
    }else{
        if (failure) {
            failure(@"发送失败");
        }
    }
}

//广播给粉丝
-(void)broadcastToFans:(NSString*)dynamicId resuccess:(void (^)(id responseObject))resuccess refailure:(void (^)(id error))refailure
{
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [paramDict setObject:dynamicId forKey:@"messageid"];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"145" forKey:@"method"];
    [postDict setObject:paramDict forKey:@"params"];
    [postDict setObject:[[NSUserDefaults standardUserDefaults] objectForKey:kMyToken] forKey:@"token"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict   success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (resuccess) {
            resuccess(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, id error) {
        if (refailure) {
            refailure(error);
        }
    }];
}


//分享到其他平台
-(void)shareToOther:(NSString*)msgid MsgTitle:(NSString*)msgtitle Description:(NSString*)description Image:(NSString*)image  UserNickName:(NSString*)userNickName index:(NSInteger)buttonIndex{
    NSString * shareUrl = [self getShareUrl:[GameCommon getNewStringWithId:msgid]];
   if (buttonIndex ==1)
    {//分享到微博
        NSString * title = msgtitle;
        if ([GameCommon isEmtity:title]) {
            title = description;
        }else{
            title = [NSString stringWithFormat:@"《%@》",title];
        }
        if (title.length>100) {
            title = [title substringToIndex:100];
        }
        [[ShareToOther singleton]shareTosinass:[self getShareImageToSima:image] Title:title Description:description Url:[self getShareUrl:[GameCommon getNewStringWithId:msgid]]];
    }
    else if(buttonIndex ==2)
    {//分享到QQ
        [[ShareToOther singleton]changeScene:WXSceneSession];
        NSString * title = msgtitle;
        if ([GameCommon isEmtity:title]) {
            title = [NSString stringWithFormat:@"分享自%@的动态",userNickName];
        }
        if (title.length>100) {
            title = [title substringToIndex:100];
        }
        if ([GameCommon isEmtity:image]) {
            NSData * data = [self getNSDataFromURL:@"icon"];
            [[ShareToOther singleton] onShareToQQ:title Description:description Url:shareUrl previewImageData:data IsZone:NO];
        }else{
            [[ShareToOther singleton] onShareToQQ:title Description:description Url:shareUrl previewImageURL:[ImageService getImageString:image] IsZone:NO];
        }
    }else if(buttonIndex ==3)
    {//分享到微信
        NSString * title = msgtitle;
        if ([GameCommon isEmtity:title]) {
            title = description;
        }
        if (title.length>100) {
            title = [title substringToIndex:100];
        }
        [[ShareToOther singleton] changeScene:WXSceneTimeline];
        [[ShareToOther singleton] sendAppExtendContent_friend:[self getShareImage:image] Title:title Description:description Url:[self getShareUrl:[GameCommon getNewStringWithId:msgid]]];
    }
}

-(NSString*)getShareUrl:(NSString*)msgid
{
    return [NSString stringWithFormat:@"%@%@%@",BaseDynamicShareUrl,@"id=",msgid];
}

//请求网络图片
-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    return result;
}

//请求网络图片
-(NSData *) getNSDataFromURL:(NSString *)imageName {
    return UIImageJPEGRepresentation(KUIImage(imageName),0.8);
}

-(UIImage*)getShareImageToSima:(NSString*)image
{
    NSString * imageUrl = [ImageService getImageString:[GameCommon getNewStringWithId:image]];
    if (![GameCommon isEmtity:imageUrl]) {
        return [self getImageFromURL:imageUrl];
    }
    return nil;
}
-(UIImage*)getShareImage:(NSString *)image
{
    NSString * imageUrl = [ImageService getImageString:[GameCommon getNewStringWithId:image]];
    if (![GameCommon isEmtity:imageUrl]) {
        return [self getImageFromURL:imageUrl];
    }
    return KUIImage(@"icon");
}

@end
