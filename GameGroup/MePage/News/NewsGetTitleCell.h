//
//  NewsGetTitleCell.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-27.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface NewsGetTitleCell : UITableViewCell

@property (assign,nonatomic) id<CellButtonClickDelegate> myDelegate;
@property (strong,nonatomic) EGOImageView * headImageV;
@property (strong,nonatomic) UIButton*      headButton;

@property (strong,nonatomic) UIImageView*   authImage;
@property (strong,nonatomic) UILabel* nickNameLabel;
@property (strong,nonatomic) UIButton* nickNameButton;

@property (strong,nonatomic) UILabel* typeLabel;
@property (strong,nonatomic) UILabel* bigTitle;
@property (strong,nonatomic) UIImageView* contentBgImage;

@property (strong,nonatomic) EGOImageView* havePic;
@property (strong,nonatomic) UILabel* zanLabel;
@property (strong,nonatomic) UILabel* timeLabel;
@property (assign,nonatomic) NSInteger rowIndex;

@property (nonatomic,strong)UIButton *delBtn;
//@property (assign,nonatomic) BOOL    isShowArticle;


- (void)refreshCell;

@end

