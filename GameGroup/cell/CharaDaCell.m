//
//  CharaDaCell.m
//  GameGroup
//
//  Created by admin on 14-2-22.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CharaDaCell.h"

@implementation CharaDaCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGBA(0xf7f7f7, 1);
        self.titleImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(7, 6, 45, 45)];
        [self addSubview:self.titleImgView];
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 10, 100, 20)];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
        
        self.CountLabel = [[UILabel alloc]initWithFrame:CGRectMake(58, 30, 150, 30)];
        self.CountLabel.textColor = UIColorFromRGBA(0x696969, 1);
        self.CountLabel.numberOfLines = 0;
        self.CountLabel.font = [UIFont systemFontOfSize:12];
        self.CountLabel.textAlignment = NSTextAlignmentLeft;
        self.CountLabel.textColor = [UIColor grayColor];
        self.CountLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.CountLabel];

//        self.topImgView =[[UIImageView alloc]initWithFrame:CGRectMake(190, 20, 18, 18)];
//        [self addSubview:self.topImgView];
        
        self.dataLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 5, 85, 32)];
        self.dataLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        self.dataLabel.font = [UIFont fontWithName:@"汉仪菱心体简" size:18];
//        [UIFont fontWithName:@"DigifaceWide" size:18]
        self.dataLabel.textAlignment = NSTextAlignmentRight;
        self.dataLabel.backgroundColor =[UIColor clearColor];
        [self addSubview:self.dataLabel];

        
        
        self.rankingLabel = [[UILabel alloc]initWithFrame:CGRectMake(200, 35, 85, 15)];
        self.rankingLabel.textColor = [UIColor grayColor];
        self.rankingLabel.font = [UIFont systemFontOfSize:12];
        self.rankingLabel.textAlignment = NSTextAlignmentRight;
        self.rankingLabel.backgroundColor =[UIColor clearColor];
        [self addSubview:self.rankingLabel];
        
        self.upDowmImgView = [[UIImageView alloc]initWithFrame:CGRectMake(295, 22, 12, 12)];
        [self addSubview:self.upDowmImgView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
