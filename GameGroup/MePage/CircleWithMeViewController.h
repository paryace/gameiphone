//
//  CircleWithMeViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "SendNewsViewController.h"


@interface CircleWithMeViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,TableViewDatasourceDidChange,UIAlertViewDelegate>
@property(nonatomic,copy)NSString *userId;
@end
