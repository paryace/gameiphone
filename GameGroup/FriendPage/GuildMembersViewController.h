//
//  GuildMembersViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "RoleCell.h"
@interface GuildMembersViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,copy)NSString *guildStr;
@property(nonatomic,copy)NSString *realmStr;
@property(nonatomic,copy)NSString *gameidStr;
@end
