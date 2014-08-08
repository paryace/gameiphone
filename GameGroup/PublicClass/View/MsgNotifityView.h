//
//  MsgNotifityView.h
//  GameGroup
//
//  Created by Apple on 14-7-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgNotifityView : UIView
@property (strong,nonatomic) UILabel * unreadCountLabel;
@property (strong,nonatomic) UIImageView * notiBgV;

-(void)setMsgCount:(NSInteger)msgCount;

-(void)setMsgCount:(NSInteger)msgCount IsSimple:(BOOL)isSimple;

-(void)hide;

-(void)show;

-(void)simpleDot;

@end
