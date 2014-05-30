//
//  GameListCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GameListCell.h"

@implementation GameListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor =[ UIColor clearColor];
        // Initialization code
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 5, 29, 29)];
        [self addSubview:self.gameIconImg];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 5, 200, 29)];
        self.nameLabel.backgroundColor =[UIColor clearColor];
        self.nameLabel.textColor = [UIColor whiteColor];
        self.nameLabel.font = [UIFont boldSystemFontOfSize:16];
        [self addSubview:self.nameLabel];
        
//        UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 39, 320, 1)];
//        bottomView.backgroundColor = [UIColor whiteColor];
//        [self addSubview:bottomView];
        
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
