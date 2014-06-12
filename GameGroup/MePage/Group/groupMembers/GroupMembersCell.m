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
        // Initialization code
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [self addSubview:self.bgView];
        
        self.headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 6, 45, 45)];
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self.bgView addSubview:self.headImageView];
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 90, 20)];
        [self.nameLable setTextAlignment:NSTextAlignmentLeft];
        [self.nameLable setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLable setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.nameLable];
        
        self.sexImageView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 25, 20, 20)];
        self.sexImageView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.sexImageView];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 25, 100, 20)];
        [self.timeLabel setTextColor:[UIColor blackColor]];
        [self.timeLabel setFont:[UIFont systemFontOfSize:13]];
        [self.timeLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.timeLabel];

        self.clazzImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(80, 45, 20, 20)];
        self.clazzImageView.backgroundColor = [UIColor clearColor];
        [self.bgView addSubview:self.clazzImageView];
        
        self.roleLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 45, 240, 20)];
        [self.roleLabel setTextColor:[UIColor blackColor]];
        [self.roleLabel setFont:[UIFont systemFontOfSize:13]];
        [self.roleLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.roleLabel];

        UIView *lineView =[[ UIView alloc]initWithFrame:CGRectMake(220, 0, 1, 60)];
        lineView.backgroundColor = [UIColor grayColor];
        [self.bgView addSubview:lineView];
        
        self.numLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 10, 60, 20)];
        [self.numLabel setTextColor:[UIColor blueColor]];
        [self.numLabel setFont:[UIFont systemFontOfSize:18]];
        self.numOfLabel.textAlignment = NSTextAlignmentCenter;
        [self.numLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.numLabel];
        
        self.numOfLabel = [[UILabel alloc] initWithFrame:CGRectMake(240, 40, 60, 20)];
        [self.numOfLabel setTextColor:[UIColor blackColor]];
        [self.numOfLabel setFont:[UIFont systemFontOfSize:13]];
        self.numOfLabel.textAlignment  = NSTextAlignmentCenter;
        [self.numOfLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.numOfLabel];

        
        
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
