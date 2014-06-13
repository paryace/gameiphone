//
//  GroupNameCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupNameCell.h"

@implementation GroupNameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)];
        titleLabel.textColor = [UIColor grayColor];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        titleLabel.text = @"群名称";
        
        self.nameLabel  = [[UILabel alloc]initWithFrame:CGRectMake(80, 0,200, 40)];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.textColor =[ UIColor blackColor];
        [self addSubview:self.nameLabel];

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
