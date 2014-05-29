//
//  DataNewsCell.m
//  GameGroup
//
//  Created by 魏星 on 14-5-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "DataNewsCell.h"

@implementation DataNewsCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(30, 0, 1, 164)];
        lineView.backgroundColor = [UIColor grayColor];
        [self addSubview:lineView];
        UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(31, 0, 1, 164)];
        lineView1.backgroundColor = [UIColor whiteColor];
        [self addSubview:lineView1];

        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 30, 30, 30)];
        self.gameIconImg.center = CGPointMake(30, 75);
        [self addSubview:self.gameIconImg];
        
        
        self.bigImg = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 10, 220, 146)];
        self.bigImg.placeholderImage = KUIImage(@"placeholder");
        [self addSubview:self.bigImg];
        
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 120, 220, 20)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.text = @"暂时没有标题";
        self.titleLabel.font =[ UIFont systemFontOfSize:12];
        [self.bigImg addSubview:self.titleLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 110, 50, 20)];
        self.timeLabel.backgroundColor =[ UIColor grayColor];
        self.timeLabel.center = CGPointMake(30, self.timeLabel.center.y);
        self.timeLabel.textAlignment = NSTextAlignmentCenter;
        self.timeLabel.textColor = [UIColor darkGrayColor];
        self.timeLabel.font = [UIFont boldSystemFontOfSize:13];
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
