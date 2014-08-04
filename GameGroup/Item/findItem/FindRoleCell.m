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
        self.headImgView = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 15, 40, 40)];
        self.headImgView.placeholderImage = KUIImage(@"placeholder");
        [self.contentView addSubview:self.headImgView];
        
        self.roleNameLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 15, 140, 20) font:[UIFont systemFontOfSize:kFontSize(28)] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.roleNameLabel];
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(60, 35, 20, 20)];
        [self.contentView addSubview: self.gameIconImg];
        
        self.realmLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 35, 120, 20) font:[UIFont systemFontOfSize:kFontSize(24)] textColor:UIColorFromRGBA(0xa3a8b5, 1) backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.realmLabel];
        
        NSLog(@"%f",kFontSize(24));
        
        self.zdlLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(210, 0, 50, 70) font:[UIFont systemFontOfSize:kFontSize(20)] textColor:UIColorFromRGBA(0xa3a8b5, 1) backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.zdlLabel.text = @"战斗力";
        [self.contentView addSubview:self.zdlLabel];
        
        self.zdlNumLabel  =[GameCommon buildLabelinitWithFrame:CGRectMake(270, 0, 50, 70) font:[UIFont boldSystemFontOfSize:kFontSize(34)] textColor:UIColorFromRGBA(0x339adf, 1) backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.zdlNumLabel];
        
        UIImageView * lineView =[[ UIImageView alloc]initWithFrame:CGRectMake(0, 69, self.frame.size.width, 1)];
        lineView.image  = KUIImage(@"team_line_2");
        [self addSubview:lineView];
        
        
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
