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
        self.imageView = [[EGOImageView alloc]initWithFrame:self.bounds];
        self.imageView.placeholderImage = KUIImage(@"placeholder");
        self.imageView.userInteractionEnabled = YES;
        [self addSubview:self.imageView];
    }
    return self;
}
- (void)dealloc
{
    self.imageView.imageURL =nil;
}

@end
