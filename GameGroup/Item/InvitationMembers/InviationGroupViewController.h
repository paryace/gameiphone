//
//  InviationGroupViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-25.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface InviationGroupViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>
@property(nonatomic,copy)NSString *gameId;
@property(nonatomic,copy)NSString *roomId;
@property (strong, nonatomic)  NSMutableDictionary *roomInfoDic;
@end
