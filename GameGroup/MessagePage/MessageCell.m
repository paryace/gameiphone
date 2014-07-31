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
        
        self.dotV = [[MsgNotifityView alloc] initWithFrame:CGRectMake(42, 8, 22, 18)];
        [self.contentView addSubview:self.dotV];
        
        
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


-(void)setMsgState:(NSMutableDictionary*)message{
    if ([KISDictionaryHaveKey(message,@"msgType")isEqualToString:@"groupchat"]) {
        NSString * groupId = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message,@"groupId")];
        if ([[GameCommon getMsgSettingStateByGroupId:groupId] isEqualToString:@"1"]) {//关闭模式
            self.settingState.hidden=NO;
            self.settingState.image=KUIImage(@"close_receive");
            if([KISDictionaryHaveKey(message,@"unRead")intValue]>0){
                self.contentLabel.text = [NSString stringWithFormat:@"%@%d%@",@"有",[KISDictionaryHaveKey(message,@"unRead") intValue] ,@"条新消息"];
            }
        }else{
            if ([[GameCommon getMsgSettingStateByGroupId:groupId] isEqualToString:@"2"]) {//无声模式
                self.settingState.hidden=NO;
                self.settingState.image=KUIImage(@"nor_soundSong");
            }else{
                self.settingState.hidden=YES;
                self.settingState.image=KUIImage(@"");
            }
        }
    }else{
        self.settingState.hidden=YES;
    }
}

//设置红点 start
-(void)setNotReadMsgCount:(NSMutableDictionary*)message
{
    if ([KISDictionaryHaveKey(message,@"msgType")isEqualToString:@"groupchat"]) {
        NSString * groupId = [NSString stringWithFormat:@"%@",KISDictionaryHaveKey(message,@"groupId")];
        if ([[GameCommon getMsgSettingStateByGroupId:groupId] isEqualToString:@"1"]) {//关闭模式
            [self.dotV hide];
        }else{
            NSInteger msgCount =  [KISDictionaryHaveKey(message,@"unRead") intValue];
            if ([MsgTypeManager payloadType:message]==1||[MsgTypeManager payloadType:message]==2) {
                if (msgCount==0) {
                    msgCount = [DataStoreManager getDSTeamNotificationMsgCount:groupId];
                }
            }
            [self.dotV setMsgCount:msgCount];
        }
    }else{
        if ([KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"recommendfriend"] |
            [KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"sayHello"] ||
            [KISDictionaryHaveKey(message,@"msgType") isEqualToString:@"deletePerson"]) {
            [self.dotV simpleDot];
        }else{
            [self.dotV setMsgCount:[KISDictionaryHaveKey(message,@"unRead") intValue]];
        }
    }
}

@end
