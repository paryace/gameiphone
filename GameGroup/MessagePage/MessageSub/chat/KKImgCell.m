//
//  KKImgCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKImgCell.h"

@implementation KKImgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

        self.MSGImageView = [[EGOImageView alloc]initWithFrame:CGRectZero];
        self.MSGImageView.layer.cornerRadius = 5;
        self.headImgV.layer.masksToBounds  = YES;
        [self.contentView addSubview:self.MSGImageView];
        
        
        
        
        
        
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
