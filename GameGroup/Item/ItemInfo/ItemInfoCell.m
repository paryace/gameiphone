//
//  ItemInfoCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ItemInfoCell.h"

@implementation ItemInfoCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.headImageView =[[EGOImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;

        [self addSubview:self.headImageView];
        
        self.nickLabel =[GameCommon buildLabelinitWithFrame:CGRectMake(70, 5, 100, 15) font:[UIFont systemFontOfSize:15] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.nickLabel];
        
        self.genderImgView = [[UIImageView alloc]initWithFrame:CGRectMake(175, 2, 20, 20)];
        [self addSubview:self.genderImgView];
        
        self.MemberImgView = [[UIImageView alloc]initWithFrame:CGRectMake(195, 5, 30, 15)];
        [self addSubview:self.MemberImgView];
        
        self.gameIconImgView =[[ EGOImageView alloc]initWithFrame:CGRectMake(70, 22, 15, 15)];
        self.gameIconImgView.placeholderImage = KUIImage(@"clazz_0");
        [self addSubview:self.gameIconImgView];
        
        self.value1Lb =[GameCommon buildLabelinitWithFrame:CGRectMake(90, 22, 200, 15) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.value1Lb];

        self.value2Lb =[GameCommon buildLabelinitWithFrame:CGRectMake(70, 39, 200, 15) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.value2Lb];

        
        self.value3Lb = [GameCommon buildLabelinitWithFrame:CGRectMake(260, 0, 50, 60) font:[UIFont boldSystemFontOfSize:20] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
        self.value1Lb.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.value3Lb];
        
    }
    return self;
}

-(void)refreshViewFrameWithText:(NSString *)text
{
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
    self.nickLabel.frame = CGRectMake(70, 5, size.width, 15);
    self.genderImgView.frame = CGRectMake(70+size.width+5, 2, 15, 15);
    self.MemberImgView.frame = CGRectMake(70+size.width+25, 5, 30, 15);
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
