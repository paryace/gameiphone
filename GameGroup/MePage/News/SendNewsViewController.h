//
//  SendNewsViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-31.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
#import "TableViewDatasourceDidChange.h"
#import "EmojiView.h"


@interface SendNewsViewController : BaseViewController<UIAlertViewDelegate,EmojiViewDelegate,QiniuUploadDelegate>

@property (nonatomic,weak)id<TableViewDatasourceDidChange>delegate;
@property (nonatomic, strong)UIImage* titleImage;//分享头衔
@property (nonatomic, strong)NSString* titleImageName;
@property (nonatomic, strong)NSString* defaultContent;//分享头衔默认字
@property (nonatomic,assign)BOOL isComeFromMe;
@end
