//
//  MyHeadView.m
//  GameGroup
//
//  Created by wangxr on 14-3-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyHeadView.h"
@interface MyHeadView ()
{
    
}
@end
@implementation MyHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
        UIImageView * imageV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
        imageV.backgroundColor = UIColorFromRGBA(0xf8f8f8, 1);
        [self addSubview:imageV];
        self.titleL = [[UILabel alloc]initWithFrame:CGRectMake(10, 7.5, 300, 20)];
        _titleL.backgroundColor = [UIColor clearColor];
        _titleL.textColor = UIColorFromRGBA(0x999999, 1);
        [self addSubview:_titleL];
    }
    return self;
}

@end
