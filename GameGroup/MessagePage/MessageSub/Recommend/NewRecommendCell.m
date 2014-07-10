//
//  NewRecommendCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewRecommendCell.h"

@implementation NewRecommendCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.chooseImg = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
        [self.chooseImg setImageEdgeInsets:UIEdgeInsetsMake(20, 20, 20, 20)];
        [self.chooseImg addTarget:self action:@selector(chooseGz:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.chooseImg];
        
        self.headImg =[[EGOImageView alloc]initWithFrame:CGRectMake(60, 10, 40, 40)];
        self.headImg.layer.cornerRadius = 5;
        self.headImg.layer.masksToBounds=YES;
        
        [self addSubview:self.headImg];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(110, 10, 200, 30)];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.nameLabel];
        

    }
    return self;
}

-(void)chooseGz:(id)sender
{
    [self.myDelegate chooseWithCell:self];
}

-(void)setChooseimgWithString:(NSString *)str
{
    [self.chooseImg setImage:KUIImage(str) forState:UIControlStateNormal];
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
