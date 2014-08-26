//
//  CharacterCell.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface CharacterCell : UITableViewCell
@property(nonatomic,strong)EGOImageView *headerImageView;
@property(nonatomic,strong)EGOImageView *gameTitleImage;
@property(nonatomic,strong)UIImageView *jtImageView;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *serverLabel;
@end
