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
        self.backgroundColor = [UIColor colorWithRed:76/255.0f green:75/255.0f blue:81/255.0f alpha:1];
        
        self.headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 15, 40, 40)];
        self.headImageView.placeholderImage = KUIImage(@"mess_news");
        [self addSubview:self.headImageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(70, 10, 210, 40)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.label.numberOfLines =2;
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:13.0f];
        self.label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
        self.contentLabel =  [[UILabel alloc] initWithFrame:CGRectMake(70, 45, 130, 15)];
        self.contentLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
        self.contentLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.contentLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.contentLabel];
        
        self.timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(200, 45, 210, 15)];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font = [UIFont boldSystemFontOfSize:13.0f];
        self.timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.timeLabel];


    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
