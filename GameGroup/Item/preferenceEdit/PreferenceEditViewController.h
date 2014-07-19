//
//  PreferenceEditViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface PreferenceEditViewController : BaseViewController<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic,strong)NSDictionary * mainDict;

@end
