//
//  NewFriendPageController.h
//  GameGroup
//
//  Created by Apple on 14-5-16.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FriendTopCell.h"
#import "MenuTableView.h"
#import "SearchResultView.h"
@interface NewFriendPageController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate, UIActionSheetDelegate,UIScrollViewDelegate,FriendTabDelegate,ItemClickDelegate>
@end
