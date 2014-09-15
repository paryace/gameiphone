//
//  SendFileManager.m
//  GameGroup
//
//  Created by Apple on 14-9-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SendFileManager.h"
static SendFileManager *sendFileManager = NULL;
@implementation SendFileManager
+ (SendFileManager*)singleton
{
    @synchronized(self)
    {
		if (sendFileManager == nil)
		{
			sendFileManager = [[self alloc] init];
		}
	}
	return sendFileManager;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheMessages = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)addUploadImage:(int)index FilePath:(NSString*)filePath SendFileDelegate:(id<SendFileMessageDelegate>) updeleGate
{
    self.uploaddelegate = updeleGate;
    [self.cacheMessages setObject:[NSNumber numberWithInt:index] forKey:filePath];
    if(self.uploaddelegate) {
        [self.uploaddelegate uploading:index Type:@"image"];
    }
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:filePath UpDeleGate:self];
}

// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    if (self.uploaddelegate) {
        [self.uploaddelegate uploadProgressUpdated:[[self.cacheMessages objectForKey:theFilePath] intValue] percent:percent Type:@"image"];//上传进度
    }
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    if (self.uploaddelegate) {
        [self.uploaddelegate uploadFinish:[[self.cacheMessages objectForKey:theFilePath] intValue] FileKey:response Type:@"image"];//上传完成
    }
    [self.cacheMessages removeObjectForKey:theFilePath];
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    if (self.uploaddelegate) {
        [self.uploaddelegate uploadFail:[[self.cacheMessages objectForKey:theFilePath] intValue] Type:@"image"];//上传失败
    }
    [self.cacheMessages removeObjectForKey:theFilePath];
}

@end
