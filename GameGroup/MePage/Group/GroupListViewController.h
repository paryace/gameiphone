//
//  GroupListViewController.h
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface GroupListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIScrollViewDelegate>
@property(nonatomic, retain) NSString *type;//类型

@property(nonatomic, retain) NSString * conditiona;//条件

@end
