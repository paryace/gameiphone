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
        self.backgroundColor = [UIColor clearColor];
        self.senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        //居中显示
        self.senderAndTimeLabel.backgroundColor = [UIColor clearColor];
        self.senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        //文字颜色
        self.senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.senderAndTimeLabel];
        
        self.headImgV = [[EGOImageButton alloc] initWithFrame:CGRectZero];
        self.headImgV.layer.cornerRadius = 5;
        self.headImgV.layer.masksToBounds=YES;
        [self.contentView addSubview:self.headImgV];
        
        self.bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgImageView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.contentView addSubview:self.bgImageView];

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
        
//        self.arrowImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 12)];
//        self.arrowImage.image = KUIImage(@"right_arrow");
//        [self.contentView addSubview:self.arrowImage];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
