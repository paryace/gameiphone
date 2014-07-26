//
//  InvitationListViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-25.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface InvitationListViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,copy)NSString *gameId;
@property(nonatomic,copy)NSString *roomId;
@end
