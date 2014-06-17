//
//  EditGroupNameViewController.h
//  GameGroup
//
//  Created by Apple on 14-6-17.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
@protocol GroupEditGroupNameDelegate;
@interface EditGroupNameViewController : BaseViewController<UITextViewDelegate,UIAlertViewDelegate>
@property(nonatomic,assign)id<GroupEditGroupNameDelegate>delegate;
@property(nonatomic,strong)NSString* placeHold;
@end
@protocol GroupEditGroupNameDelegate <NSObject>

-(void)comeBackGroupNameWithController:(NSString *)groupName;
@end