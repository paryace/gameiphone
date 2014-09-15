//
//  TagCell.m
//  GameGroup
//
//  Created by Apple on 14-9-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupTagCell.h"

@implementation GroupTagCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 80, 30)];
        [self.titleLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.titleLabel setBackgroundColor:[UIColor clearColor]];
          self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = UIColorFromRGBA(0x8d8d8b, 1);
        [self.contentView addSubview:self.titleLabel];
    }
    return self;
}

@end
