//
//  SearchPersonViewController.h
//  GameGroup
//  搜索角色
//  Created by Shen Yanping on 13-12-16.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "RealmsSelectViewController.h"
#import "SearchRoleViewController.h"

typedef enum
{
    SEARCH_TYPE_ID = 0,//陌游ID
    SEARCH_TYPE_PHONE,//手机号
    SEARCH_TYPE_ROLE,//游戏角色
    SEARCH_TYPE_NICKNAME,//陌游昵称
}SearchViewType;

@interface SearchPersonViewController : BaseViewController<UITextFieldDelegate, RealmSelectDelegate, SearchRoleDelegate>

@property (nonatomic, assign)SearchViewType viewType;

@end
