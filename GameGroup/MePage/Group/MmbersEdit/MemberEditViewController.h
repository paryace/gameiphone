//
//  MemberEditViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface MemberEditViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,assign)NSInteger shiptype;

@end
