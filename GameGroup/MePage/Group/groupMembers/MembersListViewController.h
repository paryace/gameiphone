//
//  MembersListViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface MembersListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,copy)NSString *groupId;
@end
