//
//  IntroduceViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RegisterViewController.h"
@interface IntroduceViewController : BaseViewController<UIScrollViewDelegate>
@property (nonatomic,retain) id <RegisterViewControllerDelegate>delegate;
@end

#define kMAXPAGE  5//启动页数