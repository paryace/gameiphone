//
//  CircleHeadViewController.h
//  GameGroup
//  朋友圈
//  Created by 魏星 on 14-4-23.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "CircleHeadCell.h"
#import "HPGrowingTextView.h"
#import "SendNewsViewController.h"
#import "EmojiView.h"


@interface CircleHeadViewController : BaseViewController
<
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
TableViewDatasourceDidChange
,EmojiViewDelegate,
QiniuUploadDelegate
>
@property(nonatomic,copy)NSString *imageStr;    //Cover图片
@property(nonatomic,copy)NSString *nickNmaeStr; //昵称
@property(nonatomic,copy)NSString *userId;  //userid
@property(nonatomic,assign)NSInteger msgCount;

@property (assign, nonatomic)  NSInteger msgUnReadCount;//未读的消息数

@property(nonatomic,strong)HPGrowingTextView *textView;

@end
