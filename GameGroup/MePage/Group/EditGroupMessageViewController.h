//
//  EditGroupMessageViewController.h
//  GameGroup
//
//  Created by 魏星 on 14-6-13.
//  Copyright (c) 2014年 Swallow. All rights reserved.
//

#import "BaseViewController.h"
typedef enum
{
    EDIT_TYPE_BASE = 0,
    EDIT_TYPE_nickName,
    EDIT_TYPE_signature,
}EditType;
@protocol GroupEditMessageDelegate;

@interface EditGroupMessageViewController : BaseViewController<UITextViewDelegate,UIAlertViewDelegate>
@property(nonatomic,assign)EditType editType;
@property(nonatomic,strong)NSString* placeHold;
@property(nonatomic,assign)id<GroupEditMessageDelegate>delegate;

@end
@protocol GroupEditMessageDelegate <NSObject>

-(void)comeBackInfoWithController:(EditGroupMessageViewController *)controller type:(EditType)mysetupType info:(NSString *)info;


@end