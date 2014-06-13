//
//  SetUpGroupViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol SetupDelegate;
@interface SetUpGroupViewController : BaseViewController<UITextViewDelegate,UIPickerViewDataSource,UIPickerViewDelegate>
@property(nonatomic,copy)NSString *groupid;
@property(nonatomic,assign)id<SetupDelegate>delegate;

@end
@protocol SetupDelegate <NSObject>
@end