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
   COME_GUILD,
    COME_ROLE,
}MYINFOTYPE;
@interface SearchWithGameViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,assign)MYINFOTYPE *myInfoType;
@property(nonatomic,assign)NSMutableDictionary *dataDic;
@end
