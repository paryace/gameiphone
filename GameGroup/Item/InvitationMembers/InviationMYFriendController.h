//
//  InviationMYFriendController.h
//  GameGroup
//
//  Created by Apple on 14-8-26.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "AddGroupMemberCell.h"

@interface InviationMYFriendController : BaseViewController<UITableViewDataSource,
UITableViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegate,
addGroupMemberDelegate,
UISearchBarDelegate,
UISearchDisplayDelegate>
@property(nonatomic,copy)NSString     *     roomId;
@property(nonatomic,copy)NSString     *     gameId;
@property(nonatomic,copy)NSString     *     groupId;
@property (strong, nonatomic)  NSMutableDictionary *roomInfoDic;
@end
