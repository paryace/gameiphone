//
//  MyGroupViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "ReusableView.h"
#import "GroupInformationViewController.h"
@interface MyGroupViewController : BaseViewController<UICollectionViewDataSource,UICollectionViewDelegate,GroupBillBoardDeleGate,GroupEditRefreshInfoDelegate>
@property (assign, nonatomic)  NSInteger msgUnReadCount;//未读的消息数
@end

