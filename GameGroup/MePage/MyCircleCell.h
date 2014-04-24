//
//  MyCircleCell.h
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@interface MyCircleCell : UITableViewCell
@property (nonatomic,strong)EGOImageView *heanderImageView;
@property (nonatomic,strong)UILabel *nickNameLabel;
@property (nonatomic,strong)UILabel *dataLabel;
@property (nonatomic,strong)UILabel *monthLabel;
@property (nonatomic,strong)EGOImageView * thumbImageView;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIView *contentsView;
@property (nonatomic,strong)UILabel *imgCountLabel;
@property (nonatomic,copy)NSString *commentStr;
+ (CGSize)getContentHeigthWithStr:(NSString*)contStr;
- (void)refreshCell;
-(void)getImageWithCount:(NSString *)img;
@end
