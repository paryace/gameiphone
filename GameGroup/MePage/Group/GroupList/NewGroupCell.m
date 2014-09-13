//
//  NewGroupCell.m
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewGroupCell.h"

@implementation NewGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 12, 50, 50)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 320-80-35-2-60, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLabel];
        
        self.gameImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(60, 32, 13, 13)];
        [self addSubview:self.gameImageV];
        
        self.numberLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 34, 50, 10)];
        [self.numberLable setTextAlignment:NSTextAlignmentLeft];
        [self.numberLable setFont:[UIFont systemFontOfSize:11.0]];
        [self.numberLable setBackgroundColor:[UIColor clearColor]];
        self.numberLable.textColor = [UIColor grayColor];
        [self addSubview:self.numberLable];
        
        self.cricleLable= [[UILabel alloc] initWithFrame:CGRectMake(60, 45, 320-80-60-5, 20)];
        [self.cricleLable setTextAlignment:NSTextAlignmentLeft];
        [self.cricleLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.cricleLable setBackgroundColor:[UIColor clearColor]];
        self.cricleLable.textColor = [UIColor grayColor];
        [self addSubview:self.cricleLable];
        
        self.levelLable= [[UILabel alloc] initWithFrame:CGRectMake(320-35-80, 14, 26, 13)];
        [self.levelLable setTextAlignment:NSTextAlignmentCenter];
        self.levelLable.backgroundColor = kColorWithRGB(119, 137, 203, 1);
        self.levelLable.textColor = [UIColor whiteColor];
        self.levelLable.layer.cornerRadius = 2;
        self.levelLable.layer.masksToBounds=YES;
        [self.levelLable setFont:[UIFont systemFontOfSize:10.0]];
        [self addSubview:self.levelLable];
    }
    return self;
}

@end
