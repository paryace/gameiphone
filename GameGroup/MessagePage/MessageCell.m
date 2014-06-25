//
//  MessageCell.m
//  NewXMPPTest
//
//  Created by Tolecen on 13-6-26.
//  Copyright (c) 2013年 Tolecen. All rights reserved.
//

#import "MessageCell.h"

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.headImageV = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 12.5, 45, 45)];
        self.headImageV.backgroundColor = [UIColor clearColor];
        self.headImageV.layer.cornerRadius = 5;
        self.headImageV.layer.masksToBounds=YES;
        [self.contentView addSubview:self.headImageV];
        self.notiBgV = [[UIImageView alloc] initWithFrame:CGRectMake(42, 8, 18, 18)];
        [self.notiBgV setImage:[UIImage imageNamed:@"redCB.png"]];
        self.notiBgV.tag=999;
        [self.contentView addSubview:self.notiBgV];

        self.unreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        [self.unreadCountLabel setBackgroundColor:[UIColor clearColor]];
        [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.unreadCountLabel setTextColor:[UIColor whiteColor]];
        self.unreadCountLabel.font = [UIFont systemFontOfSize:12.0];
        [self.notiBgV addSubview:self.unreadCountLabel];
        [self.notiBgV setHidden:YES];
        
        self.unreadCountLabel.hidden = YES;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 170, 20)];
        [self.nameLabel setTextAlignment:NSTextAlignmentLeft];
        self.nameLabel.backgroundColor = [UIColor clearColor];
        [self.nameLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        [self.contentView addSubview:self.nameLabel];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 28, 230, 40)];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.contentLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentLabel setFont:[UIFont systemFontOfSize:14]];
        [self.contentLabel setTextColor:[UIColor grayColor]];
        self.contentLabel.numberOfLines = 2;
        [self.contentView addSubview:self.contentLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 8, 100, 20)];
        [self.timeLabel setTextAlignment:NSTextAlignmentRight];
        [self.timeLabel setTextColor:[UIColor grayColor]];
        self.timeLabel.backgroundColor = [UIColor clearColor];
        [self.timeLabel setFont:[UIFont systemFontOfSize:13]];
        [self.timeLabel setAdjustsFontSizeToFitWidth:YES];
        [self.contentView addSubview:self.timeLabel];
        
        
        self.settingState = [[UIImageView alloc] initWithFrame:CGRectMake(290, 37, 17, 17)];
        self.settingState.backgroundColor = [UIColor clearColor];
        self.settingState.image=KUIImage(@"nor_soundSong");
        [self.contentView addSubview:self.settingState];
        
    }
    return self;
}

-(void)setNotReadMsgCount:(DSThumbMsgs*)message
{
    if ([[message msgType]isEqualToString:@"groupchat"]) {
        NSString * groupId = [NSString stringWithFormat:@"%@",[message groupId]];
        if ([[GameCommon getMsgSettingStateByGroupId:groupId] isEqualToString:@"1"]) {//关闭模式
            self.settingState.hidden=NO;
            self.settingState.image=KUIImage(@"close_receive");
            self.unreadCountLabel.hidden = YES;
            self.notiBgV.hidden = YES;
            if([[message unRead]intValue]>0)
            {
                self.contentLabel.text = [NSString stringWithFormat:@"%@%d%@",@"有",[[message unRead]intValue] ,@"条新消息"];
            }
            
        }else{
            if ([[GameCommon getMsgSettingStateByGroupId:groupId] isEqualToString:@"2"]) {//无声模式
                self.settingState.hidden=NO;
                self.settingState.image=KUIImage(@"nor_soundSong");
            }else{
                self.settingState.hidden=YES;
                self.settingState.image=KUIImage(@"");
            }
            if ([[message unRead]intValue]>0) {
                self.unreadCountLabel.hidden = NO;
                self.notiBgV.hidden = NO;
                [self.unreadCountLabel setText:[message unRead]];
                if ([[message unRead] intValue]>99) {
                    [self.unreadCountLabel setText:@"99+"];
                    self.notiBgV.image = KUIImage(@"redCB_big");
                    self.notiBgV.frame=CGRectMake(40, 8, 22, 18);
                    self.unreadCountLabel.frame =CGRectMake(0, 0, 22, 18);
                }
                else{
                    self.notiBgV.image = KUIImage(@"redCB.png");
                    [self.unreadCountLabel setText:[message unRead]];
                    self.notiBgV.frame=CGRectMake(42, 8, 18, 18);
                    self.unreadCountLabel.frame =CGRectMake(0, 0, 18, 18);
                }
            }
            else
            {
                self.unreadCountLabel.hidden = YES;
                self.notiBgV.hidden = YES;
            }
        }
        
    }else{
        //设置红点 start
        self.settingState.hidden=YES;
        if ([[message unRead]intValue]>0) {
            self.unreadCountLabel.hidden = NO;
            self.notiBgV.hidden = NO;
            if ([[message msgType] isEqualToString:@"recommendfriend"] |
                [[message msgType] isEqualToString:@"sayHello"] ||
                [[message msgType] isEqualToString:@"deletePerson"]) {
                self.notiBgV.image = KUIImage(@"redpot");
                self.unreadCountLabel.hidden = YES;
            }
            else
            {
                [self.unreadCountLabel setText:[message unRead]];
                if ([[message unRead] intValue]>99) {
                    [self.unreadCountLabel setText:@"99+"];
                    self.notiBgV.image = KUIImage(@"redCB_big");
                    self.notiBgV.frame=CGRectMake(40, 8, 22, 18);
                    self.unreadCountLabel.frame =CGRectMake(0, 0, 22, 18);
                }
                else{
                    self.notiBgV.image = KUIImage(@"redCB.png");
                    [self.unreadCountLabel setText:[message unRead]];
                    self.notiBgV.frame=CGRectMake(42, 8, 18, 18);
                    self.unreadCountLabel.frame =CGRectMake(0, 0, 18, 18);
                }
            }
        }
        else
        {
            self.unreadCountLabel.hidden = YES;
            self.notiBgV.hidden = YES;
        }
    }
}
@end
