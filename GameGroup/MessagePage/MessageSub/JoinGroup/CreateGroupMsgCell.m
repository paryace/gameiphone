//
//  CreateGroupMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "CreateGroupMsgCell.h"

@implementation CreateGroupMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentLable = [[UILabel alloc]initWithFrame:CGRectMake(30, 37, 310-60, 60)];
        self.contentLable.backgroundColor = [UIColor clearColor];
        self.contentLable.textColor = [UIColor grayColor];
        self.contentLable.text = @"申请理由";
        self.contentLable.font =[ UIFont systemFontOfSize:14];
        self.contentLable.numberOfLines = 4 ;
        [self.bgV addSubview:self.contentLable];
        
        
        self.oneBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 98, (310-1)/2, 33)];
        [self.oneBtn addTarget:self action:@selector(oneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.oneBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.oneBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [self.oneBtn setTitle:@"邀请新成员" forState:UIControlStateNormal];
        self.oneBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.oneBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.oneBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.oneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.bgV addSubview:self.oneBtn];
        
        
        self.twoBtn = [[UIButton alloc] initWithFrame:CGRectMake((310-1)/2+6, 98, (310-1)/2, 33)];
        [self.twoBtn addTarget:self action:@selector(twoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.twoBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.twoBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        
        [self.twoBtn setTitle:@"群组小技巧" forState:UIControlStateNormal];
        self.twoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.twoBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.twoBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.twoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.bgV addSubview:self.twoBtn];
        
        self.threeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 98,310, 33)];
        [self.threeBtn addTarget:self action:@selector(threeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.threeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.threeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        [self.threeBtn setTitle:@"查看进度" forState:UIControlStateNormal];
        self.threeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.threeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.threeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.threeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [self.bgV addSubview:self.threeBtn];
        
        [self addSubview:self.bgV];
    }
    return self;
}

-(void)oneButtonClick:(UIButton*)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate inviteClick:self];
    }
}
-(void)twoButtonClick:(UIButton*)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate skillClick:self];
    }
}
-(void)threeButtonClick:(UIButton*)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate detailClick:self];
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
