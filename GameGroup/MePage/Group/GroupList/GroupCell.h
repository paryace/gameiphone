//
//  GroupCell.h
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface GroupCell : UITableViewCell
@property (strong,nonatomic) EGOImageView * headImageV;
@property (strong,nonatomic) UILabel * nameLabel;
@property (strong,nonatomic) EGOImageView * gameImageV;

@property (strong,nonatomic) UILabel * numberLable;

@property (strong,nonatomic) UILabel * cricleLable;

@property (strong,nonatomic) UILabel * levelLable;

@end
