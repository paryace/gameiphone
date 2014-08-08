//
//  NewFirstCell.m
//  GameGroup
//
//  Created by 魏星 on 14-7-28.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "NewFirstCell.h"

@implementation NewFirstCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];

        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45)];
        self.headImageV.backgroundColor = [UIColor whiteColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.bgView addSubview:self.headImageV];
        
        self.cardLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(70, 10, 90, 20) font:[UIFont boldSystemFontOfSize:16] textColor:[UIColor blueColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self.bgView addSubview:self.cardLabel];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(170, 10, 90, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        [self.nameLabel setFont:[UIFont boldSystemFontOfSize:14.0]];
        [self.nameLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.nameLabel];
        
        
//        self.sexImg = [[UIImageView alloc] initWithFrame:CGRectMake(170, 5, 20, 20)];
//        self.sexImg.backgroundColor = [UIColor clearColor];
//        [self.bgView addSubview:self.sexImg];
        self.timeLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(100, 3, 200, 10) font:[UIFont systemFontOfSize:10] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
        [self.bgView addSubview:self.timeLabel];
        
        
        self.distLabel = [[UILabel alloc] initWithFrame:CGRectMake(70, 35, 240, 20)];
        [self.distLabel setTextColor:[UIColor grayColor]];
        [self.distLabel setFont:[UIFont systemFontOfSize:13]];
        [self.distLabel setBackgroundColor:[UIColor clearColor]];
        [self.bgView addSubview:self.distLabel];
        [self.contentView addSubview:self.bgView];
        
        self.stopImg = [[UIImageView alloc]initWithFrame:CGRectMake(290, 35, 20, 20)];
        self.stopImg.image = KUIImage(@"palceholder");
        [self.bgView addSubview:self.stopImg];
        //消息数字红点(暂时不上，隐藏)
        self.dotV = [[MsgNotifityView alloc] initWithFrame:CGRectMake(45, 5, 22, 18)];
//        [self.contentView addSubview:self.dotV];
        
    }
    return self;
}


//设置群信息
-(void)setTime:(NSString*)msgTime
{
    self.timeLabel.text = [NSString stringWithFormat:@"%@", [self getMsgTime:msgTime]];
    [self refreTimeLable];
}

//刷新时间控件
-(void)refreTimeLable
{
    CGSize nameSize = [self.timeLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.timeLabel.frame=CGRectMake(310-nameSize.width-5, 10, nameSize.width, 20);
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
