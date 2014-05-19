//
//  GuildCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GuildCell.h"

@implementation GuildCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.gameImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        self.gameImageView.image = KUIImage(@"wow");
        [self.contentView addSubview:self.gameImageView];
        
        self.guildLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 10, 250, 40)];
        self.guildLabel.textAlignment = NSTextAlignmentLeft;
        self.guildLabel.font = [UIFont boldSystemFontOfSize:15];
        self.guildLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.guildLabel];
        
        
        self.guildsNumLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 55, 250, 20)];
        self.guildsNumLabel.font = [UIFont systemFontOfSize:12];
        self.guildsNumLabel.textColor = [UIColor grayColor];
        self.guildsNumLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.guildsNumLabel];
        
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
