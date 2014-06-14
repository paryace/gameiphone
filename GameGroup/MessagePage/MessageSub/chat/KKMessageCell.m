//
//  KKMessageCell.m
//  XmppDemo
//
//  Created by 夏 华 on 12-7-16.
//  Copyright (c) 2012年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import "KKMessageCell.h"
#import "KKChatCell.h"

@implementation KKMessageCell

@synthesize senderAndTimeLabel; 
@synthesize messageContentView;
@synthesize bgImageView;    //聊天气泡



-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //聊天信息
        messageContentView = [[UILabel alloc] initWithFrame:CGRectZero];
        messageContentView.backgroundColor = [UIColor clearColor];
        messageContentView.font = [UIFont systemFontOfSize:16];
        messageContentView.numberOfLines = 0;
        [self.contentView addSubview:messageContentView];
    }
    
    return self;
}

@end
