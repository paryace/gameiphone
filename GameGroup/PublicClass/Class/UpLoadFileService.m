//
//  UpLoadFileService.m
//  GameGroup
//
//  Created by Apple on 14-5-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "UpLoadFileService.h"

@implementation UpLoadFileService

- (void)resumableUpload:(NSString*)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate{
    NSString * upToken=[[NSUserDefaults standardUserDefaults] objectForKey:UploadImageToken];
    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:TokenEfficaciousTime];
    
    NSString* nowTime = [GameCommon getCurrentTime];
    if ([nowTime intValue]<[time intValue]) {//token处于有效的状态
        [self simpleUpload:upToken FilePath:filePath UpDeleGate:updeleGate];
    }else{//token处于无效状态
        [self getUploadImageToken:filePath UpDeleGate:updeleGate];
    }
}

- (void)simpleUpload:(NSString*)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate{
//    NSString * upToken=[[NSUserDefaults standardUserDefaults] objectForKey:UploadImageToken];
//    NSString * time=[[NSUserDefaults standardUserDefaults] objectForKey:TokenEfficaciousTime];
//    
//    NSString* nowTime = [GameCommon getCurrentTime];
//    if ([nowTime intValue]<[time intValue]) {//token处于有效的状态
//        [self simpleUpload:upToken FilePath:filePath UpDeleGate:updeleGate];
//    }else{//token处于无效状态
        [self getUploadImageToken:filePath UpDeleGate:updeleGate];
//    }
}



#pragma mark 上传注册时头像
+(void)uploadImageWithRegister:(UIImage *)uploadImage WithURLStr:(NSString *)urlStr ImageName:(NSString *)imageName TheController:(UIViewController *)controller Progress:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))block Success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    
}



-(void)resumableUpload:(NSString *)token FilePath:(NSString *)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate
{
    QiniuResumableUploader *rUploader = [[QiniuResumableUploader alloc] initWithToken:token];
    rUploader.delegate=updeleGate;
    [rUploader uploadFile:filePath key:[[GameCommon shareGameCommon] uuid] extra:nil];
}

-(void)simpleUpload:(NSString *)token FilePath:(NSString *)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate
{
    QiniuSimpleUploader *sUploader = [QiniuSimpleUploader uploaderWithToken:token];
    sUploader.delegate = updeleGate;
    [sUploader uploadFile:filePath key:[[GameCommon shareGameCommon] uuid] extra:nil];

}

-(void)getUploadImageToken:(NSString*)filePath UpDeleGate:(id<QiniuUploadDelegate>) updeleGate
{
    NSMutableDictionary * postDict = [NSMutableDictionary dictionary];
    [postDict addEntriesFromDictionary:[[GameCommon shareGameCommon] getNetCommomDic]];
    [postDict setObject:@"222" forKey:@"method"];
    [NetManager requestWithURLStr:BaseClientUrl Parameters:postDict
    success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSLog(@"deviceToken successed:%@",responseObject);
        
//        NSString * expireSeconds=KISDictionaryHaveKey(responseObject, @"expireSeconds");
        NSString * upToken=KISDictionaryHaveKey(responseObject, @"uploadToken");
        [self simpleUpload:upToken FilePath:filePath UpDeleGate:updeleGate];
        
        
        [[NSUserDefaults standardUserDefaults] setValue:@"uploadToken" forKey:UploadImageToken];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[NSUserDefaults standardUserDefaults] setValue:@"time" forKey:TokenEfficaciousTime];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    failure:^(AFHTTPRequestOperation *operation, id error)
    {
        NSLog(@"deviceToken fail");
    }];
}


// Upload progress
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    //NSString *progressStr = [NSString stringWithFormat:@"Progress Updated: - %f\n", percent];
    
}
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    //NSString *succeedMsg = [NSString stringWithFormat:@"Upload Succeeded: - Ret: %@\n", ret];
    
}
// Upload failed
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    //NSString *failMsg = [NSString stringWithFormat:@"Upload Failed: %@  - Reason: %@", theFilePath, error];
}

@end
