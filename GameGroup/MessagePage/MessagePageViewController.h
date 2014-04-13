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

@interface MessagePageViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,UISearchBarDelegate,StoreMsgDelegate,UISearchDisplayDelegate>

@property (assign,nonatomic) AppDelegate * appDel;
@property(nonatomic,strong)UILabel*   titleLabel;;
@end
