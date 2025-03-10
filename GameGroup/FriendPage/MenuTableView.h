//
//  MenuTableView.h
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupTagCell.h"
@protocol OnItemClickDelegate;
@interface MenuTableView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *mTableView;
@property (strong, nonatomic)  NSMutableArray * menuDataList;
@property (strong, nonatomic)  NSMutableDictionary * menuDataDic;
@property (strong, nonatomic)  NSMutableArray * menuKeyList;
@property (strong, nonatomic)  NSIndexPath * lastIndexPath;
@property (assign, nonatomic)  NSInteger * nowIndexs;
@property (nonatomic, assign) BOOL isSecion;

@property(assign,nonatomic)id<OnItemClickDelegate> delegate;
-(void)setMenuTagList:(NSMutableArray*)array;
-(void)addMenuTagList:(NSMutableArray*)array Reload:(BOOL)reload;
-(void)setMenuTagList:(NSMutableArray*)keyArray DateDic:(NSMutableDictionary*)dataDic;
@end

@protocol OnItemClickDelegate <NSObject>

- (void)itemClick:(MenuTableView*)Sender DateDic:(NSMutableDictionary*)dataDic;

@end