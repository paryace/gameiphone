//
//  CreateTimeCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CreateTimeCell.h"

@implementation CreateTimeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 10, 50, 20)]
        ;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor grayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.titleLabel.text = @"创建于";
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(80, 10, 210, 20)];
        self.timeLabel.textColor = [UIColor grayColor];
        self.timeLabel.adjustsFontSizeToFitWidth = YES;
        self.timeLabel.font = [UIFont systemFontOfSize:14];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.backgroundColor=[UIColor clearColor];
        [self.contentView addSubview:self.timeLabel];
        
        

    }
    return self;
}

@end
