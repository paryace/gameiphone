//
//  FindRoleCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-30.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FindRoleCell.h"

@implementation FindRoleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.headImgView.placeholderImage = KUIImage(@"placeholder");
        [self.contentView addSubview:self.headImgView];
        
        self.roleNameLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 10, 140, 20) font:[UIFont systemFontOfSize:16] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.roleNameLabel];
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(60, 30, 20, 20)];
        [self.contentView addSubview: self.gameIconImg];
        
        self.realmLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 30, 120, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.realmLabel];
        
        self.zdlLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(210, 0, 50, 60) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.zdlLabel.text = @"战斗力";
        [self.contentView addSubview:self.zdlLabel];
        
        self.zdlNumLabel  =[GameCommon buildLabelinitWithFrame:CGRectMake(270, 0, 50, 60) font:[UIFont boldSystemFontOfSize:14] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.zdlNumLabel];
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
