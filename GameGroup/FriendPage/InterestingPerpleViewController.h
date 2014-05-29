//
//  InterestingPerpleViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-5-29.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "CircleHeadCell.h"
#import "HPGrowingTextView.h"
#import "SendNewsViewController.h"
#import "EmojiView.h"

@interface InterestingPerpleViewController : BaseViewController<
UITableViewDataSource,
UITableViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
UIActionSheetDelegate,
CircleHeadDelegate,
CommentCellDelegate,
UITextViewDelegate,
HPGrowingTextViewDelegate,
UIActionSheetDelegate,
UIScrollViewDelegate,
EGOImageViewDelegate,
UIAlertViewDelegate,
UIScrollViewDelegate,
TableViewDatasourceDidChange,
EmojiViewDelegate
>
@property(nonatomic,copy)NSString *imageStr;    //Cover图片
@property(nonatomic,copy)NSString *nickNmaeStr; //昵称
@property(nonatomic,copy)NSString *userId;  //userid
@property(nonatomic,strong)HPGrowingTextView *textView;

@end
