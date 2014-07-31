//
//  ICreatedCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ICreatedCell.h"

@implementation ICreatedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(10, 10, 200, 20) font:[UIFont boldSystemFontOfSize:15] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.titleLabel];
        
        self.gameIconImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 30, 20, 20)];
        self.gameIconImageView.placeholderImage = KUIImage(@"clazz_0");
        [self.contentView addSubview:self.gameIconImageView];
        
        self.realmLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(33, 32, 180, 15) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.realmLabel];
        
        self.numLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(220, 0, 40, 60) font:[UIFont boldSystemFontOfSize:18] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.numLabel];
        
        self.sqLb = [GameCommon buildLabelinitWithFrame:CGRectMake(260, 0, 40, 60) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.sqLb.text = @"申请";
        [self.contentView addSubview:self.sqLb];
        
        
        
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
