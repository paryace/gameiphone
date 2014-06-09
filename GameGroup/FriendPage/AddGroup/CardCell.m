//
//  CardCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CardCell.h"

@implementation CardCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.bgImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.bgImgView];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.titleLabel .textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.titleLabel];

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
