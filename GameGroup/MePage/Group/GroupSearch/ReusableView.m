//
//  ReusableView.m
//  GameGroup
//
//  Created by 魏星 on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ReusableView.h"

@implementation ReusableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:232/255.0f green:232/255.0f blue:232/255.0f alpha:1];
        self.topBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 70)];
        self.topBtn.backgroundColor= [UIColor whiteColor];
        [self addSubview:self.topBtn];
        self.headImageView = [[EGOImageView alloc]initWithFrame:CGRectMake(5, 10, 50, 50)];
        self.headImageView.layer.cornerRadius = 5;
        self.headImageView.layer.masksToBounds=YES;

        self.headImageView.placeholderImage = KUIImage(@"group_icon");
        [self.topBtn addSubview:self.headImageView];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(65, 10, 320-90, 20)];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.textAlignment = NSTextAlignmentLeft;
        self.label.font = [UIFont boldSystemFontOfSize:14.0f];
        self.label.textColor = [UIColor grayColor];
        [self.topBtn addSubview:self.label];
        
        self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 28, 220, 40)];
        self.contentLabel.backgroundColor = [UIColor clearColor];
        [self.contentLabel setTextAlignment:NSTextAlignmentLeft];
        [self.contentLabel setFont:[UIFont systemFontOfSize:12]];
        [self.contentLabel setTextColor:[UIColor grayColor]];
        self.contentLabel.numberOfLines = 2;
        [self.topBtn addSubview:self.contentLabel];

        
        
        self.timeLabel =  [[UILabel alloc] initWithFrame:CGRectMake(205, 10, 100, 15)];
        self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth |
        UIViewAutoresizingFlexibleHeight;
        self.timeLabel.backgroundColor = [UIColor clearColor];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.font = [UIFont boldSystemFontOfSize:11.0f];
        self.timeLabel.textColor = [UIColor grayColor];
        [self.topBtn addSubview:self.timeLabel];
        
        UIImageView * lineImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 71, 320, 1)];
        lineImage.image = KUIImage(@"my_group_line");
        [self.topBtn addSubview:lineImage];
        
        
        self.roghtImage = [[UIImageView alloc] initWithFrame:CGRectMake(320-10-8, (70-12)/2, 8, 12)];
        self.roghtImage.image = KUIImage(@"right");
        self.roghtImage.hidden = YES;
        [self.topBtn addSubview:self.roghtImage];
        
        
        self.gbMsgCountImageView = [[UIImageView alloc] initWithFrame:CGRectMake(48, 6, 18, 18)];
        [self.gbMsgCountImageView setImage:[UIImage imageNamed:@"redCB.png"]];
        self.gbMsgCountImageView.hidden = YES;
        [self.topBtn addSubview:self.gbMsgCountImageView];
        
        
        self.gbMsgCountLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        [self.gbMsgCountLable setBackgroundColor:[UIColor clearColor]];
        [self.gbMsgCountLable setTextAlignment:NSTextAlignmentCenter];
        [self.gbMsgCountLable setTextColor:[UIColor whiteColor]];
        self.gbMsgCountLable.font = [UIFont systemFontOfSize:14.0];
        self.gbMsgCountLable.text = @"20";
        [self.gbMsgCountImageView addSubview:self.gbMsgCountLable];
        
        
        [self addSubview:self.topBtn];
        
    }
    return self;
}

-(void)setInfo:(NSDictionary*)dict setMsgCount:(NSInteger)msgCount
{
    self.label.text = @"组织公告";
    if (dict) {
        self.topBtn.backgroundColor = [UIColor whiteColor];
        self.topBtn.tag=123;
        self.roghtImage.hidden=NO;
        NSString * groupName = KISDictionaryHaveKey(dict, @"groupName");
        NSString * billboard = KISDictionaryHaveKey(dict, @"billboard");
        NSString * createDate = KISDictionaryHaveKey(dict, @"createDate");
        NSString * backgroundImg = KISDictionaryHaveKey(dict, @"backgroundImg");
        self.contentLabel.text = [NSString stringWithFormat:@"%@%@%@",groupName,@":",billboard];
        self.timeLabel.text = [GameCommon getTimeWithMessageTime:createDate];
        if ([GameCommon isEmtity:backgroundImg]) {
            self.headImageView.imageURL = nil;
        }else{
            self.headImageView.imageURL = [ImageService getImageUrl3:backgroundImg Width:120];
        }
        [self.topBtn addTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setMsgCount:msgCount];
    }else{
        self.roghtImage.hidden=YES;
        self.contentLabel.text = @"还没有组织公告哦!";
        self.timeLabel.text = @"";
        self.headImageView.image = KUIImage(@"group_billboard");
        [self.topBtn removeTarget:self action:@selector(topBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    CGSize textSize = [self.timeLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:14] constrainedToSize:CGSizeMake(100, 20) lineBreakMode:NSLineBreakByWordWrapping];
    self.timeLabel.frame=CGRectMake(320 - textSize.width-20, 10, textSize.width, 15);
}
-(void)topBtnClick:(UIButton*)sender
{
    if (self.delegate) {
        [self.delegate onClick:sender];
    }
}
-(void)setMsgCount:(NSInteger)msgCount
{
    if (msgCount>0) {
        self.gbMsgCountImageView.hidden = NO;
        if (msgCount > 99) {
           self.gbMsgCountLable.text = @"99+";
        }
        else{
            self.gbMsgCountLable.text =[NSString stringWithFormat:@"%d",msgCount] ;
        }
    }else
    {
        self.gbMsgCountImageView.hidden = YES;
    }
}

@end
