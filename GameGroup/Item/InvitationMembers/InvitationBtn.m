//
//  InvitationBtn.m
//  GameGroup
//
//  Created by 魏星 on 14-8-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InvitationBtn.h"

@implementation InvitationBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code

        self.backgroundColor =UIColorFromRGBA(0xffffff, 1);
        
            self.headImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 40, 40)];
            [self addSubview:self.headImg];
            
            self.titleLb = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 5, 200, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
            [self addSubview:self.titleLb];
//            view.tag = 100+i;
//            UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shareToView:)];
//            [view addGestureRecognizer:tap];
            
            UIImageView *right = [[UIImageView alloc]initWithFrame:CGRectMake(280, 20, 10, 10)];
            right.image = KUIImage(@"right");
            [self addSubview:right];
        self.selected = YES;
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
