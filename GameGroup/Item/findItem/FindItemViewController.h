//
//  FindItemViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-14.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "ChooseTab.h"
#import "DropDownChooseDelegate.h"

@interface FindItemViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,DropDownChooseDelegate,DropDownChooseDataSource>

@end
