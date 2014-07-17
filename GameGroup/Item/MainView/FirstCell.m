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
    
    UIButton *editBtn;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.isrow = YES;
        
        UIImageView *bgImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 300, 60)];
        bgImg.image = KUIImage(@"other_normal2");
        [self.contentView addSubview:bgImg];
        
        UIImageView *lodImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 50, 50)];
        lodImageView.image = KUIImage(@"start_team_bj");
        [self.contentView addSubview:lodImageView];
        
        UIImage *aImage = KUIImage(@"start_team_bj1");
        self.headImgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 50, 50)];
        self.headImgView.image = aImage;
        [self.contentView addSubview:self.headImgView];
        
        UIButton *button  =[[UIButton alloc]initWithFrame:CGRectMake(15, 10, 50, 50)];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(didClickSearch:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];
        
        
        self.nameLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 10, 140, 20) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.nameLabel];
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 35, 20, 20)];
//        self.gameIconImg.image = [UIImage imageNamed:@"1"];
        [self.contentView addSubview:self.gameIconImg];

        
        self.realmLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(105, 35, 160, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor  grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.realmLabel.adjustsLetterSpacingToFitWidth = YES;
        [self.contentView addSubview:self.realmLabel];
        
        self.editLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(270, 20, 40, 20) font:[UIFont systemFontOfSize:13] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.contentView addSubview:self.editLabel];
        
        editBtn = [[UIButton alloc]initWithFrame:CGRectMake(270, 0, 30, 60)];
        editBtn.backgroundColor = [UIColor clearColor];
        [editBtn addTarget:self action:@selector(enterEditPage:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:editBtn];
    }
    return self;
}

-(void)didClickRow
{
    
    NSLog(@"%hhd",self.isrow);
    if (!self.isrow) {
        self.isrow = YES;
        self.editLabel.text = @"编辑";
    }else{
        self.isrow =NO;
        self.editLabel.text = [NSString stringWithFormat:@"%@支队伍",self.machCountStr];
    }
    [self didRow];
}

-(void)didClickSearch:(id)sender
{
//    NSLog(@"%hhd",self.isrow);
//    if (!self.isrow) {
//        self.isrow = YES;
//        self.editLabel.text = @"编辑";
//    }else{
//        self.isrow =NO;
//        
//    }
    if ([self.myDelegate respondsToSelector:@selector(didClickRowWithCell:isRow:)]) {
        [self.myDelegate didClickRowWithCell:self isRow:self.isrow];
    }
//    [self didRow];
}


-(void)didRow
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationDelegate:self];
    if (!self.isrow) {
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
    if ([self.myDelegate respondsToSelector:@selector(didClickEnterEditPageWithCell:isrow:)]) {
        [self.myDelegate didClickEnterEditPageWithCell:self isrow:self.isrow];
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
