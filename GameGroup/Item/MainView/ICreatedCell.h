//
//  ICreatedCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-31.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface ICreatedCell : UITableViewCell
@property (nonatomic,strong)UILabel * titleLabel;
@property (nonatomic,strong)UILabel * realmLabel;
@property (nonatomic,strong)UILabel * numLabel;
@property (nonatomic,strong)UILabel * sqLb;
@property (nonatomic,strong)EGOImageView *gameIconImageView;
@end
