//
//  KKChatCell.m
//  GameGroup
//
//  Created by admin on 14-4-27.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "KKChatCell.h"

@implementation KKChatCell

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
        
        //重连
        self.failImage = [[UIButton alloc]initWithFrame:CGRectZero];
        [self.failImage setBackgroundImage:KUIImage(@"fail_bg") forState:UIControlStateNormal];
        [self.contentView addSubview:self.failImage];

        [self.contentView addSubview:self.headImgV];
    }
    return self;
}

-(id)initWithMessage:(NSMutableDictionary *)msg
   reuseIdentifier:(NSString *)reuseIdentifier
{
    self.message = msg;
    return [self initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
}

#pragma mark 重连标识 FailImg
- (void)refreshStatusPoint:(CGPoint)point status:(NSString*)status
{
    if ([status isEqualToString:@"0"]) {//失败
        self.failImage.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.failImage.hidden = NO;
        self.statusLabel.hidden = YES;
        
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        [self.activityView stopAnimating];
    }
    else if([status isEqualToString:@"2"])//发送中
    {
        self.failImage.hidden = YES;
        self.statusLabel.hidden = YES;
        
        if (![self.cellTimer isValid]) {
            self.cellTimer = [NSTimer scheduledTimerWithTimeInterval:mSendTime target:self selector:@selector(stopActivity) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:self.cellTimer forMode:NSRunLoopCommonModes];
            
            self.activityView.center = point;
            [self.activityView startAnimating];
        }
    }
    else if ([status isEqualToString:@"3"])//送达
    {
        self.failImage.hidden = YES;
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        [self.activityView stopAnimating];
        
        self.statusLabel.hidden = NO;
        self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.statusLabel.text = @"送达";
    }
    else if ([status isEqualToString:@"4"])//已读
    {
        self.failImage.hidden = YES;
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        [self.activityView stopAnimating];
        
        self.statusLabel.hidden = NO;
        self.statusLabel.frame = CGRectMake(point.x-12, point.y-12, 24, 24);
        self.statusLabel.text = @"已读";
    }
    else
    {
        self.statusLabel.hidden = YES;
        self.failImage.hidden = YES;
        if ([self.cellTimer isValid]) {
            [self.cellTimer invalidate];
            self.cellTimer = nil;
        }
        [self.activityView stopAnimating];
    }
}


- (void)stopActivity
{
    if ([self.cellTimer isValid]) {
        [self.cellTimer invalidate];
        self.cellTimer = nil;
    }
    [self.activityView stopAnimating];
    
    NSString* uuid = KISDictionaryHaveKey(self.message, @"messageuuid");
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:uuid,@"src_id",@"0", @"received",nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kMessageAck object:nil userInfo:dic];
}


#pragma mark 头像 - Headimg

- (void)setHeadImgByMe
{
    [self.headImgV setFrame:CGRectMake(320-10-40,
                                       padding*2-15,
                                       40,
                                       40)];
    
    NSString* myHeadImg = [DataStoreManager queryFirstHeadImageForUser_userManager:[[NSUserDefaults standardUserDefaults]
                                                                                    objectForKey:kMYUSERID]];
    if ([myHeadImg isEqualToString:@""]||[myHeadImg isEqualToString:@" "]) {
        self.headImgV.imageURL = nil;
    }else{
        if (myHeadImg) {
            NSURL * theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80", myHeadImg]];
            self.headImgV.imageURL = theUrl;
        }else
        {
            self.headImgV.imageURL = nil;
        }
    }
    

    [self.headImgV  addTarget:self
                       action:@selector(myHeadImgClicked:)
             forControlEvents:UIControlEventTouchUpInside];
}

- (void)setHeadImgByChatUser:(NSString*) chatUserImg;
{
    //头像居左
    [self.headImgV setFrame:CGRectMake(10, padding*2-15, 40, 40)];
    
    //头像设置为对方的
    if ([chatUserImg isEqualToString:@""]||[chatUserImg isEqualToString:@" "]) {
        self.headImgV.imageURL = nil;
    }else{
        if (chatUserImg) {
            NSURL * theUrl = [NSURL URLWithString:[BaseImageUrl stringByAppendingFormat:@"%@/80",[GameCommon getHeardImgId:chatUserImg]]];
            self.headImgV.imageURL = theUrl;
        }else
        {
            self.headImgV.imageURL = nil;
        }
    }

    //点击事件
    [self.headImgV addTarget:self
                      action:@selector(chatUserHeadImgClicked:)
                forControlEvents:UIControlEventTouchUpInside];
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