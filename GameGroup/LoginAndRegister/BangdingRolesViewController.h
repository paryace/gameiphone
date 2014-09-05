//
//  BangdingRolesViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "RealmsSelectViewController.h"
#import "introduceViewController.h"
#import "AuthViewController.h"
#import "SelectGameView.h"
@interface BangdingRolesViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UITextFieldDelegate,RealmSelectDelegate,NewRegisterViewControllerDelegate,UIAlertViewDelegate,AuthCharacterDelegate,SelectGameDelegate>
@property(nonatomic,assign)id<NewRegisterViewControllerDelegate>delegate;
@end
