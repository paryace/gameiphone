//
//  TagCell.m
//  GameGroup
//
//  Created by Apple on 14-8-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TagCell.h"

@implementation TagCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgImgView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self.bgImgView setBackgroundImage:KUIImage(@"tagBtn_normal") forState:UIControlStateNormal];
        [self.bgImgView setBackgroundImage:KUIImage(@"tagBtn_click") forState:UIControlStateHighlighted];
        [self.bgImgView setBackgroundImage:KUIImage(@"tagBtn_click") forState:UIControlStateSelected];
        [self.bgImgView addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.bgImgView];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.titleLabel];
        
    }
    return self;
}

-(void)onClick:(UIButton*)sender{
    if (self.delegate) {
        [self.delegate tagOnClick:self];
    }
}


@end
