//
//  DropTitleCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "DropTitleCell.h"

@implementation DropTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(10, self.frame.origin.y, self.frame.size.width-10, self.frame.size.height) font:[UIFont systemFontOfSize:14] textColor:[UIColor whiteColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.titleLabel];
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
