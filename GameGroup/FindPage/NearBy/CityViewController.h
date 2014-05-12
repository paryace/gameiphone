//
//  CityViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@protocol CityDelegate;
@interface CityViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,assign)id<CityDelegate>mydelegate;
@end
@protocol CityDelegate <NSObject>

-(void)pushCityNumTonextPageWithDictionary:(NSDictionary *)dic;

@end