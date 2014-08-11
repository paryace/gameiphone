//
//  KKSimpleMsgCell.m
//  GameGroup
//
//  Created by Apple on 14-8-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKSimpleMsgCell.h"

@implementation KKSimpleMsgCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //聊天信息
        self.messageContentView = [[UILabel alloc] initWithFrame:CGRectZero];
        self.messageContentView.backgroundColor = [UIColor clearColor];
        self.messageContentView.font = [UIFont systemFontOfSize:16];
        self.messageContentView.numberOfLines = 0;
        [self.contentView addSubview:self.messageContentView];
        
        self.iconImageV = [[UIImageView alloc] initWithFrame:CGRectMake(10, 12.5, 45, 45)];
        self.iconImageV.backgroundColor = [UIColor clearColor];
        self.iconImageV.layer.cornerRadius = 5;
        self.iconImageV.layer.masksToBounds=YES;
        [self.contentView addSubview:self.iconImageV];
    }
    return self;
}

@end
