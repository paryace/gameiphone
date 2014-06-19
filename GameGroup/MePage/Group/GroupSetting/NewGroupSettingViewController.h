//
//  NewGroupSettingViewController.h
//  GameGroup
//
//  Created by Apple on 14-6-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface NewGroupSettingViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate,UIActionSheetDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,copy)NSString *groupId;
@property (assign, nonatomic)  NSInteger shiptypeCount;
@property (nonatomic,copy)NSString *CharacterInfo;

@end
