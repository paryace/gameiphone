//
//  InvitationMembersViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface InvitationMembersViewController : BaseViewController
<UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate

>
@property(nonatomic,copy)NSString     *     groupId;
@end
