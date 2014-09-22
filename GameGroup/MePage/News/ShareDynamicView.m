//
//  ShareDynamicView.m
//  GameGroup
//
//  Created by Apple on 14-9-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "ShareDynamicView.h"

@implementation ShareDynamicView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.m_shareViewBg = [[UIView alloc] initWithFrame:frame];
        self.m_shareViewBg.backgroundColor = [UIColor blackColor];
        self.m_shareViewBg.alpha = 0.5;
        [self addSubview:self.m_shareViewBg];
        
        self.m_shareView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 170)];
        self.m_shareView.center = self.center;
        self.m_shareView.backgroundColor = [UIColor whiteColor];
        self.m_shareView.layer.cornerRadius = 3;
        self.m_shareView.layer.masksToBounds = YES;
        self.m_shareView.alpha = 1.0;
        [self addSubview:self.m_shareView];
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 260,100)];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 2;
        _titleLabel.text = @"";
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_m_shareView addSubview:_titleLabel];
        
        _thumb = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 50)];
        _thumb.layer.cornerRadius = 5;
        _thumb.layer.masksToBounds = YES;
        _thumb.placeholderImage = KUIImage(@"have_picture");
        [self.m_shareView addSubview:_thumb];
        
        _contentLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(70, 0, 170, 0) textColor:kColorWithRGB(102, 102, 102, 1.0) font:[UIFont boldSystemFontOfSize:13.0] text:@"" textAlignment:NSTextAlignmentLeft];
        _contentLabel.numberOfLines = 0;
        [self.m_shareView addSubview:_contentLabel];
        
        _sharePeopleLabel = [CommonControlOrView setLabelWithFrame:CGRectMake(15, 95, 250, 30) textColor:kColorWithRGB(51, 51, 51, 1.0) font:[UIFont systemFontOfSize:13.0] text:[NSString stringWithFormat:@"分享给：%@",@""] textAlignment:NSTextAlignmentLeft];
        [self.m_shareView addSubview:_sharePeopleLabel];
        
        
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(15, 125, 120, 35)];
        [_cancelBtn setBackgroundColor:kColorWithRGB(186, 186, 186, 1.0)];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        _cancelBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.m_shareView addSubview:_cancelBtn];
        
        _sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(145, 125, 120, 35)];
        [_sendBtn setBackgroundColor:kColorWithRGB(35, 167, 211, 1.0)];
        [_sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15.0];
        [_sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_sendBtn addTarget:self action:@selector(okShareClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.m_shareView addSubview:_sendBtn];
    }
    return self;
}

-(void)setTextToView:(NSString*)msgTitle MsgContext:(NSString*)msgContext ShareToUserNickName:(NSString*)shareToUserNickName ShareImage:(NSString*)shareImage type:(NSInteger)type{
    CGSize titleSize = CGSizeZero;
    if ([GameCommon getNewStringWithId:msgTitle].length > 0) {
        titleSize = [[GameCommon getNewStringWithId:msgTitle] sizeWithFont:[UIFont boldSystemFontOfSize:15.0] constrainedToSize:CGSizeMake(260, 40)];
    }
    _titleLabel.text = msgTitle;
    _titleLabel.frame = CGRectMake(10, 10, 260, titleSize.height);
    if ([GameCommon getNewStringWithId:shareImage].length > 0 && ![[GameCommon getNewStringWithId:shareImage] isEqualToString:@"null"]) {
        _thumb.frame = CGRectMake(10, (titleSize.height > 0 ? titleSize.height : 10) + 15, 50, 50);
        _thumb.imageURL = [ImageService getImageUrl3:shareImage Width:50];
        
        CGSize contentSize = [msgContext sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(200, 50)];
        _contentLabel.frame = CGRectMake(70, (titleSize.height > 0 ? titleSize.height : 10) + 15, 170, contentSize.height);
        _contentLabel.text = msgContext;
    } else{
        CGSize contentSize = [msgContext sizeWithFont:[UIFont boldSystemFontOfSize:13.0] constrainedToSize:CGSizeMake(260, 50)];
        _contentLabel.frame = CGRectMake(10, (titleSize.height > 0 ? titleSize.height : 10) + 15, 260, contentSize.height);
        _contentLabel.text = msgContext;
    }
    
    if (type == 0) {
        _sharePeopleLabel.frame = CGRectMake(15, 95, 250, 30);
        _sharePeopleLabel.text = [NSString stringWithFormat:@"分享给：%@",shareToUserNickName];
    }else{
        _sharePeopleLabel.frame = CGRectMake(15, 95, 250, 30);
        _sharePeopleLabel.text = @"分享给：好友及粉丝";
    }
}


-(void)showSelf{
    self.hidden = NO;
}
-(void)hideSelf{
    self.hidden = YES;
}


- (void)cancelShareClick:(id)sender
{
    [self hideSelf];
}
- (void)okShareClick:(id)sender
{
    if (true) {//好友
        if (self.shareDelegate) {
            [self.shareDelegate shareToFriend];
        }
    }else{//粉丝
        if (self.shareDelegate) {
            [self.shareDelegate broadcastToFans];
        }
    }
   [self hideSelf];
}

@end
