//
//  BaseGroupMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseGroupMsgCell.h"

@implementation BaseGroupMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bgV = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 310, 139)];
        self.bgV.image = KUIImage(@"group_cell_bg");
        self.bgV.userInteractionEnabled =YES;
        
        self.groupImageV = [[EGOImageView alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
        [self.bgV addSubview:self.groupImageV];
        
        
        self.imageClickBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 310, 40)];
        [self.imageClickBtn addTarget:self action:@selector(groupButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.bgV addSubview:self.imageClickBtn];
        
        self.groupNameLable = [[UILabel alloc]initWithFrame:CGRectMake(45, 12, 100, 20)];
        self.groupNameLable.backgroundColor = [UIColor clearColor];
        self.groupNameLable.textColor = kColorWithRGB(5,5,5, 0.7);
        self.groupNameLable.text = @"群名";
        self.groupNameLable.font =[ UIFont systemFontOfSize:12];
        [self.imageClickBtn addSubview:self.groupNameLable];
        
        self.groupCreateTimeLable = [[UILabel alloc]initWithFrame:CGRectMake(300-50-5, 12, 50, 20)];
        self.groupCreateTimeLable.backgroundColor = [UIColor clearColor];
        self.groupCreateTimeLable.textColor = [UIColor grayColor];
        self.groupCreateTimeLable.text = @"昨天20:09";
        self.groupCreateTimeLable.font =[ UIFont systemFontOfSize:12];
        [self.imageClickBtn addSubview:self.groupCreateTimeLable];
        
        UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(10, 43, 320-30, 1)];
        lineView1.backgroundColor = kColorWithRGB(200,200,200, 0.7);
        [self.bgV addSubview:lineView1];

    }
    return self;
}
-(void)groupButtonClick:(id)sender
{
    if (self.groupImageDeleGate) {
        [self.groupImageDeleGate groupImageClick:self];
    }
}

//刷新时间控件
-(void)refreTimeLable
{
    CGSize nameSize = [self.groupCreateTimeLable.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(300, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.groupCreateTimeLable.frame=CGRectMake(300-nameSize.width-5, 12, nameSize.width, 20);
}
//设置群信息
-(void)setGroupMsg:(NSString*)groupImage GroupName:(NSString*)groupName MsgTime:(NSString*)msgTime
{
    self.groupImageV.placeholderImage = KUIImage(@"placeholder.png");
    self.groupImageV.imageURL = [ImageService getImageStr:groupImage Width:160];
    self.groupCreateTimeLable.text = [NSString stringWithFormat:@"%@", [self getMsgTime:msgTime]];
    self.groupNameLable.text = groupName;
    [self refreTimeLable];
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
@end
