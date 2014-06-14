//
//  GroupOfMineCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupOfMineCell.h"

@implementation GroupOfMineCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.headImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.headImgView.layer.cornerRadius = 5;
        self.headImgView.layer.masksToBounds=YES;
        [self addSubview:self.headImgView];

        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-20, frame.size.width, 20)];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [UIFont systemFontOfSize:10];
        [self.headImgView addSubview:self.titleLabel];
        
        
    }
    return self;
}

@end
