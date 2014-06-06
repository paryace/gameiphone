//
//  AddGroupView.m
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddGroupView.h"

@implementation AddGroupView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.frame];
        self.scrollView.scrollEnabled = NO;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.pagingEnabled = YES;
        self.scrollView.contentSize = CGSizeMake(kScreenWidth *3, 0);
        [self addSubview:self.scrollView];
        
        self.topImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 220)];
        self.topImageView .backgroundColor = [UIColor grayColor];
        [self.scrollView addSubview:self.topImageView];
        
        
        UILabel *lb1 =[[UILabel alloc]initWithFrame:CGRectMake(20, 230, 200, 10)];
        lb1.text = @"选择游戏";
        lb1.backgroundColor = [UIColor clearColor];
        lb1.textColor = [UIColor grayColor];
        lb1.font = [UIFont systemFontOfSize:10];
        [self.scrollView addSubview:lb1];
        
        self.gameTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 250, 280, 30)];
        self.gameTextField.textColor = [UIColor blackColor];
        self.gameTextField.font = [UIFont systemFontOfSize:13];
        self.gameTextField.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview:self.gameTextField];
        
        UILabel *lb2 =[[UILabel alloc]initWithFrame:CGRectMake(20, 290, 200, 10)];
        lb2.text = @"选择游戏";
        lb2.backgroundColor = [UIColor clearColor];
        lb2.textColor = [UIColor grayColor];
        lb2.font = [UIFont systemFontOfSize:10];
        [self.scrollView addSubview:lb2];

        self.realmTextField = [[UITextField alloc]initWithFrame:CGRectMake(20, 310, 280, 30)];
        self.realmTextField.textColor = [UIColor blackColor];
        self.realmTextField.font = [UIFont systemFontOfSize:13];
        self.realmTextField.backgroundColor = [UIColor whiteColor];
        [self.scrollView addSubview: self.realmTextField];

        
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
