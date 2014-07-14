//
//  NewInvitationViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-8.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddGroupMemberCell.h"



@interface NewInvitationViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,addGroupMemberDelegate>
@property(nonatomic,copy)NSString *groupId;
@property(nonatomic,copy)NSString *realmStr;
@end
