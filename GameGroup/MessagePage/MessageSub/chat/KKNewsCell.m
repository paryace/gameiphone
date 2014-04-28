//
//  KKNewsCell.m
//  GameGroup
//
//  Created by Shen Yanping on 14-1-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKNewsCell.h"

@implementation KKNewsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //标题
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 270, 50)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self.contentView addSubview:self.titleLabel];
        
        self.thumbImgV = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.thumbImgV.placeholderImage = KUIImage(@"dynamicIMG");
        self.thumbImgV.layer.cornerRadius = 5;
        self.thumbImgV.layer.masksToBounds=YES;
        [self.contentView addSubview:self.thumbImgV];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 270, 200)];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textColor = [UIColor grayColor];
        self.contentLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self.contentView addSubview:self.contentLabel];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
