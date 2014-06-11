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
        UIImageView *bgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 310, 135)];
        bgV.image = KUIImage(@"group_cell_bg");
        bgV.userInteractionEnabled =YES;
        
        
        
        self.groupImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 5, 25, 25)];
        [bgV addSubview:self.groupImageV];
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(40, 7, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = [UIColor grayColor];
        self.groupNameLable.text = @"群名";
        self.groupNameLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.groupNameLable];
        
        self.groupCreateTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(300-50-5, 7, 50, 20)];
        self.groupCreateTimeLable.backgroundColor = [UIColor clearColor];
        self.groupCreateTimeLable.textColor = [UIColor grayColor];
        self.groupCreateTimeLable.text = @"昨天20:09";
        self.groupCreateTimeLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.groupCreateTimeLable];
        
        UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(10, 35, 310-20, 1)];
        lineView1.backgroundColor = kColorWithRGB(200,200,200, 0.7);
        [bgV addSubview:lineView1];

        
        
        
        
        self.contentLable = [[UILabel alloc]initWithFrame:CGRectMake(30, 37, 310-60, 60)];
        self.contentLable.backgroundColor = [UIColor clearColor];
        self.contentLable.textColor = [UIColor grayColor];
        self.contentLable.text = @"申请理由";
        self.contentLable.font =[ UIFont systemFontOfSize:14];
        self.contentLable.numberOfLines = 4 ;
        [bgV addSubview:self.contentLable];
        
        
        self.oneBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 98, (300-1)/2, 33)];
        [self.oneBtn addTarget:self action:@selector(oneButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.oneBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.oneBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
        [self.oneBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        [self.oneBtn setTitle:@"邀请新成员" forState:UIControlStateNormal];
        self.oneBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.oneBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.oneBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.oneBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bgV addSubview:self.oneBtn];
        
        
        self.twoBtn = [[UIButton alloc] initWithFrame:CGRectMake((300-1)/2+6, 98, (300-1)/2, 33)];
        [self.twoBtn addTarget:self action:@selector(twoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.twoBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.twoBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
        [self.twoBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        
        [self.twoBtn setTitle:@"群组小技巧" forState:UIControlStateNormal];
        self.twoBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.twoBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.twoBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.twoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bgV addSubview:self.twoBtn];
        
        self.threeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 98,300, 33)];
        [self.threeBtn addTarget:self action:@selector(threeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.threeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.threeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        [self.threeBtn setTitle:@"查看进度" forState:UIControlStateNormal];
        self.threeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.threeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.threeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.threeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bgV addSubview:self.threeBtn];
        
        [self addSubview:bgV];
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
