//
//  GroupInfoEditViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "CardViewController.h"
#import "EditGroupMessageViewController.h"
#import "EditGroupNameViewController.h"
#import "QiniuUploadDelegate.h"

@interface GroupInfoEditViewController : BaseViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,CardListDelegate,GroupEditMessageDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QiniuUploadDelegate,GroupEditGroupNameDelegate>
@property(nonatomic,copy)NSString *groupId;
@end
