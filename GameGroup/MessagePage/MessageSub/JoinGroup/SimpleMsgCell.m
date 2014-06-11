//
//  SimpleMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SimpleMsgCell.h"

@implementation SimpleMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgV.frame = CGRectMake(5, 0, 310, 100);
        self.contentLable = [[UILabel alloc]initWithFrame:CGRectMake(30, 37, 310-60, 60)];
        self.contentLable.backgroundColor = [UIColor clearColor];
        self.contentLable.textColor = [UIColor grayColor];
        self.contentLable.text = @"申请理由";
        self.contentLable.font =[ UIFont systemFontOfSize:14];
        self.contentLable.textAlignment = NSTextAlignmentCenter;
        self.contentLable.numberOfLines = 4 ;
        [self.bgV addSubview:self.contentLable];
        [self addSubview:self.bgV];
    }
    return self;
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
