//
//  InplaceCell.m
//  GameGroup
//
//  Created by Apple on 14-8-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "InplaceCell.h"

@implementation InplaceCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.stateView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 5, 78)];
        self.stateView.backgroundColor = [UIColor greenColor];
        [self.contentView addSubview:self.stateView];
        
        
        self.headImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
        [self.contentView addSubview:self.headImageV];
        
        self.bgImageView = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
        self.bgImageView.layer.cornerRadius = 5;
        self.bgImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView  addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView setBackgroundImage:nil forState:UIControlStateNormal];
        [self.contentView addSubview:self.bgImageView];
        
        
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(80, 8, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.groupNameLable.text = @"萌萌哒~";
        self.groupNameLable.font =[ UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:self.groupNameLable];
        
        self.genderImageV = [[UIImageView alloc]initWithFrame:CGRectMake(155, 8, 20, 20)];
        [self.contentView addSubview:self.genderImageV];
        
        self.gameImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 35, 20, 20)];
        [self.contentView addSubview:self.gameImageV];
        
        self.realmLable = [[UILabel alloc]initWithFrame:CGRectMake(110, 35, 200, 20)];
        self.realmLable.backgroundColor = [UIColor clearColor];
        self.realmLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.realmLable.text = @"猫小莹-德玛西亚";
        self.realmLable.font =[ UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.realmLable];
        
        self.pveLable = [[UILabel alloc]initWithFrame:CGRectMake(80, 55, 300, 20)];
        self.pveLable.backgroundColor = [UIColor clearColor];
        self.pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.pveLable.text = @"战斗力：6600   荣誉黄金";
        self.pveLable.font =[ UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.pveLable];
        
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(320-70, 5, 1, 70)];
        self.lineView.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.lineView];
        
        
        self.positionLable = [[UILabel alloc]initWithFrame:CGRectMake(320-10-50, 25, 50, 30)];
        self.positionLable.text = @"职位";
        self.positionLable.font =[ UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.positionLable];

    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
