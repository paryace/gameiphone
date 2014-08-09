//
//  NewCreateItemViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "DWTagList.h"
@interface NewCreateItemViewController : BaseViewController<UITextFieldDelegate,UITextViewDelegate,DWTagDelegate,UIPickerViewDataSource,UIPickerViewDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)NSMutableDictionary *selectRoleDict;
@property(nonatomic,strong)NSMutableDictionary *selectTypeDict;

@end
