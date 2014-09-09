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
    UIImageView * m_RecordImageView;
    BOOL isRecordMove;
    CGPoint currentLocation;
    CGPoint originalLocation;
    BOOL isReady;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.frame =CGRectMake(0, self.view.frame.size.height-50,320,50);
        isReady = YES;
//        UIImage *rawEntryBackground = [UIImage imageNamed:@"chat_input.png"];
//        UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13
//                                                                           topCapHeight:22];
//        UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
//        entryImageView.frame = CGRectMake(40, 7.5f, 206, 29);
//        entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        UIImage *rawBackground = [UIImage imageNamed:@"inputbg.png"];
        UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
        imageView.frame = CGRectMake(0,0,self.frame.size.width,self.frame.size.height);
        imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        [self addSubview:imageView];
//        [self addSubview:entryImageView];
        
        //声音button
        UIButton *  customAudioBtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 9.5f, 25, 25)];
//        customAudioBtn.center = CGPointMake(15, self.center.y);
        customAudioBtn.backgroundColor = [UIColor clearColor];
        customAudioBtn.titleLabel.numberOfLines = 0;
        [customAudioBtn setImage:KUIImage(@"keyboard") forState:UIControlStateNormal];
//        [customAudioBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [customAudioBtn addTarget:self action:@selector(hiddenStartRecordBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:customAudioBtn];
        //        [self addSubview:self.startRecordBtn];
        //        self.startRecordBtn.userInteractionEnabled = NO;
        //        self.startRecordBtn.hidden = NO;
        
        //录音button
        m_RecordImageView = [[UIImageView alloc]initWithFrame:CGRectMake(41, 4.5f, 206, 35)];
        m_RecordImageView.image = KUIImage(@"chat_recordAudio_normal");
//        m_RecordImageView.backgroundColor = [UIColor redColor];
        m_RecordImageView.userInteractionEnabled = YES;
        [self addSubview:m_RecordImageView];
        
        //加号button
        UIButton *customKKchatAddBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        customKKchatAddBtn.frame = CGRectMake(253,9.5f,25,25);
        
        [customKKchatAddBtn setImage:[UIImage imageNamed:@"kkChatAddButtonNomal.png"]forState:UIControlStateNormal];
//        [customKKchatAddBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [customKKchatAddBtn addTarget:self action:@selector(kkChatAddButtonClick:)forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:customKKchatAddBtn];
        
        //表情button
        UIButton * CustomEmojiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        CustomEmojiBtn.frame = CGRectMake(285, 9.5f,25,25);
        [CustomEmojiBtn setImage:[UIImage imageNamed:@"emoji.png"] forState:UIControlStateNormal];
        [CustomEmojiBtn addTarget:self action:@selector(kkChatEmojiBtnClicked:)forControlEvents:UIControlEventTouchUpInside];
//        [CustomEmojiBtn setImageEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        
        [self addSubview:CustomEmojiBtn];

    }
    return self;
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
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
     if ([touch view]==m_RecordImageView&&isReady ==YES)
    {
        isRecordMove = YES;
        isReady = NO;
        m_RecordImageView.image = KUIImage(@"chat_recordAudio_click");
        originalLocation = [touch locationInView:self];
        [self.mydelegate beginRecordWithView:self];
    }
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    
    if (isRecordMove) {
        currentLocation = [touch locationInView:self];
        if (originalLocation.y-currentLocation.y>20) {
            [self.mydelegate touchMovedWithView:self];
        }else{
            [self.mydelegate  touchMoveBackWithView:self];
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isRecordMove) {
        if (currentLocation.y!=0&& originalLocation.y-currentLocation.y>40) {
//            [[RecorderManager sharedManager]cancelRecording];
            [self.mydelegate cancleRecordWithView:self];
            [self performSelector:@selector(changeBool) withObject:self afterDelay:1];
        }else{
            [self.mydelegate RecordSuccessWithView:self];
            [self performSelector:@selector(changeBool) withObject:self afterDelay:1];

//            [[RecorderManager sharedManager]stopRecording];
        }
        isRecordMove = NO;
         m_RecordImageView.image = KUIImage(@"chat_recordAudio_normal");
//        showRecordView.imageView.image = KUIImage(@"third_xiemessage_record_icon");
//        showRecordView.m_bodongImg.hidden = NO;
//        showRecordView.backgroundColor = UIColorFromRGBA(0x000000, .7);
        
    }
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isRecordMove) {
//        [[RecorderManager sharedManager]cancelRecording];
        [self.mydelegate cancleRecordWithView:self];
        isRecordMove = NO;
         m_RecordImageView.image = KUIImage(@"chat_recordAudio_normal");
//        showRecordView.imageView.image = KUIImage(@"third_xiemessage_record_icon");
//        showRecordView.m_bodongImg.hidden = NO;
//        
//        showRecordView.backgroundColor = UIColorFromRGBA(0x000000, .7);
        
        
    }
}
-(void)changeBool
{
    isReady =YES;
}

-(void)rechangReadyState{
    if (isReady == NO) {
        [self changeBool];
    }
}

@end
