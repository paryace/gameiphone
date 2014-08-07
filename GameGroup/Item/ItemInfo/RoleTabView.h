//
//  RoleTabView.h
//  GameGroup
//
//  Created by 魏星 on 14-7-3.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
@protocol roleTabDelegate;

@interface RoleTabView : UIView<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
@property(nonatomic,strong)NSMutableArray *coreArray;
@property(nonatomic,strong)UITableView *roleTableView;
@property(nonatomic,assign)id<roleTabDelegate>mydelegate;
@end
@protocol roleTabDelegate <NSObject>
-(void)didClickChooseWithView:(RoleTabView*)view info:(NSDictionary *)info;
@end

