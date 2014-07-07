//
//  BaseItemCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseItemCell.h"

@implementation BaseItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColorFromRGBA(0xf3f3f3, 1);
        self.headImg =[[ EGOImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self addSubview:self.headImg];
        
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 5, 170, 20) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        self.contentLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 25, 250, 30) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.contentLabel.numberOfLines = 0;
        [self addSubview:self.contentLabel];
        
        self.timeLabel =[GameCommon buildLabelinitWithFrame:CGRectMake(220, 5, 90, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
        [self addSubview:self.timeLabel];
        
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
