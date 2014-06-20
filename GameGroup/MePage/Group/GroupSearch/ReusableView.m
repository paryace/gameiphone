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
        [self addSubview:self.topBtn];
        self.headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        self.headImageView.placeholderImage = KUIImage(@"group_icon");
        [self.topBtn addSubview:self.headImageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 320-80, 40)];
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
        
        UIImageView * lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 71, 320, 1)];
        lineImage.image = KUIImage(@"my_group_line");
        [self.topBtn addSubview:lineImage];
        
        
        self.gbMsgCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(53, 6, 18, 18)];
        [self.gbMsgCountImageView setImage:[UIImage imageNamed:@"redCB.png"]];
        self.gbMsgCountImageView.hidden = YES;
        [self.topBtn addSubview:self.gbMsgCountImageView];
        
        
        self.gbMsgCountLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        [self.gbMsgCountLable setBackgroundColor:[UIColor clearColor]];
        [self.gbMsgCountLable setTextAlignment:NSTextAlignmentCenter];
        [self.gbMsgCountLable setTextColor:[UIColor whiteColor]];
        self.gbMsgCountLable.font = [UIFont systemFontOfSize:14.0];
        self.gbMsgCountLable.text = @"20";
        [self.gbMsgCountImageView addSubview:self.gbMsgCountLable];
        
        
        [self addSubview:self.topBtn];
        
    }
    return self;
}

@end
