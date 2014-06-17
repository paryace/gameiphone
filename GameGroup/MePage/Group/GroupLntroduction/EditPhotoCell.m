//
//  EditPhotoCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "EditPhotoCell.h"

@implementation EditPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.photoImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.photoImageView.placeholderImage = KUIImage(@"placeholder");
        [self addSubview:self.photoImageView];
        
        self.delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.delBtn.frame = CGRectMake(0, 0, 15, 15);
        self.delBtn.backgroundColor = [UIColor blueColor];
        [self addSubview:self.delBtn];
        
        
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
