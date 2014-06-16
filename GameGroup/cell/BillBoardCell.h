//
//  BillBoardCell.h
//  GameGroup
//
//  Created by Apple on 14-6-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageButton.h"

@interface BillBoardCell : UITableViewCell

@property (strong,nonatomic) EGOImageButton * groupHeadImage;
@property (strong,nonatomic) UILabel* groupNameLable;
@property (strong,nonatomic) UILabel* billContentLable;
@property (strong,nonatomic) UILabel* billTimeLable;

@property (strong,nonatomic) NSString* commentStr;
@property (assign,nonatomic) NSInteger rowIndex;

- (void)refreshCell;

+ (float)getContentHeigthWithStr:(NSString*)contStr;
@end
