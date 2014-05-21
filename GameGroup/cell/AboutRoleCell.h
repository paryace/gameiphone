//
//  AboutRoleCell.h
//  GameGroup
//
//  Created by 魏星 on 14-5-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol AboutRoleCellDelegate;

@interface AboutRoleCell : UITableViewCell<UITextFieldDelegate>
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UITextField *contentTF;
@property(nonatomic,strong)UIImageView *rightImageView;
@property(nonatomic,strong)UIButton * serverButton;
@property(nonatomic,strong)EGOImageView *gameImg;
@property(nonatomic,assign)id<AboutRoleCellDelegate>myCellDelegate;
@end

@protocol AboutRoleCellDelegate <NSObject>

-(void)outputTextField:(UITextField *)tf WithCell:(AboutRoleCell *)myCell;

@end