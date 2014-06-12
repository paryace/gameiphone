//
//  GroupInfoEditViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "CardViewController.h"
#import "SetUpGroupViewController.h"

@interface GroupInfoEditViewController : BaseViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CardListDelegate,SetupDelegate>
@property(nonatomic,copy)NSString *groupId;
@end
