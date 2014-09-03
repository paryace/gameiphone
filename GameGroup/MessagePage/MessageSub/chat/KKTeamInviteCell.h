//
//  KKTeamInviteCell.h
//  GameGroup
//
//  Created by Apple on 14-7-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKChatCell.h"
#import "EGOImageButton.h"
#import "EGOImageView.h"

@interface KKTeamInviteCell : KKChatCell
@property(nonatomic, retain) UIView  *attView;
@property(nonatomic, retain) UILabel *titleLabel;
@property(nonatomic, retain) UIImageView *lineImage;
@property(nonatomic, retain) EGOImageView * thumbImgV;
@property(nonatomic, retain) UILabel *contentLabel;
@property(nonatomic, assign) NSInteger lowType;
-(void)putTextAndImgWithType:(NSInteger)type;
@end
