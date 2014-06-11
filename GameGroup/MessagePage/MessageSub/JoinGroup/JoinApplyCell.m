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
    
        
        self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 95, (300-2)/3, 35)];
        [self.agreeBtn addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.agreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
        [self.agreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        [self.agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        self.agreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.agreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.agreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.agreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bgV addSubview:self.agreeBtn];
        
        
        self.desAgreeBtn = [[UIButton alloc] initWithFrame:CGRectMake((300-2)/3+6, 95, (300-2)/3, 35)];
        [self.desAgreeBtn addTarget:self action:@selector(desAgreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        
        [self.desAgreeBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        self.desAgreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.desAgreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.desAgreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.desAgreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

       
        [bgV addSubview:self.desAgreeBtn];
        
        self.ignoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(((300-2)/3)*2+7, 95, (300-2)/3, 35)];
         [self.ignoreBtn addTarget:self action:@selector(ignoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"blue_button_click") forState:UIControlStateHighlighted];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateSelected];
        
        [self.ignoreBtn setTitle:@"忽略" forState:UIControlStateNormal];
        self.ignoreBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.ignoreBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.ignoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.ignoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [bgV addSubview:self.ignoreBtn];
        
        
        self.applicationState = [[UILabel alloc]initWithFrame:CGRectMake(0, 95, 310, 35)];
        self.applicationState.backgroundColor = [UIColor clearColor];
        self.applicationState.textColor = [UIColor grayColor];
        self.applicationState.text = @"入群申请已经被通过";
        self.applicationState.textAlignment = NSTextAlignmentCenter;
        self.applicationState.font =[ UIFont systemFontOfSize:12];
//        [bgV addSubview:self.applicationState];
        [self addSubview:bgV];
    }
    return self;
}
-(void)agreeButtonClick:(UIButton*)sender
{
//    sender.selected = !sender.selected;
    if (self.detailDeleGate) {
        [self.detailDeleGate agreeMsg:self];
    }
}
-(void)desAgreeButtonClick:(UIButton*)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate desAgreeMsg:self];
    }
}
-(void)ignoreButtonClick:(UIButton*)sender
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
