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
        
        self.headImageView =[[EGOImageView alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;
        [self addSubview:self.headImageView];
        
        self.bgImageView = [[UIButton alloc]initWithFrame:CGRectMake(10, 5, 50, 50)];
        self.bgImageView.layer.cornerRadius = 5;
        self.bgImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView  addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView setBackgroundImage:nil forState:UIControlStateNormal];
        
        
        self.nickLabel =[GameCommon buildLabelinitWithFrame:CGRectMake(70, 5, 100, 15) font:[UIFont boldSystemFontOfSize:15] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.nickLabel];
        
        self.genderImgView = [[UIImageView alloc]initWithFrame:CGRectMake(175, 2, 20, 20)];
        [self addSubview:self.genderImgView];
        
        self.MemberLable = [[UILabel alloc]initWithFrame:CGRectMake(195, 5, 30, 15)];
        self.MemberLable.layer.cornerRadius = 3;
        self.MemberLable.layer.masksToBounds=YES;
        self.MemberLable.textAlignment = NSTextAlignmentCenter;
        self.MemberLable.font = [UIFont systemFontOfSize:11];
        self.MemberLable.textColor = [UIColor whiteColor];
        [self addSubview:self.MemberLable];
        
        self.gameIconImgView =[[ EGOImageView alloc]initWithFrame:CGRectMake(70, 22, 15, 15)];
        self.gameIconImgView.placeholderImage = KUIImage(@"clazz_0");
        [self addSubview:self.gameIconImgView];
        
        self.value1Lb =[GameCommon buildLabelinitWithFrame:CGRectMake(90, 22, 200, 15) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.value1Lb.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.value1Lb];

        self.value2Lb =[GameCommon buildLabelinitWithFrame:CGRectMake(70, 39, 200, 15) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.value2Lb.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.value2Lb];

        
        self.value3Lb = [GameCommon buildLabelinitWithFrame:CGRectMake(260, 0, 50, 60) font:[UIFont boldSystemFontOfSize:16] textColor:UIColorFromRGBA(0x3eacf5, 1) backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentCenter];
        self.value1Lb.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.value3Lb];
        
    }
    return self;
}

-(void)headOnClick:(UIButton*)sender
{
    if (self.delegate) {
        [self.delegate headImgClick:self];
    }
}



-(void)refreshViewFrameWithText:(NSString *)text
{
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
    float w = size.width>185?185:size.width;
    self.nickLabel.frame = CGRectMake(70, 5, w, 15);
    self.genderImgView.frame = CGRectMake(70+w, 2, 20, 20);
    self.MemberLable.frame = CGRectMake(70+w+20+5, 5, 30, 15);
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
