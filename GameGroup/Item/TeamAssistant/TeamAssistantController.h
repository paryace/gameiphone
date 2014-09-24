//
//  TeamAssistantController.h
//  GameGroup
//
//  Created by Apple on 14-9-18.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "TeamAssistantCell.h"
#import "TeamMsgPushController.h"
#import "PreferencesMsgManager.h"

@interface TeamAssistantController : BaseViewController<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic,strong) UITableView*  m_TableView;

@property(nonatomic,strong) NSMutableArray * perferenceMsgsArray;
@end
