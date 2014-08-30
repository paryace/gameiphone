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
        self.bgV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        self.bgV.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.bgV];
        
        self.stateView = [[UIView alloc] initWithFrame:CGRectMake(1, 0, 5, 78)];
        self.stateView.backgroundColor = [UIColor greenColor];
        [self.bgV addSubview:self.stateView];
        
        self.headImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.bgV addSubview:self.headImageV];
        
        self.bgImageView = [[UIButton alloc]initWithFrame:CGRectMake(15, 10, 60, 60)];
        self.bgImageView.layer.cornerRadius = 5;
        self.bgImageView.layer.masksToBounds=YES;
        [self.bgV addSubview:self.bgImageView];
        
        [self.bgImageView  addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView setBackgroundImage:nil forState:UIControlStateNormal];
        [self.bgV addSubview:self.bgImageView];
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.groupNameLable.text = @"萌萌哒~";
        self.groupNameLable.font =[ UIFont boldSystemFontOfSize:16];
        [self.bgV addSubview:self.groupNameLable];
        
        self.genderImageV = [[UIImageView alloc]initWithFrame:CGRectMake(155, 10, 20, 20)];
        [self.bgV addSubview:self.genderImageV];
        
        
        self.MemberLable = [[UIImageView alloc]initWithFrame:CGRectMake(195, 6, 26, 12.5)];
        self.MemberLable.image = KUIImage(@"team_captain_icon.png");
        [self.bgV addSubview:self.MemberLable];
        
        self.gameImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 35, 15, 15)];
        [self.bgV addSubview:self.gameImageV];
        
        self.realmLable = [[UILabel alloc]initWithFrame:CGRectMake(100, 34, 320-110-60, 20)];
        self.realmLable.backgroundColor = [UIColor clearColor];
        self.realmLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.realmLable.text = @"猫小莹-德玛西亚";
        self.realmLable.font =[ UIFont systemFontOfSize:13];
        [self.bgV addSubview:self.realmLable];
        
        self.pveLable = [[UILabel alloc]initWithFrame:CGRectMake(80, 53, 300, 20)];
        self.pveLable.backgroundColor = [UIColor clearColor];
        self.pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.pveLable.text = @"战斗力：6600   荣誉黄金";
        self.pveLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.pveLable];
        
        self.lineView = [[UIView alloc]initWithFrame:CGRectMake(320-70, 5, 1, 70)];
        self.lineView.backgroundColor = UIColorFromRGBA(0xd9d9d9, 1);
        [self.bgV addSubview:self.lineView];
        
        
        self.positionLable = [[UILabel alloc]initWithFrame:CGRectMake(320-10-50, 25, 50, 30)];
        self.positionLable.text = @"职位";
        self.positionLable.backgroundColor = [UIColor clearColor];
        self.positionLable.textAlignment = NSTextAlignmentCenter;
        self.positionLable.font =[ UIFont systemFontOfSize:14];
        [self.bgV addSubview:self.positionLable];
        
        self.positionBtn = [[UIButton alloc]initWithFrame:CGRectMake(320-70, 0, 70, 80)];
        [self.positionBtn setBackgroundImage:nil forState:UIControlStateNormal];
        [self.positionBtn  addTarget:self action:@selector(positionOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgV addSubview:self.positionBtn];
        
        self.dotPosition = [[MsgNotifityView alloc] initWithFrame:CGRectMake(320-30,20, 22,18)];
        [self.bgV addSubview:self.dotPosition];
        
        
    }
    return self;
}

-(void)headOnClick:(UIButton*)sender{
    if ([self.headCkickDelegate respondsToSelector:@selector(userHeadImgClick:)]) {
        [self.headCkickDelegate userHeadImgClick:self];
    }
}

-(void)positionOnClick:(UIButton*)sender{
    if ([self.positionCkickDelegate respondsToSelector:@selector(positionOnClick:)]) {
        [self.positionCkickDelegate positionOnClick:sender];
    }
}

@end
