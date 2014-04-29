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
@interface KKImgCell : KKChatCell
@property (nonatomic, strong) EGOImageView *msgImageView;
@property (nonatomic, strong) UIProgressView *progressView;



@end
