//
//  MyFansPageViewController.h
//  GameGroup
//
//  Created by Apple on 14-5-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface MyFansPageViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)NSString *userId;
@end
