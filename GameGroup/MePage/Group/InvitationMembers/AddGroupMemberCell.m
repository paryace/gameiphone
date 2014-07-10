//
//  AddGroupMemberCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "AddGroupMemberCell.h"

@implementation AddGroupMemberCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.chooseImg = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 20, 20)];
        [self addSubview:self.chooseImg];
        
        self.headImg =[[EGOImageView alloc]initWithFrame:CGRectMake(60, 10, 40, 40)];
        self.headImg.layer.cornerRadius = 5;
        self.headImg.layer.masksToBounds=YES;

        [self addSubview:self.headImg];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 200, 30)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.nameLabel];
        
        
        self.disLabel = [[UILabel alloc]initWithFrame:CGRectMake(170, 5, 130, 20)];
        self.disLabel.backgroundColor = [UIColor clearColor];
        self.disLabel.textAlignment = NSTextAlignmentRight;
        self.disLabel.font = [UIFont systemFontOfSize:13];
        [self addSubview:self.disLabel];
        
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
