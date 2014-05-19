//
//  RoleCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "RoleCell.h"

@implementation RoleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.glazzImgView = [[EGOImageButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self.contentView addSubview:self.glazzImgView];
        
        self.roleLabel =[[ UILabel alloc]initWithFrame:CGRectMake(60, 10, 250, 30)];
        self.roleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.roleLabel.textColor = [UIColor grayColor];
        self.roleLabel.backgroundColor =[ UIColor clearColor];
        [self.contentView addSubview:self.roleLabel];
        
        
        self.genderImgView  =[[UIImageView alloc]initWithFrame:CGRectMake(60, 40, 20, 20)];
        [self.contentView addSubview:self.genderImgView];
        
        self.nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 40, 20, 20)];
        self.nickNameLabel.backgroundColor = [UIColor clearColor];
        self.nickNameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.nickNameLabel];
        
        
        self.headImgBtn =[[EGOImageButton alloc ]initWithFrame:CGRectMake(250, 5, 50, 50)];
        self.headImgBtn.placeholderImage = KUIImage(@"");
        [self.contentView addSubview:self.headImgBtn];
        
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
