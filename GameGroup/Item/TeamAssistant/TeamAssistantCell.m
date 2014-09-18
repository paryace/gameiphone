//
//  TeamAssistantCell.m
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "TeamAssistantCell.h"

@implementation TeamAssistantCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.headImg =[[ EGOImageButton alloc]initWithFrame:CGRectMake(10, 10, 60, 60)];
        [self addSubview:self.headImg];
        self.headImg.layer.cornerRadius = 5;
        self.headImg.layer.masksToBounds=YES;
        [self.headImg addTarget:self action:@selector(headImageOnCLick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.titleLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(80, 10, 320-80-30, 40) font:[UIFont systemFontOfSize:14] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        self.titleLabel.numberOfLines = 2;
        [self addSubview:self.titleLabel];
        
        self.gameIconImg = [[EGOImageView alloc]initWithFrame:CGRectMake(80, 53, 15, 15)];
        [self addSubview:self.gameIconImg];
        
        self.contentLabel = [GameCommon buildLabelinitWithFrame:CGRectMake(100, 50, 320-100-90, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentLeft];
        [self addSubview:self.contentLabel];
        
        self.timeLabel =[GameCommon buildLabelinitWithFrame:CGRectMake(320-90-5, 50, 90, 20) font:[UIFont systemFontOfSize:12] textColor:[UIColor grayColor] backgroundColor:[UIColor clearColor] textAlignment:NSTextAlignmentRight];
        [self addSubview:self.timeLabel];
        
        self.MemberImage = [[UIImageView alloc]initWithFrame:CGRectMake(320-30, 0, 30, 30)];
        [self addSubview:self.MemberImage];
    }
    return self;
}
-(void)refreText:(NSString*)timeStr{
    CGSize sizeThatFits = [self.titleLabel.text sizeWithFont:self.titleLabel.font constrainedToSize:CGSizeMake(320-80-30, MAXFLOAT) lineBreakMode:NSLineBreakByCharWrapping];
    float hight = sizeThatFits.height>40?40:sizeThatFits.height;
    self.titleLabel.frame = CGRectMake(80, 10, 320-80-32, hight);
    self.gameIconImg.frame = CGRectMake(80, 10+hight+8, 15, 15);
    CGSize size = [timeStr sizeWithFont:[UIFont boldSystemFontOfSize:16] constrainedToSize:CGSizeMake(MAXFLOAT, 15) lineBreakMode:NSLineBreakByCharWrapping];
    self.timeLabel.frame = CGRectMake(320-size.width-5, 10+hight+5, size.width, 20);
    self.contentLabel.frame = CGRectMake(100, 10+hight+5, 320-100-size.width - 5, 20);
    
}
-(void)headImageOnCLick:(id)sender
{
    NSLog(@"enter to other page");
}

@end
