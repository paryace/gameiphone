//
//  EveryDataNewsViewController.h
//  GameGroup
//
//  Created by admin on 14-3-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "NotConnectDelegate.h"
#import "SendNewsViewController.h"
#import "DayNewsCell.h"
@interface EveryDataNewsViewController : BaseViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIActionSheetDelegate,
UIScrollViewDelegate,
TableViewDatasourceDidChange,
EveryDataNewsCellDelegate
>

@end
