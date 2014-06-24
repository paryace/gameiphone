//
//  GroupListViewController.h
//  GameGroup
//
//  Created by Marss on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface GroupListViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIScrollViewDelegate>
@property(nonatomic,copy)NSString *userId;
@end
