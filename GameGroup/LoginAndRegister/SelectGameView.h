//
//  SelectGameView.h
//  GameGroup
//
//  Created by Marss on 14-9-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CharacterCell.h"

@protocol SelectGameDelegate;
@interface SelectGameView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property(nonatomic,strong)NSMutableArray * characterArray;
@property(nonatomic,strong)NSMutableArray * imgArray;
@property(nonatomic,assign)id<SelectGameDelegate>selectGameDelegate;
@property(nonatomic,strong)UITableView *roleTableView;

@property(nonatomic,strong)UILabel *titleView;
-(void)setDateWithNameArray:(NSMutableArray*)nameArray andImg:(NSMutableArray*)imgArray;
-(void)hiddenSelf;
-(void)showSelf;
@end

@protocol SelectGameDelegate <NSObject>
-(void)selectGame:(NSInteger)characterDic;
@end
