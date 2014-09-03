//
//  AttentionBtn.m
//  GameGroup
//
//  Created by 魏星 on 14-9-3.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AttentionBtn.h"

@implementation AttentionBtn

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 215, 1)];
        img.image = KUIImage(@"msg_line");
        [self addSubview:img];
        
        UIImageView *headImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, 15, 15)];
        [self addSubview:headImg];
        
        UILabel *titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(30, 7, 150, 15) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:titleLabel];
        
        
        UIImageView *rightImg = [[UIImageView alloc]initWithFrame:CGRectMake(190, 7, 15, 15)];
        rightImg.image = KUIImage(@"msg_right");
        [self addSubview:rightImg];
        
        switch (self.type) {
            case 0://群组
                headImg.image = KUIImage(@"msg_type_1");
                titleLabel.text = @"群组邀请";
                break;
            case 1: //角色
                headImg.image = KUIImage(@"msg_type_2");
                titleLabel.text = @"角色详情";
                break;
            case 2://组队
                headImg.image = KUIImage(@"msg_type_3");
                titleLabel.text = @"组队邀请";
                break;
            default:
                break;
        }
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
