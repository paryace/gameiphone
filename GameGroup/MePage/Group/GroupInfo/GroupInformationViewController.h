//
//  GroupInformationViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "GroupInfomationJsCell.h"
@interface GroupInformationViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,GroupInfoCellDelegate>
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,assign)NSInteger shiptypeCount;
@end
