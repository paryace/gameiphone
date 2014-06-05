//
//  BlackListCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BlackListCell.h"

@implementation BlackListCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 6, 45, 45)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        self.headImageV.placeholderImage = KUIImage(@"people_man.png");
        [self.bgView addSubview:self.headImageV];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 5, 90, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLabel];
        
        
//        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(170, 5, 20, 20)];
//        self.sexImg.backgroundColor = [UIColor clearColor];
//        [self.bgView addSubview:self.sexImg];
        
        self.distLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 35, 240, 20)];
        [self.distLabel setTextColor:[UIColor blackColor]];
        [self.distLabel setFont:[UIFont systemFontOfSize:13]];
        [self.distLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.distLabel];
        [self addSubview:self.bgView];

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
