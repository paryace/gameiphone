//
//  CircleMeCell.m
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CircleMeCell.h"

@implementation CircleMeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.headImgBtn = [[EGOImageButton alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
        self.headImgBtn.frame = CGRectMake(10, 10, 40, 40);
        self.headImgBtn.layer.cornerRadius = 5;
        self.headImgBtn.layer.masksToBounds = YES;
        [self addSubview:self.headImgBtn];
        
        self.nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 6, 120, 20)];
        self.nickNameLabel.textColor = UIColorFromRGBA(0x455ca8, 1);
        self.nickNameLabel.backgroundColor = [UIColor clearColor];
        self.nickNameLabel.font = [UIFont boldSystemFontOfSize:13];
        [self addSubview:self.nickNameLabel];
        
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, 170, 30)];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        self.titleLabel.numberOfLines=0;
        [self addSubview:self.titleLabel];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(245 , 10, 65, 60)];
        bgView.backgroundColor = [UIColor colorWithRed:240/255.0f green:240/255.0f blue:240/255.0f alpha:1];
        [self addSubview:bgView];

        self.contentImageView = [[EGOImageView alloc]initWithPlaceholderImage:KUIImage(@"placeholder")];
        self.contentImageView.frame  = CGRectMake(245, 10, 60, 60);
        [self addSubview:self.contentImageView];
        
        
        self.contentsLabel  =[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        self.contentsLabel.numberOfLines = 4;
        self.contentsLabel.font = [UIFont systemFontOfSize:12];
        self.contentsLabel.backgroundColor = [UIColor clearColor];
        self.contentsLabel.textColor = [UIColor darkGrayColor];
        [bgView addSubview:self.contentsLabel];
        
        self.timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, CGRectGetMidY(self.titleLabel.frame)+20, 170, 20)];
        self.timeLabel.font = [UIFont systemFontOfSize:11];
        self.timeLabel.textColor = [UIColor grayColor];
        [self addSubview:self.timeLabel];
        
    }
    return self;
}
+ (float)getContentHeigthWithStr:(NSString*)contStr
{
    CGSize cSize = [contStr sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(170, 300) lineBreakMode:NSLineBreakByWordWrapping];
    
    return cSize.height;
}
- (void)refreshCell
{
    float heigth = [CircleMeCell getContentHeigthWithStr:self.commentStr];
    self.titleLabel.frame = CGRectMake(60, 27, 170, heigth);
    self.timeLabel.frame  = CGRectMake(60, 30+heigth, 170, 20);
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
