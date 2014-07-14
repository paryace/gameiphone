//
//  IntroduceViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewRegisterViewController.h"
@interface IntroduceViewController : BaseViewController<UIScrollViewDelegate>
@property (nonatomic,retain) id <NewRegisterViewControllerDelegate>delegate;
@end

#define kMAXPAGE  4//启动页数