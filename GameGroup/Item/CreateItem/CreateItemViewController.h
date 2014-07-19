//
//  CreateItemViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "FillInInfoViewController.h"
#import "ChooseDelegate.h"

@interface CreateItemViewController : BaseViewController<UIPickerViewDelegate,UIPickerViewDataSource,InfoDelegate,ChooseDelegate,ChooseDataSource>

@end
