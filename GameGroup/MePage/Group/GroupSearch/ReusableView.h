//
//  ReusableView.h
//  GameGroup
//
//  Created by 魏星 on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface ReusableView : UICollectionReusableView
@property (nonatomic, strong) UILabel *label;
@property (nonatomic,strong)EGOImageView *headImageView;
@property (nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIButton *topBtn;
@property(nonatomic,strong)UIButton *topLable;
@end
