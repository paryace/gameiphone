//
//  InvitationMembersViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-21.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "AddGroupMemberCell.h"

@interface InvitationMembersViewController : BaseViewController
<UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
addGroupMemberDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate
>
@property(nonatomic,copy)NSString     *     roomId;
@property(nonatomic,copy)NSString     *     gameId;
@property(nonatomic,copy)NSString     *     imgStr;
@property(nonatomic,copy)NSString     *     descriptionStr;
@property(nonatomic,copy)NSString     *     groupId;
@end
