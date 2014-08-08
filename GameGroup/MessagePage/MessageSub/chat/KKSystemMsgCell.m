//
//  KKSystemMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKSystemMsgCell.h"

@implementation KKSystemMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lineImage1 = [[UIImageView alloc]initWithFrame:CGRectMake(5, 10, 90, 1)];
        self.lineImage1.image = KUIImage(@"chat_line_left");
        [self addSubview:self.lineImage1];
        
        self.lineImage2 = [[UIImageView alloc]initWithFrame:CGRectMake(225, 10, 90, 1)];
        self.lineImage2.image = KUIImage(@"chat_line_right");
        [self addSubview:self.lineImage2];
        
        self.timeLable = [[UILabel alloc]initWithFrame:CGRectMake(100, 2, 120, 20)];
        self.timeLable.backgroundColor = [UIColor clearColor];
        self.timeLable.textColor = [UIColor grayColor];
        self.timeLable.text = @"06-13 12:34";
        self.timeLable.font =[ UIFont systemFontOfSize:10];
        self.timeLable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.timeLable];
        
        self.msgLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 22, 320, 20)];
        self.msgLable.backgroundColor = kColorWithRGB(100,100,100, 0.5);
        self.msgLable.textColor = [UIColor whiteColor];
        self.msgLable.text = @"克莱尔加入了本群";
        self.msgLable.font =[ UIFont systemFontOfSize:10];
        self.msgLable.textAlignment = NSTextAlignmentCenter;
        self.msgLable.layer.masksToBounds = YES;
        self.msgLable.layer.cornerRadius = 3;
        self.msgLable.numberOfLines = 0;
        [self addSubview:self.msgLable];
    }
    return self;
}

//设置时间
-(void)setMsgTime:(NSString*)timeStr lastTime:(NSString*)lasttime previousTime:(NSString*)previoustime
{
    if ([lasttime intValue]-[[previoustime substringToIndex:10]intValue]<300) {
        self.timeLable.hidden = YES;
        self.lineImage1.hidden=YES;
        self.lineImage2.hidden=YES;
    }
    else{
        self.timeLable.hidden = NO;
        self.lineImage1.hidden=YES;
        self.lineImage2.hidden=YES;
        self.timeLable.text = [NSString stringWithFormat:@"%@", timeStr];
    }
}

@end
