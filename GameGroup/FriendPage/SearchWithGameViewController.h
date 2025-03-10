//
//  SearchWithGameViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-19.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
typedef enum
{
   COME_GUILD=0,
    COME_ROLE,
}MYINFOTYPE;
@interface SearchWithGameViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign)MYINFOTYPE myInfoType;
@property(nonatomic,strong)NSDictionary *dataDic;
@property(nonatomic,copy)NSString *realmStr;
@property(nonatomic,copy)NSString *gameid;
@end
