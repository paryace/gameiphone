//
//  WorldViewController.h
//  GameGroup
//
//  Created by Marss on 14-9-15.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "NewNearByCell.h"
#import "HPGrowingTextView.h"
#import "EmojiView.h"
#import "WorldCell.h"
#import "SendNewsViewController.h"

#import "selectContactPage.h"
#import "ShareDynamicView.h"
#import "ShareDynamicMsgService.h"

@interface WorldViewController : BaseViewController


<
UITableViewDataSource,
UITableViewDelegate,
UIAlertViewDelegate,
NewNearByCellDelegate,
WorldCellDelegate,
UIActionSheetDelegate,
HPGrowingTextViewDelegate,
EmojiViewDelegate,
TableViewDatasourceDidChange,
getContact,
ShareDynamicDelegate
>
@property(nonatomic,strong)HPGrowingTextView *textView;
@property(nonatomic,copy)NSString *gameid;



@end
