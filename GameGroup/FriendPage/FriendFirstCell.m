//
//  FriendFirstCell.m
//  GameGroup
//
//  Created by 魏星 on 14-9-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FriendFirstCell.h"

@implementation FriendFirstCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 45, 45)];
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.headImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 150, 60)];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.titleLabel setFont:[UIFont systemFontOfSize:14.0]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.titleLabel];

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
