//
//  SoundSetCell.m
//  GameGroup
//
//  Created by Apple on 14-6-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "SoundSetCell.h"

@implementation SoundSetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, self.frame.size.height)];
        self.titleLable.backgroundColor = [UIColor clearColor];
        self.titleLable.textColor = [UIColor blackColor];
        self.titleLable.font = [UIFont systemFontOfSize:15.0];
        [self.contentView addSubview:self.titleLable];
        
        
        self.soundimageView=[[UIImageView alloc] initWithFrame:CGRectMake(250-25-10, 12.5, 25, 20)];
        self.soundimageView.image = KUIImage(@"nor_soundSong");
        self.soundimageView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.soundimageView];
        
        self.msgHintLable = [[UILabel alloc]initWithFrame:CGRectMake(320-25-8-50, 12.5, 40, 20)];
        self.msgHintLable.backgroundColor = [UIColor clearColor];
        self.msgHintLable.textColor = kColorWithRGB(100,100,100, 0.7);
        self.msgHintLable.text = @"无声";
        self.msgHintLable.font =[ UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.msgHintLable];
    }
    return self;
}

@end
