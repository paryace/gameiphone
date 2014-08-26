//
//  UpLoadFileService.m
//  GameGroup
//
//  Created by Apple on 14-5-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "UpLoadFileService.h"
static UpLoadFileService *upload = NULL;

@implementation UpLoadFileService

+ (UpLoadFileService*)singleton
{
    @synchronized(self)
    {
		if (upload == nil)
		{
			upload = [[self alloc] init];
		}
	}
	return upload;
}




#pragma mark ---上传图片
- (void)simpleUpload:(NSString*)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate{
    NSString * upToken=[[NSUserDefaults standardUserDefaults] objectForKey:UploadImageToken];
    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:TokenEfficaciousTime];
    long long expireSeconds = [time longLongValue];
    if (upToken && expireSeconds && (expireSeconds>[self getCurrentTime])) {//token处于有效的状态
        [self simpleUpload:upToken FilePath:filePath UpDeleGate:updeleGate];
    }else{//token处于无效状态
        [self getUploadImageToken:filePath UpDeleGate:updeleGate Type:0];
    }
}

#pragma mark---上传声音
-(void)simpleUploadAudio:(NSString *)filePath upDeleGate:(id<QiniuUploadDelegate>)updeleGate
{
    NSString * upToken=[[NSUserDefaults standardUserDefaults] objectForKey:UploadImageToken];
    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:TokenEfficaciousTime];
    long long expireSeconds = [time longLongValue];
    if (upToken && expireSeconds && (expireSeconds>[self getCurrentTime])) {//token处于有效的状态
        [self simpleUpload:upToken AudioFilePath:filePath UpDeleGate:updeleGate];
    }else{//token处于无效状态
        [self getUploadImageToken:filePath UpDeleGate:updeleGate Type:1];
    }

}


-(void)simpleUpload:(NSString *)token FilePath:(NSString *)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate
{
    QiniuSimpleUploader *sUploader = [QiniuSimpleUploader uploaderWithToken:token];
    sUploader.delegate = updeleGate;
    [sUploader uploadFile:filePath key:[[GameCommon shareGameCommon] uuid] extra:nil];

}

-(void)simpleUpload:(NSString *)token AudioFilePath:(NSString *)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate
{
    QiniuSimpleUploader *sUploader = [QiniuSimpleUploader uploaderWithToken:token];
    sUploader.delegate = updeleGate;
    NSDate *date = [NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"YYYYMMdd"];
    NSString * locationString=[dateformatter stringFromDate:date];

    [sUploader uploadFile:filePath key:[NSString stringWithFormat:@"audio/%@/%@.spx",locationString,[[GameCommon shareGameCommon] uuid]] extra:nil];

}

-(void)getUploadImageToken:(NSString*)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate Type:(NSInteger)type
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"222" forKey:@"method"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
    success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"deviceToken successed:%@",responseObject);
        NSString * expireSeconds=KISDictionaryHaveKey(responseObject, @"expireSeconds");
        long long alltime =([expireSeconds longLongValue]*1000)+[self getCurrentTime];
        NSString *alltimeString=[NSString stringWithFormat:@"%lld",alltime];
        NSString * upToken=KISDictionaryHaveKey(responseObject, @"uploadToken");
        if (type == 0) {
            [self simpleUpload:upToken FilePath:filePath UpDeleGate:updeleGate];
        }else if(type == 1){
            [self simpleUpload:upToken AudioFilePath:filePath UpDeleGate:updeleGate];
        }
        [[NSUserDefaults standardUserDefaults] setValue:upToken forKey:UploadImageToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setValue:alltimeString forKey:TokenEfficaciousTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    failure:^(AFHTTPRequestOperation *operation, id error)
    {
        NSLog(@"deviceToken fail");
    }];
}
-(long long)getCurrentTime{
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    nowTime = nowTime*1000;
    return (long long)nowTime;
}
@end
