//
//  OutDodeAddressTableViewCell.m
//  GameGroup
//
//  Created by wangxr on 14-3-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "OutDodeAddressTableViewCell.h"

@implementation OutDodeAddressTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor =UIColorFromRGBA(0xffffff, 1);
        self.backgroundColor = UIColorFromRGBA(0xffffff, 1);
        self.nameL = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 200, 20)];
        _nameL.backgroundColor = [UIColor clearColor];
        _nameL.textColor = UIColorFromRGBA(0x333333, 1);
        [self.contentView addSubview:_nameL];
        self.photoNoL = [[UILabel alloc]initWithFrame:CGRectMake(10, 35, 200, 20)];
        _photoNoL.backgroundColor = [UIColor clearColor];
        _photoNoL.textColor = UIColorFromRGBA(0x868686, 1);
        _photoNoL.font = [UIFont systemFontOfSize:14];
        [self.contentView addSubview:_photoNoL];
        _inviteV = [UIButton buttonWithType:UIButtonTypeCustom];
        _inviteV.titleLabel.font = [UIFont systemFontOfSize:14];
        [_inviteV setTitle:@"" forState:UIControlStateNormal];
        [_inviteV setBackgroundImage:[UIImage imageNamed:@"inv_friend_normal"] forState:UIControlStateNormal];
        [_inviteV setBackgroundImage:[UIImage imageNamed:@"inv_friend_click"] forState:UIControlStateHighlighted];
        [_inviteV addTarget:self action:@selector(inviteFriend) forControlEvents:UIControlEventTouchUpInside];
        _inviteV.frame = CGRectMake(250, 18, 47.5, 28);
        [self.contentView addSubview:_inviteV];
        UIView * lineV = [[UIView alloc]initWithFrame:CGRectMake(0, 59, 320, 1)];
        lineV.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
        [self.contentView addSubview:lineV];

    }
    return self;
}
- (void)inviteFriend
{
    if (self.delegate) {
        [_delegate DodeAddressCell:self.indexPath IsSearch:self.isSearch];
    }
}
- (void)awakeFromNib
{
    // Initialization code
}
-(void)layoutSubviews
{
    [super layoutSubviews];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
