//
//  PreferenceViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-8-5.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@protocol PreferenceDelegate;
@interface PreferenceViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate>
@property (nonatomic,assign)id<PreferenceDelegate>mydelegate;
@end

@protocol PreferenceDelegate <NSObject>

-(void)searchTeamBackViewWithDic:(NSDictionary *)dic;
-(void)reloadMsgCount;//刷新主页面的消息数量

@end
