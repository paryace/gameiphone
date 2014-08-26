//
//  PlayVoiceCell.m
//  GameGroup
//
//  Created by 魏星 on 14-8-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "PlayVoiceCell.h"

@implementation PlayVoiceCell
{
    NSInteger cellIndex;
    BOOL isPlay;
    NSMutableArray *gifArray1;
    NSMutableArray *gifArray2;
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
        // Initialization code
        isPlay = NO;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopPlay:) name:STOPPLAYAUDIO object:nil] ;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startPaly:) name:STARTPLAYAUDIO object:nil] ;
        
        gifArray1 = [NSMutableArray array];
        [gifArray1 addObject:KUIImage(@"SenderVoiceNodePlaying001")];
        [gifArray1 addObject:KUIImage(@"SenderVoiceNodePlaying002")];
        [gifArray1 addObject:KUIImage(@"SenderVoiceNodePlaying003")];
        
        gifArray2 = [NSMutableArray array];
        [gifArray2 addObject:KUIImage(@"ReceiverVoiceNodePlaying001")];
        [gifArray2 addObject:KUIImage(@"ReceiverVoiceNodePlaying002")];
        [gifArray2 addObject:KUIImage(@"ReceiverVoiceNodePlaying003")];

//        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(startPaly:) name:@"playingAudio" object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(stopPlay:) name:@"StopPlayingAudio" object:nil];
        

//        self.backgroundColor = [UIColor greenColor];
        self.voiceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 10, 10)];
        self.voiceImageView.image = KUIImage(@"SenderVoiceNodePlaying003");
//        [self.voiceImageView startAnimating];
        [self addSubview:self.voiceImageView];
        
//        [self.voiceImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playAudio:)]];
        
    }
    return self;
}
-(void)setIMGAnimationWithArray:(NSMutableArray *)array
{
//    self.voiceImageView.animationImages = array; //动画图片数组
    [self.voiceImageView setAnimationImages:array];
}
-(void)playAudio:(id)sender
{
    if (!isPlay) {
        isPlay = YES;
        [self startPaly];
        [self.mydelegate playAudioWithCell:self];
    }else{
        isPlay =NO;
        [self stopPlay];
    }
}

-(void)startPaly:(id)sender
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
-(void)stopPlay:(id)sender
{
    [self.voiceImageView stopAnimating];
}


-(void)uploadAudio:(NSInteger)index
{
    NSString *str =[NSString stringWithFormat:@"%@/%@.amr",RootDocPath,KISDictionaryHaveKey(self.message, @"messageuuid")];
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




- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
