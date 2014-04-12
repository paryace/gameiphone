//
//  HelpViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-4-12.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface HelpViewController : BaseViewController<UIWebViewDelegate>
@property(nonatomic,copy)NSString *myUrl;
@end
