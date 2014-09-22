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
#import "EmojiView.h"
#import "ShareToOther.h"
#import "selectContactPage.h"
#import "ShareDynamicView.h"
#import "ShareDynamicMsgService.h"

@interface NewNearByViewController : BaseViewController
<UICollectionViewDataSource,
UICollectionViewDelegate,
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
NewNearByCellDelegate,
CityDelegate,
UIActionSheetDelegate,
HPGrowingTextViewDelegate,
EmojiViewDelegate,
getContact,
ShareDynamicDelegate
>
@property(nonatomic,strong)HPGrowingTextView *textView;
@property(nonatomic,copy)NSString *gameid;

@property(nonatomic,copy)NSString *lastMsgId;
@end
