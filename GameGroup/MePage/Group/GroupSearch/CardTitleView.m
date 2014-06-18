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
        self.cardTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, 300, 29)];
//        self.cardTitleLabel.backgroundColor =[UIColor colorWithRed:200/255.0f green:200/255.0f blue:200/255.0f alpha:1];
        self.cardTitleLabel.textColor = [UIColor grayColor]; 
        self.cardTitleLabel.font = [UIFont systemFontOfSize:14];
        self.cardTitleLabel.backgroundColor =[UIColor clearColor];
        [self addSubview:self.cardTitleLabel];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 35, 300, 1)];
        lineView.backgroundColor = kColorWithRGB(200,200,200, 0.5);;
        [self addSubview:lineView];
    }
    return self;
}
@end
