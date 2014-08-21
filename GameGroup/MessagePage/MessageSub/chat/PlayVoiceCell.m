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
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        isPlay = NO;
//        self.backgroundColor = [UIColor greenColor];
//        NSMutableArray *gifArray = [NSMutableArray arrayWithObjects:@"SenderVoiceNodePlaying001",@"SenderVoiceNodePlaying002",@"SenderVoiceNodePlaying003", nil];
        self.voiceImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 10, 10)];
        self.voiceImageView.image = KUIImage(@"SenderVoiceNodePlaying003");
//        self.voiceImageView.animationImages = gifArray; //动画图片数组
        self.voiceImageView.animationDuration = 3; //执行一次完整动画所需的时长
        self.voiceImageView.animationRepeatCount = 10;  //动画重复次数
//        [self.voiceImageView startAnimating];
        [self addSubview:self.voiceImageView];
        
//        [self.voiceImageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playAudio:)]];
        
    }
    return self;
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

-(void)startPaly
{
    [self.voiceImageView startAnimating];
}
-(void)stopPlay
{
    [self.voiceImageView stopAnimating];
}


-(void)uploadAudio:(NSString*)audioPath cellIndex:(NSInteger)index
{
    cellIndex=index;
    UpLoadFileService * up = [[UpLoadFileService alloc] init];
    [up simpleUpload:audioPath UpDeleGate:self];
}

// 上传进度
- (void)uploadProgressUpdated:(NSString *)theFilePath percent:(float)percent
{
}
//上传成功代理回调
- (void)uploadSucceeded:(NSString *)theFilePath ret:(NSDictionary *)ret
{
    NSString *response = [GameCommon getNewStringWithId:KISDictionaryHaveKey(ret, @"key")];//图片id
    if (self.mydelegate) {
        [self.mydelegate sendAudioMsg:response Index:cellIndex];
    }
}
//上传失败代理回调
- (void)uploadFailed:(NSString *)theFilePath error:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"发送语音失败请重新发送" delegate:nil cancelButtonTitle:@"知道啦"otherButtonTitles:nil];
    [alert show];
    if (self.mydelegate) {
        [self.mydelegate refreStatus:cellIndex];
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
