//
//  ReusableView.m
//  GameGroup
//
//  Created by 魏星 on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReusableView.h"

@implementation ReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1];
        self.topBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
        [self.topBtn  setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [self addSubview:self.topBtn];
        self.headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 15, 40, 40)];
        self.headImageView.placeholderImage = KUIImage(@"mess_news");
        [self.topBtn addSubview:self.headImageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(70, 5, 320-80, 40)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.label.numberOfLines =2;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.font = [UIFont boldSystemFontOfSize:13.0f];
        self.label.textColor = [UIColor grayColor];
        [self.topBtn addSubview:self.label];
        
        self.contentLabel =  [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 130, 15)];
        self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        self.contentLabel.textColor = [UIColor grayColor];
        [self.topBtn addSubview:self.contentLabel];
        
        self.timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(220, 45, 100, 15)];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        self.timeLabel.textColor = [UIColor grayColor];
        [self.topBtn addSubview:self.timeLabel];
        
        self.topLabel =  [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 320-40, 70)];
        self.topLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.topLabel.backgroundColor = [UIColor clearColor];
        self.topLabel.textAlignment = NSTextAlignmentCenter;
        self.topLabel.font = [UIFont boldSystemFontOfSize:12.0f];
        self.topLabel.numberOfLines=2;
        self.topLabel.text=@"点击这里，可以通过标签找到与你兴趣相同得群组织，立即收获游戏小伙伴";
        self.topLabel.textColor = [UIColor grayColor];
        [self.topBtn addSubview:self.topLabel];
        [self addSubview:self.topBtn];
        
    }
    return self;
}

@end
