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
        self.backgroundColor = [UIColor whiteColor];
        self.headImg =[[ EGOImageButton alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.headImg];
        self.headImg.layer.cornerRadius = 5;
        self.headImg.layer.masksToBounds=YES;
        [self.headImg addTarget:self action:@selector(enterPersonInfoPage:) forControlEvents:UIControlEventTouchUpInside];
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 10, 320-80-30, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 53, 15, 15)];
        [self addSubview:self.gameIconImg];
        
        self.contentLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(100, 50, 320-100-90, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.contentLabel];
        
        self.timeLabel =[GameCommon buildLabelinitWithFrame:CGRectMake(320-90-5, 50, 90, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
        [self addSubview:self.timeLabel];
        
        self.bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 320, 60)];
        self.bgImageView.image = KUIImage(@"team_placeholder2.jpg");
        [self addSubview:self.bgImageView];
        
        self.MemberImage = [[UIImageView alloc]initWithFrame:CGRectMake(320-30, 0, 30, 30)];
        [self addSubview:self.MemberImage];

    }
    return self;
}

-(void)enterPersonInfoPage:(id)sender
{
    if ([self.mydelegate respondsToSelector:@selector(enterPersonInfoPageWithCell:)]) {
        [self.mydelegate enterPersonInfoPageWithCell:self];
    }
}
-(void)refreText:(NSString*)timeStr{
     CGSize sizeThatFits = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(320-80-30, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    float hight = sizeThatFits.height>40?40:sizeThatFits.height;
    self.titleLabel.frame = CGRectMake(80, 10, 320-80-32, hight);
    self.gameIconImg.frame = CGRectMake(80, 10+hight+8, 15, 15);
    CGSize size = [timeStr sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
    self.timeLabel.frame = CGRectMake(320-size.width-5, 10+hight+5, size.width, 20);
    self.contentLabel.frame = CGRectMake(100, 10+hight+5, 320-100-size.width - 5, 20);
    
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
