//
//  BoundRoleCell.m
//  GameGroup
//
//  Created by Marss on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BoundRoleCell.h"

@implementation BoundRoleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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
