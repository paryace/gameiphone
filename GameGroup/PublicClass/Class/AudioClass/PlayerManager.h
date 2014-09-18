//
//  PlayerManager.h
//  OggSpeex
//
//  Created by Jiang Chuncheng on 6/25/13.
//  Copyright (c) 2013 Sense Force. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Decapsulator.h"

@protocol PlayingDelegate <NSObject>

- (void)playingStoped;

@end

@interface PlayerManager : NSObject <DecapsulatingDelegate, AVAudioPlayerDelegate> {
    Decapsulator *decapsulator;
    
}
@property (nonatomic, strong) Decapsulator *decapsulator;
@property (nonatomic, weak)  id<PlayingDelegate> delegate;
@property (assign, nonatomic)  NSInteger playIndex;
@property(nonatomic, retain)   NSString * messageuuid;

+ (PlayerManager *)sharedManager;

- (void)playAudioWithFileName:(NSString *)filename delegate:(id<PlayingDelegate>)newDelegate;
- (void)stopPlaying;

@end
