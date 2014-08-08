//
//  KKChatCell.m
//  GameGroup
//
//  Created by admin on 14-4-27.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKChatCell.h"

@implementation KKChatCell
{
    CGPoint mPoint;
}

@synthesize message;
@synthesize headImgV;
@synthesize senderAndTimeLabel;
@synthesize bgImageView;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryNone;  //cell的为无样式
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
        //中央文字Label - 用来显示聊天时间
        self.senderAndTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 300, 20)];
        self.senderAndTimeLabel.backgroundColor = [UIColor clearColor];
        self.senderAndTimeLabel.textAlignment = NSTextAlignmentCenter;
        self.senderAndTimeLabel.font = [UIFont systemFontOfSize:11.0];
        self.senderAndTimeLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.senderAndTimeLabel];
        
        //中央文字Label - 用来显示聊天时间[self.headImgV setFrame:CGRectMake(10, padding*2-15, 40, 40)];
        self.senderNickName = [[UILabel alloc] initWithFrame:CGRectMake(10+40+10, padding*2-16, 100, 20)];
        self.senderNickName.backgroundColor = [UIColor clearColor];
        self.senderNickName.font = [UIFont systemFontOfSize:11.0];
        self.senderNickName.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:self.senderNickName];
        
        self.bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgImageView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.contentView addSubview:self.bgImageView];
        [self.bgImageView  addTarget:self action:@selector(onClick:) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer* longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongClick:)];
        [self.bgImageView addGestureRecognizer:longPress];
        
        //头像
        self.headImgV = [[EGOImageButton alloc] initWithFrame:CGRectZero];
        self.headImgV.layer.cornerRadius = 5;
        self.headImgV.layer.masksToBounds=YES;
        self.headImgV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
        [self.contentView addSubview:self.headImgV];
        
        //重连
        self.failImage = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.failImage setBackgroundImage:KUIImage(@"fail_bg") forState:UIControlStateNormal];
        self.failImage.hidden = YES;
        [self.contentView addSubview:self.failImage];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.statusLabel setTextColor:kColorWithRGB(151, 151, 151, 1.0)];
        self.statusLabel.backgroundColor=[UIColor clearColor];
        [self.statusLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        self.statusLabel.hidden = YES;
        [self.contentView addSubview:self.statusLabel];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:self.activityView];
        
        self.levelLable= [[UILabel alloc] initWithFrame:CGRectMake(0, 2.5, 30, 19)];
        [self.levelLable setTextAlignment:NSTextAlignmentCenter];
        self.levelLable.backgroundColor = [UIColor blueColor];
        self.levelLable.layer.cornerRadius = 3;
        self.levelLable.layer.masksToBounds=YES;
        self.levelLable.textColor = [UIColor whiteColor];
        [self.levelLable setFont:[UIFont boldSystemFontOfSize:10.0]];
        [self.contentView addSubview:self.levelLable];
    }
    return self;
}

-(id)initWithMessage:(NSMutableDictionary *)msg reuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}
-(void)setMessageDictionary:(NSMutableDictionary*)msg
{
    self.message = msg;
}
//设置时间
-(void)setMsgTime:(NSString*)timeStr lastTime:(NSString*)lasttime previousTime:(NSString*)previoustime
{
    if ([lasttime intValue]-[[previoustime substringToIndex:10]intValue]<300) {
        self.senderAndTimeLabel.hidden = YES;
    }
    else{
        self.senderAndTimeLabel.hidden = NO;
        self.senderAndTimeLabel.text = [NSString stringWithFormat:@"%@", timeStr];
    }
}

//Cell点击
-(void)onClick:(UIButton*)sender
{
    if (self.myChatCellDelegate) {
        [self.myChatCellDelegate onCellBgClick:sender];
    }
}
//Cell长按
-(void)onLongClick:(UITapGestureRecognizer*)sender
{
    if (self.myChatCellDelegate) {
        [self.myChatCellDelegate onCellBgLongClick:sender];
    }
}

-(void)setViewPoint:(CGPoint)point
{
    mPoint = point;
    self.failImage.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
    self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
    self.activityView.center = point;
}

-(void)setViewState:(NSString*)status
{
    if ([status isEqualToString:@"0"]) {//失败
        self.failImage.hidden = NO;
        self.statusLabel.hidden = YES;
        [self.activityView stopAnimating];
    }
    else if([status isEqualToString:@"2"])//发送中
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = YES;
        [self.activityView startAnimating];
    }
    else if ([status isEqualToString:@"3"])//送达
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = NO;
        [self.activityView stopAnimating];
        self.statusLabel.text = @"送达";
    }
    else if ([status isEqualToString:@"4"])//已读
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = NO;
        [self.activityView stopAnimating];
        self.statusLabel.text = @"已读";
    }
    else if ([status isEqualToString:@"1"])//已发送，对方未收到
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = YES; //这种情况不显示状态
        [self.activityView stopAnimating];
    }
    else
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = YES;
        [self.activityView stopAnimating];
    }
}

#pragma mark
- (void)refreshStatusPoint:(CGPoint)point status:(NSString*)status
{
    [self setViewPoint:point];
    [self setViewState:status];
    
}


#pragma mark 头像 - Headimg
//设置自己头像
- (void)setHeadImgByMe:(NSString*) myHeadImg;
{
    [self.headImgV setFrame:CGRectMake(320-10-40,padding*2-15,40,40)];
    
    [self.levelLable setFrame:CGRectMake(320-10-40+7.5, padding*2-15+40+3, 25, 12)];
    
    if ([GameCommon isEmtity:myHeadImg]) {
        self.headImgV.imageURL = nil;
    }else{
        headImgV.imageURL = [ImageService getImageUrl3:myHeadImg Width:80];
    }
    [self.headImgV removeTarget:self action:@selector(chatUserHeadImgClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.headImgV  addTarget:self action:@selector(myHeadImgClicked:)forControlEvents:UIControlEventTouchUpInside];
}
//设置对方头像
- (void)setHeadImgByChatUser:(NSString*) chatUserImg;
{
    //头像居左
    [self.headImgV setFrame:CGRectMake(10, padding*2-15, 40, 40)];
    [self.levelLable setFrame:CGRectMake(17.5, padding*2-15+40+3, 25, 12)];
    //头像设置为对方的
    self.headImgV.imageURL=[ImageService getImageStr:chatUserImg Width:80];
    //点击事件
    [self.headImgV removeTarget:self action:@selector(myHeadImgClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.headImgV addTarget:self action:@selector(chatUserHeadImgClicked:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)setMePosition:(BOOL)isTeam TeanPosition:(NSString*)teamPosition
{
    if (isTeam) {
        self.levelLable.hidden=NO;
        
        if (![GameCommon isEmtity:teamPosition]) {
            self.levelLable.text = teamPosition;
        }else{
            self.levelLable.text = @"未选";
        }
    }else{
        self.levelLable.hidden=YES;
    }
    
}
-(void)setUserPosition:(BOOL)isTeam TeanPosition:(NSString*)teamPosition
{
    if (isTeam) {
        self.levelLable.hidden=NO;
        if (![GameCommon isEmtity:teamPosition]) {
            self.levelLable.text = teamPosition;
        }else{
            self.levelLable.text = @"未选";
        }
    }else{
        self.levelLable.hidden=YES
        ;
    }
    
}

//点击我的头像
-(void)myHeadImgClicked:(id)Sender
{
    [self.myChatCellDelegate myHeadImgClicked:self];
}
//点击对方的头像
-(void)chatUserHeadImgClicked:(id)Sender
{
    [self.myChatCellDelegate chatUserHeadImgClicked:self];
}

@end