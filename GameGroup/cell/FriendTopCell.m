//
//  FriendTopCell.m
//  GameGroup
//
//  Created by Marss on 14-6-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FriendTopCell.h"

@interface FriendTopCell (){
    NSArray *topTitle;
}
@end
@implementation FriendTopCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
       UIView *topView = [[UIView alloc] init];
        topView.frame = CGRectMake(0,0,320,60);
        topView.backgroundColor = [UIColor blackColor];

        topTitle = @[@"粉丝数量",@"好友出没",@"有趣的人",@"添加好友"];
        self.btn1 = [self getUIBtn:0];
        [topView addSubview:self.btn1];
        
        self.lable1=[self getUILable:0];
        [topView addSubview:self.lable1];
        
        //---
         self.btn2 = [self getUIBtn:1];
        [topView addSubview:self.btn2];
        
         self.lable2=[self getUILable:1];
        [topView addSubview:self.lable2];
        
        
        //---
        self.btn3 = [self getUIBtn:2];
        [topView addSubview:self.btn3];
        
        self.lable3=[self getUILable:2];
        [topView addSubview:self.lable3];
        
        
        //---
        self.btn4 = [self getUIBtn:3];
        [topView addSubview:self.btn4];
        
        self.lable4=[self getUILable:3];
        [topView addSubview:self.lable4];
        [self addSubview:topView];
    }
    return self;
}


-(UIButton *)getUIBtn:(NSInteger)i{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = i;
    [button  setExclusiveTouch :YES];
    button.frame = CGRectMake(i*80, 0, 80, 60);
    [button addTarget:self action:@selector(btnAction:)
     forControlEvents:UIControlEventTouchUpInside];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_normal_%d",i+1]]
            forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:[NSString stringWithFormat:@"new_friend_click_%d",i+1]]
            forState:UIControlStateHighlighted];
    [button setImageEdgeInsets:UIEdgeInsetsMake(1, 0, 0, 1)];
    return button;
}
-(UILabel *)getUILable:(NSInteger)i{
    UILabel *titleLable = [[UILabel alloc] init];
    CGSize textSize =[[topTitle objectAtIndex:i] sizeWithFont:[UIFont systemFontOfSize:12] constrainedToSize:CGSizeMake(MAXFLOAT,30)];
    CGFloat textWidth = textSize.width;
    titleLable.frame=CGRectMake(i*80+((80-textWidth)/2),40, 80 ,20);
    titleLable.font = [UIFont systemFontOfSize:11];
    titleLable.textColor=UIColorFromRGBA(0xf7f7f7, 1);
    titleLable.backgroundColor=[UIColor clearColor];
    titleLable.text=[topTitle objectAtIndex:i];
    return titleLable;
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
