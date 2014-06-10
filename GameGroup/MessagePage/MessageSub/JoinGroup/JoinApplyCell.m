//
//  JoinApplyCell.m
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//
//@property(nonatomic,strong)EGOImageView * groupImageV;
//@property(nonatomic,strong)UILabel * groupNameLable;
//@property(nonatomic,strong)UILabel * groupCreateTimeLable;
//
//@property(nonatomic,strong)EGOImageView *userImageV;
//@property(nonatomic,strong)UILabel * userNameLable;
//@property(nonatomic,strong)UILabel * joinReasonLable;
//
//@property(nonatomic,strong)UIButton * agreeBtn;//同意
//@property(nonatomic,strong)UIButton * desAgreeBtn;//拒绝
//@property(nonatomic,strong)UIButton * ignoreBtn;//忽略
#import "JoinApplyCell.h"

@implementation JoinApplyCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        UIImageView *bgV = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 310, 85)];
        [self addSubview:bgV];
        
       
        
        self.groupImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 5, 25, 25)];
        self.groupImageV.image = KUIImage(@"bg_cell");
        [bgV addSubview:self.groupImageV];
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(35, 7, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = [UIColor grayColor];
        self.groupNameLable.text = @"群名";
        self.groupNameLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.groupNameLable];
        
        self.groupCreateTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(320-50-5, 7, 50, 20)];
        self.groupCreateTimeLable.backgroundColor = [UIColor clearColor];
        self.groupCreateTimeLable.textColor = [UIColor grayColor];
        self.groupCreateTimeLable.text = @"昨天20:09";
        self.groupCreateTimeLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.groupCreateTimeLable];
        
        UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(5, 35, 320-5, 1)];
        lineView1.backgroundColor = [UIColor whiteColor];
        [bgV addSubview:lineView1];
        
        self.userImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(30, 40, 50, 50)];
        [bgV addSubview:self.userImageV];
        
        
        self.userNameLable = [[UILabel alloc]initWithFrame:CGRectMake(75, 40, 100, 20)];
        self.userNameLable.backgroundColor = [UIColor clearColor];
        self.userNameLable.textColor = [UIColor grayColor];
        self.userNameLable.text = @"用户昵称";
        self.userNameLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.userNameLable];
        
        
        self.joinReasonLable = [[UILabel alloc]initWithFrame:CGRectMake(75, 65, 100, 20)];
        self.joinReasonLable.backgroundColor = [UIColor clearColor];
        self.joinReasonLable.textColor = [UIColor grayColor];
        self.joinReasonLable.text = @"申请理由";
        self.joinReasonLable.font =[ UIFont systemFontOfSize:12];
        [bgV addSubview:self.joinReasonLable];
        
        
        self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 90, 310/3, 25)];
        [self.agreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [self.agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        self.agreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.agreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.agreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.agreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.agreeBtn.userInteractionEnabled = YES;
        [self.agreeBtn addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgV addSubview:self.agreeBtn];
        
        self.desAgreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5+310/3, 90, 310/3, 25)];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [self.desAgreeBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        self.desAgreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.desAgreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.desAgreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.desAgreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.desAgreeBtn.userInteractionEnabled = YES;
        [self.desAgreeBtn addTarget:self action:@selector(desAgreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgV addSubview:self.desAgreeBtn];
        
        self.ignoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(5+310/3+310/3, 90, 310/3, 25)];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [self.ignoreBtn setTitle:@"忽略" forState:UIControlStateNormal];
        self.ignoreBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.ignoreBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.ignoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.ignoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        self.ignoreBtn.userInteractionEnabled = YES;
        [self.ignoreBtn addTarget:self action:@selector(ignoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgV addSubview:self.ignoreBtn];
    }
    return self;
}
-(void)agreeButtonClick:(id)sender
{
    
}
-(void)desAgreeButtonClick:(id)sender
{
    
}
-(void)ignoreButtonClick:(id)sender
{
    
}

- (void)awakeFromNib
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
