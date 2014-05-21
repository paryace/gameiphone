//
//  SearchJSViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchRoleViewController.h"
#import "RealmsSelectViewController.h"
#import "AboutRoleCell.h"

typedef enum
{
    SEARCH_TYPE_ROLE=0,
    SEARCH_TYPE_FORCES=1,
}SearchViewType;


@interface SearchJSViewController : BaseViewController<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,SearchRoleDelegate,RealmSelectDelegate,UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign)SearchViewType myViewType;
@end
