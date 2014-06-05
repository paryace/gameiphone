//
//  BlackListCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface BlackListCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *headImageV;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *distLabel;
@property(nonatomic,strong)UIImageView *bgView;
@end
