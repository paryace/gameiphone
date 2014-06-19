//
//  SearchGroupViewController.h
//  GameGroup
//
//  Created by Apple on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
typedef enum
{
    SETUP_Search = 0,
    SETUP_Tags,
    SETUP_NEARBY,
    SETUP_SAMEREALM,
    SETUP_HOT,
}setUpType;

@interface SearchGroupViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate,UIScrollViewDelegate>
@property(nonatomic, retain) NSString * conditiona;//条件
@property(nonatomic, assign)setUpType ComeType;
@property(nonatomic,copy)NSString *tagsId;
@property(nonatomic,copy)NSString *realmStr;
@property(nonatomic,copy)NSString *gameid;
@end
