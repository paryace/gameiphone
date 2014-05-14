//
//  NewNearByViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-9.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "NewNearByCell.h"
#import "CityViewController.h"
#import "HPGrowingTextView.h"
@interface NewNearByViewController : BaseViewController
<UICollectionViewDataSource,
UICollectionViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
NewNearByCellDelegate,
CityDelegate,
UIActionSheetDelegate,
HPGrowingTextViewDelegate
>
@property(nonatomic,strong)HPGrowingTextView *textView;

@end
