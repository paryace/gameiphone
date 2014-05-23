//
//  SearchResultViewController.h
//  GameGroup
//  查询结果
//  Created by admin on 14-2-20.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotConnectDelegate.h"

#import "BaseViewController.h"

@protocol getContact <NSObject>
-(void)getContact:(NSDictionary *)userDict;
@end

@interface SearchResultViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UIScrollViewDelegate,UIAlertViewDelegate>
@property (strong,nonatomic) id responseObject;
@property(nonatomic,copy)NSString *nickNameList;
@end
