//
//  GroupSettingController.h
//  GameGroup
//
//  Created by Apple on 14-6-11.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface GroupSettingController : BaseViewController<UIActionSheetDelegate>
@property(nonatomic,copy)NSString *groupId;
@property (assign, nonatomic)  NSInteger shiptypeCount;
@end
