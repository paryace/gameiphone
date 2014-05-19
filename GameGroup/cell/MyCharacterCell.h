//
//  MyCharacterCell.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-19.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface MyCharacterCell : UITableViewCell

@property(nonatomic,assign)id<CellButtonClickDelegate> myDelegate;
@property(strong,nonatomic)EGOImageView* heardImg;
@property(strong,nonatomic)UIImageView* authBg;
@property(strong,nonatomic)UILabel* nameLabel;
@property(strong,nonatomic)UILabel* realmLabel;
@property(strong,nonatomic)UIImageView* gameImg;
@property(strong,nonatomic)UILabel* pveLabel;//战斗力
@property(assign,nonatomic)NSInteger rowIndex;
@property(strong,nonatomic)UIButton* refreshPVEbtn;

@property(strong,nonatomic)UILabel* noCharacterLabel;
@end
