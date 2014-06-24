//
//  GroupCell.m
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupCell.h"

@implementation GroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(15, 12, 50, 50)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 12, 150, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLabel];
        
        self.gameImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(80, 32, 10, 10)];
        [self addSubview:self.gameImageV];
        
        self.numberLable = [[UILabel alloc] initWithFrame:CGRectMake(95, 32, 50, 10)];
        [self.numberLable setTextAlignment:NSTextAlignmentLeft];
        [self.numberLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.numberLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.numberLable];
        
        self.cricleLable= [[UILabel alloc] initWithFrame:CGRectMake(80, 40, 200, 20)];
        [self.cricleLable setTextAlignment:NSTextAlignmentLeft];
        [self.cricleLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.cricleLable setBackgroundColor:[UIColor clearColor]];
        self.cricleLable.textColor = [UIColor grayColor];
        [self addSubview:self.cricleLable];
        
        UIImageView * leveImageV = [[UIImageView alloc] initWithFrame:CGRectMake(320-55, 5, 40, 25)];
        leveImageV.backgroundColor = [UIColor clearColor];
        leveImageV.image = KUIImage(@"level_image.png");
        

        self.levelLable= [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 40, 20)];
        [self.levelLable setTextAlignment:NSTextAlignmentCenter];
        self.levelLable.backgroundColor = [UIColor clearColor];
        self.levelLable.textColor = [UIColor whiteColor];
        [self.levelLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [leveImageV addSubview:self.levelLable];
        [self addSubview:leveImageV];
    }
    return self;
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
