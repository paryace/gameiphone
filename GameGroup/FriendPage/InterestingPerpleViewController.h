//
//  InterestingPerpleViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "NewNearByCell.h"
#import "HPGrowingTextView.h"
#import "EmojiView.h"
@interface InterestingPerpleViewController : BaseViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
NewNearByCellDelegate,
UIActionSheetDelegate,
HPGrowingTextViewDelegate,
EmojiViewDelegate
>
@property(nonatomic,strong)HPGrowingTextView *textView;
@property(nonatomic,copy)NSString *gameid;

@end
