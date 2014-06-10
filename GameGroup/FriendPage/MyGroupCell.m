//
//  MyGroupCell.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyGroupCell.h"

@implementation MyGroupCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(5, 5, 45, 45)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self addSubview:self.headImageV];
        
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(55, 5, 100, 20)];
        [self.titleLable setTextAlignment:NSTextAlignmentLeft];
        [self.titleLable setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.titleLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview: self.titleLable];

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
