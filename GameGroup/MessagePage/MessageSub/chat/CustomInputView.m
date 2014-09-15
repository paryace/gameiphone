//
//  CustomInputView.m
//  GameGroup
//
//  Created by 魏星 on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CustomInputView.h"
@implementation CustomInputView
{
    CGPoint currentLocation;
    CGPoint originalLocation;
    BOOL isReady;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isReady = YES;
        UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
        UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        
        //声音button
        UIButton *  customAudioBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 9.5f, 25, 25)];
        customAudioBtn.backgroundColor = [UIColor clearColor];
        customAudioBtn.titleLabel.numberOfLines = 0;
        [customAudioBtn setImage:KUIImage(@"keyboard") forState:UIControlStateNormal];
        [customAudioBtn addTarget:self action:@selector(hiddenStartRecordBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:customAudioBtn];
        
        //录音button
        _RecordImageView = [[UIButton alloc]initWithFrame:CGRectMake(41, 7, 206, 29)];
        _RecordImageView.userInteractionEnabled = YES;
        [_RecordImageView setImage:KUIImage(@"chat_recordAudio_normal") forState:UIControlStateNormal];
        [_RecordImageView setImage:KUIImage(@"chat_recordAudio_click") forState:UIControlStateHighlighted];
        [_RecordImageView addTarget:self action:@selector(holdDownButtonTouchDown) forControlEvents:UIControlEventTouchDown];
        [_RecordImageView addTarget:self action:@selector(holdDownButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
        [_RecordImageView addTarget:self action:@selector(holdDownButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [_RecordImageView addTarget:self action:@selector(holdDownDragOutside) forControlEvents:UIControlEventTouchDragExit];
        [_RecordImageView addTarget:self action:@selector(holdDownDragInside) forControlEvents:UIControlEventTouchDragEnter];
        [self addSubview:_RecordImageView];
        
        //加号button
        UIButton *customKKchatAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        customKKchatAddBtn.frame = CGRectMake(253,9.5f,25,25);
        [customKKchatAddBtn setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
        [customKKchatAddBtn addTarget:self action:@selector(kkChatAddButtonClick:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:customKKchatAddBtn];
        
        //表情button
        UIButton * CustomEmojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CustomEmojiBtn.frame = CGRectMake(285, 9.5f,25,25);
        [CustomEmojiBtn setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
        [CustomEmojiBtn addTarget:self action:@selector(kkChatEmojiBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:CustomEmojiBtn];
    }
    return self;
}



//手指按下开始录音
- (void)holdDownButtonTouchDown {
    if (isReady ==YES){
        isReady = NO;
        [self.mydelegate beginRecordWithView:self];
    }
}
//取消本次录音
- (void)holdDownButtonTouchUpOutside {
    [self.mydelegate cancleRecordWithView:self];
    [self performSelector:@selector(changeBool) withObject:self afterDelay:1];
}
//正常录音完成
- (void)holdDownButtonTouchUpInside {
    //半秒后执行完成录音
    [self performSelector:@selector(afterharfs) withObject:self afterDelay:.5f];
    //一秒后令录音button 启用
    [self performSelector:@selector(changeBool) withObject:self afterDelay:1];
}
//手指移动到取消录制范围
- (void)holdDownDragOutside {
    [self.mydelegate touchMovedWithView:self];
}
//手指移动回来重新录制
- (void)holdDownDragInside {
    [self.mydelegate  touchMoveBackWithView:self];
}

-(void)hiddenStartRecordBtn:(id)sender
{
    [self.mydelegate didClickAudioWithView:self];
}

-(void)kkChatEmojiBtnClicked:(id)sender
{
    [self.mydelegate didClickEmjoWithView:self];
}
-(void)kkChatAddButtonClick:(id)sender
{
    [self.mydelegate didClickkkchatAddBtnWithView:self];
}
//正常录音完成
-(void)afterharfs
{
    [self.mydelegate RecordSuccessWithView:self];

}
-(void)changeBool
{
    isReady =YES;
}

-(void)rechangReadyState{
    if (isReady == NO) {
         isReady =YES;
    }
}

@end
