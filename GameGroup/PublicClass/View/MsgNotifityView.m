//
//  MsgNotifityView.m
//  GameGroup
//
//  Created by Apple on 14-7-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "MsgNotifityView.h"

@implementation MsgNotifityView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.notiBgV = [[UIImageView alloc] initWithFrame:CGRectMake(40, 0, 18, 18)];
        [self.notiBgV setImage:[UIImage imageNamed:@"redCB.png"]];
        self.notiBgV.tag=999;
        [self.notiBgV setHidden:YES];
        [self addSubview:self.notiBgV];
        
        self.unreadCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        [self.unreadCountLabel setBackgroundColor:[UIColor clearColor]];
        [self.unreadCountLabel setTextAlignment:NSTextAlignmentCenter];
        [self.unreadCountLabel setTextColor:[UIColor whiteColor]];
        self.unreadCountLabel.font = [UIFont systemFontOfSize:12.0];
        [self.notiBgV addSubview:self.unreadCountLabel];
    }
    return self;
}

-(void)setMsgCount:(NSInteger)msgCount{
    if (msgCount>0) {
        [self show];
        if (msgCount>99) {
            self.notiBgV.image = KUIImage(@"redCB_big");
            [self.unreadCountLabel setText:@"99+"];
            self.notiBgV.frame=CGRectMake(0, 0, 22, 18);
            self.unreadCountLabel.frame =CGRectMake(0, 0, 22, 18);
        }
        else{
            self.notiBgV.image = KUIImage(@"redCB.png");
            [self.unreadCountLabel setText:[NSString stringWithFormat:@"%d",msgCount]];
            self.notiBgV.frame=CGRectMake(0, 0, 18, 18);
            self.unreadCountLabel.frame =CGRectMake(0, 0, 18, 18);
        }
    }else{
        [self hide];
    }
}

-(void)simpleDot{
    self.notiBgV.image = KUIImage(@"redpot");
    self.unreadCountLabel.hidden = YES;
}

-(void)hide{
    self.unreadCountLabel.hidden = YES;
    self.notiBgV.hidden = YES;
}

-(void)show{
    self.unreadCountLabel.hidden = NO;
    self.notiBgV.hidden = NO;

}

@end
