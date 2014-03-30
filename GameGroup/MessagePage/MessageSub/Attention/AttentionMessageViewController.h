//
//  AttentionMessageViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-31.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@interface AttentionMessageViewController : BaseViewController<UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,assign)int personCount;
@property(nonatomic,strong)NSMutableArray *nickNameArray;
@property(nonatomic,strong)NSMutableArray *imgArray;
@end
