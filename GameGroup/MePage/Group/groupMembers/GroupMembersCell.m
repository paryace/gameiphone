//
//  GroupMembersCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupMembersCell.h"

@implementation GroupMembersCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.bgView];
        
        self.headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self.bgView addSubview:self.headImageView];
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 200, 40)];
        [self.nameLable setTextAlignment:NSTextAlignmentLeft];
        [self.nameLable setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLable setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.nameLable];
        
        self.sexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(110, 23, 20, 20)];
        self.sexImageView.backgroundColor = [UIColor clearColor];
        [self.headImageView addSubview:self.sexImageView];
        [self.bgView addSubview:self.sexImageView];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 10, 60, 40)];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        [self.timeLabel setFont:[UIFont systemFontOfSize:13]];
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.timeLabel];

        
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
