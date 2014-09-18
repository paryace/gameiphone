//
//  TeamAssistantCell.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "EGOImageButton.h"

@interface TeamAssistantCell : UITableViewCell
@property(nonatomic,strong)EGOImageButton *headImg;
@property(nonatomic,strong)EGOImageView *gameIconImg;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIImageView *MemberImage;
-(void)refreText:(NSString*)timeStr;

@end
