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
        // Initialization code
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
        
        self.bgImageView = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.bgImageView setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [self.contentView addSubview:self.bgImageView];
        
        //头像
        self.headImgV = [[EGOImageButton alloc] initWithFrame:CGRectZero];
        self.headImgV.layer.cornerRadius = 5;
        self.headImgV.layer.masksToBounds=YES;
        self.headImgV.placeholderImage = [UIImage imageNamed:@"moren_people.png"];
        [self.contentView addSubview:self.headImgV];
        
        //重连
        self.failImage = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.failImage setBackgroundImage:KUIImage(@"fail_bg") forState:UIControlStateNormal];
        [self.contentView addSubview:self.failImage];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.statusLabel setTextColor:kColorWithRGB(151, 151, 151, 1.0)];
        self.statusLabel.backgroundColor=[UIColor clearColor];
        [self.statusLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        self.statusLabel.hidden = YES;
        [self.contentView addSubview:self.statusLabel];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
       // self.activityView.hidesWhenStopped = YES;
        [self.contentView addSubview:self.activityView];
    }
    return self;
}

-(id)initWithMessage:(NSMutableDictionary *)msg
   reuseIdentifier:(NSString *)reuseIdentifier
{
//    self.message = msg;
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}
-(void)setMessageDictionary:(NSMutableDictionary*)msg
{
    self.message = msg;
}

#pragma mark 重连标识 FailImg
- (void)refreshStatusPoint:(CGPoint)point status:(NSString*)status
{
    mPoint = point;
    self.failImage.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
    self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
    if ([status isEqualToString:@"0"]) {//失败
//        self.failImage.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.failImage.hidden = NO;
        self.statusLabel.hidden = YES;
        [self.activityView stopAnimating];
        
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
    }
    else if([status isEqualToString:@"2"])//发送中
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = YES;
        self.activityView.center = point;
        [self.activityView startAnimating];
        if (![self.cellTimer isValid]) {
            self.cellTimer = [NSTimer scheduledTimerWithTimeInterval:mSendTime target:self selector:@selector(stopActivity) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.cellTimer forMode:NSRunLoopCommonModes];
//            self.activityView.center = point;
//            [self.activityView startAnimating];
        }
    }
    else if ([status isEqualToString:@"3"])//送达
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = NO;
        [self.activityView stopAnimating];
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
//        self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.statusLabel.text = @"送达";
    }
    else if ([status isEqualToString:@"4"])//已读
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = NO;
         [self.activityView stopAnimating];
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
//        self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.statusLabel.text = @"已读";
    }
    else if ([status isEqualToString:@"1"])//已发送，对方未收到
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = YES; //这种情况不显示状态
        [self.activityView stopAnimating];
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        
        self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.statusLabel.text = @"已发送";
    }
    else
    {
        self.statusLabel.hidden = YES;
        self.failImage.hidden = YES;
        [self.activityView stopAnimating];
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
    }
}

//菊花停止转动
- (void)stopActivity
{
    NSString* uuid = KISDictionaryHaveKey(self.message, @"messageuuid");
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"src_id",@"0", @"received",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:dic];
    //10秒后通知大家检查现在的status状态
}


#pragma mark 头像 - Headimg
//设置自己头像
- (void)setHeadImgByMe:(NSString*) myHeadImg;
{
    [self.headImgV setFrame:CGRectMake(320-10-40,padding*2-15,40,40)];
    
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
    //头像设置为对方的
    self.headImgV.imageURL=[ImageService getImageStr:chatUserImg Width:80];
    //点击事件
    [self.headImgV removeTarget:self action:@selector(myHeadImgClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.headImgV addTarget:self action:@selector(chatUserHeadImgClicked:) forControlEvents:UIControlEventTouchUpInside];

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