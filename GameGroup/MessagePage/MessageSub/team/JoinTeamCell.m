//
//  JoinTeamCell.m
//  GameGroup
//
//  Created by Apple on 14-7-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#define bgVImageHeight self.bgV.bounds.size.height
#import "JoinTeamCell.h"

@implementation JoinTeamCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 310, 85)];
        self.bgV.image = KUIImage(@"upimage");
        self.bgV.userInteractionEnabled =YES;
        
        self.headImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self.bgV addSubview:self.headImageV];
        
        self.bgImageView = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        self.bgImageView.layer.cornerRadius = 5;
        self.bgImageView.layer.masksToBounds=YES;
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView  addTarget:self action:@selector(headOnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgImageView setBackgroundImage:nil forState:UIControlStateNormal];
        [self.bgV addSubview:self.bgImageView];

    
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(75, 12, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.groupNameLable.text = @"萌萌哒~";
        self.groupNameLable.font =[ UIFont systemFontOfSize:17];
        [self.bgV addSubview:self.groupNameLable];
        
        self.genderImageV = [[UIImageView alloc]initWithFrame:CGRectMake(180, 10, 20, 20)];
        [self.bgV addSubview:self.genderImageV];
        
        self.positionLable = [[UILabel alloc]initWithFrame:CGRectMake(205, 13, 30, 15)];
        self.positionLable.backgroundColor = [UIColor blueColor];
        self.positionLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.positionLable.text = @"职位";
        self.positionLable.textColor = [UIColor whiteColor];
        self.positionLable.layer.masksToBounds = YES;
        self.positionLable.layer.cornerRadius = 3.0;
        self.positionLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.positionLable];
        
        self.gameImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(75, 35, 25, 25)];
        [self.bgV addSubview:self.gameImageV];
        
        self.realmLable = [[UILabel alloc]initWithFrame:CGRectMake(105, 37, 200, 20)];
        self.realmLable.backgroundColor = [UIColor clearColor];
        self.realmLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.realmLable.text = @"猫小莹-德玛西亚";
        self.realmLable.font =[ UIFont systemFontOfSize:13];
        [self.bgV addSubview:self.realmLable];
        
        self.pveLable = [[UILabel alloc]initWithFrame:CGRectMake(75, 62, 300, 20)];
        self.pveLable.backgroundColor = [UIColor clearColor];
        self.pveLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.pveLable.text = @"战斗力：6600   荣誉黄金";
        self.pveLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.pveLable];
        
        self.timeLable = [[UILabel alloc]initWithFrame:CGRectMake(220, 12, 80, 20)];
        self.timeLable.backgroundColor = [UIColor clearColor];
        self.timeLable.textAlignment = NSTextAlignmentRight;
        self.timeLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.timeLable.text = @"时间";
        self.timeLable.font =[ UIFont systemFontOfSize:12];
        [self.bgV addSubview:self.timeLable];
        [self.contentView addSubview:self.bgV];
        
        
        self.agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.agreeButton.frame = CGRectMake(5,95,155, 36);
        [self.agreeButton setBackgroundImage:[UIImage imageNamed:@"agree.png"] forState:UIControlStateNormal];
        [self.agreeButton addTarget:self action:@selector(agreeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.agreeButton];
        
        self.refuseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.refuseButton.frame = CGRectMake(160,95,155, 36);
        [self.refuseButton setBackgroundImage:[UIImage imageNamed:@"refuse.png"] forState:UIControlStateNormal];
        [self.refuseButton addTarget:self action:@selector(refuseButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.refuseButton];
        
        
        self.detailLable = [[UILabel alloc]initWithFrame:CGRectMake(7, 96, 303, 33)];
        self.detailLable.backgroundColor = [UIColor whiteColor];
        self.detailLable.textAlignment = NSTextAlignmentCenter;
        self.detailLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.detailLable.text = @"已经处理";
        self.detailLable.font =[ UIFont systemFontOfSize:12];
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.detailLable.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(5, 5)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.detailLable.bounds;
        maskLayer.path = maskPath.CGPath;
        self.detailLable.hidden=YES;
        self.detailLable.layer.mask = maskLayer;
        [self.contentView addSubview:self.detailLable];
    }
    return self;
}

- (void)agreeButtonAction:(UIButton *)button
{
    if (self.delegate) {
        [self.delegate onAgreeClick:self];
    }
}

- (void)refuseButtonAction:(UIButton *)button
{
    if (self.delegate) {
        [self.delegate onDisAgreeClick:self];
    }
}

-(void)headOnClick:(UIButton*)sender
{
    if (self.delegate) {
        [self.delegate headImgClick:self];
    }
}

//设置群信息
-(void)setTime:(NSString*)msgTime
{
    self.timeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:msgTime]];
    [self refreTimeLable];
}

//刷新时间控件
-(void)refreTimeLable
{
    CGSize nameSize = [self.timeLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.timeLable.frame=CGRectMake(300-nameSize.width-5, 12, nameSize.width, 20);
}

//格式化时间
-(NSString*)getMsgTime:(NSString*)senderTime
{
    NSString *time = [senderTime substringToIndex:10];
    NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
    NSString* strNowTime = [NSString stringWithFormat:@"%d",(int)nowTime];
    NSString* strTime = [NSString stringWithFormat:@"%d",[time intValue]];
    return [GameCommon getTimeWithChatStyle:strNowTime AndMessageTime:strTime];
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
