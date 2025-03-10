//
//  MyGroupsTableViewCell.h
//  GameGroup
//
//  Created by 魏星 on 14-9-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface MyGroupsTableViewCell : UITableViewCell
@property (nonatomic,strong)EGOImageView * headImageView;
@property (nonatomic,strong)EGOImageView * gameImageView;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *memberCountLable;
@property (nonatomic,strong)UILabel *describeLable;
@property (nonatomic,strong)UILabel *leveLable;

@end
