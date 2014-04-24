//
//  MyCircleViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-4-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface MyCircleViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(nonatomic,copy)NSString *imageStr;
@property(nonatomic,copy)NSString *nickNmaeStr;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *myViewType;
@end

