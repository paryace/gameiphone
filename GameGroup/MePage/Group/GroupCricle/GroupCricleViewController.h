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
#import "HPGrowingTextView.h"
#import "SendNewsViewController.h"
#import "selectContactPage.h"
#import "ShareDynamicView.h"
#import "ShareDynamicMsgService.h"

@interface GroupCricleViewController : BaseViewController
<
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
NewNearByCellDelegate,
UIActionSheetDelegate,
HPGrowingTextViewDelegate,
EmojiViewDelegate,
TableViewDatasourceDidChange,
getContact,
ShareDynamicDelegate
>
@property(nonatomic,strong)HPGrowingTextView *textView;
@property(nonatomic,copy)NSString *groupId;

@end
