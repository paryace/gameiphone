//
//  NewInvitationViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-8.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewInvitationViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic,copy)NSString *groupId;
@end
