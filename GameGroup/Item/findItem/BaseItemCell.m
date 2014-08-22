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
        self.headImg =[[ EGOImageButton alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
        [self addSubview:self.headImg];
        self.headImg.layer.cornerRadius = 5;
        self.headImg.layer.masksToBounds=YES;
        [self.headImg addTarget:self action:@selector(enterPersonInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(60, 10, 170, 20) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.titleLabel];
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(60, 33, 15, 15)];
        [self addSubview:self.gameIconImg];
        
        self.contentLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 26.0f, 320-80-10-26-2, 30) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.contentLabel];
        
        self.timeLabel =[GameCommon buildLabelinitWithFrame:CGRectMake(220, 5, 90, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
        [self addSubview:self.timeLabel];
        
        self.bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 60)];
        self.bgImageView.image = KUIImage(@"team_placeholder2.jpg");
        [self addSubview:self.bgImageView];
        
        self.MemberLable = [[UILabel alloc]initWithFrame:CGRectMake(320-10-26, 49/2+5, 26, 11)];
        self.MemberLable.layer.cornerRadius = 3;
        self.MemberLable.layer.masksToBounds=YES;
        self.MemberLable.textAlignment = NSTextAlignmentCenter;
        self.MemberLable.font = [UIFont systemFontOfSize:10];
        self.MemberLable.textColor = [UIColor whiteColor];
        [self addSubview:self.MemberLable];

    }
    return self;
}

-(void)enterPersonInfoPage:(id)sender
{
    if ([self.mydelegate respondsToSelector:@selector(enterPersonInfoPageWithCell:)]) {
        [self.mydelegate enterPersonInfoPageWithCell:self];
    }
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
