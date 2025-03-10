//
//  RecorderManager.mm
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import "RecorderManager.h"
#import "AQRecorder.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface RecorderManager()

- (void)updateLevelMeter:(id)sender;
- (void)stopRecording:(BOOL)isCanceled;

@end

@implementation RecorderManager

@synthesize dateStartRecording, dateStopRecording;
@synthesize encapsulator;
@synthesize timerLevelMeter;
@synthesize timerTimeout;

static RecorderManager *mRecorderManager = nil;
AQRecorder *mAQRecorder;
AudioQueueLevelMeterState *levelMeterStates;

+ (RecorderManager *)sharedManager {
    @synchronized(self) {
        if (mRecorderManager == nil)
        {
            mRecorderManager = [[self alloc] init];
        }
    }
    return mRecorderManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if(mRecorderManager == nil)
        {
            mRecorderManager = [super allocWithZone:zone];
            return mRecorderManager;
        }
    }
    
    return nil;
}
//开始录音
- (void)startRecording {
     AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    if ( ! mAQRecorder) {
        mAQRecorder = new AQRecorder();
        OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListener, (__bridge void *)self);
        if (error) printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
        else
        {
            UInt32 category = kAudioSessionCategory_PlayAndRecord;
            error = AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(category), &category);
            if (error) printf("couldn't set audio category!");
            error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, propListener, (__bridge void *)self);
            if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
            UInt32 inputAvailable = 0;
            UInt32 size = sizeof(inputAvailable);
            // we do not want to allow recording if input is not available
            error = AudioSessionGetProperty(kAudioSessionProperty_AudioInputAvailable, &size, &inputAvailable);
            if (error) printf("ERROR GETTING INPUT AVAILABILITY! %d\n", (int)error);
            // we also need to listen to see if input availability changes
            error = AudioSessionAddPropertyListener(kAudioSessionProperty_AudioInputAvailable, propListener, (__bridge void *)self);
            if (error) printf("ERROR ADDING AUDIO SESSION PROP LISTENER! %d\n", (int)error);
            error = AudioSessionSetActive(true);
            if (error) printf("AudioSessionSetActive (true) failed");
        }
    }
    filename = [NSString stringWithString:[Encapsulator defaultFileName]];
    if ( ! self.encapsulator) {
        self.encapsulator = [[Encapsulator alloc] initWithFileName:filename];
        self.encapsulator.delegete = self;
    }
    else {
        [self.encapsulator resetWithFileName:filename];
    }
    if ( ! mAQRecorder->IsRunning()) {
        NSLog(@"audio session category : %@", [[AVAudioSession sharedInstance] category]);
        Boolean recordingWillBegin = mAQRecorder->StartRecord(encapsulator);
        if ( ! recordingWillBegin) {
            if ([self.delegate respondsToSelector:@selector(recordingFailed:)]) {
                [self.delegate recordingFailed:filename];
            }
            return;
        }
    }

    self.dateStartRecording = [NSDate date];
    
    if (!levelMeterStates)
    {
        levelMeterStates = (AudioQueueLevelMeterState *)malloc(sizeof(AudioQueueLevelMeterState) * 1);
    }
    self.timerLevelMeter = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateLevelMeter:) userInfo:nil repeats:YES];
    self.timerTimeout = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeoutCheck:) userInfo:nil repeats:NO];
}
//停止录音
- (void)stopRecording {
    [self stopRecording:NO];
}
//取消录音
- (void)cancelRecording {
    [self stopRecording:YES];
}
//停止录音
- (void)stopRecording:(BOOL)isCanceled {
    if (self.delegate) {
        [self.delegate recordingStopped];
    }
    if (isCanceled) {
        if (self.encapsulator) {
            [self.encapsulator stopEncapsulating:YES];
        }
    }
    [self.timerLevelMeter invalidate];
    [self.timerTimeout invalidate];
    self.timerLevelMeter = nil;
    if (mAQRecorder) {
        mAQRecorder->StopRecord();
    }
    self.dateStopRecording = [NSDate date];
    [self audioPlayerDidFinishPlaying];
}
//录音完成
- (void)encapsulatingOver {
    if (self.delegate) {
        [self.delegate recordingFinishedWithFileName:filename time:[self recordedTimeInterval]];
    }
    [self audioPlayerDidFinishPlaying];
}
//录音过程
- (NSTimeInterval)recordedTimeInterval {
    return (dateStopRecording && dateStartRecording) ? [dateStopRecording timeIntervalSinceDate:dateStartRecording] : 0;
}
//录音过程
- (void)updateLevelMeter:(id)sender {
    if (self.delegate) {
        UInt32 dataSize = sizeof(AudioQueueLevelMeterState);
        AudioQueueGetProperty(mAQRecorder->Queue(), kAudioQueueProperty_CurrentLevelMeter, levelMeterStates, &dataSize);
        if ([self.delegate respondsToSelector:@selector(levelMeterChanged:)]) {
            [self.delegate levelMeterChanged:levelMeterStates[0].mPeakPower];
        }

    }
}
//录音超时
- (void)timeoutCheck:(id)sender {
    [[self delegate] recordingTimeout];
    [self audioPlayerDidFinishPlaying];
}

- (void)dealloc {
    if (mAQRecorder) {
        delete mAQRecorder;
    }
    if (levelMeterStates)
    {
        delete levelMeterStates;
    }
    self.encapsulator = nil;
}
//初始化
- (void)audioPlayerDidFinishPlaying{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
    audioSession = nil;
}
#pragma mark AudioSession listeners
void interruptionListener(	void *	inClientData,
                          UInt32	inInterruptionState)
{
	RecorderManager *THIS = (__bridge RecorderManager*)inClientData;
	if (inInterruptionState == kAudioSessionBeginInterruption)
	{
		if (mAQRecorder->IsRunning()) {
			[THIS stopRecording];
		}
	}
}

void propListener(	void *                  inClientData,
                  AudioSessionPropertyID	inID,
                  UInt32                  inDataSize,
                  const void *            inData)
{
	RecorderManager *THIS = (__bridge RecorderManager*)inClientData;
	if (inID == kAudioSessionProperty_AudioRouteChange)
	{
		CFDictionaryRef routeDictionary = (CFDictionaryRef)inData;
		//CFShow(routeDictionary);
		CFNumberRef reason = (CFNumberRef)CFDictionaryGetValue(routeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
		SInt32 reasonVal;
		CFNumberGetValue(reason, kCFNumberSInt32Type, &reasonVal);
		if (reasonVal != kAudioSessionRouteChangeReason_CategoryChange)
		{
			// stop the queue if we had a non-policy route change
			if (mAQRecorder->IsRunning()) {
				[THIS stopRecording];
			}
		}
	}
	else if (inID == kAudioSessionProperty_AudioInputAvailable)
	{
		if (inDataSize == sizeof(UInt32))
        {
//			UInt32 isAvailable = *(UInt32*)inData;
			// disable recording if input is not available
//			BOOL available = (isAvailable > 0) ? YES : NO;
		}
	}
}

@end
