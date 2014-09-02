//
//  BaseItemCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "EGOImageButton.h"
@protocol teamlistCellDelegate;
@interface BaseItemCell : UITableViewCell
@property(nonatomic,strong)UIImageView *bgImageView;
@property(nonatomic,strong)EGOImageButton *headImg;
@property(nonatomic,strong)EGOImageView *gameIconImg;
@property(nonatomic,strong)UILabel *titleLabel;
@property(nonatomic,strong)UILabel *contentLabel;
@property(nonatomic,strong)UILabel *timeLabel;
@property(nonatomic,strong)UIImageView *MemberImage;
@property(nonatomic,assign)id<teamlistCellDelegate>mydelegate;
@end
@protocol teamlistCellDelegate <NSObject>

-(void)enterPersonInfoPageWithCell:(BaseItemCell*)cell;

@end
