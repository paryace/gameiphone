//
//  MemberEditCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MemberEditCell.h"

@implementation MemberEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 12.5, 45, 45)];
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self addSubview:self.headImageView];
        
        self.bgImageView = [[UIButton alloc]initWithFrame:CGRectMake(10, 12.5, 45, 45)];
        self.bgImageView.layer.cornerRadius = 5;
        self.bgImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView  addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView setBackgroundImage:nil forState:UIControlStateNormal];
        [self.contentView addSubview:self.bgImageView];
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 90, 60)];
        [self.nameLable setTextAlignment:NSTextAlignmentLeft];
        [self.nameLable setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLable];

        self.sfLb = [[UILabel alloc]initWithFrame:CGRectMake(250, 20, 50, 20)];
        self.sfLb.textColor  = [UIColor grayColor];
        self.sfLb.textAlignment = NSTextAlignmentCenter;
        self.sfLb.font = [UIFont boldSystemFontOfSize:12];
        [self addSubview:self.sfLb];
        
        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(100, 0, 20, 20)];
        self.sexImg.backgroundColor = [UIColor clearColor];
        [self addSubview:self.sexImg];
        
        
    }
    return self;
}

-(void)headOnClick:(UIButton*)sender{
    if ([self.headCkickDelegate respondsToSelector:@selector(userHeadImgClick:)]) {
        [self.headCkickDelegate userHeadImgClick:self];
    }
}
@end
