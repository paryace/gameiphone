//
//  JoinApplyCell.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//
#import "JoinApplyCell.h"

@implementation JoinApplyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *bgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 310, 125)];
         bgV.image = KUIImage(@"group_cell_bg");
        
        
       
        
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
        lineView1.backgroundColor = [UIColor grayColor];
        [bgV addSubview:lineView1];
        
        self.userImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(30, 40, 50, 50)];
        [bgV addSubview:self.userImageV];
        
        
        self.userNameLable = [[UILabel alloc]initWithFrame:CGRectMake(85, 40, 100, 20)];
        self.userNameLable.backgroundColor = [UIColor clearColor];
        self.userNameLable.textColor = [UIColor grayColor];
        self.userNameLable.text = @"用户昵称";
        self.userNameLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.userNameLable];
        
        
        self.joinReasonLable = [[UILabel alloc]initWithFrame:CGRectMake(85, 65, 100, 20)];
        self.joinReasonLable.backgroundColor = [UIColor clearColor];
        self.joinReasonLable.textColor = [UIColor grayColor];
        self.joinReasonLable.text = @"申请理由";
        self.joinReasonLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.joinReasonLable];
        
        
        UIButton *agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 95, 100, 25)];
        [agreeBtn addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [agreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [agreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        agreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [agreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        agreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        agreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

        [bgV addSubview:agreeBtn];
        
        UIButton * desAgreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5+100, 95, 100, 25)];
        [desAgreeBtn addTarget:self action:@selector(desAgreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [desAgreeBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        desAgreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [desAgreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        desAgreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        desAgreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

       
        [bgV addSubview:desAgreeBtn];
        
        UIButton *ignoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(5+200, 95, 100, 25)];
         [ignoreBtn addTarget:self action:@selector(ignoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [ignoreBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [ignoreBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        
        [ignoreBtn setTitle:@"忽略" forState:UIControlStateNormal];
        ignoreBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [ignoreBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        ignoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        ignoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bgV addSubview:ignoreBtn];
        [self addSubview:bgV];
    }
    return self;
}
-(void)agreeButtonClick:(id)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate agreeMsg:self];
    }
}
-(void)desAgreeButtonClick:(id)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate desAgreeMsg:self];
    }
}
-(void)ignoreButtonClick:(id)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate ignoreMsg:self];
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
