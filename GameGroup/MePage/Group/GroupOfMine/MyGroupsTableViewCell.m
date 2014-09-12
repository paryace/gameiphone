//
//  MyGroupsTableViewCell.m
//  GameGroup
//
//  Created by 魏星 on 14-9-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MyGroupsTableViewCell.h"

@implementation MyGroupsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 6, 64, 64)];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.headImageView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 6, 150, 20)];
        [self.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.titleLabel];

        self.gameImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(80, 30, 15, 15)];
        [self.contentView addSubview:self.headImageView];
        
        
        
        self.memberCountLable = [[UILabel alloc] initWithFrame:CGRectMake(100, 32, 320-80, 20)];
        [self.memberCountLable setTextAlignment:NSTextAlignmentLeft];
        [self.memberCountLable setFont:[UIFont systemFontOfSize:12.0]];
        [self.memberCountLable setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.memberCountLable];
        
        self.describeLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 50, 320-80-5, 20)];
        [self.describeLable setTextAlignment:NSTextAlignmentLeft];
        [self.describeLable setFont:[UIFont systemFontOfSize:12.0]];
        [self.describeLable setBackgroundColor:[UIColor clearColor]];
        [self.contentView addSubview:self.describeLable];
        
        
        
        self.leveLable= [[UILabel alloc] initWithFrame:CGRectMake(320-30, 6, 25, 15)];
        [self.leveLable setTextAlignment:NSTextAlignmentCenter];
        self.leveLable.backgroundColor = kColorWithRGB(119, 137, 203, 1);
        self.leveLable.textColor = [UIColor whiteColor];
        self.leveLable.layer.cornerRadius = 2;
        self.leveLable.layer.masksToBounds=YES;
        [self.leveLable setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.contentView addSubview:self.leveLable];
        
        

    }
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
