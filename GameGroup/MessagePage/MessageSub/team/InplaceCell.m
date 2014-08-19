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
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.contentView addSubview:self.headImageV];
        
        self.bgImageView = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
        self.bgImageView.layer.cornerRadius = 5;
        self.bgImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView  addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView setBackgroundImage:nil forState:UIControlStateNormal];
        [self.contentView addSubview:self.bgImageView];
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.groupNameLable.text = @"萌萌哒~";
        self.groupNameLable.font =[ UIFont boldSystemFontOfSize:16];
        [self.contentView addSubview:self.groupNameLable];
        
        self.genderImageV = [[UIImageView alloc]initWithFrame:CGRectMake(155, 10, 20, 20)];
        [self.contentView addSubview:self.genderImageV];
        
        
        self.MemberLable = [[UILabel alloc]initWithFrame:CGRectMake(195, 6, 26, 11)];
        self.MemberLable.layer.cornerRadius = 3;
        self.MemberLable.layer.masksToBounds=YES;
        self.MemberLable.textAlignment = NSTextAlignmentCenter;
        self.MemberLable.font = [UIFont systemFontOfSize:10];
        self.MemberLable.textColor = [UIColor whiteColor];
        [self addSubview:self.MemberLable];
        
        self.gameImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 35, 15, 15)];
        [self.contentView addSubview:self.gameImageV];
        
        self.realmLable = [[UILabel alloc]initWithFrame:CGRectMake(100, 34, 320-110-60, 20)];
        self.realmLable.backgroundColor = [UIColor clearColor];
        self.realmLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.realmLable.text = @"猫小莹-德玛西亚";
        self.realmLable.font =[ UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.realmLable];
        
        self.pveLable = [[UILabel alloc]initWithFrame:CGRectMake(80, 53, 300, 20)];
        self.pveLable.backgroundColor = [UIColor clearColor];
        self.pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.pveLable.text = @"战斗力：6600   荣誉黄金";
        self.pveLable.font =[ UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.pveLable];
        
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(320-70, 5, 1, 70)];
        self.lineView.backgroundColor = UIColorFromRGBA(0xd9d9d9, 1);
        [self.contentView addSubview:self.lineView];
        
        
        self.positionLable = [[UILabel alloc]initWithFrame:CGRectMake(320-10-50, 25, 50, 30)];
        self.positionLable.text = @"职位";
        self.positionLable.backgroundColor = [UIColor clearColor];
        self.positionLable.textAlignment = NSTextAlignmentCenter;
        self.positionLable.font =[ UIFont systemFontOfSize:14];
        [self.contentView addSubview:self.positionLable];
        
        self.positionBtn = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 70, 60)];
        self.positionBtn.layer.cornerRadius = 5;
        self.positionBtn.layer.masksToBounds=YES;
        [self.positionBtn  addTarget:self action:@selector(positionOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.positionBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.contentView addSubview:self.bgImageView];


    }
    return self;
}

-(void)headOnClick:(UIButton*)sender{
    if ([self.headCkickDelegate respondsToSelector:@selector(userHeadImgClick:)]) {
        [self.headCkickDelegate userHeadImgClick:self];
    }
}

-(void)positionOnClick:(UIButton*)sender{
    if ([self.onclickdelegate respondsToSelector:@selector(positionOnClick:)]) {
        [self.onclickdelegate positionOnClick:self];
    }
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
