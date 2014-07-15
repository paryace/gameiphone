//
//  ChooseTab.h
//  GameGroup
//
//  Created by 魏星 on 14-7-1.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol chooseTabDelegate;

@interface ChooseTab : UITableView<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSMutableArray *coreArray;
@property(nonatomic,assign)id<chooseTabDelegate>mydelegate;
@end
@protocol chooseTabDelegate <NSObject>
-(void)didClickChooseWithView:(ChooseTab*)view info:(NSDictionary *)info;
@end
