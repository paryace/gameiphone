//
//  TeamMsgPushController.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "TeamMsgPushCell.h"
#import "AddTeamMsgPushController.h"
#import "EGoImageView.h"

@interface TeamMsgPushController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong) UITableView*  m_TableView;
@property(nonatomic,strong) NSMutableArray * characterKey;
@property(nonatomic,strong) NSMutableDictionary * characterDic
;
@end
