//
//  EditInfoViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-7-4.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

@protocol editInfoDelegate;

@interface EditInfoViewController : BaseViewController
@property(nonatomic,copy)NSString *firstStr;
@property(nonatomic,copy)NSString *secondStr;
@property(nonatomic,copy)NSString *itemId;
@property(nonatomic,copy)NSString *gameid;
@property(nonatomic,assign)BOOL isStyle;
@property(nonatomic,assign)id<editInfoDelegate>delegate;
@end
@protocol editInfoDelegate <NSObject>

-(void)refreshMyTeamInfoWithViewController:(UIViewController *)vc;

@end