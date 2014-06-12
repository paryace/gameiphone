//
//  MemberEditCell.m
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MemberEditCell.h"

@implementation MemberEditCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 6, 45, 45)];
        self.headImageView.backgroundColor = [UIColor whiteColor];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self addSubview:self.headImageView];
        
        self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, 90, 60)];
        [self.nameLable setTextAlignment:NSTextAlignmentLeft];
        [self.nameLable setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLable setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.nameLable];

        self.sfLb = [[UILabel alloc]initWithFrame:CGRectMake(250, 20, 40, 20)];
        self.sfLb.backgroundColor = [UIColor colorWithPatternImage:KUIImage(@"card_click_no")];
        self.sfLb.textColor  = [UIColor grayColor];
        self.sfLb.textAlignment = NSTextAlignmentCenter;
        self.sfLb.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:self.sfLb];
        
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
