//
//  NewFirstCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewFirstCell.h"

@implementation NewFirstCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.bgView addSubview:self.headImageV];
        
        self.cardLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(70, 10, 90, 20) font:[UIFont boldSystemFontOfSize:16] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.bgView addSubview:self.cardLabel];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 10, 90, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.nameLabel];
        
        
//        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(170, 5, 20, 20)];
//        self.sexImg.backgroundColor = [UIColor clearColor];
//        [self.bgView addSubview:self.sexImg];
        self.timeLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(100, 3, 200, 10) font:[UIFont systemFontOfSize:10] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
        [self.bgView addSubview:self.timeLabel];
        
        
        self.distLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 240, 20)];
        [self.distLabel setTextColor:[UIColor grayColor]];
        [self.distLabel setFont:[UIFont systemFontOfSize:13]];
        [self.distLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.distLabel];
        [self.contentView addSubview:self.bgView];
        
        self.stopImg = [[UIImageView alloc]initWithFrame:CGRectMake(290, 20, 20, 20)];
        self.stopImg.image = KUIImage(@"palceholder");
        [self.bgView addSubview:self.stopImg];
        
        self.notiBgV = [[UIImageView alloc] initWithFrame:CGRectMake(45, 5, 18, 18)];
        [self.notiBgV setImage:[UIImage imageNamed:@"redCB.png"]];
        self.notiBgV.tag=999;
        self.notiBgV.hidden = NO;
        [self.contentView addSubview:self.notiBgV];
        self.unreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        [self.unreadCountLabel setBackgroundColor:[UIColor clearColor]];
        [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.unreadCountLabel setTextColor:[UIColor whiteColor]];
        self.unreadCountLabel.font = [UIFont systemFontOfSize:12.0];
        self.unreadCountLabel.text = @"98";
        [self.notiBgV addSubview:self.unreadCountLabel];
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
