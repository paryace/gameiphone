//
//  ItemInfoCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface ItemInfoCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *headImageView;
@property(nonatomic,strong)UILabel *nickLabel;
@property(nonatomic,strong)UILabel *value1Lb;
@property(nonatomic,strong)UILabel *value2Lb;
@end
