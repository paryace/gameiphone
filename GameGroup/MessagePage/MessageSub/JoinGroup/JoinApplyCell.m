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

        self.userInfoBg = [[UIButton alloc] initWithFrame:CGRectMake(5, 45, 310, 55)];
        self.userInfoBg.backgroundColor = [UIColor clearColor];
        [self.userInfoBg addTarget:self action:@selector(userInfoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgV addSubview:self.userInfoBg];
        
        self.userImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 0, 50, 50)];
        [self.userInfoBg addSubview:self.userImageV];
    
        self.userNameLable = [[UILabel alloc]initWithFrame:CGRectMake(65, 3, 100, 20)];
        self.userNameLable.backgroundColor = [UIColor clearColor];
        self.userNameLable.textColor = [UIColor grayColor];
        self.userNameLable.text = @"用户昵称";
        self.userNameLable.font =[ UIFont systemFontOfSize:14];
        [self.userInfoBg addSubview:self.userNameLable];
        
        
        self.joinReasonLable = [[UILabel alloc]initWithFrame:CGRectMake(65, 30, 300-85, 20)];
        self.joinReasonLable.backgroundColor = [UIColor clearColor];
        self.joinReasonLable.textColor = [UIColor grayColor];
        self.joinReasonLable.text = @"申请理由";
        self.joinReasonLable.font =[ UIFont systemFontOfSize:12];
        [self.userInfoBg addSubview:self.joinReasonLable];
    
        
        self.agreeBtn = [[UIButton alloc] initWithFrame:CGRectMake(3, 104, (304-2)/3, 33)];
        [self.agreeBtn addTarget:self action:@selector(agreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.agreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.agreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        [self.agreeBtn setTitle:@"同意" forState:UIControlStateNormal];
        self.agreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.agreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.agreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.agreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        UIBezierPath *maskPathgreeBtn = [UIBezierPath bezierPathWithRoundedRect:self.agreeBtn.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(3, 3)];
        CAShapeLayer *maskLayergreeBtn = [[CAShapeLayer alloc] init];
        maskLayergreeBtn.frame = self.agreeBtn.bounds;
        maskLayergreeBtn.path = maskPathgreeBtn.CGPath;
        self.agreeBtn.layer.mask = maskLayergreeBtn;
        
        [self.bgV addSubview:self.agreeBtn];
        
        
        self.desAgreeBtn = [[UIButton alloc] initWithFrame:CGRectMake((304-2)/3+4, 104, (304-2)/3, 33)];
        [self.desAgreeBtn addTarget:self action:@selector(desAgreeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.desAgreeBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        
        [self.desAgreeBtn setTitle:@"拒绝" forState:UIControlStateNormal];
        self.desAgreeBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.desAgreeBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.desAgreeBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.desAgreeBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;

       
        [self.bgV addSubview:self.desAgreeBtn];
        
        self.ignoreBtn = [[UIButton alloc] initWithFrame:CGRectMake(((304-2)/3)*2+5, 104, (304-2)/3+3, 33)];
         [self.ignoreBtn addTarget:self action:@selector(ignoreButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"line_btn_normal") forState:UIControlStateNormal];
        [self.ignoreBtn setBackgroundImage:KUIImage(@"line_btn_click") forState:UIControlStateHighlighted];
        
        [self.ignoreBtn setTitle:@"忽略" forState:UIControlStateNormal];
        self.ignoreBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        [self.ignoreBtn setTitleColor:kColorWithRGB(41, 164, 246, 1.0) forState:UIControlStateNormal];
        self.ignoreBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        self.ignoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        UIBezierPath *maskPathignoreBtn = [UIBezierPath bezierPathWithRoundedRect:self.ignoreBtn.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
        CAShapeLayer *maskLayerignoreBtn = [[CAShapeLayer alloc] init];
        maskLayerignoreBtn.frame = self.ignoreBtn.bounds;
        maskLayerignoreBtn.path = maskPathignoreBtn.CGPath;
        self.ignoreBtn.layer.mask = maskLayerignoreBtn;
        
        [self.bgV addSubview:self.ignoreBtn];

        self.stateLable = [[UILabel alloc]initWithFrame:CGRectMake(2, 104, 306, 33)];
        self.stateLable.backgroundColor = kColorWithRGB(230,230,230, 0.7);
        self.stateLable.textColor = [UIColor grayColor];
        self.stateLable.text = @"已同意";
        self.stateLable.font =[ UIFont systemFontOfSize:14];
        self.stateLable.textAlignment = NSTextAlignmentCenter;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.stateLable.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(3, 3)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.stateLable.bounds;
        maskLayer.path = maskPath.CGPath;
        self.stateLable.layer.mask = maskLayer;
        [self.bgV addSubview:self.stateLable];
        
        [self addSubview:self.bgV];
    }
    return self;
}

-(void)userInfoButtonClick:(UIButton*)sender
{
    if (self.detailDeleGate) {
        [self.detailDeleGate userInfoClick:self];
    }
}
-(void)agreeButtonClick:(UIButton*)sender
{
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
