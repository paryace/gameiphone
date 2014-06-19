//
//  GroupSettingCell.m
//  GameGroup
//
//  Created by Apple on 14-6-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "GroupSettingCell.h"

@implementation GroupSettingCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 15, 200, 20)];
        self.titleLable.backgroundColor = [UIColor clearColor];
        self.titleLable.textColor = [UIColor blackColor];
        self.titleLable.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.titleLable];
    }
    return self;
}

@end
