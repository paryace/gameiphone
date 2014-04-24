//
//  ImgCollCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ImgCollCell.h"

@implementation ImgCollCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
        [self addSubview:self.imageView];
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
