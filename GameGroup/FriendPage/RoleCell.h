//
//  RoleCell.h
//  GameGroup
//
//  Created by 魏星 on 14-5-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"
@interface RoleCell : UITableViewCell
@property(nonatomic,strong)EGOImageButton *headImgBtn;
@property(nonatomic,strong)UIImageView *genderImgView;
@property(nonatomic,strong)UILabel *nickNameLabel;
@property(nonatomic,strong)UILabel *roleLabel;
@property(nonatomic,strong)EGOImageButton *glazzImgView;
@end
