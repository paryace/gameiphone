//
//  GameListCell.h
//  GameGroup
//
//  Created by 魏星 on 14-5-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface GameListCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *gameIconImg;
@property(nonatomic,strong)UILabel *nameLabel;
@end
