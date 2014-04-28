//
//  KKMessageCell.m
//  XmppDemo
//
//  Created by 夏 华 on 12-7-16.
//  Copyright (c) 2012年 无锡恩梯梯数据有限公司. All rights reserved.
//

#import "KKMessageCell.h"
#import "KKChatCell.h"

@implementation KKMessageCell

@synthesize senderAndTimeLabel; 
@synthesize messageContentView;
@synthesize bgImageView;    //聊天气泡
@synthesize ifRead,playAudioImageV;



-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //聊天信息
        messageContentView = [[OHAttributedLabel alloc] initWithFrame:CGRectZero];
        messageContentView.backgroundColor = [UIColor clearColor];
        messageContentView.delegate = self;
        [self.contentView addSubview:messageContentView];
        
        self.playAudioImageV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.playAudioImageV.animationDuration=1.0;
        self.playAudioImageV.animationRepeatCount=0;
        [self.contentView addSubview:self.playAudioImageV];
        
        self.statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.statusLabel setTextColor:kColorWithRGB(151, 151, 151, 1.0)];
        [self.statusLabel setFont:[UIFont boldSystemFontOfSize:12.0]];
        [self.contentView addSubview:self.statusLabel];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.hidesWhenStopped = YES;
        [self.contentView addSubview:self.activityView];
        
    }
    
    return self;
}





-(BOOL)attributedLabel:(OHAttributedLabel *)attributedLabel shouldFollowLink:(NSTextCheckingResult *)linkInfo
{
    //	[self.visitedLinks addObject:objectForLinkInfo(linkInfo)];
	[attributedLabel setNeedsRecomputeLinksInText];
	
    if ([[UIApplication sharedApplication] canOpenURL:linkInfo.extendedURL])
    {
        // use default behavior
        return YES;
    }
    else
    {
        switch (linkInfo.resultType) {
            case NSTextCheckingTypeAddress:
                NSLog(@"%@",[linkInfo.addressComponents description]);
                break;
            case NSTextCheckingTypeDate:
                NSLog(@"%@",[linkInfo.date description]);
                break;
            case NSTextCheckingTypePhoneNumber:
                NSLog(@"%@",linkInfo.phoneNumber);
                break;
            default: {
                //                NSString* message = [NSString stringWithFormat:@"You typed on an unknown link type (NSTextCheckingType %lld)",linkInfo.resultType];
                //                [UIAlertView showWithTitle:@"Unknown link type" message:message];
                break;
            }
        }
        return NO;
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}



@end
