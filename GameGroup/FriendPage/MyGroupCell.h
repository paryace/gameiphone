//
//  MyGroupCell.h
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface MyGroupCell : UITableViewCell
@property (strong,nonatomic) EGOImageView * headImageV;
@property (nonatomic,strong) UILabel* titleLable;
@end
