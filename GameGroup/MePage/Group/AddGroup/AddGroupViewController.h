//
//  AddGroupViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-6.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "AddGroupView.h"
#import "RealmsSelectViewController.h"
#import "CardViewController.h"
@interface AddGroupViewController : BaseViewController<groupViewDelegate,RealmSelectDelegate,CardListDelegate,UIAlertViewDelegate>

@end
