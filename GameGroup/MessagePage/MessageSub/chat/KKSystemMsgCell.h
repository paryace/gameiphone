//
//  KKSystemMsgCell.h
//  GameGroup
//
//  Created by Apple on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
// UIImageView * lineImage1

#import <UIKit/UIKit.h>

@interface KKSystemMsgCell : UITableViewCell
@property (nonatomic, strong) UILabel *timeLable;
@property (nonatomic, strong) UILabel *msgLable;
@property (nonatomic, strong) UIImageView *lineImage1;
@property (nonatomic, strong) UIImageView *lineImage2;
-(void)setMsgTime:(NSString*)timeStr lastTime:(NSString*)lasttime previousTime:(NSString*)previoustime;
@end
