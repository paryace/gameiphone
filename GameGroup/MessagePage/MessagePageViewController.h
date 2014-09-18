//
//  MessagePageViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-5.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "NotConnectDelegate.h"
#import "AppDelegate.h"
#import "NewRegisterViewController.h"
#import "TemporaryFriendController.h"
#import "TeamAssistantController.h"

@interface MessagePageViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,NewRegisterViewControllerDelegate>

@property (assign,nonatomic) AppDelegate * appDel;
@property(nonatomic,strong)UILabel*   titleLabel;;
@property (nonatomic, retain) NSTimer* cellTimer;
@end
