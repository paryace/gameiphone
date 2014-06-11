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
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 5, 65, 65)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 5, 150, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLabel];
        
        self.gameImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(75, 30, 10, 10)];
        [self addSubview:self.gameImageV];
        
        self.numberLable = [[UILabel alloc] initWithFrame:CGRectMake(90, 30, 50, 10)];
        [self.numberLable setTextAlignment:NSTextAlignmentLeft];
        [self.numberLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.numberLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.numberLable];
        
        self.cricleLable= [[UILabel alloc] initWithFrame:CGRectMake(75, 45, 200, 20)];
        [self.cricleLable setTextAlignment:NSTextAlignmentLeft];
        [self.cricleLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.cricleLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.cricleLable];
        
        UIImageView * leveImageV = [[UIImageView alloc] initWithFrame:CGRectMake(225, 5, 70, 20)];
        leveImageV.image = KUIImage(@"level_image.png");
        self.levelLable= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
        [self.levelLable setTextAlignment:NSTextAlignmentRight];
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
