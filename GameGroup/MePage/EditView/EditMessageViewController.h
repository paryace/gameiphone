//
//  EditMessageViewController.h
//  GameGroup
//
//  Created by Shen Yanping on 13-12-19.
//  Copyright (c) 2013年 Swallow. All rights reserved.
//

#import "BaseViewController.h"

typedef enum
{
    EDIT_TYPE_BASE = 0,
    EDIT_TYPE_nickName,
    EDIT_TYPE_birthday,
    EDIT_TYPE_signature,
    EDIT_TYPE_hobby,
}EditType;

@protocol editMessageDelegate;

@interface EditMessageViewController : BaseViewController<UITextViewDelegate, UIAlertViewDelegate>

@property(nonatomic,assign)EditType editType;
@property(nonatomic,strong)NSString* placeHold;
@property(nonatomic,assign)id<editMessageDelegate>delegate;
@end

@protocol editMessageDelegate <NSObject>

-(void)changeMessageWithType:(EditType)type text:(NSString*)text;

@end
