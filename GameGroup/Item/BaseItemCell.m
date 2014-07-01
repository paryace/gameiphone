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
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(0, 0, 0, 0) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        
        
        
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
