//
//  LocationViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-8-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@protocol LocationViewDelegate;

@interface LocationViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,copy)NSString * gameid;
@property(nonatomic,assign)id<LocationViewDelegate>mydelegate;
@end

@protocol LocationViewDelegate <NSObject>

-(void)returnChooseInfoFrom:(UIViewController *)vc info:(NSDictionary *)info;

@end