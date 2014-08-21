//
//  TeamApplyController.h
//  GameGroup
//
//  Created by Apple on 14-8-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JoinTeamCell.h"
#import "H5CharacterDetailsViewController.h"
@interface TeamApplyController : BaseViewController<UITableViewDataSource,UITableViewDelegate,TeamDetailDelegate>
@property (nonatomic, strong) NSString *groipId;
@property (nonatomic, strong) NSString *roomId;
@property (nonatomic, strong) NSString *gameId;
@property (nonatomic, nonatomic)  BOOL teamUsershipType;
@end


