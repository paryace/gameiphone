//
//  BottomView.m
//  GameGroup
//
//  Created by 魏星 on 14-8-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BottomView.h"

@implementation BottomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor =UIColorFromRGBA(0x282c32, 1);
        
        self.lowImg = [[EGOImageView alloc]initWithFrame:CGRectMake( 10, 10, 30, 30)];
        [self addSubview:self.lowImg];
        
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(50, 10, 80, 15) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        self.gameIcon = [[EGOImageView alloc]initWithFrame:CGRectMake(50, 25, 15, 15)];
        [self addSubview:self.gameIcon];
        
        self.realmLb =[GameCommon buildLabelinitWithFrame:CGRectMake(65, 25, 70, 15) font:[UIFont systemFontOfSize:10] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.realmLb];
        
        
        self.topLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(0, 0, 160, 50) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:UIColorFromRGBA(0x282c32, 1) textAlignment:NSTextAlignmentCenter];
        self.topLabel.text = @"请选择角色";
        [self addSubview:self.topLabel];

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
