//
//  GroupCricleViewController.h
//  GameGroup
//
//  Created by Apple on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "NewNearByCell.h"
#import "HPGrowingTextView.h"
#import "EmojiView.h"

@interface GroupCricleViewController : BaseViewController
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
@property(nonatomic,copy)NSString *groupId;

@end
