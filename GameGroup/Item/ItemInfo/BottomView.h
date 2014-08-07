//
//  BottomView.h
//  GameGroup
//
//  Created by 魏星 on 14-8-7.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface BottomView : UIView
@property (nonatomic,strong)EGOImageView * lowImg;
@property (nonatomic,strong)UILabel * titleLabel;
@property (nonatomic,strong)EGOImageView * gameIcon;
@property (nonatomic,strong)UILabel * realmLb;
@property (nonatomic,strong)UILabel * topLabel;
@end
