//
//  CircleHeadCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
#import "EGOImageView.h"
@interface CircleHeadCell : UITableViewCell
@property(nonatomic,strong)EGOImageButton *headImgBtn;
@property(nonatomic,strong)EGOImageView *thumbImgView;
@property(nonatomic,strong)UILabel *nickNameLabel;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UILabel *lastLabel;//XXX发表了 、分享了XXX
@property(nonatomic,copy)NSString *commentStr;
@property(nonatomic,strong)UIView * shareView;
@property(nonatomic,strong)UIButton *openBtn;
@property(nonatomic,strong)EGOImageView *shareImgView;
+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
-(void)buildImagePathWithImage:(NSString *)imgStr;
- (void)refreshCell;
@end
