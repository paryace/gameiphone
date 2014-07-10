//
//  NewRecommendCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol RecommendCellDelegate;


@interface NewRecommendCell : UITableViewCell
@property(nonatomic,strong)UIButton *chooseImg;
@property(nonatomic,strong)EGOImageView *headImg;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,assign)id<RecommendCellDelegate>myDelegate;
@property(nonatomic,strong)UILabel *disLb;

-(void)setChooseimgWithString:(NSString *)str;

@end
@protocol RecommendCellDelegate <NSObject>

-(void)chooseWithCell:(NewRecommendCell *)cell;

@end