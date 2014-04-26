//
//  CircleHeadViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "CircleHeadCell.h"
@interface CircleHeadViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,CircleHeadDelegate,UITextViewDelegate>
@property(nonatomic,copy)NSString *imageStr;
@property(nonatomic,copy)NSString *nickNmaeStr;
@property(nonatomic,copy)NSString *userId;
@end
