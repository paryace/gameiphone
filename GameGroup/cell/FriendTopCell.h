//
//  FriendTopCell.h
//  GameGroup
//
//  Created by Marss on 14-6-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FriendTabDelegate;

@interface FriendTopCell : UITableViewCell
@property(nonatomic,assign)id<FriendTabDelegate>friendTabDelegate;

@property(nonatomic,strong)UIButton *btn1;
@property(nonatomic,strong)UILabel *lable1;

@property(nonatomic,strong)UIButton *btn2;
@property(nonatomic,strong)UILabel *lable2;

@property(nonatomic,strong)UIButton *btn3;
@property(nonatomic,strong)UILabel *lable3;

@property(nonatomic,strong)UIButton *btn4;
@property(nonatomic,strong)UILabel *lable4;

@end
@protocol FriendTabDelegate <NSObject>
- (void)topBtnAction:(UIButton *)sender;
@end
