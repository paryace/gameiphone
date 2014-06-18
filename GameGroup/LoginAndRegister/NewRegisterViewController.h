//
//  NewRegisterViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "RealmsSelectViewController.h"
#import "SearchRoleViewController.h"
#import "UpLoadFileService.h"
@protocol NewRegisterViewControllerDelegate <NSObject>
@optional
-(void)NewRegisterViewControllerFinishRegister;

@end

@interface NewRegisterViewController : BaseViewController
<UITextFieldDelegate,
RealmSelectDelegate,
UIAlertViewDelegate,
SearchRoleDelegate,
UIActionSheetDelegate,
UIImagePickerControllerDelegate,
UINavigationControllerDelegate,
UIGestureRecognizerDelegate,
UIPickerViewDataSource,
UIPickerViewDelegate,
UITableViewDelegate,
UITableViewDataSource,
QiniuUploadDelegate
>
@property (nonatomic,retain) id <NewRegisterViewControllerDelegate>delegate;



@end
