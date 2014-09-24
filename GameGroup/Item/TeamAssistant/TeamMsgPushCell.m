//
//  TeamMsgPushCell.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamMsgPushCell.h"

@implementation TeamMsgPushCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(20, 10, 320-65, 20) font:[UIFont systemFontOfSize:16] textColor:kColorWithRGB(112, 112, 112, 1) backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        self.contentLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(20, 35, 320-65, 20) font:[UIFont systemFontOfSize:12] textColor:kColorWithRGB(164, 164, 164, 1) backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.contentLabel];
        
        self.stopImg = [[UIImageView alloc]initWithFrame:CGRectMake(320-45, 22.5, 20, 20)];
        self.stopImg.image = KUIImage(@"palceholder");
        [self addSubview:self.stopImg];

    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
