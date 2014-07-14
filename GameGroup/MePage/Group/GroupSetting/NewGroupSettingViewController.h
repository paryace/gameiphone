//
//  NewGroupSettingViewController.h
//  GameGroup
//
//  Created by Apple on 14-6-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "GroupInfoEditViewController.h"
@interface NewGroupSettingViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource,GroupEditRefreshInfoDelegate>
@property(nonatomic,copy)NSString *groupId;
@property (assign, nonatomic)  NSInteger shiptypeCount;
@property (nonatomic,copy)NSString *CharacterInfo;
@property(nonatomic,copy)NSString *realmStr;
@property(nonatomic,assign)id<GroupEditRefreshInfoDelegate>myDelegate;
@end
