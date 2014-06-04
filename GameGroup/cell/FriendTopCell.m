//
//  FriendTopCell.m
//  GameGroup
//
//  Created by Marss on 14-6-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FriendTopCell.h"

@implementation FriendTopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        NSArray *topTitle = @[@"粉丝数量",@"附近的朋友",@"有趣的人",@"添加好友"];
        self.backgroundColor = [UIColor blackColor];
        self.btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn1.tag = 0;
        self.btn1.frame = CGRectMake(0*80, 0, 80, 60);
        [self.btn1 addTarget:self action:@selector(btnAction:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.btn1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_normal_%d",0+1]]
                forState:UIControlStateNormal];
        [self.btn1 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_click_%d",0+1]]
                forState:UIControlStateHighlighted];
        [self.btn1 setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
        [self addSubview:self.btn1];
        
        
       self.lable1= [[UILabel alloc] init];
        CGSize textSize1 =[[topTitle objectAtIndex:0] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        CGFloat textWidth1 = textSize1.width;
        self.lable1.frame=CGRectMake(0*80+((80-textWidth1)/2),40, 80 ,20);
        self.lable1.font = [UIFont systemFontOfSize:11];
        self.lable1.textColor=UIColorFromRGBA(0xf7f7f7, 1);
        self.lable1.backgroundColor=[UIColor clearColor];
        self.lable1.text=[topTitle objectAtIndex:0];
        [self addSubview:self.lable1];
        
        //---
        
        self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn2.tag = 1;
        self.btn2.frame = CGRectMake(1*80, 0, 80, 60);
        [self.btn2 addTarget:self action:@selector(btnAction:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.btn2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_normal_%d",1+1]]
                   forState:UIControlStateNormal];
        [self.btn2 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_click_%d",1+1]]
                   forState:UIControlStateHighlighted];
        [self.btn2 setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
        [self addSubview:self.btn2];
        
        
        self.lable2= [[UILabel alloc] init];
        CGSize textSize2 =[[topTitle objectAtIndex:1] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        CGFloat textWidth2 = textSize2.width;
        self.lable2.frame=CGRectMake(1*80+((80-textWidth2)/2),40, 80 ,20);
        self.lable2.font = [UIFont systemFontOfSize:11];
        self.lable2.textColor=UIColorFromRGBA(0xf7f7f7, 1);
        self.lable2.backgroundColor=[UIColor clearColor];
        self.lable2.text=[topTitle objectAtIndex:1];
        [self addSubview:self.lable2];
        
        
        //---
        
        self.btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn3.tag = 2;
        self.btn3.frame = CGRectMake(2*80, 0, 80, 60);
        [self.btn3 addTarget:self action:@selector(btnAction:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.btn3 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_normal_%d",2+1]]
                   forState:UIControlStateNormal];
        [self.btn3 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_click_%d",2+1]]
                   forState:UIControlStateHighlighted];
        [self.btn3 setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
        [self addSubview:self.btn3];
        
        
        self.lable3= [[UILabel alloc] init];
        CGSize textSize3 =[[topTitle objectAtIndex:2] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        CGFloat textWidth3 = textSize3.width;
        self.lable3.frame=CGRectMake(2*80+((80-textWidth3)/2),40, 80 ,20);
        self.lable3.font = [UIFont systemFontOfSize:11];
        self.lable3.textColor=UIColorFromRGBA(0xf7f7f7, 2);
        self.lable3.backgroundColor=[UIColor clearColor];
        self.lable3.text=[topTitle objectAtIndex:2];
        [self addSubview:self.lable3];
        
        
        //---
        
        
        self.btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btn4.tag = 3;
        self.btn4.frame = CGRectMake(3*80, 0, 80, 60);
        [self.btn4 addTarget:self action:@selector(btnAction:)
            forControlEvents:UIControlEventTouchUpInside];
        [self.btn4 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_normal_%d",3+1]]
                   forState:UIControlStateNormal];
        [self.btn4 setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_click_%d",3+1]]
                   forState:UIControlStateHighlighted];
        [self.btn4 setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
        [self addSubview:self.btn4];
        
        
        self.lable4= [[UILabel alloc] init];
        CGSize textSize4 =[[topTitle objectAtIndex:3] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
        CGFloat textWidth4 = textSize4.width;
        self.lable4.frame=CGRectMake(3*80+((80-textWidth4)/2),40, 80 ,20);
        self.lable4.font = [UIFont systemFontOfSize:11];
        self.lable4.textColor=UIColorFromRGBA(0xf7f7f7, 2);
        self.lable4.backgroundColor=[UIColor clearColor];
        self.lable4.text=[topTitle objectAtIndex:3];
        [self addSubview:self.lable4];
    }
    return self;
}

- (void)btnAction:(UIButton *)sender{
    if (self.friendTabDelegate) {
        [self.friendTabDelegate topBtnAction:sender];
    }
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
