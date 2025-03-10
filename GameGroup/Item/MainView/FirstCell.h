//
//  FirstCell.h
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@protocol firstCellDelegate;

@interface FirstCell : UITableViewCell
@property(nonatomic,strong)UILabel *nameLabel;
@property(nonatomic,strong)UIImageView *headImgView;
@property(nonatomic,strong)EGOImageView *gameIconImg;
@property(nonatomic,strong)UILabel *realmLabel;
@property(nonatomic,strong)UILabel * editLabel;
@property(nonatomic,copy)NSString *machCountStr;
@property (strong,nonatomic) UILabel * unreadCountLabel;
@property (strong,nonatomic) UIImageView * notiBgV;

@property(nonatomic,assign)BOOL isrow;
@property(nonatomic,assign)id<firstCellDelegate>myDelegate;
-(void)didClickRow;
@end

@protocol firstCellDelegate <NSObject>

-(void)didClickRowWithCell:(FirstCell*)cell isRow:(BOOL)isRow ;
-(void)didClickEnterEditPageWithCell:(FirstCell*)cell isrow:(BOOL)row;

@end
