//
//  FirstCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "FirstCell.h"

@implementation FirstCell
{
    float dd;
    BOOL isrow;
    UIButton *editBtn;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        isrow = YES;
        
        UIImageView *bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 300, 60)];
        bgImg.image = KUIImage(@"other_normal2");
        [self.contentView addSubview:bgImg];
        
        
        UIImage *aImage = KUIImage(@"clazz_0");
        self.headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 50, 50)];
        self.headImgView.image = aImage;
        [self.contentView addSubview:self.headImgView];
        
        UIButton *button  =[[UIButton alloc]initWithFrame:CGRectMake(15, 10, 50, 50)];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(didClickRow:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        
        
        self.nameLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 10, 140, 20) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.nameLabel];
        
        self.gameIconImg = [[UIImageView alloc]initWithFrame:CGRectMake(80, 30, 15, 15)];
        self.gameIconImg.image = [UIImage imageNamed:@"1"];
        [self.contentView addSubview:self.gameIconImg];
        
        
        self.realmLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(90, 30, 120, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor  grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.realmLabel];
        
        self.editLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(270, 20, 30, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.editLabel];
        
        editBtn = [[UIButton alloc]initWithFrame:CGRectMake(270, 0, 30, 60)];
        editBtn.backgroundColor = [UIColor clearColor];
        [editBtn addTarget:self action:@selector(enterEditPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editBtn];
    }
    return self;
}

-(void)didClickRow:(id)sender
{
    if ([self.myDelegate respondsToSelector:@selector(didClickRowWithCell:)]) {
        [self.myDelegate didClickRowWithCell:self];
    }
    if (!isrow) {
        isrow = YES;
        editBtn.hidden  = NO;
        self.editLabel.text = @"编辑";
    }else{
        isrow =NO;
        editBtn.hidden  =YES;
        self.editLabel.text = @"2/5人";
    }
    [self didRow];
}
-(void)didRow
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.01];
    [UIView setAnimationDelegate:self];
    if (!isrow) {
        [UIView setAnimationDidStopSelector:@selector(endAnimation)];
    }
    self.headImgView.transform = CGAffineTransformMakeRotation(dd * (M_PI / 180.0f));
    [UIView commitAnimations];
}
-(void)endAnimation
{
    dd += 10;
    [self didRow];
}

-(void)enterEditPage:(id)sender
{
    if ([self.myDelegate respondsToSelector:@selector(didClickEnterEditPageWithCell:)]) {
        [self.myDelegate didClickEnterEditPageWithCell:self];
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
