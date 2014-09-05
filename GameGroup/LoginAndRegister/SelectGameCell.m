//
//  SelectGameCell.m
//  GameGroup
//
//  Created by Marss on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SelectGameCell.h"

@implementation SelectGameCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setSubView];
    }
    return self;
}
- (void)setSubView
{
    // 箭头
    UIImageView * arrowImage = [[UIImageView alloc]initWithFrame:CGRectMake(250, 29, 18, 18)];
//    arrowImage.backgroundColor = [UIColor blackColor];
    arrowImage.image = KUIImage(@"touxiang_14");
    [self addSubview:arrowImage];
    // 游戏名称label
    self.gameLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 20, 100, 40)];
//    self.gameLabel.backgroundColor = [UIColor redColor];
    [self addSubview:self.gameLabel];
    // 游戏标志
    self.gameIcon = [[EGOImageView alloc]initWithFrame:CGRectMake(20, 20, 40, 40)];
    [self addSubview:self.gameIcon];
    
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
