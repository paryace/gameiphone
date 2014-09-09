//
//  KKTeamInviteCell.m
//  GameGroup
//
//  Created by Apple on 14-7-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKTeamInviteCell.h"
@implementation KKTeamInviteCell
{
    UIImageView *headImg;
    UILabel *titleLabel;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //标题
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 270, 50)];
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor blackColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
        [self.contentView addSubview:self.titleLabel];
        
        self.lineImage = [[UIImageView alloc] initWithFrame:CGRectMake(56, 0, 50, 1)];
        self.lineImage.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.lineImage];
        
        self.thumbImgV = [[EGOImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.thumbImgV.placeholderImage = KUIImage(@"dynamicIMG");
        self.thumbImgV.layer.cornerRadius = 5;
        self.thumbImgV.layer.masksToBounds=YES;
        [self.contentView addSubview:self.thumbImgV];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 270, 200)];
        self.contentLabel.textAlignment = NSTextAlignmentLeft;
        self.contentLabel.numberOfLines = 0;
        self.contentLabel.backgroundColor = [UIColor clearColor];
        self.contentLabel.textColor = [UIColor grayColor];
        self.contentLabel.font = [UIFont boldSystemFontOfSize:13.0];
        [self.contentView addSubview:self.contentLabel];

        self.attView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 220, 25)];
        [self.contentView addSubview:self.attView];
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 215, 1)];
        img.image = KUIImage(@"msg_line");
        [self.attView addSubview:img];
        
        headImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 7, 11, 11)];
        [self.attView addSubview:headImg];
        
        titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(30, 5, 150, 15) font:[UIFont systemFontOfSize:10] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.attView addSubview:titleLabel];
        
        
        UIImageView *rightImg = [[UIImageView alloc]initWithFrame:CGRectMake(190, 7, 11, 11)];
        rightImg.image = KUIImage(@"msg_right");
        [self.attView addSubview:rightImg];
        
        
    }
    return self;
}

-(void)putTextAndImgWithType:(NSInteger)type
{
    switch (type) {
        case 0://群组
            headImg.image = KUIImage(@"msg_type_1");
            titleLabel.text = @"群组邀请";
            break;
        case 1: //角色
            headImg.image = KUIImage(@"msg_type_2");
            titleLabel.text = @"角色详情";
            break;
        case 2://组队
            headImg.image = KUIImage(@"msg_type_3");
            titleLabel.text = @"组队邀请";
            break;
        default:
            break;
    }
    

}
- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
