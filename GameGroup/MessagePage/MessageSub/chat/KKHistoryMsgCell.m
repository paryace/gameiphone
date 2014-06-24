//
//  KKHistoryMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-6-24.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKHistoryMsgCell.h"

@implementation KKHistoryMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 100, 1)];
        self.lineImage1.image = KUIImage(@"chat_line_left");
        [self addSubview:self.lineImage1];
        
        self.lineImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(215, 10, 100, 1)];
        self.lineImage2.image = KUIImage(@"chat_line_right");
        [self addSubview:self.lineImage2];

        
        self.msgLable = [[UILabel alloc]initWithFrame:CGRectMake(110, 2, 100, 20)];
        self.msgLable.backgroundColor = [UIColor clearColor];
        self.msgLable.textColor = [UIColor grayColor];
        self.msgLable.text = @"以上是历史记录";
        self.msgLable.font =[ UIFont systemFontOfSize:10];
        self.msgLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.msgLable];
    }
    return self;
}

@end
