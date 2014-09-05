//
//  BoundRoleCell.h
//  GameGroup
//
//  Created by Marss on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@protocol BoundCellDelegate;
@interface BoundRoleCell : UITableViewCell<UITextFieldDelegate>

@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UITextField *contentTF;
@property(nonatomic,strong)UIButton *rightImageView;
@property(nonatomic,strong)UIButton * serverButton;
@property(nonatomic,strong)EGOImageView *gameImg;
@property(nonatomic,strong)UIButton *gameNameBt;
@property(nonatomic,assign)id<BoundCellDelegate>myCellDelegate;

@property(nonatomic,strong)EGOImageView *smallImg;
@end

@protocol BoundCellDelegate <NSObject>

-(void)outputTextField:(UITextField *)tf WithCell:(BoundRoleCell *)myCell;
-(void)didClickRightImgWithCell:(BoundRoleCell *)myCell;

@end
