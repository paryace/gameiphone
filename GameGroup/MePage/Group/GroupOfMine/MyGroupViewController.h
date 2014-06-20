//
//  MyGroupViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-10.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
@interface MyGroupViewController : BaseViewController<UICollectionViewDataSource,UICollectionViewDelegate>
@property (assign, nonatomic)  NSInteger msgUnReadCount;//未读的消息数
@end

