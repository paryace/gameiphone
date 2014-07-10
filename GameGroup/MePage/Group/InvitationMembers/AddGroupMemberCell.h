//
//  AddGroupMemberCell.h
//  GameGroup
//
//  Created by 魏星 on 14-6-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface AddGroupMemberCell : UITableViewCell
@property(nonatomic,strong)UIImageView *chooseImg;
@property(nonatomic,strong)EGOImageView *headImg;
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UILabel *disLabel;
@end
