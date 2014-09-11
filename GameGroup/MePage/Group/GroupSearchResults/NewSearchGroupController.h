//
//  NewSearchGroupController.h
//  GameGroup
//
//  Created by Apple on 14-9-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "MenuTableView.h"
#import "NewGroupCell.h"

@interface NewSearchGroupController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIScrollViewDelegate,UIAlertViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate,OnItemClickDelegate>
@property(nonatomic, retain) NSString * conditiona;//条件
@property(nonatomic,copy)NSString *tagsId;
@property(nonatomic,copy)NSString *realmStr;
@property(nonatomic,copy)NSString *gameid;

@end
