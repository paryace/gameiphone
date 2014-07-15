//
//  CreateTeamCell.m
//  GameGroup
//
//  Created by Marss on 14-7-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CreateTeamCell.h"

@implementation CreateTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imageV= [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.imageV.layer.cornerRadius = 5;
        self.imageV.layer.masksToBounds=YES;
        self.imageV.backgroundColor = [UIColor clearColor];
        [self addSubview:self.imageV];
        
        self.lable = [[UILabel alloc] initWithFrame:CGRectMake(55, 15, 150, 30)];
        [self.lable setTextAlignment:NSTextAlignmentLeft];
         self.lable.text = @"创建组队";
        [self.lable setFont:[UIFont boldSystemFontOfSize:13.0]];
        [self.lable setBackgroundColor:[UIColor clearColor]];
        [self.lable setTextColor:UIColorFromRGBA(0x455ca8, 1)];
        [self addSubview:self.lable];

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

}

@end
