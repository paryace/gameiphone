//
//  TypeView.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TypeDelegate;
@interface TypeView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic,strong)NSMutableArray * typeArray;
@property(nonatomic,strong)UITableView *typeTableView;
@property(nonatomic,assign)id<TypeDelegate>typeDelegate;
-(void)setDate:(NSMutableArray*)typeArray;
-(void)hiddenSelf;
-(void)showSelf;
@end
@protocol TypeDelegate <NSObject>
-(void)selectType:(NSMutableDictionary *)typeDic;
@end
