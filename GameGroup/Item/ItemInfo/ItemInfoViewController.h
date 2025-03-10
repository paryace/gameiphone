//
//  ItemInfoViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-2.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "RoleTabView.h"
#import "EditInfoViewController.h"
#import "ItemInfoCell.h"
#import "ChineseString.h"

@interface ItemInfoViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,roleTabDelegate,UIAlertViewDelegate,editInfoDelegate,HeadClickDelegate>
@property(nonatomic,strong)NSMutableDictionary *infoDict;
@property(nonatomic,strong)NSString *itemId;
@property(nonatomic,strong)NSString *gameid;
@end
