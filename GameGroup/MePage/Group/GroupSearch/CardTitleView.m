//
//  CardTitleView.m
//  GameGroup
//
//  Created by 魏星 on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CardTitleView.h"

@implementation CardTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.cardTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 300, 29)];
//        self.cardTitleLabel.backgroundColor =[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];
        self.cardTitleLabel.textColor = [UIColor grayColor];
        self.cardTitleLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:self.cardTitleLabel];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 35, 300, 1)];
        lineView.backgroundColor = [UIColor grayColor];
        [self addSubview:lineView];
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
