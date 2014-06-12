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
        // Initialization code
        self.headImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.headImgView];

        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, frame.size.height-20, frame.size.width, 20)];
        self.titleLabel.backgroundColor = [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont systemFontOfSize:10];
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
