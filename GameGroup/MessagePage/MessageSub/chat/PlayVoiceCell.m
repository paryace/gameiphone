//
//  PlayVoiceCell.m
//  GameGroup
//
//  Created by 魏星 on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PlayVoiceCell.h"
#import "AudioDownLoader.h"

@implementation PlayVoiceCell
{
    NSInteger cellIndex;
    NSMutableArray *gifArray1;
    NSMutableArray *gifArray2;
    NSMutableData *receivedData;
    NSURLConnection *connection;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopPlay:) name:STOPPLAYAUDIO object:nil] ;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startPaly:) name:STARTPLAYAUDIO object:nil] ;
        receivedData = [NSMutableData data];

        gifArray1 = [NSMutableArray array];
        [gifArray1 addObject:KUIImage(@"SenderVoiceNodePlaying001")];
        [gifArray1 addObject:KUIImage(@"SenderVoiceNodePlaying002")];
        [gifArray1 addObject:KUIImage(@"SenderVoiceNodePlaying003")];
        
        gifArray2 = [NSMutableArray array];
        [gifArray2 addObject:KUIImage(@"ReceiverVoiceNodePlaying001")];
        [gifArray2 addObject:KUIImage(@"ReceiverVoiceNodePlaying002")];
        [gifArray2 addObject:KUIImage(@"ReceiverVoiceNodePlaying003")];
        

        self.voiceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 10, 10)];
        self.voiceImageView.image = KUIImage(@"SenderVoiceNodePlaying003");
        [self addSubview:self.voiceImageView];
        
        self.audioTimeSizeLb = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 20, 20)];
        self.audioTimeSizeLb.backgroundColor = [UIColor clearColor];
        self.audioTimeSizeLb.textColor = [UIColor grayColor];
        self.audioTimeSizeLb.font = [UIFont boldSystemFontOfSize:12];
        self.audioTimeSizeLb.textAlignment =NSTextAlignmentCenter;
        [self addSubview:self.audioTimeSizeLb];
        self.audioRedImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
        self.audioRedImg.image = KUIImage(@"msg_audio_red");
        [self addSubview:self.audioRedImg];
        
    }
    return self;
}

-(void)startPaly
{
    if (self.cellCount !=self.tag) {
        return;
    }
    if ([self.sendType isEqualToString:@"you"]) {
        [self.voiceImageView setAnimationImages:gifArray1];
    }else{
        [self.voiceImageView setAnimationImages:gifArray2];
    }
    self.voiceImageView.animationDuration = 1; //执行一次完整动画所需的时长
    self.voiceImageView.animationRepeatCount = 10000;  //动画重复次数
    [self.voiceImageView startAnimating];
}
-(void)stopPlay
{
    if (self.cellCount !=self.tag) {
        return;
    }
    [self.voiceImageView stopAnimating];
}


-(void)uploadAudio:(NSInteger)index
{
    NSDictionary *dic =[[self.message objectForKey:@"payload"]JSONValue];
    NSString *str = [dic objectForKey:@"messageid"];
    NSString * state = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(self.message, @"status")];
    if ([state isEqualToString:@"10"]) {//假如还没有执行上传操作
        if (self.uploaddelegate) {
            [self.uploaddelegate uploading:index];
        }
        cellIndex=index;
        UpLoadFileService * up = [[UpLoadFileService alloc] init];
        [up simpleUploadAudio:str upDeleGate:self];
    }
}

// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
    NSLog(@"--uploadpercent--%f",percent);
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSLog(@"上传成功");
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];
    NSString *ps = [self getVoideFilePath:response];
    NSData* fileData = [NSData dataWithContentsOfFile:theFilePath];
    [[AudioManager singleton]isHaveThisFolderWithFilePath:[NSString stringWithFormat:@"%@/voice",RootDocPath]];
    [fileData writeToFile:ps atomically:YES];
    if (self.uploaddelegate) {
        [self.uploaddelegate uploadFinish:cellIndex];//上传完成
    }
    if (self.mydelegate) {
        [self.mydelegate sendAudioMsg:response Index:cellIndex];
    }
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    NSLog(@"上传失败");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送语音失败请重新发送" delegate:nil cancelButtonTitle:@"知道啦"otherButtonTitles:nil];
    [alert show];
    if (self.uploaddelegate) {
        [self.uploaddelegate uploadFail:cellIndex];//上传失败
    }
}

#pragma mark --- 下载语音消息并且保存到沙盒
-(void)downLoadAudioFromNet
{
    [AudioDownLoader fileDownloaderWithURLString:[self getUrlPath:KISDictionaryHaveKey(self.payloadDict, @"messageid")] MessageId:KISDictionaryHaveKey(self.payloadDict, @"messageid") delegate:nil];
}

-(NSString*)getUrlPath:(NSString*)messageId{
    return [NSString stringWithFormat:@"%@%@",QiniuBaseImageUrl,[GameCommon getNewStringWithId:messageId]];
}
-(NSString*)getVoideFilePath:(NSString*)messageId{
    return [NSString stringWithFormat:@"%@/voice/%@",RootDocPath,[[AudioManager singleton]changeStringWithString:[GameCommon getNewStringWithId:messageId]]];
}
@end
