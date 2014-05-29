//
//  KKImgCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"
#import "KKChatCell.h"
#import "KKMessageCell.h"
@protocol SendMsgDeleGate;

@interface KKImgCell : KKChatCell<QiniuUploadDelegate>
@property (nonatomic, strong) EGOImageView *msgImageView;
@property (nonatomic, strong) UIProgressView *progressView;

@property(nonatomic,assign)id<SendMsgDeleGate>sendMsgDeleGate;
-(void)uploadImage:(NSString*)imagePath cellIndex:(int)index;
@end
@protocol SendMsgDeleGate <NSObject>

-(void)sendMsg:(NSString *)imageId Index:(NSInteger)index;
-(void)refreStatus:(NSInteger)cellIndex;
@end

