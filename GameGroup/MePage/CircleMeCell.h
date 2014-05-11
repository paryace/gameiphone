//
//  CircleMeCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"
#import "PBEmojiLabel.h"
@interface CircleMeCell : UITableViewCell
@property(nonatomic,strong)EGOImageButton *headImgBtn;
@property(nonatomic,strong)UILabel *nickNameLabel;
@property(nonatomic,strong)UILabel *contentsLabel;
@property(nonatomic,strong)EGOImageView *contentImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,copy)NSString *commentStr;

//- (void)refreshCell;

+ (float)getContentHeigthWithStr:(NSString*)contStr;


@end
