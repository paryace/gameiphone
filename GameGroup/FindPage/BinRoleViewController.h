//
//  BinRoleViewController.h
//  GameGroup
//
//  Created by Apple on 14-5-22.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface BinRoleViewController : BaseViewController<UIActionSheetDelegate,MFMessageComposeViewControllerDelegate>
@property(nonatomic,strong)NSDictionary *dataDic;
@property(nonatomic, copy)NSString*   type;
@property(nonatomic, copy)NSString*   gameId;
@end
