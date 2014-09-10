//
//  MenuTableView.h
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableView : UIView<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *mTableView;
@property (strong, nonatomic)  NSMutableArray * menuDataList;
@property (strong, nonatomic)  NSDictionary * menuDataDic;
@property (strong, nonatomic)  NSMutableArray * menuKeyList;
@property (nonatomic, assign) BOOL isSecion;
-(void)setMenuTagList:(NSMutableArray*)array;
@end
